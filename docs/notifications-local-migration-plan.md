# Plano: migrar o inbox de notificações para storage local (Hive)

> **Status:** planejado, ainda não implementado. Registrado em 2026-07-13 para execução em uma sessão futura.

## Contexto

A app tem hoje dois mecanismos distintos chamados de "notificação":

1. **Lembretes locais no SO** (`NotificationService`, `flutter_local_notifications`) — já são 100% locais, sem custo, disparados de `TransactionBloc`. Não muda.
2. **Inbox de notificações** (feature `notifications/`: entidade, bloc, página "Notificações") — hoje 100% no Firestore (`users/{uid}/notifications`).

O ponto que gera custo real: em `TransactionBloc._onTransactionsUpdated` ([lib/features/transactions/presentation/bloc/transaction_bloc.dart:72-240](../lib/features/transactions/presentation/bloc/transaction_bloc.dart#L72)), toda emissão do stream de transações recalcula e regrava no Firestore os lembretes de TODAS as transações não pagas, mesmo que nada relevante tenha mudado. Isso cresce com "quantas vezes a tela abre", não com "quantos eventos aconteceram" — exatamente o cenário que preocupa o usuário.

A documentação interna (`.gemini/docs/notifications.md`) descreve um design com Firebase Cloud Messaging que nunca foi implementado (`firebase_messaging` está no `pubspec.yaml` sem nenhum uso no código) — está desatualizada.

**Decisões já validadas com o usuário:**
- Escopo completo: migrar `notifications/` para storage local **e** corrigir o recompute redundante em `transaction_bloc.dart`/`dashboard_bloc.dart`.
- Storage local: **Hive** — especificamente o fork mantido **`hive_ce` / `hive_ce_flutter`** (o pacote `hive` original está parado desde 2021; o fork da comunidade é quem recebe atualizações).
- Remover `firebase_messaging` do `pubspec.yaml` (dependência morta) e atualizar a doc.
- Reter só as últimas 100 notificações no dispositivo (sem crescimento ilimitado).
- A intenção original do usuário também incluía notificações **deletáveis** ("registradas, deletadas, editadas... localmente") — hoje só existe `addNotification`/`markAsRead`, falta delete. Isso entra no escopo.

---

## 1. Dependências (`pubspec.yaml`)

- Adicionar `hive_ce` e `hive_ce_flutter` (via `fvm flutter pub add hive_ce hive_ce_flutter` na execução, para pegar as versões mais recentes compatíveis em vez de fixar números no plano).
- Remover `firebase_messaging: ^16.1.2` (confirmado sem nenhum uso em `lib/`).

Não é necessário gerar `TypeAdapter`/codegen do Hive: `NotificationModel` já serializa para `Map<String, dynamic>` totalmente primitivo via `toJson()`/`fromJson()` (o `TimestampConverter` já converte `DateTime` ⇄ `String` ISO8601, não depende de `Timestamp` do Firestore — [lib/core/utils/converters/timestamp_converter.dart](../lib/core/utils/converters/timestamp_converter.dart)). Vamos persistir esse Map diretamente num `Box<Map>`, reaproveitando o model/entity existentes sem alterá-los.

## 2. Nova camada de dados local (`features/notifications/data`)

**`data/datasources/notifications_local_data_source.dart`** (substitui `notifications_remote_data_source.dart`, que será removido):
- Interface igual em espírito à atual (`addNotification`, `markAsRead`, `getNotifications`) **+ `deleteNotification(String id)`** novo.
- Implementação usa um `Box<Map>` injetado (chave = `notification.id`) e `FirebaseAuth` só para resolver `userId` (reaproveita o `sl<FirebaseAuth>()` já registrado em `auth_injection.dart` — autenticação continua na nuvem, só o storage de notificações fica local).
- `getNotifications()`: lê `box.values`, filtra por `userId`, ordena por `timestamp` desc, e re-emite a cada mudança via `box.watch()` (stream), igual ao padrão reativo que a página já espera.
- `addNotification()`: `box.put(id, json)`; depois, se `box.length > 100`, remove as entradas mais antigas (por `timestamp`) até caber no limite — mantém as últimas 100 notificações.
- Exceções: `CacheException` (já existe em [lib/core/errors/exceptions.dart](../lib/core/errors/exceptions.dart)), seguindo o padrão descrito em `.gemini/skills/create_datasource.md`.

**`data/repositories/notifications_repository_impl.dart`**: troca `NotificationsRemoteDataSource` → `NotificationsLocalDataSource`; troca `on ServerException` → `on CacheException` mapeando para `CacheFailure`. Interface do repositório (`domain/repositories/notifications_repository.dart`) ganha só `deleteNotification`; resto não muda — nenhum consumidor externo é afetado além do que será listado abaixo.

## 3. Domain: nova ação de delete

**`domain/usecases/notification_usecases.dart`**: adicionar `DeleteNotification` (mesmo padrão de `MarkNotificationAsRead`, callable class, `Future<Either<Failure, void>> call(String id)`).

## 4. Corrigir o recompute redundante em `TransactionBloc`

Hoje a lógica de "que lembrete cada transação precisa" (atrasado / vence hoje / vence amanhã, datas de disparo) está misturada com formatação l10n dentro do bloc, e reexecuta do zero a cada emissão do stream.

Extrair a parte pura (sem Flutter/l10n) para um usecase novo, seguindo o mesmo padrão de `GetDashboardSummary` ([lib/features/dashboard/domain/usecases/get_dashboard_summary.dart](../lib/features/dashboard/domain/usecases/get_dashboard_summary.dart)) — classe pura, síncrona, sem dependências externas:

**`features/transactions/domain/usecases/classify_transaction_reminders.dart`** (novo):
```dart
enum ReminderUrgency { overdue, dueToday, dueTomorrow }

class TransactionReminder extends Equatable {
  final TransactionEntity transaction;
  final ReminderUrgency urgency;
  final DateTime notifyAt; // quando o lembrete OS deve disparar
  // props: [transaction, urgency, notifyAt] — permite diff por igualdade
}

class ClassifyTransactionReminders {
  List<TransactionReminder> call(List<TransactionEntity> transactions, {DateTime? now});
  // mesma regra de datas que já existe hoje em transaction_bloc.dart:96-237
}
```

`TransactionBloc._onTransactionsUpdated` passa a:
1. Chamar `classifyTransactionReminders(event.transactions)`.
2. Comparar o resultado com o último conjunto processado (`List<TransactionReminder>` guardado em campo do bloc). Se for igual, **não faz nada** (sem `cancelAll()`, sem reagendar, sem regravar) — isso elimina o recompute redundante.
3. Se mudou, só então: `cancelAll()` + reagenda os lembretes OS (`notificationService.scheduleTransactionReminder`) + persiste no inbox local (`addNotification`), construindo o texto localizado exatamente como hoje (essa parte tem que ficar no bloc mesmo — `l10n_resolver.dart` importa `flutter/widgets.dart`, então não pode virar usecase de domínio puro, conforme a própria regra do projeto em `.gemini/docs/architecture.md`).

`DashboardBloc._notifyRecurringDebited` não precisa mexer — não há duplicação real de lógica ali (é um evento diferente: notificação pontual pós-criação de instância recorrente, não um recompute em loop), então extrair um usecase ali seria abstração sem necessidade (KISS).

## 5. Notificação deletável (fecha o gap do pedido original)

- `NotificationsBloc`: novo evento `DeleteNotificationEvent(String id)` → chama `DeleteNotification` usecase.
- `NotificationsPage` / `_NotificationCard`: envolver o card num `Dismissible` (swipe para excluir), disparando o evento. Sem diálogo de confirmação — é uma entrada de histórico, não um dado crítico, e não há precedente de diálogo de confirmação para ações reversíveis/leves no restante do app.

## 6. Injeção de dependências

**`injection_container.dart`**: antes de `initNotifications()`, inicializar o Hive e abrir a box:
```dart
await Hive.initFlutter();
final notificationsBox = await Hive.openBox<Map>('notifications_box');
sl.registerLazySingleton<Box<Map>>(() => notificationsBox);
```
(mesmo padrão de inicialização eager que já existe para `NotificationService`.)

**`notifications_injection.dart`**: troca o registro do datasource remoto pelo local; adiciona `DeleteNotification`; `NotificationsBloc` passa a receber `deleteNotification: sl()`.

**`transaction_injection.dart`**: registra `ClassifyTransactionReminders`; `TransactionBloc` passa a receber `classifyTransactionReminders: sl()`.

## 7. Localização

`NotificationsPage` hoje mistura chamadas a `l10n.notificationsXxx` já existentes com strings PT hardcoded (`'Tudo em dia!'`, `'Erro ao carregar notificações.'`, `'Há 1 minuto'`, `'URGENTE'`, etc. — ver [lib/features/notifications/presentation/pages/notifications_page.dart:130-401](../lib/features/notifications/presentation/pages/notifications_page.dart#L130)), o que viola a convenção do projeto (`.gemini/references/localization.md`). Já que vou mexer nesse arquivo para o delete, aproveito para:
- Usar as chaves já existentes e não utilizadas (`notificationsGroupNew`, `notificationsGroupEarlier`, `notificationsUrgent`, `notificationsEnd`, `notifJustNow`, `notifYesterday`).
- Adicionar as poucas chaves que realmente faltam em `app_en.arb`/`app_pt.arb` (empty state título/descrição, mensagem de erro, "há X minutos/horas/dias" parametrizados — seguindo o padrão posicional simples já usado no projeto, sem ICU plural, pois isso não é usado em nenhum outro lugar do catálogo).
- Rodar `fvm flutter gen-l10n` para regenerar o adapter.

## 8. Atualizar documentação interna

- `.gemini/docs/notifications.md`: remover a seção "Firebase Cloud Messaging (FCM)" (nunca implementada, dependência removida); documentar a seção 2 como "Inbox de Notificações (Local/Hive)", descrevendo `NotificationsLocalDataSource`/Hive.
- `.gemini/skills/add_notification.md`: remover "Phase 2: Remote Push Alerts"; adicionar um passo curto sobre usar `AddNotification`/`DeleteNotification` para o histórico local.

## 9. Testes

Seguindo o padrão de camadas em `.gemini/docs/testing.md` (`given-when-then`, `mocktail`, `bloc_test`) e o que já existe em `test/features/transactions/` e `test/features/dashboard/`:

- **Novo**: `test/features/notifications/data/models/notification_model_test.dart` (serialização/`fromEntity`/`toEntity`/equality — hoje não existe teste nenhum para essa feature).
- **Novo**: `test/features/notifications/data/datasources/notifications_local_data_source_test.dart` (usa `Hive.init` num diretório temporário de teste, sem mocks — testa put/get/watch/delete/cap de 100).
- **Novo**: `test/features/notifications/data/repositories/notifications_repository_impl_test.dart` (mock do datasource local, mapeamento de `CacheException`→`CacheFailure`).
- **Novo**: `test/features/notifications/domain/usecases/notification_usecases_test.dart` (Add/Get/MarkAsRead/Delete).
- **Novo**: `test/features/notifications/presentation/bloc/notifications_bloc_test.dart` (incluindo o novo `DeleteNotificationEvent`).
- **Novo**: `test/features/transactions/domain/usecases/classify_transaction_reminders_test.dart` (casos: atrasado, vence hoje, vence amanhã, sem `dueDate`, já pago, tipo não-expense).
- **Atualizar**: `test/features/transactions/presentation/bloc/transaction_bloc_test.dart` — ajustar os mocks para injetar `MockClassifyTransactionReminders`, e adicionar um caso novo: duas emissões idênticas do stream não devem chamar `cancelAll`/`addNotification` na segunda vez.

`dashboard_bloc_test.dart` não deve precisar de mudanças (nenhuma mudança de assinatura ali).

## Verificação

1. `fvm flutter pub get` após editar o `pubspec.yaml`.
2. `fvm flutter gen-l10n` após editar os `.arb`.
3. `fvm flutter analyze` (zero warnings novos).
4. `fvm flutter test` (suíte completa, incluindo os testes novos/atualizados).
5. Rodar o app (`fvm flutter run`), abrir a tela de Notificações, criar uma transação com vencimento próximo, confirmar que:
   - a notificação aparece na lista sem round-trip de rede (testável offline/airplane mode);
   - marcar como lida e excluir (swipe) funcionam e persistem após reiniciar o app;
   - reabrir a tela de transações repetidamente não dispara novos agendamentos/gravações quando nada mudou (dá pra observar via log temporário ou breakpoint em `cancelAll`).
