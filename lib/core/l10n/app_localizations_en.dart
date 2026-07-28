// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String dashboardGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get dashboardMonthlySummary => 'Monthly Summary';

  @override
  String get dashboardGeneralBalance => 'General Balance';

  @override
  String get dashboardIncomes => 'Incomes';

  @override
  String get dashboardExpenses => 'Expenses';

  @override
  String get dashboardUpcomingDues => 'Upcoming Dues';

  @override
  String get dashboardNoUpcomingDues => 'No upcoming dues.';

  @override
  String get dashboardDueToday => 'Due today';

  @override
  String get dashboardDueTomorrow => 'Due tomorrow';

  @override
  String dashboardDueInDays(int days) {
    return 'Due in $days days';
  }

  @override
  String get dashboardProjectedBalance => 'Projected Balance';

  @override
  String get dashboardCategorySpending => 'Category Spending';

  @override
  String get dashboardFinancialInsights => 'Financial Insights';

  @override
  String get dashboardInsightHealthy => 'Your finances are healthy this month!';

  @override
  String dashboardInsightWarning(String category) {
    return 'Pay attention to spending in $category.';
  }

  @override
  String dashboardInsightBudget(int percent) {
    return 'You have already used $percent% of your monthly budget.';
  }

  @override
  String get defaultTransaction => 'Transaction';

  @override
  String get loginSubtitle => 'Your digital financial curator.';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginSubmitButton => 'Sign In';

  @override
  String get loginGoogleButton => 'Continue with Google';

  @override
  String get loginNoAccount => 'Don\'t have an account? ';

  @override
  String get loginCreateNow => 'Create now';

  @override
  String get loginErrorFallback => 'An error occurred during login.';

  @override
  String get authErrorInvalidCredentials => 'Invalid email or password.';

  @override
  String get authErrorEmailAlreadyInUse => 'This email is already in use.';

  @override
  String get authErrorWeakPassword => 'The password provided is too weak.';

  @override
  String get authErrorUserDisabled => 'This user account has been disabled.';

  @override
  String get authErrorCancelled => 'Authentication was cancelled.';

  @override
  String get authErrorUserNotFound => 'User account not found.';

  @override
  String get signupTitle => 'Create your account';

  @override
  String get signupSubtitle => 'Start organizing your finances today.';

  @override
  String get signupNameLabel => 'Name';

  @override
  String get signupNameHint => 'Enter your name';

  @override
  String get signupSubmitButton => 'Create account';

  @override
  String get signupErrorFallback =>
      'An error occurred while creating your account.';

  @override
  String get navHome => 'Home';

  @override
  String get navAdd => 'Add';

  @override
  String get navTrans => 'Transactions';

  @override
  String get navAccount => 'Accounts';

  @override
  String get navCategory => 'Categories';

  @override
  String get accountsTitle => 'My Accounts';

  @override
  String get accountsComingSoon => 'Feature coming soon!';

  @override
  String get accountsEmpty => 'No accounts added. Start by creating one!';

  @override
  String get accountsBanks => 'Banks & Wallets';

  @override
  String get accountsAddAccount => 'Add Account';

  @override
  String get accountsEditAccount => 'Edit Account';

  @override
  String get accountsNameLabel => 'NAME';

  @override
  String get accountsNameHint => 'Enter account name';

  @override
  String get accountsBalanceLabel => 'INITIAL BALANCE';

  @override
  String get accountsCategoryLabel => 'CATEGORY';

  @override
  String get accountsCategoryInvestments => 'Investments';

  @override
  String get accountsCategorySavings => 'Savings';

  @override
  String get accountsCategoryDailyUse => 'Daily Use';

  @override
  String get accountsSaveAccount => 'Save Account';

  @override
  String get accountsDeleteAccount => 'Delete Account';

  @override
  String get accountsConfirmDelete =>
      'Are you sure you want to delete this account?';

  @override
  String get accountsDeleted => '(Deleted)';

  @override
  String get accountsDueDateLabel => 'DUE DATE (INVOICE/CARD)';

  @override
  String get accountsCategoryCreditCard => 'Credit Card';

  @override
  String get accountsErrorNotFound => 'Account not found.';

  @override
  String get accountsErrorNotAuthenticated =>
      'User not authenticated. Please log in again.';

  @override
  String get accountsErrorFallback =>
      'An error occurred while managing your accounts.';

  @override
  String get accountsErrorSaveFailed =>
      'Failed to save account. Please try again.';

  @override
  String get accountsErrorDeleteFailed =>
      'Failed to delete account. Please try again.';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get categoriesSubtitle => 'Curate your spending flow.';

  @override
  String get categoriesFinancialArchitect => 'FINANCIAL ARCHITECT';

  @override
  String get categoriesIncome => 'Incomes';

  @override
  String get categoriesExpense => 'Expenses';

  @override
  String get categoriesEmptyIncome => 'No income categories found.';

  @override
  String get categoriesEmptyExpense => 'No expense categories found.';

  @override
  String get categoriesEmpty => 'No categories saved yet.';

  @override
  String get categoriesBudgetUsed => 'Budget data pending';

  @override
  String get categoriesNewCategory => 'New Category';

  @override
  String get categoriesEditCategory => 'Edit Category';

  @override
  String get categoriesMostActive => 'MOST ACTIVE';

  @override
  String categoriesTransactionCount(int count) {
    return '$count TRNS';
  }

  @override
  String get categoriesNameLabel => 'CATEGORY NAME';

  @override
  String get categoriesNameHint => 'e.g. Subscriptions';

  @override
  String get categoriesSelectIcon => 'SELECT ICON';

  @override
  String get categoriesSelectColor => 'SEMANTIC COLOR';

  @override
  String get categoriesSave => 'Save Category';

  @override
  String get profileTitle => 'Profile & Settings';

  @override
  String get profilePremiumMember => 'PREMIUM MEMBER';

  @override
  String get profileConfirmDeleteTitle => 'Confirm Deletion';

  @override
  String get profileConfirmDeleteDesc =>
      'Do you really want to permanently delete your account? This action cannot be undone.';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get profileExclude => 'Delete';

  @override
  String get profileExcludeDevAlert => 'Delete functionality in development.';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileLanguageEn => 'English-US';

  @override
  String get profileLanguagePt => 'Português-BR';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profilePushAlerts => 'Push Alerts';

  @override
  String get profilePushAlertsDesc => 'Bills, reminders, updates';

  @override
  String get profileLogOut => 'Log Out';

  @override
  String get profileDeleteAccount => 'Delete Account';

  @override
  String get profileSecurity => 'Biometric Security';

  @override
  String get profileSecurityDesc => 'Active for all transactions';

  @override
  String get profileBiometricsNotSupported =>
      'This device does not have active biometric support.';

  @override
  String get profileBiometricsAuthFailed =>
      'Authentication cancelled or incorrect.';

  @override
  String get profileBiometricsLockedOut =>
      'Too many failed attempts. Biometric authentication has been temporarily locked.';

  @override
  String get profileBiometricsNotEnrolled =>
      'No biometrics enrolled on this device. Set up biometrics in your system settings.';

  @override
  String get biometricLockTitle => 'Access Locked';

  @override
  String get biometricLockDescription =>
      'Your privacy is our priority. To access DueDay, confirm your identity using biometrics.';

  @override
  String get biometricUnlockButton => 'Unlock App';

  @override
  String get profileTheme => 'Theme';

  @override
  String get profileThemeSystem => 'System Default';

  @override
  String get profileThemeLight => 'Light Mode';

  @override
  String get profileThemeDark => 'Dark Mode';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notifAppUpdateTitle => 'System Update';

  @override
  String get notifAppUpdateDesc =>
      'The platform\'s terms of use have been updated.';

  @override
  String get notifCardDueDateTitle => 'Electricity bill due tomorrow';

  @override
  String get notifCardDueDateDesc =>
      'Avoid interest and fines by paying your electricity bill by tomorrow.';

  @override
  String get notifCardDepositTitle => 'New deposit received';

  @override
  String get notifCardDepositDesc =>
      'A deposit of R\$ 5,500.00 was successfully processed in your Vault.';

  @override
  String get notifCardReminderTitle => 'Reminder: Card bill';

  @override
  String get notifCardReminderDesc =>
      'Your card bill is near its due date. Current amount: R\$ 2,450.00.';

  @override
  String get notifJustNow => 'Just now';

  @override
  String get notifHoursAgo => '4 hours ago';

  @override
  String get notifYesterday => 'Yesterday';

  @override
  String get notifDaysAgo => '3 days ago';

  @override
  String get notificationsGroupNew => 'New';

  @override
  String get notificationsGroupEarlier => 'Earlier';

  @override
  String get notificationsUrgent => 'URGENT';

  @override
  String get notificationsEnd => 'End of notifications';

  @override
  String get notificationsEmptyTitle => 'All caught up!';

  @override
  String get notificationsEmptyDesc =>
      'You have no pending notifications right now.';

  @override
  String get notificationsErrorLoading => 'Error loading notifications.';

  @override
  String notifMinutesAgo(int count) {
    return '$count minute(s) ago';
  }

  @override
  String notifHoursAgoCount(int count) {
    return '$count hour(s) ago';
  }

  @override
  String notifDaysAgoCount(int count) {
    return '$count day(s) ago';
  }

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String get transactionsFilterAll => 'All';

  @override
  String get transactionsFilterIncome => 'Incomes';

  @override
  String get transactionsFilterExpense => 'Expenses';

  @override
  String get transactionsEmpty => 'No transactions found.';

  @override
  String get transactionsPaid => 'Paid';

  @override
  String get transactionsPending => 'Pending';

  @override
  String get transactionsNew => 'New Transaction';

  @override
  String get transactionsAmount => 'AMOUNT';

  @override
  String get transactionsConfirm => 'Confirm Transaction';

  @override
  String get transactionsDate => 'TRANSACTION DATE';

  @override
  String get transactionsCategory => 'CATEGORY';

  @override
  String get transactionsAccountFrom => 'FROM ACCOUNT';

  @override
  String get transactionsAccountTo => 'TO ACCOUNT';

  @override
  String get transactionsRecurrence => 'RECURRENCE';

  @override
  String get transactionsNotesLabel => 'NOTES & REMINDERS';

  @override
  String get transactionsNotesHint => 'Add a descriptive note...';

  @override
  String get transactionsPaidStatus => 'PAYMENT STATUS';

  @override
  String get transactionsPaidLabel => 'PAID / RECEIVED';

  @override
  String get transactionsFrequencyWeekly => 'WEEKLY';

  @override
  String get transactionsFrequencyBiWeekly => 'BI-WEEKLY';

  @override
  String get transactionsFrequencyMonthly => 'MONTHLY';

  @override
  String get transactionsFrequencyYearly => 'YEARLY';

  @override
  String get transactionsRecurringLabel => 'RECURRING TRANSACTION';

  @override
  String get transactionsHistory => 'History';

  @override
  String get transactionsSchedule => 'Schedule';

  @override
  String get transactionsTypeExpense => 'EXPENSE';

  @override
  String get transactionsTypeIncome => 'INCOME';

  @override
  String get transactionsTypeTransfer => 'TRANSFER';

  @override
  String get transactionsSavedSuccess => 'Transaction saved!';

  @override
  String get transactionsSave => 'Save Transaction';

  @override
  String get transactionsSelectCategory => 'Select Category';

  @override
  String get transactionsSelectAccount => 'Select Account';

  @override
  String get transactionsEditTransaction => 'Edit Transaction';

  @override
  String get transactionsAddTransaction => 'Add Transaction';

  @override
  String get transactionsDeleteTransaction => 'Delete Transaction';

  @override
  String get transactionsConfirmDelete =>
      'Are you sure you want to delete this transaction?';

  @override
  String get transactionsDetailTitle => 'Transaction Details';

  @override
  String get transactionsErrorNotFound => 'Transaction not found.';

  @override
  String get transactionsErrorNotAuthenticated =>
      'User not authenticated. Please log in again.';

  @override
  String get transactionsErrorFallback =>
      'An error occurred while managing your transactions.';

  @override
  String get transactionsErrorSaveFailed =>
      'Failed to save transaction. Please try again.';

  @override
  String get transactionsErrorDeleteFailed =>
      'Failed to delete transaction. Please try again.';

  @override
  String get transactionsNotificationOverdueTitle => 'Overdue bill!';

  @override
  String transactionsNotificationOverdueBody(
    String description,
    String amount,
    String date,
  ) {
    return 'The transaction \'$description\' of $amount is overdue since $date.';
  }

  @override
  String get transactionsNotificationDueTodayTitle => 'Bill due today!';

  @override
  String transactionsNotificationDueTodayBody(
    String description,
    String amount,
  ) {
    return 'Your transaction \'$description\' of $amount is due today. Make the payment!';
  }

  @override
  String get transactionsNotificationDueTomorrowTitle => 'Bill due tomorrow!';

  @override
  String transactionsNotificationDueTomorrowBody(
    String description,
    String amount,
  ) {
    return 'Your transaction \'$description\' of $amount is due tomorrow.';
  }

  @override
  String get transactionsNotificationRecurringDebitedTitle =>
      'Recurring bill debited';

  @override
  String transactionsNotificationRecurringDebitedBody(
    String description,
    String amount,
  ) {
    return 'The recurring debit \'$description\' of $amount was automatically debited and paid.';
  }

  @override
  String get scheduleTitle => 'Financial Schedule';

  @override
  String get scheduleSummaryWeeklyOverview => 'Weekly Overview';

  @override
  String get scheduleSummaryTotalPaid => 'Total Paid';

  @override
  String get scheduleSummaryToPay => 'To Pay';

  @override
  String get scheduleSummaryNextIncome => 'Next Income';

  @override
  String get scheduleSummaryEstimatedArrival => 'Estimated Arrival';

  @override
  String get scheduleTimelineTitle => 'Timeline & Agenda';

  @override
  String get scheduleStatusPaid => 'Paid';

  @override
  String get scheduleStatusOverdue => 'Overdue';

  @override
  String get scheduleStatusDueSoon => 'Due Soon';

  @override
  String get scheduleStatusScheduled => 'Scheduled';

  @override
  String get scheduleMarkAsPaid => 'Mark as Paid';

  @override
  String get notAvailable => 'N/A';

  @override
  String get splashAppName => 'DueDay';

  @override
  String get splashTagline => 'Your finances, on the right day.';

  @override
  String get splashLogoSemanticLabel => 'DueDay logo';

  @override
  String get dateToday => 'Today';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String get validatorRequired => 'Required field';

  @override
  String get hintSelect => 'Select';

  @override
  String get filters => 'Filters';

  @override
  String get clear => 'Clear';

  @override
  String get category => 'Category';

  @override
  String get type => 'Type';

  @override
  String get frequency => 'Frequency';

  @override
  String get all => 'All';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get transfer => 'Transfer';

  @override
  String get period => 'Period';

  @override
  String get apply => 'Apply';

  @override
  String get transactionsFrequencyNone => 'ONE-TIME';

  @override
  String get dateThisWeek => 'This Week';

  @override
  String get dateThisMonth => 'This Month';

  @override
  String get dateLastMonth => 'Last Month';

  @override
  String get dateCustom => 'Custom';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonSeeAll => 'See All';

  @override
  String get profileDefaultUserName => 'User';

  @override
  String get categoriesErrorNotFound => 'Category not found.';

  @override
  String get categoriesErrorNotAuthenticated =>
      'User not authenticated. Please log in again.';

  @override
  String get categoriesErrorFallback =>
      'An error occurred while managing your categories.';

  @override
  String get categoriesErrorSaveFailed =>
      'Failed to save category. Please try again.';

  @override
  String get categoriesErrorDeleteFailed =>
      'Failed to delete category. Please try again.';

  @override
  String get dashboardErrorFallback =>
      'An error occurred while loading the dashboard.';

  @override
  String get scheduleErrorFallback =>
      'An error occurred while loading your schedule.';

  @override
  String get scheduleErrorNotAuthenticated =>
      'User not authenticated. Please log in again.';

  @override
  String get scheduleActionErrorFallback =>
      'Failed to update your schedule. Please try again.';
}
