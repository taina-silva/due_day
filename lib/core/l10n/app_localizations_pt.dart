// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String dashboardGreeting(String name) {
    return 'Olá, $name';
  }

  @override
  String get dashboardMonthlySummary => 'Resumo Mensal';

  @override
  String get dashboardGeneralBalance => 'Saldo Geral';

  @override
  String get dashboardIncomes => 'Receitas';

  @override
  String get dashboardExpenses => 'Despesas';

  @override
  String get dashboardUpcomingDues => 'Próximos Vencimentos';

  @override
  String get dashboardNoUpcomingDues => 'Nenhuma conta a vencer próxima.';

  @override
  String get dashboardDueToday => 'Vence hoje';

  @override
  String get dashboardDueTomorrow => 'Vence amanhã';

  @override
  String dashboardDueInDays(int days) {
    return 'Vence em $days dias';
  }

  @override
  String get dashboardProjectedBalance => 'Saldo Projetado';

  @override
  String get dashboardCategorySpending => 'Gastos por Categoria';

  @override
  String get dashboardFinancialInsights => 'Insights Financeiros';

  @override
  String get dashboardInsightHealthy =>
      'Suas finanças estão saudáveis este mês!';

  @override
  String dashboardInsightWarning(String category) {
    return 'Atenção aos gastos em $category.';
  }

  @override
  String dashboardInsightBudget(int percent) {
    return 'Você já utilizou $percent% do seu orçamento mensal.';
  }

  @override
  String get defaultTransaction => 'Transação';

  @override
  String get loginWelcome => 'Boas-vindas!';

  @override
  String get loginSubtitle => 'O seu curador digital financeiro.';

  @override
  String get loginAccessAccount => 'Acesse sua conta para continuar.';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginEmailHint => 'Digite seu e-mail';

  @override
  String get loginPasswordLabel => 'Senha';

  @override
  String get loginPasswordHint => 'Digite sua senha';

  @override
  String get loginSubmitButton => 'Entrar';

  @override
  String get loginGoogleButton => 'Continuar com o Google';

  @override
  String get loginNoAccount => 'Não tem uma conta? ';

  @override
  String get loginCreateNow => 'Criar agora';

  @override
  String get loginErrorFallback => 'Ocorreu um erro ao fazer login.';

  @override
  String get authErrorInvalidCredentials => 'E-mail ou senha incorretos.';

  @override
  String get authErrorEmailAlreadyInUse => 'Este e-mail já está em uso.';

  @override
  String get authErrorWeakPassword => 'A senha fornecida é muito fraca.';

  @override
  String get authErrorUserDisabled => 'Esta conta de usuário foi desativada.';

  @override
  String get authErrorCancelled => 'A autenticação foi cancelada.';

  @override
  String get authErrorUserNotFound => 'Conta de usuário não encontrada.';

  @override
  String get signupTitle => 'Crie sua conta';

  @override
  String get signupSubtitle => 'Comece a organizar suas finanças hoje.';

  @override
  String get signupNameLabel => 'Nome';

  @override
  String get signupNameHint => 'Digite seu nome';

  @override
  String get signupSubmitButton => 'Criar conta';

  @override
  String get signupHaveAccount => 'Já tem uma conta? ';

  @override
  String get signupDoLogin => 'Fazer login';

  @override
  String get signupEmptyFields => 'Preencha todos os campos';

  @override
  String get signupErrorFallback => 'Ocorreu um erro ao criar conta.';

  @override
  String get navHome => 'Home';

  @override
  String get navAdd => 'Adicionar';

  @override
  String get navTrans => 'Transações';

  @override
  String get navAccount => 'Contas';

  @override
  String get navCategory => 'Categorias';

  @override
  String get accountsTitle => 'Minhas Contas';

  @override
  String get accountsComingSoon => 'Funcionalidade disponível em breve!';

  @override
  String get accountsEmpty => 'Nenhuma conta adicionada. Comece criando uma!';

  @override
  String get accountsBanks => 'Bancos & Carteiras';

  @override
  String get accountsAddAccount => 'Nova Conta';

  @override
  String get accountsEditAccount => 'Editar Conta';

  @override
  String get accountsNameLabel => 'NOME';

  @override
  String get accountsNameHint => 'Nome da conta';

  @override
  String get accountsBalanceLabel => 'SALDO INICIAL';

  @override
  String get accountsCategoryLabel => 'CATEGORIA';

  @override
  String get accountsCategoryInvestments => 'Investimentos';

  @override
  String get accountsCategorySavings => 'Poupança';

  @override
  String get accountsCategoryDailyUse => 'Uso Diário';

  @override
  String get accountsSaveAccount => 'Salvar Conta';

  @override
  String get accountsDeleteAccount => 'Deletar Conta';

  @override
  String get accountsConfirmDelete =>
      'Tem certeza que deseja deletar esta conta?';

  @override
  String get accountsDeleted => '(Deletada)';

  @override
  String get accountsDueDateLabel => 'VENCIMENTO (FATURA/CARTÃO)';

  @override
  String get accountsCategoryCreditCard => 'Cartão de Crédito';

  @override
  String get accountsErrorNotFound => 'Conta não encontrada.';

  @override
  String get accountsErrorNotAuthenticated =>
      'Usuário não autenticado. Por favor, faça login novamente.';

  @override
  String get accountsErrorFallback =>
      'Ocorreu um erro ao gerenciar suas contas.';

  @override
  String get categoriesTitle => 'Categorias';

  @override
  String get categoriesSubtitle => 'Curadoria do seu fluxo de gastos.';

  @override
  String get categoriesFinancialArchitect => 'ARQUITETO FINANCEIRO';

  @override
  String get categoriesIncome => 'Receitas';

  @override
  String get categoriesExpense => 'Despesas';

  @override
  String get categoriesEmptyIncome =>
      'Nenhuma categoria de receita encontrada.';

  @override
  String get categoriesEmptyExpense =>
      'Nenhuma categoria de despesa encontrada.';

  @override
  String get categoriesEmpty => 'Nenhuma categoria salva ainda.';

  @override
  String get categoriesBudgetUsed => 'Dados orçamentários pendentes';

  @override
  String get categoriesNewCategory => 'Nova Categoria';

  @override
  String get categoriesEditCategory => 'Editar Categoria';

  @override
  String get categoriesMostActive => 'MAIS ATIVA';

  @override
  String categoriesTransactionCount(int count) {
    return '$count TRNS';
  }

  @override
  String get categoriesNameLabel => 'NOME DA CATEGORIA';

  @override
  String get categoriesNameHint => 'ex. Assinaturas';

  @override
  String get categoriesSelectIcon => 'SELECIONAR ÍCONE';

  @override
  String get categoriesSelectColor => 'COR SEMÂNTICA';

  @override
  String get categoriesSave => 'Salvar Categoria';

  @override
  String get profileTitle => 'Perfil e Configurações';

  @override
  String get profilePremiumMember => 'MEMBRO PREMIUM';

  @override
  String get profileConfirmDeleteTitle => 'Confirmar exclusão';

  @override
  String get profileConfirmDeleteDesc =>
      'Deseja realmente excluir sua conta permanentemente? Esta ação não tem retorno.';

  @override
  String get profileCancel => 'Cancelar';

  @override
  String get profileExclude => 'Excluir';

  @override
  String get profileExcludeDevAlert => 'Função de exclusão em desenvolvimento.';

  @override
  String get profileLanguage => 'Idioma';

  @override
  String get profileLanguageEn => 'Inglês-EUA';

  @override
  String get profileLanguagePt => 'Português-BR';

  @override
  String get profileNotifications => 'Notificações';

  @override
  String get profilePushAlerts => 'Alertas Automáticos';

  @override
  String get profilePushAlertsDesc => 'Contas, lembretes, atualizações';

  @override
  String get profileLogOut => 'Sair da Conta';

  @override
  String get profileDeleteAccount => 'Deletar Conta';

  @override
  String get profileSecurity => 'Segurança Biométrica';

  @override
  String get profileSecurityDesc => 'Ativa para todas as transações';

  @override
  String get profileBiometricsNotSupported =>
      'Este dispositivo não possui suporte biométrico ativo.';

  @override
  String get profileBiometricsAuthFailed =>
      'Autenticação cancelada ou incorreta.';

  @override
  String get profileTheme => 'Tema';

  @override
  String get profileThemeSystem => 'Padrão do Sistema';

  @override
  String get profileThemeLight => 'Modo Claro';

  @override
  String get profileThemeDark => 'Modo Escuro';

  @override
  String get notificationsTitle => 'Notificações';

  @override
  String get notifAppUpdateTitle => 'Atualização do Sistema';

  @override
  String get notifAppUpdateDesc =>
      'Os termos de uso da plataforma foram atualizados.';

  @override
  String get notifCardDueDateTitle => 'Conta de Luz vence amanhã';

  @override
  String get notifCardDueDateDesc =>
      'Evite juros e multas realizando o pagamento da sua conta de luz até amanhã.';

  @override
  String get notifCardDepositTitle => 'Novo depósito recebido';

  @override
  String get notifCardDepositDesc =>
      'Um depósito de R\$ 5.500,00 foi processado com sucesso no seu Vault.';

  @override
  String get notifCardReminderTitle => 'Lembrete: fatura Cartão';

  @override
  String get notifCardReminderDesc =>
      'Sua fatura do cartão está próxima do vencimento. Valor atual: R\$ 2.450,00.';

  @override
  String get notifJustNow => 'Agora mesmo';

  @override
  String get notifHoursAgo => 'Há 4 horas';

  @override
  String get notifYesterday => 'Ontem';

  @override
  String get notifDaysAgo => 'Há 3 dias';

  @override
  String get notificationsGroupNew => 'Novas';

  @override
  String get notificationsGroupEarlier => 'Anteriores';

  @override
  String get notificationsUrgent => 'URGENTE';

  @override
  String get notificationsEnd => 'Fim das notificações';

  @override
  String get transactionsTitle => 'Transações';

  @override
  String get transactionsFilterAll => 'Todas';

  @override
  String get transactionsFilterIncome => 'Receitas';

  @override
  String get transactionsFilterExpense => 'Despesas';

  @override
  String get transactionsEmpty => 'Nenhuma transação encontrada.';

  @override
  String get transactionsPaid => 'Paga';

  @override
  String get transactionsPending => 'Pendente';

  @override
  String get transactionsNew => 'Nova Transação';

  @override
  String get transactionsAmount => 'VALOR';

  @override
  String get transactionsConfirm => 'Confirmar Transação';

  @override
  String get transactionsDate => 'DATA DA TRANSAÇÃO';

  @override
  String get transactionsCategory => 'CATEGORIA';

  @override
  String get transactionsAccountFrom => 'DA CONTA';

  @override
  String get transactionsAccountTo => 'PARA CONTA';

  @override
  String get transactionsRecurrence => 'RECORRÊNCIA';

  @override
  String get transactionsNotesLabel => 'NOTAS E LEMBRETES';

  @override
  String get transactionsNotesHint => 'Adicione uma nota descritiva...';

  @override
  String get transactionsPaidStatus => 'STATUS DE PAGAMENTO';

  @override
  String get transactionsPaidLabel => 'PAGA / RECEBIDA';

  @override
  String get transactionsFrequencyWeekly => 'SEMANAL';

  @override
  String get transactionsFrequencyBiWeekly => 'QUINZENAL';

  @override
  String get transactionsFrequencyMonthly => 'MENSAL';

  @override
  String get transactionsFrequencyYearly => 'ANUAL';

  @override
  String get transactionsRecurringLabel => 'TRANSAÇÃO RECORRENTE';

  @override
  String get transactionsHistory => 'Histórico';

  @override
  String get transactionsSchedule => 'Agenda';

  @override
  String get transactionsTypeExpense => 'DESPESA';

  @override
  String get transactionsTypeIncome => 'RECEITA';

  @override
  String get transactionsTypeTransfer => 'TRANSFERÊNCIA';

  @override
  String get transactionsSavedSuccess => 'Transação salva!';

  @override
  String get transactionsSave => 'Salvar Transação';

  @override
  String get transactionsSelectCategory => 'Selecionar Categoria';

  @override
  String get transactionsSelectAccount => 'Selecionar Conta';

  @override
  String get transactionsEditTransaction => 'Editar Transação';

  @override
  String get transactionsAddTransaction => 'Nova Transação';

  @override
  String get transactionsDeleteTransaction => 'Excluir Transação';

  @override
  String get transactionsConfirmDelete =>
      'Tem certeza que deseja excluir esta transação?';

  @override
  String get transactionsDetailTitle => 'Detalhes da Transação';

  @override
  String get scheduleTitle => 'Agenda Financeira';

  @override
  String get scheduleSummaryWeeklyOverview => 'Visão Semanal';

  @override
  String get scheduleSummaryTotalPaid => 'Total Pago';

  @override
  String get scheduleSummaryToPay => 'A Pagar';

  @override
  String get scheduleSummaryNextIncome => 'Próxima Receita';

  @override
  String get scheduleSummaryEstimatedArrival => 'Chegada Prevista';

  @override
  String get scheduleTimelineTitle => 'Linha do Tempo & Agenda';

  @override
  String get scheduleStatusPaid => 'Pago';

  @override
  String get scheduleStatusOverdue => 'Atrasado';

  @override
  String get scheduleStatusDueSoon => 'Vence Logo';

  @override
  String get scheduleStatusScheduled => 'Agendado';

  @override
  String get scheduleMarkAsPaid => 'Marcar como Pago';

  @override
  String get notAvailable => 'N/A';

  @override
  String get splashAppName => 'DueDay';

  @override
  String get splashTagline => 'Suas finanças, no dia certo.';

  @override
  String get dateToday => 'Hoje';

  @override
  String get dateYesterday => 'Ontem';

  @override
  String get validatorRequired => 'Campo obrigatório';

  @override
  String get hintSelect => 'Selecione';

  @override
  String get filters => 'Filtros';

  @override
  String get clear => 'Limpar';

  @override
  String get category => 'Categoria';

  @override
  String get type => 'Tipo';

  @override
  String get frequency => 'Frequência';

  @override
  String get all => 'Todos';

  @override
  String get income => 'Receita';

  @override
  String get expense => 'Despesa';

  @override
  String get transfer => 'Transferência';

  @override
  String get period => 'Período';

  @override
  String get apply => 'Aplicar';

  @override
  String get transactionsFrequencyNone => 'ÚNICA';

  @override
  String get dateThisWeek => 'Esta Semana';

  @override
  String get dateThisMonth => 'Este Mês';

  @override
  String get dateLastMonth => 'Mês Passado';

  @override
  String get dateCustom => 'Personalizado';

  @override
  String get commonAdd => 'Adicionar';

  @override
  String get commonSeeAll => 'Ver tudo';

  @override
  String get profileDefaultUserName => 'Usuário';

  @override
  String get categoriesErrorNotFound => 'Categoria não encontrada.';

  @override
  String get categoriesErrorNotAuthenticated =>
      'Usuário não autenticado. Por favor, faça login novamente.';

  @override
  String get categoriesErrorFallback =>
      'Ocorreu um erro ao gerenciar suas categorias.';

  @override
  String get dashboardErrorFallback => 'Ocorreu um erro ao carregar o painel.';
}
