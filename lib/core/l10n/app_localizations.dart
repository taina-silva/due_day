import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @dashboardGreeting.
  ///
  /// In pt, this message translates to:
  /// **'Olá, {name}'**
  String dashboardGreeting(String name);

  /// No description provided for @dashboardMonthlySummary.
  ///
  /// In pt, this message translates to:
  /// **'Resumo Mensal'**
  String get dashboardMonthlySummary;

  /// No description provided for @dashboardGeneralBalance.
  ///
  /// In pt, this message translates to:
  /// **'Saldo Geral'**
  String get dashboardGeneralBalance;

  /// No description provided for @dashboardIncomes.
  ///
  /// In pt, this message translates to:
  /// **'Receitas'**
  String get dashboardIncomes;

  /// No description provided for @dashboardExpenses.
  ///
  /// In pt, this message translates to:
  /// **'Despesas'**
  String get dashboardExpenses;

  /// No description provided for @dashboardUpcomingDues.
  ///
  /// In pt, this message translates to:
  /// **'Próximos Vencimentos'**
  String get dashboardUpcomingDues;

  /// No description provided for @dashboardNoUpcomingDues.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma conta a vencer próxima.'**
  String get dashboardNoUpcomingDues;

  /// No description provided for @dashboardDueToday.
  ///
  /// In pt, this message translates to:
  /// **'Vence hoje'**
  String get dashboardDueToday;

  /// No description provided for @dashboardDueTomorrow.
  ///
  /// In pt, this message translates to:
  /// **'Vence amanhã'**
  String get dashboardDueTomorrow;

  /// No description provided for @dashboardDueInDays.
  ///
  /// In pt, this message translates to:
  /// **'Vence em {days} dias'**
  String dashboardDueInDays(int days);

  /// No description provided for @dashboardProjectedBalance.
  ///
  /// In pt, this message translates to:
  /// **'Saldo Projetado'**
  String get dashboardProjectedBalance;

  /// No description provided for @dashboardCategorySpending.
  ///
  /// In pt, this message translates to:
  /// **'Gastos por Categoria'**
  String get dashboardCategorySpending;

  /// No description provided for @dashboardFinancialInsights.
  ///
  /// In pt, this message translates to:
  /// **'Insights Financeiros'**
  String get dashboardFinancialInsights;

  /// No description provided for @dashboardInsightHealthy.
  ///
  /// In pt, this message translates to:
  /// **'Suas finanças estão saudáveis este mês!'**
  String get dashboardInsightHealthy;

  /// No description provided for @dashboardInsightWarning.
  ///
  /// In pt, this message translates to:
  /// **'Atenção aos gastos em {category}.'**
  String dashboardInsightWarning(String category);

  /// No description provided for @dashboardInsightBudget.
  ///
  /// In pt, this message translates to:
  /// **'Você já utilizou {percent}% do seu orçamento mensal.'**
  String dashboardInsightBudget(int percent);

  /// No description provided for @defaultTransaction.
  ///
  /// In pt, this message translates to:
  /// **'Transação'**
  String get defaultTransaction;

  /// No description provided for @loginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'O seu curador digital financeiro.'**
  String get loginSubtitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get loginPasswordLabel;

  /// No description provided for @loginSubmitButton.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginSubmitButton;

  /// No description provided for @loginGoogleButton.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com o Google'**
  String get loginGoogleButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In pt, this message translates to:
  /// **'Não tem uma conta? '**
  String get loginNoAccount;

  /// No description provided for @loginCreateNow.
  ///
  /// In pt, this message translates to:
  /// **'Criar agora'**
  String get loginCreateNow;

  /// No description provided for @loginErrorFallback.
  ///
  /// In pt, this message translates to:
  /// **'Ocorreu um erro ao fazer login.'**
  String get loginErrorFallback;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In pt, this message translates to:
  /// **'E-mail ou senha incorretos.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorEmailAlreadyInUse.
  ///
  /// In pt, this message translates to:
  /// **'Este e-mail já está em uso.'**
  String get authErrorEmailAlreadyInUse;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In pt, this message translates to:
  /// **'A senha fornecida é muito fraca.'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorUserDisabled.
  ///
  /// In pt, this message translates to:
  /// **'Esta conta de usuário foi desativada.'**
  String get authErrorUserDisabled;

  /// No description provided for @authErrorCancelled.
  ///
  /// In pt, this message translates to:
  /// **'A autenticação foi cancelada.'**
  String get authErrorCancelled;

  /// No description provided for @authErrorUserNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Conta de usuário não encontrada.'**
  String get authErrorUserNotFound;

  /// No description provided for @signupTitle.
  ///
  /// In pt, this message translates to:
  /// **'Crie sua conta'**
  String get signupTitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Comece a organizar suas finanças hoje.'**
  String get signupSubtitle;

  /// No description provided for @signupNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get signupNameLabel;

  /// No description provided for @signupNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Digite seu nome'**
  String get signupNameHint;

  /// No description provided for @signupSubmitButton.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get signupSubmitButton;

  /// No description provided for @signupErrorFallback.
  ///
  /// In pt, this message translates to:
  /// **'Ocorreu um erro ao criar conta.'**
  String get signupErrorFallback;

  /// No description provided for @navHome.
  ///
  /// In pt, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAdd.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get navAdd;

  /// No description provided for @navTrans.
  ///
  /// In pt, this message translates to:
  /// **'Transações'**
  String get navTrans;

  /// No description provided for @navAccount.
  ///
  /// In pt, this message translates to:
  /// **'Contas'**
  String get navAccount;

  /// No description provided for @navCategory.
  ///
  /// In pt, this message translates to:
  /// **'Categorias'**
  String get navCategory;

  /// No description provided for @accountsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Minhas Contas'**
  String get accountsTitle;

  /// No description provided for @accountsComingSoon.
  ///
  /// In pt, this message translates to:
  /// **'Funcionalidade disponível em breve!'**
  String get accountsComingSoon;

  /// No description provided for @accountsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma conta adicionada. Comece criando uma!'**
  String get accountsEmpty;

  /// No description provided for @accountsBanks.
  ///
  /// In pt, this message translates to:
  /// **'Bancos & Carteiras'**
  String get accountsBanks;

  /// No description provided for @accountsAddAccount.
  ///
  /// In pt, this message translates to:
  /// **'Nova Conta'**
  String get accountsAddAccount;

  /// No description provided for @accountsEditAccount.
  ///
  /// In pt, this message translates to:
  /// **'Editar Conta'**
  String get accountsEditAccount;

  /// No description provided for @accountsNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'NOME'**
  String get accountsNameLabel;

  /// No description provided for @accountsNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Nome da conta'**
  String get accountsNameHint;

  /// No description provided for @accountsBalanceLabel.
  ///
  /// In pt, this message translates to:
  /// **'SALDO INICIAL'**
  String get accountsBalanceLabel;

  /// No description provided for @accountsCategoryLabel.
  ///
  /// In pt, this message translates to:
  /// **'CATEGORIA'**
  String get accountsCategoryLabel;

  /// No description provided for @accountsCategoryInvestments.
  ///
  /// In pt, this message translates to:
  /// **'Investimentos'**
  String get accountsCategoryInvestments;

  /// No description provided for @accountsCategorySavings.
  ///
  /// In pt, this message translates to:
  /// **'Poupança'**
  String get accountsCategorySavings;

  /// No description provided for @accountsCategoryDailyUse.
  ///
  /// In pt, this message translates to:
  /// **'Uso Diário'**
  String get accountsCategoryDailyUse;

  /// No description provided for @accountsSaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Salvar Conta'**
  String get accountsSaveAccount;

  /// No description provided for @accountsDeleteAccount.
  ///
  /// In pt, this message translates to:
  /// **'Deletar Conta'**
  String get accountsDeleteAccount;

  /// No description provided for @accountsConfirmDelete.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja deletar esta conta?'**
  String get accountsConfirmDelete;

  /// No description provided for @accountsDeleted.
  ///
  /// In pt, this message translates to:
  /// **'(Deletada)'**
  String get accountsDeleted;

  /// No description provided for @accountsDueDateLabel.
  ///
  /// In pt, this message translates to:
  /// **'VENCIMENTO (FATURA/CARTÃO)'**
  String get accountsDueDateLabel;

  /// No description provided for @accountsCategoryCreditCard.
  ///
  /// In pt, this message translates to:
  /// **'Cartão de Crédito'**
  String get accountsCategoryCreditCard;

  /// No description provided for @accountsErrorNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Conta não encontrada.'**
  String get accountsErrorNotFound;

  /// No description provided for @accountsErrorNotAuthenticated.
  ///
  /// In pt, this message translates to:
  /// **'Usuário não autenticado. Por favor, faça login novamente.'**
  String get accountsErrorNotAuthenticated;

  /// No description provided for @accountsErrorFallback.
  ///
  /// In pt, this message translates to:
  /// **'Ocorreu um erro ao gerenciar suas contas.'**
  String get accountsErrorFallback;

  /// No description provided for @accountsErrorSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao salvar a conta. Tente novamente.'**
  String get accountsErrorSaveFailed;

  /// No description provided for @accountsErrorDeleteFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao deletar a conta. Tente novamente.'**
  String get accountsErrorDeleteFailed;

  /// No description provided for @categoriesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Categorias'**
  String get categoriesTitle;

  /// No description provided for @categoriesSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Curadoria do seu fluxo de gastos.'**
  String get categoriesSubtitle;

  /// No description provided for @categoriesFinancialArchitect.
  ///
  /// In pt, this message translates to:
  /// **'ARQUITETO FINANCEIRO'**
  String get categoriesFinancialArchitect;

  /// No description provided for @categoriesIncome.
  ///
  /// In pt, this message translates to:
  /// **'Receitas'**
  String get categoriesIncome;

  /// No description provided for @categoriesExpense.
  ///
  /// In pt, this message translates to:
  /// **'Despesas'**
  String get categoriesExpense;

  /// No description provided for @categoriesEmptyIncome.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma categoria de receita encontrada.'**
  String get categoriesEmptyIncome;

  /// No description provided for @categoriesEmptyExpense.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma categoria de despesa encontrada.'**
  String get categoriesEmptyExpense;

  /// No description provided for @categoriesEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma categoria salva ainda.'**
  String get categoriesEmpty;

  /// No description provided for @categoriesBudgetUsed.
  ///
  /// In pt, this message translates to:
  /// **'Dados orçamentários pendentes'**
  String get categoriesBudgetUsed;

  /// No description provided for @categoriesNewCategory.
  ///
  /// In pt, this message translates to:
  /// **'Nova Categoria'**
  String get categoriesNewCategory;

  /// No description provided for @categoriesEditCategory.
  ///
  /// In pt, this message translates to:
  /// **'Editar Categoria'**
  String get categoriesEditCategory;

  /// No description provided for @categoriesMostActive.
  ///
  /// In pt, this message translates to:
  /// **'MAIS ATIVA'**
  String get categoriesMostActive;

  /// No description provided for @categoriesTransactionCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} TRNS'**
  String categoriesTransactionCount(int count);

  /// No description provided for @categoriesNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'NOME DA CATEGORIA'**
  String get categoriesNameLabel;

  /// No description provided for @categoriesNameHint.
  ///
  /// In pt, this message translates to:
  /// **'ex. Assinaturas'**
  String get categoriesNameHint;

  /// No description provided for @categoriesSelectIcon.
  ///
  /// In pt, this message translates to:
  /// **'SELECIONAR ÍCONE'**
  String get categoriesSelectIcon;

  /// No description provided for @categoriesSelectColor.
  ///
  /// In pt, this message translates to:
  /// **'COR SEMÂNTICA'**
  String get categoriesSelectColor;

  /// No description provided for @categoriesSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar Categoria'**
  String get categoriesSave;

  /// No description provided for @profileTitle.
  ///
  /// In pt, this message translates to:
  /// **'Perfil e Configurações'**
  String get profileTitle;

  /// No description provided for @profilePremiumMember.
  ///
  /// In pt, this message translates to:
  /// **'MEMBRO PREMIUM'**
  String get profilePremiumMember;

  /// No description provided for @profileConfirmDeleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar exclusão'**
  String get profileConfirmDeleteTitle;

  /// No description provided for @profileConfirmDeleteDesc.
  ///
  /// In pt, this message translates to:
  /// **'Deseja realmente excluir sua conta permanentemente? Esta ação não tem retorno.'**
  String get profileConfirmDeleteDesc;

  /// No description provided for @profileCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get profileCancel;

  /// No description provided for @profileExclude.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get profileExclude;

  /// No description provided for @profileExcludeDevAlert.
  ///
  /// In pt, this message translates to:
  /// **'Função de exclusão em desenvolvimento.'**
  String get profileExcludeDevAlert;

  /// No description provided for @profileLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get profileLanguage;

  /// No description provided for @profileLanguageEn.
  ///
  /// In pt, this message translates to:
  /// **'Inglês-EUA'**
  String get profileLanguageEn;

  /// No description provided for @profileLanguagePt.
  ///
  /// In pt, this message translates to:
  /// **'Português-BR'**
  String get profileLanguagePt;

  /// No description provided for @profileNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get profileNotifications;

  /// No description provided for @profilePushAlerts.
  ///
  /// In pt, this message translates to:
  /// **'Alertas Automáticos'**
  String get profilePushAlerts;

  /// No description provided for @profilePushAlertsDesc.
  ///
  /// In pt, this message translates to:
  /// **'Contas, lembretes, atualizações'**
  String get profilePushAlertsDesc;

  /// No description provided for @profileLogOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair da Conta'**
  String get profileLogOut;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In pt, this message translates to:
  /// **'Deletar Conta'**
  String get profileDeleteAccount;

  /// No description provided for @profileSecurity.
  ///
  /// In pt, this message translates to:
  /// **'Segurança Biométrica'**
  String get profileSecurity;

  /// No description provided for @profileSecurityDesc.
  ///
  /// In pt, this message translates to:
  /// **'Ativa para todas as transações'**
  String get profileSecurityDesc;

  /// No description provided for @profileBiometricsNotSupported.
  ///
  /// In pt, this message translates to:
  /// **'Este dispositivo não possui suporte biométrico ativo.'**
  String get profileBiometricsNotSupported;

  /// No description provided for @profileBiometricsAuthFailed.
  ///
  /// In pt, this message translates to:
  /// **'Autenticação cancelada ou incorreta.'**
  String get profileBiometricsAuthFailed;

  /// No description provided for @profileBiometricsLockedOut.
  ///
  /// In pt, this message translates to:
  /// **'Muitas tentativas falhas. A autenticação biométrica foi bloqueada temporariamente.'**
  String get profileBiometricsLockedOut;

  /// No description provided for @profileBiometricsNotEnrolled.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma biometria cadastrada neste dispositivo. Configure a biometria nas configurações do sistema.'**
  String get profileBiometricsNotEnrolled;

  /// No description provided for @biometricLockTitle.
  ///
  /// In pt, this message translates to:
  /// **'Acesso Bloqueado'**
  String get biometricLockTitle;

  /// No description provided for @biometricLockDescription.
  ///
  /// In pt, this message translates to:
  /// **'Sua privacidade é nossa prioridade. Para acessar o DueDay, confirme sua identidade utilizando biometria.'**
  String get biometricLockDescription;

  /// No description provided for @biometricUnlockButton.
  ///
  /// In pt, this message translates to:
  /// **'Desbloquear Aplicativo'**
  String get biometricUnlockButton;

  /// No description provided for @profileTheme.
  ///
  /// In pt, this message translates to:
  /// **'Tema'**
  String get profileTheme;

  /// No description provided for @profileThemeSystem.
  ///
  /// In pt, this message translates to:
  /// **'Padrão do Sistema'**
  String get profileThemeSystem;

  /// No description provided for @profileThemeLight.
  ///
  /// In pt, this message translates to:
  /// **'Modo Claro'**
  String get profileThemeLight;

  /// No description provided for @profileThemeDark.
  ///
  /// In pt, this message translates to:
  /// **'Modo Escuro'**
  String get profileThemeDark;

  /// No description provided for @notificationsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get notificationsTitle;

  /// No description provided for @notifAppUpdateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Atualização do Sistema'**
  String get notifAppUpdateTitle;

  /// No description provided for @notifAppUpdateDesc.
  ///
  /// In pt, this message translates to:
  /// **'Os termos de uso da plataforma foram atualizados.'**
  String get notifAppUpdateDesc;

  /// No description provided for @notifCardDueDateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Conta de Luz vence amanhã'**
  String get notifCardDueDateTitle;

  /// No description provided for @notifCardDueDateDesc.
  ///
  /// In pt, this message translates to:
  /// **'Evite juros e multas realizando o pagamento da sua conta de luz até amanhã.'**
  String get notifCardDueDateDesc;

  /// No description provided for @notifCardDepositTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novo depósito recebido'**
  String get notifCardDepositTitle;

  /// No description provided for @notifCardDepositDesc.
  ///
  /// In pt, this message translates to:
  /// **'Um depósito de R\$ 5.500,00 foi processado com sucesso no seu Vault.'**
  String get notifCardDepositDesc;

  /// No description provided for @notifCardReminderTitle.
  ///
  /// In pt, this message translates to:
  /// **'Lembrete: fatura Cartão'**
  String get notifCardReminderTitle;

  /// No description provided for @notifCardReminderDesc.
  ///
  /// In pt, this message translates to:
  /// **'Sua fatura do cartão está próxima do vencimento. Valor atual: R\$ 2.450,00.'**
  String get notifCardReminderDesc;

  /// No description provided for @notifJustNow.
  ///
  /// In pt, this message translates to:
  /// **'Agora mesmo'**
  String get notifJustNow;

  /// No description provided for @notifHoursAgo.
  ///
  /// In pt, this message translates to:
  /// **'Há 4 horas'**
  String get notifHoursAgo;

  /// No description provided for @notifYesterday.
  ///
  /// In pt, this message translates to:
  /// **'Ontem'**
  String get notifYesterday;

  /// No description provided for @notifDaysAgo.
  ///
  /// In pt, this message translates to:
  /// **'Há 3 dias'**
  String get notifDaysAgo;

  /// No description provided for @notificationsGroupNew.
  ///
  /// In pt, this message translates to:
  /// **'Novas'**
  String get notificationsGroupNew;

  /// No description provided for @notificationsGroupEarlier.
  ///
  /// In pt, this message translates to:
  /// **'Anteriores'**
  String get notificationsGroupEarlier;

  /// No description provided for @notificationsUrgent.
  ///
  /// In pt, this message translates to:
  /// **'URGENTE'**
  String get notificationsUrgent;

  /// No description provided for @notificationsEnd.
  ///
  /// In pt, this message translates to:
  /// **'Fim das notificações'**
  String get notificationsEnd;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tudo em dia!'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyDesc.
  ///
  /// In pt, this message translates to:
  /// **'Você não tem nenhuma notificação pendente no momento.'**
  String get notificationsEmptyDesc;

  /// No description provided for @notificationsErrorLoading.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar notificações.'**
  String get notificationsErrorLoading;

  /// No description provided for @notificationsErrorSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao atualizar a notificação.'**
  String get notificationsErrorSaveFailed;

  /// No description provided for @notificationsErrorDeleteFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao excluir a notificação.'**
  String get notificationsErrorDeleteFailed;

  /// No description provided for @notificationsMarkAllAsRead.
  ///
  /// In pt, this message translates to:
  /// **'Marcar todas como lidas'**
  String get notificationsMarkAllAsRead;

  /// No description provided for @notifMinutesAgo.
  ///
  /// In pt, this message translates to:
  /// **'Há {count} minuto(s)'**
  String notifMinutesAgo(int count);

  /// No description provided for @notifHoursAgoCount.
  ///
  /// In pt, this message translates to:
  /// **'Há {count} hora(s)'**
  String notifHoursAgoCount(int count);

  /// No description provided for @notifDaysAgoCount.
  ///
  /// In pt, this message translates to:
  /// **'Há {count} dia(s)'**
  String notifDaysAgoCount(int count);

  /// No description provided for @transactionsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Transações'**
  String get transactionsTitle;

  /// No description provided for @transactionsFilterAll.
  ///
  /// In pt, this message translates to:
  /// **'Todas'**
  String get transactionsFilterAll;

  /// No description provided for @transactionsFilterIncome.
  ///
  /// In pt, this message translates to:
  /// **'Receitas'**
  String get transactionsFilterIncome;

  /// No description provided for @transactionsFilterExpense.
  ///
  /// In pt, this message translates to:
  /// **'Despesas'**
  String get transactionsFilterExpense;

  /// No description provided for @transactionsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma transação encontrada.'**
  String get transactionsEmpty;

  /// No description provided for @transactionsPaid.
  ///
  /// In pt, this message translates to:
  /// **'Paga'**
  String get transactionsPaid;

  /// No description provided for @transactionsPending.
  ///
  /// In pt, this message translates to:
  /// **'Pendente'**
  String get transactionsPending;

  /// No description provided for @transactionsNew.
  ///
  /// In pt, this message translates to:
  /// **'Nova Transação'**
  String get transactionsNew;

  /// No description provided for @transactionsAmount.
  ///
  /// In pt, this message translates to:
  /// **'VALOR'**
  String get transactionsAmount;

  /// No description provided for @transactionsConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar Transação'**
  String get transactionsConfirm;

  /// No description provided for @transactionsDate.
  ///
  /// In pt, this message translates to:
  /// **'DATA DA TRANSAÇÃO'**
  String get transactionsDate;

  /// No description provided for @transactionsCategory.
  ///
  /// In pt, this message translates to:
  /// **'CATEGORIA'**
  String get transactionsCategory;

  /// No description provided for @transactionsAccountFrom.
  ///
  /// In pt, this message translates to:
  /// **'DA CONTA'**
  String get transactionsAccountFrom;

  /// No description provided for @transactionsAccountTo.
  ///
  /// In pt, this message translates to:
  /// **'PARA CONTA'**
  String get transactionsAccountTo;

  /// No description provided for @transactionsRecurrence.
  ///
  /// In pt, this message translates to:
  /// **'RECORRÊNCIA'**
  String get transactionsRecurrence;

  /// No description provided for @transactionsNotesLabel.
  ///
  /// In pt, this message translates to:
  /// **'NOTAS E LEMBRETES'**
  String get transactionsNotesLabel;

  /// No description provided for @transactionsNotesHint.
  ///
  /// In pt, this message translates to:
  /// **'Adicione uma nota descritiva...'**
  String get transactionsNotesHint;

  /// No description provided for @transactionsPaidStatus.
  ///
  /// In pt, this message translates to:
  /// **'STATUS DE PAGAMENTO'**
  String get transactionsPaidStatus;

  /// No description provided for @transactionsPaidLabel.
  ///
  /// In pt, this message translates to:
  /// **'PAGA / RECEBIDA'**
  String get transactionsPaidLabel;

  /// No description provided for @transactionsFrequencyWeekly.
  ///
  /// In pt, this message translates to:
  /// **'SEMANAL'**
  String get transactionsFrequencyWeekly;

  /// No description provided for @transactionsFrequencyBiWeekly.
  ///
  /// In pt, this message translates to:
  /// **'QUINZENAL'**
  String get transactionsFrequencyBiWeekly;

  /// No description provided for @transactionsFrequencyMonthly.
  ///
  /// In pt, this message translates to:
  /// **'MENSAL'**
  String get transactionsFrequencyMonthly;

  /// No description provided for @transactionsFrequencyYearly.
  ///
  /// In pt, this message translates to:
  /// **'ANUAL'**
  String get transactionsFrequencyYearly;

  /// No description provided for @transactionsRecurringLabel.
  ///
  /// In pt, this message translates to:
  /// **'TRANSAÇÃO RECORRENTE'**
  String get transactionsRecurringLabel;

  /// No description provided for @transactionsHistory.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get transactionsHistory;

  /// No description provided for @transactionsSchedule.
  ///
  /// In pt, this message translates to:
  /// **'Agenda'**
  String get transactionsSchedule;

  /// No description provided for @transactionsTypeExpense.
  ///
  /// In pt, this message translates to:
  /// **'DESPESA'**
  String get transactionsTypeExpense;

  /// No description provided for @transactionsTypeIncome.
  ///
  /// In pt, this message translates to:
  /// **'RECEITA'**
  String get transactionsTypeIncome;

  /// No description provided for @transactionsTypeTransfer.
  ///
  /// In pt, this message translates to:
  /// **'TRANSFERÊNCIA'**
  String get transactionsTypeTransfer;

  /// No description provided for @transactionsSavedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Transação salva!'**
  String get transactionsSavedSuccess;

  /// No description provided for @transactionsSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar Transação'**
  String get transactionsSave;

  /// No description provided for @transactionsSelectCategory.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar Categoria'**
  String get transactionsSelectCategory;

  /// No description provided for @transactionsSelectAccount.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar Conta'**
  String get transactionsSelectAccount;

  /// No description provided for @transactionsEditTransaction.
  ///
  /// In pt, this message translates to:
  /// **'Editar Transação'**
  String get transactionsEditTransaction;

  /// No description provided for @transactionsAddTransaction.
  ///
  /// In pt, this message translates to:
  /// **'Nova Transação'**
  String get transactionsAddTransaction;

  /// No description provided for @transactionsDeleteTransaction.
  ///
  /// In pt, this message translates to:
  /// **'Excluir Transação'**
  String get transactionsDeleteTransaction;

  /// No description provided for @transactionsConfirmDelete.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja excluir esta transação?'**
  String get transactionsConfirmDelete;

  /// No description provided for @transactionsDetailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes da Transação'**
  String get transactionsDetailTitle;

  /// No description provided for @transactionsErrorNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Transação não encontrada.'**
  String get transactionsErrorNotFound;

  /// No description provided for @transactionsErrorNotAuthenticated.
  ///
  /// In pt, this message translates to:
  /// **'Usuário não autenticado. Faça login novamente.'**
  String get transactionsErrorNotAuthenticated;

  /// No description provided for @transactionsErrorFallback.
  ///
  /// In pt, this message translates to:
  /// **'Ocorreu um erro ao gerenciar suas transações.'**
  String get transactionsErrorFallback;

  /// No description provided for @transactionsErrorSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao salvar a transação. Tente novamente.'**
  String get transactionsErrorSaveFailed;

  /// No description provided for @transactionsErrorDeleteFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao excluir a transação. Tente novamente.'**
  String get transactionsErrorDeleteFailed;

  /// No description provided for @transactionsNotificationOverdueTitle.
  ///
  /// In pt, this message translates to:
  /// **'Conta atrasada!'**
  String get transactionsNotificationOverdueTitle;

  /// No description provided for @transactionsNotificationOverdueBody.
  ///
  /// In pt, this message translates to:
  /// **'A transação \'{description}\' de {amount} está atrasada desde {date}.'**
  String transactionsNotificationOverdueBody(
    String description,
    String amount,
    String date,
  );

  /// No description provided for @transactionsNotificationDueTodayTitle.
  ///
  /// In pt, this message translates to:
  /// **'Conta vence hoje!'**
  String get transactionsNotificationDueTodayTitle;

  /// No description provided for @transactionsNotificationDueTodayBody.
  ///
  /// In pt, this message translates to:
  /// **'Sua transação \'{description}\' de {amount} vence hoje. Realize o pagamento!'**
  String transactionsNotificationDueTodayBody(
    String description,
    String amount,
  );

  /// No description provided for @transactionsNotificationDueTomorrowTitle.
  ///
  /// In pt, this message translates to:
  /// **'Conta vence amanhã!'**
  String get transactionsNotificationDueTomorrowTitle;

  /// No description provided for @transactionsNotificationDueTomorrowBody.
  ///
  /// In pt, this message translates to:
  /// **'Sua transação \'{description}\' de {amount} vence amanhã.'**
  String transactionsNotificationDueTomorrowBody(
    String description,
    String amount,
  );

  /// No description provided for @transactionsNotificationRecurringDebitedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Conta recorrente debitada'**
  String get transactionsNotificationRecurringDebitedTitle;

  /// No description provided for @transactionsNotificationRecurringDebitedBody.
  ///
  /// In pt, this message translates to:
  /// **'O débito recorrente \'{description}\' de {amount} foi debitado e pago automaticamente.'**
  String transactionsNotificationRecurringDebitedBody(
    String description,
    String amount,
  );

  /// No description provided for @scheduleTitle.
  ///
  /// In pt, this message translates to:
  /// **'Agenda Financeira'**
  String get scheduleTitle;

  /// No description provided for @scheduleSummaryWeeklyOverview.
  ///
  /// In pt, this message translates to:
  /// **'Visão Semanal'**
  String get scheduleSummaryWeeklyOverview;

  /// No description provided for @scheduleSummaryTotalPaid.
  ///
  /// In pt, this message translates to:
  /// **'Total Pago'**
  String get scheduleSummaryTotalPaid;

  /// No description provided for @scheduleSummaryToPay.
  ///
  /// In pt, this message translates to:
  /// **'A Pagar'**
  String get scheduleSummaryToPay;

  /// No description provided for @scheduleSummaryNextIncome.
  ///
  /// In pt, this message translates to:
  /// **'Próxima Receita'**
  String get scheduleSummaryNextIncome;

  /// No description provided for @scheduleSummaryEstimatedArrival.
  ///
  /// In pt, this message translates to:
  /// **'Chegada Prevista'**
  String get scheduleSummaryEstimatedArrival;

  /// No description provided for @scheduleTimelineTitle.
  ///
  /// In pt, this message translates to:
  /// **'Linha do Tempo & Agenda'**
  String get scheduleTimelineTitle;

  /// No description provided for @scheduleStatusPaid.
  ///
  /// In pt, this message translates to:
  /// **'Pago'**
  String get scheduleStatusPaid;

  /// No description provided for @scheduleStatusOverdue.
  ///
  /// In pt, this message translates to:
  /// **'Atrasado'**
  String get scheduleStatusOverdue;

  /// No description provided for @scheduleStatusDueSoon.
  ///
  /// In pt, this message translates to:
  /// **'Vence Logo'**
  String get scheduleStatusDueSoon;

  /// No description provided for @scheduleStatusScheduled.
  ///
  /// In pt, this message translates to:
  /// **'Agendado'**
  String get scheduleStatusScheduled;

  /// No description provided for @scheduleMarkAsPaid.
  ///
  /// In pt, this message translates to:
  /// **'Marcar como Pago'**
  String get scheduleMarkAsPaid;

  /// No description provided for @notAvailable.
  ///
  /// In pt, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @splashAppName.
  ///
  /// In pt, this message translates to:
  /// **'DueDay'**
  String get splashAppName;

  /// No description provided for @splashTagline.
  ///
  /// In pt, this message translates to:
  /// **'Suas finanças, no dia certo.'**
  String get splashTagline;

  /// No description provided for @splashLogoSemanticLabel.
  ///
  /// In pt, this message translates to:
  /// **'Logo do DueDay'**
  String get splashLogoSemanticLabel;

  /// No description provided for @dateToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get dateToday;

  /// No description provided for @dateYesterday.
  ///
  /// In pt, this message translates to:
  /// **'Ontem'**
  String get dateYesterday;

  /// No description provided for @validatorRequired.
  ///
  /// In pt, this message translates to:
  /// **'Campo obrigatório'**
  String get validatorRequired;

  /// No description provided for @hintSelect.
  ///
  /// In pt, this message translates to:
  /// **'Selecione'**
  String get hintSelect;

  /// No description provided for @filters.
  ///
  /// In pt, this message translates to:
  /// **'Filtros'**
  String get filters;

  /// No description provided for @clear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get clear;

  /// No description provided for @category.
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get category;

  /// No description provided for @type.
  ///
  /// In pt, this message translates to:
  /// **'Tipo'**
  String get type;

  /// No description provided for @frequency.
  ///
  /// In pt, this message translates to:
  /// **'Frequência'**
  String get frequency;

  /// No description provided for @all.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get all;

  /// No description provided for @income.
  ///
  /// In pt, this message translates to:
  /// **'Receita'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In pt, this message translates to:
  /// **'Despesa'**
  String get expense;

  /// No description provided for @transfer.
  ///
  /// In pt, this message translates to:
  /// **'Transferência'**
  String get transfer;

  /// No description provided for @period.
  ///
  /// In pt, this message translates to:
  /// **'Período'**
  String get period;

  /// No description provided for @apply.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar'**
  String get apply;

  /// No description provided for @transactionsFrequencyNone.
  ///
  /// In pt, this message translates to:
  /// **'ÚNICA'**
  String get transactionsFrequencyNone;

  /// No description provided for @dateThisWeek.
  ///
  /// In pt, this message translates to:
  /// **'Esta Semana'**
  String get dateThisWeek;

  /// No description provided for @dateThisMonth.
  ///
  /// In pt, this message translates to:
  /// **'Este Mês'**
  String get dateThisMonth;

  /// No description provided for @dateLastMonth.
  ///
  /// In pt, this message translates to:
  /// **'Mês Passado'**
  String get dateLastMonth;

  /// No description provided for @dateCustom.
  ///
  /// In pt, this message translates to:
  /// **'Personalizado'**
  String get dateCustom;

  /// No description provided for @commonAdd.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get commonAdd;

  /// No description provided for @commonSeeAll.
  ///
  /// In pt, this message translates to:
  /// **'Ver tudo'**
  String get commonSeeAll;

  /// No description provided for @profileDefaultUserName.
  ///
  /// In pt, this message translates to:
  /// **'Usuário'**
  String get profileDefaultUserName;

  /// No description provided for @categoriesErrorNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Categoria não encontrada.'**
  String get categoriesErrorNotFound;

  /// No description provided for @categoriesErrorNotAuthenticated.
  ///
  /// In pt, this message translates to:
  /// **'Usuário não autenticado. Por favor, faça login novamente.'**
  String get categoriesErrorNotAuthenticated;

  /// No description provided for @categoriesErrorFallback.
  ///
  /// In pt, this message translates to:
  /// **'Ocorreu um erro ao gerenciar suas categorias.'**
  String get categoriesErrorFallback;

  /// No description provided for @categoriesErrorSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao salvar a categoria. Tente novamente.'**
  String get categoriesErrorSaveFailed;

  /// No description provided for @categoriesErrorDeleteFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao deletar a categoria. Tente novamente.'**
  String get categoriesErrorDeleteFailed;

  /// No description provided for @dashboardErrorFallback.
  ///
  /// In pt, this message translates to:
  /// **'Ocorreu um erro ao carregar o painel.'**
  String get dashboardErrorFallback;

  /// No description provided for @scheduleErrorFallback.
  ///
  /// In pt, this message translates to:
  /// **'Ocorreu um erro ao carregar sua agenda.'**
  String get scheduleErrorFallback;

  /// No description provided for @scheduleErrorNotAuthenticated.
  ///
  /// In pt, this message translates to:
  /// **'Usuário não autenticado. Por favor, faça login novamente.'**
  String get scheduleErrorNotAuthenticated;

  /// No description provided for @scheduleActionErrorFallback.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao atualizar sua agenda. Tente novamente.'**
  String get scheduleActionErrorFallback;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
