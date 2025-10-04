// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appName => 'Slim Verdienen';

  @override
  String get onboardingTitle1 => 'Rijd slimmer';

  @override
  String get onboardingBody1 =>
      'Deze app helpt bepalen wanneer je een rit aanneemt, wanneer je rust pakt en hoe je je inkomsten maximaliseert.';

  @override
  String get onboardingTitle2 => 'Realtime aanbiedingen';

  @override
  String get onboardingBody2 =>
      'Krijg tijdige aanbiedingen met heldere info: ophaalpunt, bestemming, duur, verdiensten en advies van het model.';

  @override
  String get onboardingTitle3 => 'Jij houdt controle';

  @override
  String get onboardingBody3 =>
      'Zet \"Beschikbaar\" aan wanneer je klaar bent. We houden je verbonden en geven direct meldingen.';

  @override
  String get permTitle => 'Benodigde rechten';

  @override
  String get permBody =>
      'We gebruiken je locatie om je te koppelen aan ritten in de buurt en je status te delen met de server.';

  @override
  String get permAllow => 'Locatie toestaan';

  @override
  String get permDeniedTitle => 'Toestemming vereist';

  @override
  String get permDeniedBody =>
      'Zonder locatie werkt de app niet. Je kunt toestemming geven via Instellingen.';

  @override
  String get openSettings => 'Open instellingen';

  @override
  String get exitApp => 'Afsluiten';

  @override
  String get allSetTitle => 'Alles klaar';

  @override
  String get allSetBody => 'Zet Beschikbaar aan om aanbiedingen te ontvangen.';

  @override
  String get letsGo => 'Starten';

  @override
  String get homeTitle => 'Slim Verdienen';

  @override
  String get available => 'Beschikbaar';

  @override
  String get unavailable => 'Pauze';

  @override
  String get toggleAvailable => 'Online gaan';

  @override
  String get toggleUnavailable => 'Offline gaan';

  @override
  String get statusWaiting => 'Wachten op een klantaanvraag…';

  @override
  String get statusBreak =>
      'Zet de schakelaar op Beschikbaar om aanbiedingen te ontvangen.';

  @override
  String get statusNothing => 'Momenteel geen activiteit';

  @override
  String get earningsLabel => 'Verdiensten';

  @override
  String get durationLabel => 'Duur';

  @override
  String mins(Object mins) {
    return '$mins min';
  }

  @override
  String get adviceYes => 'Aanbevolen';

  @override
  String get adviceNo => 'Niet aanbevolen';

  @override
  String get rating => 'Beoordeling';

  @override
  String get customer => 'Klant';

  @override
  String get pickup => 'Ophaalpunt';

  @override
  String get dropoff => 'Bestemming';

  @override
  String get coords => 'Coördinaten';

  @override
  String get accept => 'Accepteren';

  @override
  String get skip => 'Overslaan';

  @override
  String expiresIn(Object secs) {
    return 'Verloopt over ${secs}s';
  }

  @override
  String get requestTitle => 'Nieuwe aanvraag';

  @override
  String get requestTitleRecommended => 'Aanbevolen aanvraag';

  @override
  String get idMissing => 'Klant niet gevonden';

  @override
  String get imThere => 'Ik ben er';

  @override
  String get cancel => 'Annuleren';

  @override
  String get queued => 'Gekoppeld';

  @override
  String get tripInTransit => 'Onderweg';

  @override
  String get arrived => 'Bestemming bereikt';

  @override
  String get settings => 'Instellingen';

  @override
  String get language => 'Taal';

  @override
  String get languageSystem => 'Systeem';

  @override
  String get languageEnglish => 'Engels';

  @override
  String get languageDutch => 'Nederlands';

  @override
  String get driver => 'Bestuurder';

  @override
  String get serverIp => 'Server IP';

  @override
  String get about => 'Over';

  @override
  String get privacy => 'Privacybeleid';

  @override
  String get aboutBody =>
      'Slim Verdienen is een hackathon-demo die chauffeurs helpt slimmere en veiligere keuzes te maken.';

  @override
  String get privacyBody =>
      'Deze demo gebruikt je locatie lokaal en stuurt die via de LAN-WebSocket naar je server.';
}
