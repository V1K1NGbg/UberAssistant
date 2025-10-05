// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeTitle => 'Uber Assistant';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get privacy => 'Privacy Policy';

  @override
  String get privacyBody =>
      'We process only the minimum data needed for the demo.';

  @override
  String get aboutBody =>
      'Hackathon demo to help earners make smarter choices.';

  @override
  String get available => 'Available';

  @override
  String get unavailable => 'Taking a break';

  @override
  String get statusWaiting => 'Waiting for customer requests…';

  @override
  String get statusBreak =>
      'Turn the switch on when you are ready to receive requests.';

  @override
  String get statusNothing => 'Nothing going on currently';

  @override
  String get queued => 'Queued next trip';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get driver => 'Driver';

  @override
  String get language => 'Language';

  @override
  String get themeMode => 'Theme';

  @override
  String get serverIp => 'Server IP';

  @override
  String get tripInTransit => 'In transit';

  @override
  String get imThere => 'I’m there';

  @override
  String get requestTitle => 'New request';

  @override
  String get requestTitleRecommended => 'Recommended request';

  @override
  String get customer => 'Customer';

  @override
  String get pickup => 'Pickup';

  @override
  String get dropoff => 'Drop-off';

  @override
  String get durationLabel => 'Duration';

  @override
  String get earningsLabel => 'Earnings';

  @override
  String get skip => 'Ignore';

  @override
  String get accept => 'Slide to accept';

  @override
  String mins(Object minutes) {
    return '$minutes mins';
  }

  @override
  String expiresIn(Object seconds) {
    return 'Expires in ${seconds}s';
  }

  @override
  String get onboardingTitle1 => 'Welcome';

  @override
  String get onboardingBody1 =>
      'This app helps you earn smarter with timely offers and safe nudges.';

  @override
  String get onboardingTitle2 => 'Always on it';

  @override
  String get onboardingBody2 =>
      'We notify you when there’s a good request nearby.';

  @override
  String get onboardingTitle3 => 'Balanced & safe';

  @override
  String get onboardingBody3 =>
      'We nudge you to rest when needed and keep your data safe.';

  @override
  String get permTitle => 'Permissions';

  @override
  String get permBody => 'We need your location to find offers near you.';

  @override
  String get permAllow => 'Allow location';

  @override
  String get permAllowSubtitle =>
      'Grant location while using the app. You can upgrade to “Allow all the time” in Settings for background operation.';

  @override
  String get permGranted => 'Location granted';

  @override
  String get checkAgain => 'Check again';

  @override
  String get permDeniedTitle => 'Permission required';

  @override
  String get permDeniedBody =>
      'The app can’t function without location. You can exit or grant the permission in Settings.';

  @override
  String get exitApp => 'Exit';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get allSetTitle => 'You’re all set!';

  @override
  String get allSetBody => 'Let’s get ready and start receiving offers.';

  @override
  String get letsGo => 'Let’s go!';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get selectDriver => 'Choose your driver';

  @override
  String get selectDriverBody =>
      'Pick your demo identity. You can change it later in Settings.';

  @override
  String get permAlwaysBanner =>
      'For background operation, allow location \"All the time\" in Settings.';

  @override
  String get learnHow => 'How to fix';

  @override
  String get locationHelpTitle => 'Enable \"Allow all the time\"';

  @override
  String get locationHelpBody =>
      'To receive offers in the background, enable background location.';

  @override
  String get locationHelpAndroid =>
      'Android: Open the app’s settings > Permissions > Location, then select \"Allow all the time\".';

  @override
  String get locationHelpiOS =>
      'iOS: Settings > Privacy & Security > Location Services > Uber Assistant > Allow Location Access: Always.';

  @override
  String get errNoInternet =>
      'No internet connection detected. Please check Wi-Fi or mobile data.';

  @override
  String get errNoLocationPermission =>
      'The app currently is not functional because it has no location permission.';

  @override
  String get wipeData => 'Wipe app data';

  @override
  String get wipeConfirmTitle => 'Delete all app data?';

  @override
  String get wipeConfirmBody =>
      'This will remove saved language/theme, driver selection, server IP and any other stored preferences. The app will restart into setup.';

  @override
  String get delete => 'Delete';

  @override
  String get wipeDone => 'App data cleared.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGeneral => 'General';

  @override
  String get langSystem => 'System';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String get none => 'None';

  @override
  String get dailyReport => 'Daily report';

  @override
  String get dailyGains => 'Daily gains';

  @override
  String get completedTrips => 'Completed trips';

  @override
  String get driveTimeLabel => 'Drive time';

  @override
  String get breakTimeLabel => 'Break time';

  @override
  String get breakCountLabel => 'Breaks';

  @override
  String get tripHistory => 'Trip history';

  @override
  String get filter => 'Filter';

  @override
  String get filterToday => 'Today';

  @override
  String get filterWeek => 'This week';

  @override
  String get filterMonth => 'This month';

  @override
  String get filterYear => 'This year';

  @override
  String get sort => 'Sort';

  @override
  String get sortEarningsHighLow => 'Earnings high → low';

  @override
  String get sortEarningsLowHigh => 'Earnings low → high';

  @override
  String get sortCompleted => 'Completed first';

  @override
  String get sortCancelled => 'Cancelled first';

  @override
  String get status => 'Status';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get depart => 'Depart';

  @override
  String get arrive => 'Arrive';

  @override
  String get details => 'Details';

  @override
  String get takeABreak => 'Take a break';

  @override
  String get motivationTitle => 'Nice work!';

  @override
  String get openDialerError => 'Couldn\'t open dialer.';

  @override
  String get seedMockTitle => 'Load demo data';

  @override
  String get seedMockSubtitle =>
      'Preload realistic history and breaks so you can explore reports right away.';

  @override
  String get goalsTitle => 'Personal goals';

  @override
  String get setGoalsSubtitle => 'Adjust your daily targets.';

  @override
  String get editGoals => 'Edit goals';
}
