// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get homeTitle => 'Uber Assistant';

  @override
  String get settings => 'Instellingen';

  @override
  String get about => 'Over';

  @override
  String get privacy => 'Privacybeleid';

  @override
  String get privacyBody =>
      'We verwerken alleen de minimale gegevens die nodig zijn voor de demo.';

  @override
  String get aboutBody =>
      'Hackathon-demo om rijders te helpen slimmer te kiezen.';

  @override
  String get available => 'Beschikbaar';

  @override
  String get unavailable => 'Pauze';

  @override
  String get statusWaiting => 'Wachten op klantaanvragen…';

  @override
  String get statusBreak =>
      'Zet de schakelaar aan wanneer je klaar bent om aanvragen te ontvangen.';

  @override
  String get statusNothing => 'Momenteel geen activiteiten';

  @override
  String get queued => 'Volgende rit in wachtrij';

  @override
  String get cancel => 'Annuleren';

  @override
  String get ok => 'OK';

  @override
  String get dismiss => 'Sluiten';

  @override
  String get driver => 'Bestuurder';

  @override
  String get language => 'Taal';

  @override
  String get themeMode => 'Thema';

  @override
  String get serverIp => 'Server-IP';

  @override
  String get tripInTransit => 'Onderweg';

  @override
  String get imThere => 'Ik ben er';

  @override
  String get requestTitle => 'Nieuwe aanvraag';

  @override
  String get requestTitleRecommended => 'Aanbevolen aanvraag';

  @override
  String get customer => 'Klant';

  @override
  String get pickup => 'Ophaalpunt';

  @override
  String get dropoff => 'Bestemming';

  @override
  String get durationLabel => 'Duur';

  @override
  String get earningsLabel => 'Verdiensten';

  @override
  String get skip => 'Negeren';

  @override
  String get accept => 'Schuif om te accepteren';

  @override
  String mins(Object minutes) {
    return '$minutes min';
  }

  @override
  String expiresIn(Object seconds) {
    return 'Verloopt over ${seconds}s';
  }

  @override
  String get onboardingTitle1 => 'Welkom';

  @override
  String get onboardingBody1 =>
      'Deze app helpt je slimmer te verdienen met tijdige aanbiedingen.';

  @override
  String get onboardingTitle2 => 'Altijd paraat';

  @override
  String get onboardingBody2 =>
      'We sturen meldingen wanneer er een goede rit in de buurt is.';

  @override
  String get onboardingTitle3 => 'Balans & veiligheid';

  @override
  String get onboardingBody3 =>
      'We geven pauze-tips en gaan veilig met je gegevens om.';

  @override
  String get permTitle => 'Machtigingen';

  @override
  String get permBody =>
      'We hebben je locatie nodig om ritten in de buurt te vinden.';

  @override
  String get permAllow => 'Sta locatie toe';

  @override
  String get permAllowSubtitle =>
      'Geef toestemming ‘Tijdens gebruik’. Je kunt later in Instellingen ‘Altijd toestaan’ kiezen voor achtergrondgebruik.';

  @override
  String get permGranted => 'Locatie toegestaan';

  @override
  String get checkAgain => 'Opnieuw controleren';

  @override
  String get permDeniedTitle => 'Toestemming vereist';

  @override
  String get permDeniedBody =>
      'De app werkt niet zonder locatie. Je kunt afsluiten of in Instellingen toestemming geven.';

  @override
  String get exitApp => 'Afsluiten';

  @override
  String get openSettings => 'Open Instellingen';

  @override
  String get allSetTitle => 'Je bent klaar!';

  @override
  String get allSetBody =>
      'Kies een bestuurder en begin aanvragen te ontvangen.';

  @override
  String get letsGo => 'Starten';

  @override
  String get next => 'Volgende';

  @override
  String get back => 'Terug';

  @override
  String get selectDriver => 'Kies je bestuurder';

  @override
  String get selectDriverBody =>
      'Kies je demo-identiteit. Later te wijzigen bij Instellingen.';

  @override
  String get permAlwaysBanner =>
      'Voor werking op de achtergrond: geef \"Altijd toestaan\" voor locatie.';

  @override
  String get learnHow => 'Zo los je dit op';

  @override
  String get locationHelpTitle => '\"Altijd toestaan\" inschakelen';

  @override
  String get locationHelpBody =>
      'Schakel achtergrondlocatie in om ook op de achtergrond aanvragen te ontvangen.';

  @override
  String get locationHelpAndroid =>
      'Android: App-instellingen > Machtigingen > Locatie > \"Altijd toestaan\".';

  @override
  String get locationHelpiOS =>
      'iOS: Instellingen > Privacy en beveiliging > Locatievoorzieningen > Uber Assistant > Toegang: Altijd.';

  @override
  String get errNoInternet =>
      'Geen internetverbinding. Controleer je wifi of mobiele data.';

  @override
  String get errNoLocationPermission =>
      'De app werkt momenteel niet omdat er geen locatietoestemming is.';

  @override
  String get wipeData => 'Appgegevens wissen';

  @override
  String get wipeConfirmTitle => 'Alle appgegevens verwijderen?';

  @override
  String get wipeConfirmBody =>
      'Dit verwijdert je taal/thema, bestuurder, server-IP en alle andere voorkeuren. De app start opnieuw in de setup.';

  @override
  String get delete => 'Verwijderen';

  @override
  String get wipeDone => 'Appgegevens gewist.';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get settingsGeneral => 'Algemeen';

  @override
  String get langSystem => 'Systeem';

  @override
  String get theme => 'Thema';

  @override
  String get themeSystem => 'Systeem';

  @override
  String get themeLight => 'Licht';

  @override
  String get themeDark => 'Donker';

  @override
  String get edit => 'Bewerken';

  @override
  String get save => 'Opslaan';

  @override
  String get none => 'Geen';

  @override
  String get dailyReport => 'Dagrapport';

  @override
  String get dailyGains => 'Opbrengst';

  @override
  String get completedTrips => 'Voltooide ritten';

  @override
  String get driveTimeLabel => 'Rijtijd';

  @override
  String get breakTimeLabel => 'Pauzetijd';

  @override
  String get breakCountLabel => 'Pauzes';

  @override
  String get tripHistory => 'Ritgeschiedenis';

  @override
  String get filter => 'Filter';

  @override
  String get filterToday => 'Vandaag';

  @override
  String get filterWeek => 'Deze week';

  @override
  String get filterMonth => 'Deze maand';

  @override
  String get filterYear => 'Dit jaar';

  @override
  String get sort => 'Sorteren';

  @override
  String get sortEarningsHighLow => 'Verdiensten hoog → laag';

  @override
  String get sortEarningsLowHigh => 'Verdiensten laag → hoog';

  @override
  String get sortCompleted => 'Eerst voltooid';

  @override
  String get sortCancelled => 'Eerst geannuleerd';

  @override
  String get status => 'Status';

  @override
  String get statusCompleted => 'Voltooid';

  @override
  String get statusCancelled => 'Geannuleerd';

  @override
  String get depart => 'Vertrek';

  @override
  String get arrive => 'Aankomst';

  @override
  String get details => 'Details';

  @override
  String get takeABreak => 'Neem pauze';

  @override
  String get motivationTitle => 'Goed bezig!';

  @override
  String get openDialerError => 'Kon de telefoonapp niet openen.';
}
