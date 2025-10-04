// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Uber Assistant';

  @override
  String get onboardingTitle1 => 'Drive smarter';

  @override
  String get onboardingBody1 =>
      'This app helps you decide when to accept a request, when to rest, and how to maximise earnings.';

  @override
  String get onboardingTitle2 => 'Real-time offers';

  @override
  String get onboardingBody2 =>
      'Get timely offers with clear info: pickup, dropoff, duration, earnings and model advice.';

  @override
  String get onboardingTitle3 => 'Stay in control';

  @override
  String get onboardingBody3 =>
      'Switch \"Available\" when you’re ready. We’ll keep you connected and notify you instantly.';

  @override
  String get permTitle => 'Permissions we need';

  @override
  String get permBody =>
      'We use your location to connect you with nearby requests and to share status with the server.';

  @override
  String get permAllow => 'Allow location';

  @override
  String get permDeniedTitle => 'Permission needed';

  @override
  String get permDeniedBody =>
      'This app can’t work without location. You can grant permission in Settings.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get exitApp => 'Exit';

  @override
  String get allSetTitle => 'You’re all set';

  @override
  String get allSetBody => 'Switch to Available to start receiving offers.';

  @override
  String get letsGo => 'Let’s go';

  @override
  String get homeTitle => 'Uber Assistant';

  @override
  String get available => 'Available';

  @override
  String get unavailable => 'Taking a break';

  @override
  String get toggleAvailable => 'Go online';

  @override
  String get toggleUnavailable => 'Go offline';

  @override
  String get statusWaiting => 'Waiting for a customer request…';

  @override
  String get statusBreak =>
      'Turn the switch to Available to start receiving offers.';

  @override
  String get statusNothing => 'Nothing going on right now';

  @override
  String get earningsLabel => 'Earnings';

  @override
  String get durationLabel => 'Duration';

  @override
  String mins(Object mins) {
    return '$mins min';
  }

  @override
  String get adviceYes => 'Recommended';

  @override
  String get adviceNo => 'Not recommended';

  @override
  String get rating => 'Rating';

  @override
  String get customer => 'Customer';

  @override
  String get pickup => 'Pickup';

  @override
  String get dropoff => 'Drop-off';

  @override
  String get coords => 'Coordinates';

  @override
  String get accept => 'Accept';

  @override
  String get skip => 'Skip';

  @override
  String expiresIn(Object secs) {
    return 'Expires in ${secs}s';
  }

  @override
  String get requestTitle => 'New request';

  @override
  String get requestTitleRecommended => 'Recommended request';

  @override
  String get idMissing => 'Customer not found';

  @override
  String get imThere => 'I’m there';

  @override
  String get cancel => 'Cancel';

  @override
  String get queued => 'Queued';

  @override
  String get tripInTransit => 'In transit';

  @override
  String get arrived => 'Location reached';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageDutch => 'Nederlands';

  @override
  String get driver => 'Driver';

  @override
  String get serverIp => 'Server IP';

  @override
  String get about => 'About';

  @override
  String get privacy => 'Privacy policy';

  @override
  String get aboutBody =>
      'Uber Assistant is a hackathon demo built to help earners make smarter, safer choices.';

  @override
  String get privacyBody =>
      'This demo uses your location locally and sends it to your server over the LAN WebSocket.';
}
