import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/driver.dart';
import '../models/customer.dart';
import '../models/trip_record.dart';
import '../models/break_session.dart';
import '../providers/app_state.dart';
import '../constants.dart';

class LocalDataService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<Map<String, Customer>> loadCustomers() async {
    final raw = await rootBundle.loadString('assets/data/customers.json');
    final List list = jsonDecode(raw);
    final map = <String, Customer>{};
    for (final e in list) {
      final c = Customer(
        id: e['customer_id'] as String,
        name: e['customer_name'] as String,
        rating: (e['customer_rating'] as num).toDouble(),
      );
      map[c.id] = c;
    }
    return map;
  }

  Future<Map<String, Driver>> loadDrivers() async {
    final raw = await rootBundle.loadString('assets/data/drivers.json');
    final List list = jsonDecode(raw);
    final map = <String, Driver>{};
    for (final e in list) {
      final d = Driver(
        id: e['driver_id'] as String,
        name: e['driver_name'] as String,
        rating: (e['driver_rating'] as num).toDouble(),
      );
      map[d.id] = d;
    }
    return map;
  }

  // messages (motivation)
  Future<List<String>> loadMotivationMessages() async {
    try {
      final raw = await rootBundle.loadString('assets/data/messages.json');
      final List list = jsonDecode(raw);
      return list.cast<String>();
    } catch (_) {
      return const [];
    }
  }

  // persistence
  Future<void> setSeenOnboarding(bool v) async => _prefs.setBool('seenOnboarding', v);
  Future<bool> getSeenOnboarding() async => _prefs.getBool('seenOnboarding') ?? false;

  Future<void> setLanguage(AppLanguage l) async => _prefs.setString('language', l.name);
  Future<AppLanguage> getLanguage() async {
    final v = _prefs.getString('language');
    return AppLanguage.values.firstWhere((e) => e.name == v, orElse: () => AppLanguage.system);
  }

  Future<void> setThemeMode(AppThemeMode m) async => _prefs.setString('themeMode', m.name);
  Future<AppThemeMode> getThemeMode() async {
    final v = _prefs.getString('themeMode');
    return AppThemeMode.values.firstWhere((e) => e.name == v, orElse: () => AppThemeMode.system);
  }

  Future<void> setServerIp(String v) async => _prefs.setString('serverIp', v);
  Future<String> getServerIp({String defaultValue = K.defaultServerIp}) async =>
      _prefs.getString('serverIp') ?? defaultValue;

  Future<void> setDriver(Driver d) async => _prefs.setString('driverId', d.id);
  Future<Driver?> getDriver() async {
    final id = _prefs.getString('driverId');
    if (id == null) return null;
    final drivers = await loadDrivers();
    return drivers[id];
  }

  Future<List<TripRecord>> loadTripHistory() async {
    final raw = _prefs.getString('tripHistory');
    if (raw == null) return [];
    final List list = jsonDecode(raw);
    return list.map((e) => TripRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveTripHistory(List<TripRecord> items) async {
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString('tripHistory', raw);
  }

  Future<List<BreakSession>> loadBreakSessions() async {
    final raw = _prefs.getString('breakSessions');
    if (raw == null) return [];
    final List list = jsonDecode(raw);
    return list.map((e) => BreakSession.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveBreakSessions(List<BreakSession> items) async {
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString('breakSessions', raw);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
