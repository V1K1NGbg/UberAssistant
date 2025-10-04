import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:uber_assistant/l10n/app_localizations.dart';
import 'constants.dart';
import 'theme.dart';
import 'pages/home_page.dart';
import 'pages/onboarding.dart';
import 'pages/settings_page.dart';
import 'pages/privacy_page.dart';
import 'pages/about_page.dart';
import 'providers/app_state.dart';
import 'services/local_data_service.dart';
import 'services/notification_service.dart';
import 'services/websocket_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final data = LocalDataService();
  final notif = NotificationService();
  final ws = WebSocketService();
  await notif.init();

  final appState = AppState(data, notif, ws);
  await appState.init();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => appState),
    ],
    child: const UberAssistantApp(),
  ));
}

class UberAssistantApp extends StatelessWidget {
  const UberAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    Locale? locale;
    switch (app.language) {
      case AppLanguage.en:
        locale = const Locale('en');
        break;
      case AppLanguage.nl:
        locale = const Locale('nl');
        break;
      case AppLanguage.system:
        locale = PlatformDispatcher.instance.locale.languageCode.startsWith('nl')
            ? const Locale('nl')
            : const Locale('en');
        break;
    }

    return MaterialApp(
      title: 'Uber Assistant',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {
        '/': (_) => app.seenOnboarding ? const HomePage() : const OnboardingPage(),
        '/home': (_) => const HomePage(),
        '/settings': (_) => const SettingsPage(),
        '/privacy': (_) => const PrivacyPage(),
        '/about': (_) => const AboutPage(),
      },
    );
  }
}
