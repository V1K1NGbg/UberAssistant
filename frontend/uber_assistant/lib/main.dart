import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'theme.dart';
import 'providers/app_state.dart';
import 'services/local_data_service.dart';
import 'services/notification_service.dart';
import 'services/websocket_service.dart';
import 'services/permission_service.dart';
import 'services/location_service.dart';

import 'pages/home_page.dart';
import 'pages/onboarding.dart';
import 'pages/settings_page.dart';
import 'pages/privacy_page.dart';
import 'pages/about_page.dart';
import 'pages/location_permission_help.dart';
import 'pages/history_page.dart';
import 'pages/heatmap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final data = LocalDataService();
  final notif = NotificationService();
  final ws = WebSocketService();
  final perms = PermissionService();
  final loc = LocationService();

  await notif.init();

  final app = AppState(data, notif, ws, perms, loc);
  await app.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => app,
      child: const UberAssistantApp(),
    ),
  );
}

class UberAssistantApp extends StatelessWidget {
  const UberAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    final systemLang = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    Locale resolvedLocale;
    switch (app.language) {
      case AppLanguage.en:
        resolvedLocale = const Locale('en');
        break;
      case AppLanguage.nl:
        resolvedLocale = const Locale('nl');
        break;
      case AppLanguage.system:
        resolvedLocale = systemLang.startsWith('nl') ? const Locale('nl') : const Locale('en');
        break;
    }

    ThemeMode themeMode;
    switch (app.themeMode) {
      case AppThemeMode.system:
        themeMode = ThemeMode.system; break;
      case AppThemeMode.light:
        themeMode = ThemeMode.light; break;
      case AppThemeMode.dark:
        themeMode = ThemeMode.dark; break;
    }

    final needsSetup = !app.isDriverSelected || !app.hasMinimumLocationPermission;

    return MaterialApp(
      title: 'Uber Assistant',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themeMode,
      locale: resolvedLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {
        '/': (_) => needsSetup ? const OnboardingPage() : const HomePage(),
        '/home': (_) => const HomePage(),
        '/settings': (_) => const SettingsPage(),
        '/privacy': (_) => const PrivacyPage(),
        '/about': (_) => const AboutPage(),
        '/location-help': (_) => const LocationPermissionHelpPage(),
        '/history': (_) => const HistoryPage(),
        '/heatmap': (_) => const RideActivityHeatMapPage(),
      },
    );
  }
}
