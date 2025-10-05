import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

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
    Locale('nl')
  ];

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Uber Assistant'**
  String get homeTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'We process only the minimum data needed for the demo.'**
  String get privacyBody;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Hackathon demo to help earners make smarter choices.'**
  String get aboutBody;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Taking a break'**
  String get unavailable;

  /// No description provided for @statusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for customer requests…'**
  String get statusWaiting;

  /// No description provided for @statusBreak.
  ///
  /// In en, this message translates to:
  /// **'Turn the switch on when you are ready to receive requests.'**
  String get statusBreak;

  /// No description provided for @statusNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing going on currently'**
  String get statusNothing;

  /// No description provided for @queued.
  ///
  /// In en, this message translates to:
  /// **'Queued next trip'**
  String get queued;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeMode;

  /// No description provided for @serverIp.
  ///
  /// In en, this message translates to:
  /// **'Server IP'**
  String get serverIp;

  /// No description provided for @tripInTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get tripInTransit;

  /// No description provided for @imThere.
  ///
  /// In en, this message translates to:
  /// **'I’m there'**
  String get imThere;

  /// No description provided for @requestTitle.
  ///
  /// In en, this message translates to:
  /// **'New request'**
  String get requestTitle;

  /// No description provided for @requestTitleRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended request'**
  String get requestTitleRecommended;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// No description provided for @dropoff.
  ///
  /// In en, this message translates to:
  /// **'Drop-off'**
  String get dropoff;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @earningsLabel.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earningsLabel;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get skip;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Slide to accept'**
  String get accept;

  /// No description provided for @mins.
  ///
  /// In en, this message translates to:
  /// **'{minutes} mins'**
  String mins(Object minutes);

  /// No description provided for @expiresIn.
  ///
  /// In en, this message translates to:
  /// **'Expires in {seconds}s'**
  String expiresIn(Object seconds);

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'This app helps you earn smarter with timely offers and safe nudges.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Always on it'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'We notify you when there’s a good request nearby.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Balanced & safe'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'We nudge you to rest when needed and keep your data safe.'**
  String get onboardingBody3;

  /// No description provided for @permTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permTitle;

  /// No description provided for @permBody.
  ///
  /// In en, this message translates to:
  /// **'We need your location to find offers near you.'**
  String get permBody;

  /// No description provided for @permAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get permAllow;

  /// No description provided for @permAllowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Grant location while using the app. You can upgrade to “Allow all the time” in Settings for background operation.'**
  String get permAllowSubtitle;

  /// No description provided for @permGranted.
  ///
  /// In en, this message translates to:
  /// **'Location granted'**
  String get permGranted;

  /// No description provided for @checkAgain.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get checkAgain;

  /// No description provided for @permDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission required'**
  String get permDeniedTitle;

  /// No description provided for @permDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'The app can’t function without location. You can exit or grant the permission in Settings.'**
  String get permDeniedBody;

  /// No description provided for @exitApp.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitApp;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @allSetTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re all set!'**
  String get allSetTitle;

  /// No description provided for @allSetBody.
  ///
  /// In en, this message translates to:
  /// **'Let’s get ready and start receiving offers.'**
  String get allSetBody;

  /// No description provided for @letsGo.
  ///
  /// In en, this message translates to:
  /// **'Let’s go!'**
  String get letsGo;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @selectDriver.
  ///
  /// In en, this message translates to:
  /// **'Choose your driver'**
  String get selectDriver;

  /// No description provided for @selectDriverBody.
  ///
  /// In en, this message translates to:
  /// **'Pick your demo identity. You can change it later in Settings.'**
  String get selectDriverBody;

  /// No description provided for @permAlwaysBanner.
  ///
  /// In en, this message translates to:
  /// **'For background operation, allow location \"All the time\" in Settings.'**
  String get permAlwaysBanner;

  /// No description provided for @learnHow.
  ///
  /// In en, this message translates to:
  /// **'How to fix'**
  String get learnHow;

  /// No description provided for @locationHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable \"Allow all the time\"'**
  String get locationHelpTitle;

  /// No description provided for @locationHelpBody.
  ///
  /// In en, this message translates to:
  /// **'To receive offers in the background, enable background location.'**
  String get locationHelpBody;

  /// No description provided for @locationHelpAndroid.
  ///
  /// In en, this message translates to:
  /// **'Android: Open the app’s settings > Permissions > Location, then select \"Allow all the time\".'**
  String get locationHelpAndroid;

  /// No description provided for @locationHelpiOS.
  ///
  /// In en, this message translates to:
  /// **'iOS: Settings > Privacy & Security > Location Services > Uber Assistant > Allow Location Access: Always.'**
  String get locationHelpiOS;

  /// No description provided for @errNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection detected. Please check Wi-Fi or mobile data.'**
  String get errNoInternet;

  /// No description provided for @errNoLocationPermission.
  ///
  /// In en, this message translates to:
  /// **'The app currently is not functional because it has no location permission.'**
  String get errNoLocationPermission;

  /// No description provided for @wipeData.
  ///
  /// In en, this message translates to:
  /// **'Wipe app data'**
  String get wipeData;

  /// No description provided for @wipeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all app data?'**
  String get wipeConfirmTitle;

  /// No description provided for @wipeConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will remove saved language/theme, driver selection, server IP and any other stored preferences. The app will restart into setup.'**
  String get wipeConfirmBody;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @wipeDone.
  ///
  /// In en, this message translates to:
  /// **'App data cleared.'**
  String get wipeDone;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @langSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get langSystem;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @dailyReport.
  ///
  /// In en, this message translates to:
  /// **'Daily report'**
  String get dailyReport;

  /// No description provided for @dailyGains.
  ///
  /// In en, this message translates to:
  /// **'Daily gains'**
  String get dailyGains;

  /// No description provided for @completedTrips.
  ///
  /// In en, this message translates to:
  /// **'Completed trips'**
  String get completedTrips;

  /// No description provided for @driveTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Drive time'**
  String get driveTimeLabel;

  /// No description provided for @breakTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Break time'**
  String get breakTimeLabel;

  /// No description provided for @breakCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Breaks'**
  String get breakCountLabel;

  /// No description provided for @tripHistory.
  ///
  /// In en, this message translates to:
  /// **'Trip history'**
  String get tripHistory;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @filterToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get filterToday;

  /// No description provided for @filterWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get filterWeek;

  /// No description provided for @filterMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get filterMonth;

  /// No description provided for @filterYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get filterYear;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @sortEarningsHighLow.
  ///
  /// In en, this message translates to:
  /// **'Earnings high → low'**
  String get sortEarningsHighLow;

  /// No description provided for @sortEarningsLowHigh.
  ///
  /// In en, this message translates to:
  /// **'Earnings low → high'**
  String get sortEarningsLowHigh;

  /// No description provided for @sortCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed first'**
  String get sortCompleted;

  /// No description provided for @sortCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled first'**
  String get sortCancelled;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @depart.
  ///
  /// In en, this message translates to:
  /// **'Depart'**
  String get depart;

  /// No description provided for @arrive.
  ///
  /// In en, this message translates to:
  /// **'Arrive'**
  String get arrive;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @takeABreak.
  ///
  /// In en, this message translates to:
  /// **'Take a break'**
  String get takeABreak;

  /// No description provided for @motivationTitle.
  ///
  /// In en, this message translates to:
  /// **'Nice work!'**
  String get motivationTitle;

  /// No description provided for @openDialerError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open dialer.'**
  String get openDialerError;

  /// No description provided for @seedMockTitle.
  ///
  /// In en, this message translates to:
  /// **'Load demo data'**
  String get seedMockTitle;

  /// No description provided for @seedMockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Preload realistic history and breaks so you can explore reports right away.'**
  String get seedMockSubtitle;
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
      <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
