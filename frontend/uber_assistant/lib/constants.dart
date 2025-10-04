import 'package:flutter/material.dart';

class K {
  // sockets + timing
  static const wsDefault = 'ws://192.168.0.2:3000'; // change in Settings
  static const wsHeartbeatSeconds = 10;
  static const offerTimeoutSeconds = 20;
  static const arrivedBannerSeconds = 2;

  // safety / emergency
  static const String emergencyNumber = '112';
  static const double emergencyButtonSize = 56;

  // motivation
  static const int motivationIntervalMinutes = 45; // summed drive time trigger

  // breaks
  static const int minBreakMinutesToCount = 5;

  // daily default goals (tweak freely)
  static const double dailyGoalEarnings = 60.0;     // €
  static const int dailyGoalTrips = 10;
  static const int dailyGoalDriveMinutes = 180;     // 3h
  static const int dailyGoalBreakMinutes = 45;      // 45m
  static const int dailyGoalBreaks = 3;

  static const uberGray = Color(0xFFC0C0C8); // subtle border
  static const warningYellow = Color(0xFFFFC043);
  static const dangerRed = Color(0xFFF25138);

  // storage keys
  static const keySeenOnboarding = 'seen_onboarding';
  static const keyDriverId = 'driver_id';
  static const keyServerIp = 'server_ip';
  static const keyLanguage = 'language'; // 'system' | 'en' | 'nl'
  static const String defaultServerIp = '192.168.8.103';

  // ui
  static const double corner = 16;
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(corner));
  static const Color uberBlack = Color(0xFF000000);
  static const Color uberEbony = Color(0xFF0B0B0B);
  static const Color safetyBlue = Color(0xFF3A8DFF);
  static const Color successGreen = Color(0xFF22C55E);
  static const Color warnOrange = Color(0xFFFFA500);
  static const Color errorRed = Color(0xFFE11D48);

  // colorful, accessible progress colors (friendly in light/dark; color-blind aware)
  static const Color progressBlue = Color(0xFF0C7BDC);   // data-safe blue
  static const Color progressGreen = Color(0xFF22C55E);  // success green
  static const Color progressOrange = Color(0xFFF59E0B); // darker amber for light mode
  static const Color progressPurple = Color(0xFF7C3AED); // purple
  static const Color progressRed = Color(0xFFE11D48);    // error/red

  // keep legacy name used inside WebSocketService
  static const int updateIntervalSeconds = wsHeartbeatSeconds;
  static const int wsPingSeconds = 10; // send update every 10s
}
