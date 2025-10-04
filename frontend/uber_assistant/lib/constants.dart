import 'package:flutter/material.dart';

class K {
  // sockets + timing
  static const wsDefault = 'ws://192.168.0.2:3000'; // change in Settings
  static const wsHeartbeatSeconds = 10;
  static const offerTimeoutSeconds = 20;
  static const arrivedBannerSeconds = 10;

  static const uberGray = Color(0xFFC0C0C8); // subtle border
  static const warningYellow = Color(0xFFFFC043);
  static const dangerRed = Color(0xFFF25138);

  // storage keys
  static const keySeenOnboarding = 'seen_onboarding';
  static const keyDriverId = 'driver_id';
  static const keyServerIp = 'server_ip';
  static const keyLanguage = 'language'; // 'system' | 'en' | 'nl'
  // ui
  static const double corner = 16;
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(corner));
  static const Color uberBlack = Color(0xFF000000);
  static const Color uberEbony = Color(0xFF0B0B0B);
  static const Color safetyBlue = Color(0xFF3A8DFF);
  static const Color successGreen = Color(0xFF22C55E);

  // keep legacy name used inside WebSocketService
  static const int updateIntervalSeconds = wsHeartbeatSeconds;
}
