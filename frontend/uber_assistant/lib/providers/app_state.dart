import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../models/driver.dart';
import '../models/customer.dart';
import '../models/customer_request.dart';
import '../models/trip.dart';
import '../models/trip_record.dart';
import '../models/break_session.dart';
import '../services/local_data_service.dart';
import '../services/notification_service.dart';
import '../services/websocket_service.dart';
import '../services/permission_service.dart';
import '../services/location_service.dart';
import '../constants.dart';

enum AppLanguage { system, en, nl }
enum AppThemeMode { system, light, dark }

class DailyStats {
  final double earnings;
  final int completedTrips;
  final double driveMinutes;
  final double breakMinutes;
  final int breakCount;
  DailyStats(
      this.earnings,
      this.completedTrips,
      this.driveMinutes,
      this.breakMinutes,
      this.breakCount,
      );
}

class AppState extends ChangeNotifier {
  final LocalDataService _data;
  final NotificationService _notif;
  final WebSocketService _ws;
  final PermissionService _perms;
  final LocationService _loc;

  AppState(this._data, this._notif, this._ws, this._perms, this._loc);

  // expose
  LocalDataService get dataService => _data;
  NotificationService get notifService => _notif;
  WebSocketService get wsService => _ws;
  PermissionService get permsService => _perms;
  LocationService get locService => _loc;

  // persisted
  AppLanguage language = AppLanguage.system;
  AppThemeMode themeMode = AppThemeMode.system;
  String serverIp = K.defaultServerIp;
  Driver? driver;

  // personal goals (persisted)
  double goalEarnings = K.dailyGoalEarnings;
  int goalTrips = K.dailyGoalTrips;
  int goalDriveMinutes = K.dailyGoalDriveMinutes;
  int goalBreakMinutes = K.dailyGoalBreakMinutes;
  int goalBreaks = K.dailyGoalBreaks;

  // runtime
  bool available = false;
  bool seenOnboarding = false;
  bool get isDriverSelected => driver != null;
  bool get hasMinimumLocationPermission => _perms.hasWhenInUsePermissionCache;

  // Location services (GPS) state
  bool locationServicesOn = true;
  StreamSubscription<bool>? _locServiceSub;

  Map<String, Driver> drivers = {};
  Map<String, Customer> customers = {};
  CustomerRequest? pendingOffer;
  Trip? activeTrip;
  Trip? queuedTrip;

  // history & breaks & messages
  List<TripRecord> _history = [];
  List<BreakSession> _breaks = [];
  double _accumulatedMinutesForMotivation = 0;
  List<String> _motivationMessages = [];
  String? motivationalMessage;

  // connectivity/error
  String? lastError;
  void setError(String? e) {
    lastError = e;
    notifyListeners();
  }

  StreamSubscription? _connSub;
  bool hasNetwork = true;

  // telemetry
  Timer? _telemetryTimer;
  Timer? _watchdogTimer;
  DateTime? _lastTelemetrySentAt;

  DateTime? _lastDropoffAt;
  DateTime? _breakStartAt;

  Future<void> init() async {
    await _data.init();

    language = await _data.getLanguage();
    themeMode = await _data.getThemeMode();
    serverIp = await _data.getServerIp(defaultValue: K.defaultServerIp);
    driver = await _data.getDriver();

    drivers = await _data.loadDrivers();
    customers = await _data.loadCustomers();

    // goals
    final g = await _data.getGoals();
    goalEarnings = g.$1;
    goalTrips = g.$2;
    goalDriveMinutes = g.$3;
    goalBreakMinutes = g.$4;
    goalBreaks = g.$5;

    _history = await _data.loadTripHistory();
    _breaks = await _data.loadBreakSessions();
    _motivationMessages = await _data.loadMotivationMessages();

    await _perms.refreshStatus();

    // location services state + subscription
    locationServicesOn = await _loc.isServiceEnabled();
    _locServiceSub = _loc.onServiceStatusChanged().listen((on) async {
      locationServicesOn = on;
      if (!on && available) {
        // Lost while online — force offline and alert
        available = false;
        _stopTimers();
        try {
          await _ws.deregister();
        } catch (_) {}
        await _notif.showAlert(
          title: 'Location services are OFF',
          body:
          'Turn on Location Services (GPS) to stay online. Open settings to enable it.',
        );
        await _notif.stopOnlineService();
        setError('Location services are OFF.');
      } else {
        if (lastError != null &&
            lastError!.toLowerCase().contains('location services')) {
          setError(null);
        }
      }
      notifyListeners();
    });

    // connectivity subscription + initial check (fix false "no wifi" on first open)
    _connSub = Connectivity().onConnectivityChanged.listen((_) async {
      final ok = await InternetConnection().hasInternetAccess;
      hasNetwork = ok;
      if (!ok) {
        setError('No internet connection detected.');
      } else {
        if (lastError != null && lastError!.contains('internet')) {
          setError(null);
        }
      }
      notifyListeners();
    });
    // initial check now
    hasNetwork = await InternetConnection().hasInternetAccess;
    if (!hasNetwork) setError('No internet connection detected.');
    notifyListeners();

    _ws.onOffer = (req) async {
      pendingOffer = req;
      await _notif.showOffer(
        title: 'New offer',
        body: '${req.from.address ?? 'From'} – ${req.to.address ?? 'To'}',
      );
      notifyListeners();
    };
    _ws.onError = (err) {
      setError(err);
    };
    _ws.onDisconnected = () {
      // server closed or socket died: force offline
      if (available) {
        available = false;
        _stopTimers();
        notifyListeners();
      }
    };
  }

  // public wrappers for permission actions
  Future<PermissionStatus> requestWhenInUse() => _perms.requestWhenInUse();
  Future<void> openAppSettings() => _perms.openAppSettingsScreen();

  Future<void> setSeenOnboarding() async {
    seenOnboarding = true;
    await _data.setSeenOnboarding(true);
    notifyListeners();
  }

  Future<void> setDriver(Driver d) async {
    final reRegister = available && driver?.id != d.id;
    driver = d;
    await _data.setDriver(d);
    notifyListeners();
    if (reRegister) {
      await _ws.deregister();
      await Future.delayed(const Duration(milliseconds: 150));
      final ok = await _connectIfAvailable();
      if (ok) {
        await _registerWithCoords();
      }
    }
  }

  Future<void> setLanguage(AppLanguage l) async {
    language = l;
    await _data.setLanguage(l);
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode m) async {
    themeMode = m;
    await _data.setThemeMode(m);
    notifyListeners();
  }

  Future<void> setServerIp(String v) async {
    serverIp = v.trim();
    await _data.setServerIp(serverIp);
    notifyListeners();
    if (available) {
      try {
        await _ws.reconnect('ws://$serverIp:3000');
        // ensure foreground/ongoing is active for the reconnected session
        await _notif.startOnlineService();
        await _registerWithCoords();
      } catch (_) {
        setError('Could not reach server at $serverIp. Check IP in Settings.');
        available = false;
        _stopTimers();
        notifyListeners();
      }
    }
  }

  /// called by the UI when toggling ON; returns false if we failed and reverted
  Future<bool> tryGoOnline() async {
    if (!isDriverSelected) {
      setError('Select a driver first.');
      return false;
    }
    if (!_perms.hasWhenInUsePermissionCache) {
      setError('Location permission required.');
      return false;
    }
    if (!locationServicesOn) {
      setError('Location services are OFF. Enable GPS to go online.');
      return false;
    }

    // If we were on a break, close it now (if long enough)
    _finishBreakIfAny();

    available = true;
    notifyListeners();

    final ok = await _connectIfAvailable();
    if (!ok) {
      // failed: ensure any foreground/notification is not running
      await _notif.stopOnlineService();
      available = false;
      notifyListeners();
      return false;
    }
    await _registerWithCoords();
    _startTimers();
    return true;
  }

  Future<void> setAvailable(bool v) async {
    if (!v) {
      // turning off
      if (available && _breakStartAt == null) {
        _breakStartAt = DateTime.now(); // start break
      }
      available = false;
      notifyListeners();
      _stopTimers();
      try {
        await _ws.deregister();
      } catch (_) {}
      await _notif.stopOnlineService();
      return;
    }
    // turning on should be via tryGoOnline (to handle failures)
    await tryGoOnline();
  }

  Future<bool> _connectIfAvailable() async {
    if (!available || driver == null) return false;
    try {
      await _ws.connect('ws://$serverIp:3000', driverId: driver!.id);
      // only after successful connect start the foreground/ongoing notification
      await _notif.startOnlineService();
      return true;
    } catch (_) {
      setError('Could not reach server at $serverIp. Check IP in Settings.');
      return false;
    }
  }

  // === timers / telemetry ===
  void _startTimers() {
    _telemetryTimer?.cancel();
    _telemetryTimer =
        Timer.periodic(const Duration(seconds: K.wsPingSeconds), (_) async {
          await _sendTelemetryUpdate();
        });
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!available) return;
      if (_lastTelemetrySentAt == null) return;
      if (DateTime.now().difference(_lastTelemetrySentAt!).inSeconds > 60) {
        // server would assume deregistered; flip off locally too
        available = false;
        _stopTimers();
        setError('Connection lost (no heartbeat > 60s).');
        notifyListeners();
      }
    });
  }

  void _stopTimers() {
    _telemetryTimer?.cancel();
    _telemetryTimer = null;
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
  }

  Future<void> _registerWithCoords() async {
    final pos = await _loc.getPositionOrNull();
    final rest = _computeRestMinutes();
    await _ws.sendRegister(lat: pos?.lat, lon: pos?.lon, restMinutes: rest);
    _lastTelemetrySentAt = DateTime.now();
  }

  Future<void> _sendTelemetryUpdate() async {
    await _perms.refreshStatus();

    // permission revoked mid-session — stop & alert
    if (!_perms.hasWhenInUsePermissionCache) {
      if (available) {
        available = false;
        _stopTimers();
        try {
          await _ws.deregister();
        } catch (_) {}
        await _notif.showAlert(
          title: 'Location permission lost',
          body:
          'The app cannot function without location permission. Open settings to enable it.',
        );
        await _notif.stopOnlineService();
        setError('Location permission revoked.');
        notifyListeners();
      }
      return;
    }

    // services disabled mid-session — stop & alert
    final servicesOn = await _loc.isServiceEnabled();
    locationServicesOn = servicesOn;
    if (!servicesOn) {
      if (available) {
        available = false;
        _stopTimers();
        try {
          await _ws.deregister();
        } catch (_) {}
        await _notif.showAlert(
          title: 'Location services are OFF',
          body:
          'Turn on Location Services (GPS) to continue. Open settings to enable it.',
        );
        await _notif.stopOnlineService();
        setError('Location services are OFF.');
        notifyListeners();
      }
      return;
    }

    final pos = await _loc.getPositionOrNull();
    final rest = _computeRestMinutes();
    await _ws.sendUpdate(lat: pos?.lat, lon: pos?.lon, restMinutes: rest);
    _lastTelemetrySentAt = DateTime.now();
  }

  double _computeRestMinutes() {
    final now = DateTime.now();
    if (activeTrip != null && activeTrip!.completedAt == null) {
      // on a trip
      if (queuedTrip != null) return -99999999;
      // negative remaining (as before), but keep seconds precision
      return -activeTrip!.remaining(now).inSeconds / 60.0;
    }
    if (queuedTrip != null) {
      return -99999999;
    }
    final since = _lastDropoffAt ?? activeTrip?.completedAt;
    if (since == null) return 0;
    final mins = now.difference(since).inSeconds / 60.0;
    return mins.clamp(0, double.infinity);
  }

  // === offer handling ===
  void clearPendingOffer() {
    pendingOffer = null;
    notifyListeners();
  }

  Future<void> acceptOffer(CustomerRequest req) async {
    clearPendingOffer();

    if (activeTrip == null) {
      activeTrip = Trip.fromRequest(
        req,
        DateTime.now(),
        Duration(minutes: req.durationMins.round()),
      );
    } else if (queuedTrip == null) {
      queuedTrip = Trip.fromRequest(
        req,
        DateTime.now(),
        Duration(minutes: req.durationMins.round()),
      );
    }
    notifyListeners();

    final pos = await _loc.getPositionOrNull();
    await _ws.sendResponse(
      customerId: req.customerId,
      accept: true,
      lat: pos?.lat,
      lon: pos?.lon,
      restMinutes: _computeRestMinutes(),
    );
  }

  Future<void> declineOffer(CustomerRequest req) async {
    clearPendingOffer();
    final pos = await _loc.getPositionOrNull();
    await _ws.sendResponse(
      customerId: req.customerId,
      accept: false,
      lat: pos?.lat,
      lon: pos?.lon,
      restMinutes: _computeRestMinutes(),
    );
    // store as canceled "trip-like" record for history (no end)
    final now = DateTime.now();
    _history.add(
      TripRecord(
        customerId: req.customerId,
        customerName: customers[req.customerId]?.name,
        customerRating: customers[req.customerId]?.rating,
        from: req.from,
        to: req.to,
        start: now,
        end: now,
        durationMinutes: 0,
        price: 0,
        status: TripStatus.canceled,
      ),
    );
    await _data.saveTripHistory(_history);
    notifyListeners();
  }

  // === trip flow ===
  Future<void> iArrived() async {
    if (activeTrip == null) return;

    activeTrip = activeTrip!.completeNow();
    _lastDropoffAt = DateTime.now();
    notifyListeners();

    // immediate update with rest=0 and coords
    final pos = await _loc.getPositionOrNull();
    await _ws.sendUpdate(lat: pos?.lat, lon: pos?.lon, restMinutes: 0);
    _lastTelemetrySentAt = DateTime.now();

    // store record
    final t = activeTrip!;
    final durMins = t.duration.inSeconds / 60.0;
    _history.add(
      TripRecord(
        customerId: t.request.customerId,
        customerName: customers[t.request.customerId]?.name,
        customerRating: customers[t.request.customerId]?.rating,
        from: t.from,
        to: t.to,
        start: t.start,
        end: t.completedAt ?? DateTime.now(),
        durationMinutes: durMins,
        price: t.request.price,
        status: TripStatus.completed,
      ),
    );
    await _data.saveTripHistory(_history);

    // add for motivation
    _accumulatedMinutesForMotivation += durMins;
    if (_accumulatedMinutesForMotivation >= K.motivationIntervalMinutes) {
      _accumulatedMinutesForMotivation = 0;
      if (_motivationMessages.isNotEmpty) {
        _motivationMessages.shuffle();
        motivationalMessage = _motivationMessages.first;
        notifyListeners();
      }
    }

    // show "Arrived" for K.arrivedBannerSeconds, then clear or switch to queued
    await Future.delayed(const Duration(seconds: K.arrivedBannerSeconds));

    if (queuedTrip != null) {
      activeTrip = Trip.fromRequest(
        queuedTrip!.request,
        DateTime.now(),
        Duration(minutes: queuedTrip!.request.durationMins.round()),
      );
      queuedTrip = null;
      notifyListeners();

      final pos2 = await _loc.getPositionOrNull();
      await _ws.sendUpdate(
        lat: pos2?.lat,
        lon: pos2?.lon,
        restMinutes: _computeRestMinutes(),
      );
      _lastTelemetrySentAt = DateTime.now();
    } else {
      activeTrip = null;
      notifyListeners();
    }
  }

  void cancelQueued() async {
    if (queuedTrip != null) {
      // record as canceled
      final q = queuedTrip!;
      _history.add(
        TripRecord(
          customerId: q.request.customerId,
          customerName: customers[q.request.customerId]?.name,
          customerRating: customers[q.request.customerId]?.rating,
          from: q.from,
          to: q.to,
          start: q.start,
          end: DateTime.now(),
          durationMinutes: 0,
          price: 0,
          status: TripStatus.canceled,
        ),
      );
      await _data.saveTripHistory(_history);
    }
    queuedTrip = null;
    notifyListeners();
  }

  // === breaks (count only OFF periods >= min after being ON and before being ON again)
  void _finishBreakIfAny() async {
    if (_breakStartAt != null) {
      final end = DateTime.now();
      final mins = end.difference(_breakStartAt!).inMinutes;
      if (mins >= K.minBreakMinutesToCount) {
        _breaks.add(BreakSession(_breakStartAt!, end));
        await _data.saveBreakSessions(_breaks);
      }
      _breakStartAt = null;
    }
  }

  // === today stats & series ===
  DailyStats get todayStats {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    double earnings = 0;
    int completed = 0;
    double driveMin = 0;

    for (final h in _history) {
      if (h.start.isAfter(start) && h.start.isBefore(end)) {
        if (h.status == TripStatus.completed) {
          earnings += h.price;
          completed += 1;
          driveMin += h.durationMinutes;
        }
      }
    }

    double breakMin = 0;
    int breakCount = 0;
    for (final b in _breaks) {
      if (b.start.isAfter(start) && b.start.isBefore(end)) {
        breakMin += b.minutes;
        breakCount += 1;
      }
    }
    return DailyStats(earnings, completed, driveMin, breakMin, breakCount);
  }

  /// returns ordered map of Date->(driveMin, breakMin)
  Map<DateTime, (double, double)> timeSeriesLastDays(int days) {
    final now = DateTime.now();
    final map = <DateTime, (double, double)>{};
    for (int i = days - 1; i >= 0; i--) {
      final d =
      DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      map[d] = (0, 0);
    }

    for (final h in _history) {
      final d = DateTime(h.start.year, h.start.month, h.start.day);
      if (map.containsKey(d) && h.status == TripStatus.completed) {
        final curr = map[d]!;
        map[d] = (curr.$1 + h.durationMinutes, curr.$2);
      }
    }
    for (final b in _breaks) {
      final d = DateTime(b.start.year, b.start.month, b.start.day);
      if (map.containsKey(d)) {
        final curr = map[d]!;
        map[d] = (curr.$1, curr.$2 + b.minutes);
      }
    }
    return map;
  }

  /// returns ordered map of Date->earnings
  Map<DateTime, double> earningsSeriesLastDays(int days) {
    final now = DateTime.now();
    final map = <DateTime, double>{};
    for (int i = days - 1; i >= 0; i--) {
      final d =
      DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      map[d] = 0;
    }
    for (final h in _history) {
      final d = DateTime(h.start.year, h.start.month, h.start.day);
      if (map.containsKey(d) && h.status == TripStatus.completed) {
        map[d] = map[d]! + h.price;
      }
    }
    return map;
  }

  String shortDayLabel(DateTime d) {
    final w = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return w[d.weekday - 1];
  }

  List<TripRecord> historyForRange(dynamic range) {
    final now = DateTime.now();
    late DateTime start;
    switch (range) {
      case dynamic _ when range.toString().contains('today'):
        start = DateTime(now.year, now.month, now.day);
        break;
      case dynamic _ when range.toString().contains('week'):
        final monday = now.subtract(Duration(days: (now.weekday - 1)));
        start = DateTime(monday.year, monday.month, monday.day);
        break;
      case dynamic _ when range.toString().contains('month'):
        start = DateTime(now.year, now.month, 1);
        break;
      default:
        start = DateTime(now.year, 1, 1);
    }
    return _history.where((h) => h.start.isAfter(start)).toList();
  }

  // motivation helpers
  void clearMotivation() {
    motivationalMessage = null;
    notifyListeners();
  }

  // refreshes cached permission + service status and notifies listeners
  Future<void> refreshPermissions() async {
    await _perms.refreshStatus();
    locationServicesOn = await _loc.isServiceEnabled();
    notifyListeners();
  }

  // expose read-only history for UI that still references `app.history`
  List<TripRecord> get history => List.unmodifiable(_history);

  // onboarding visibility
  bool get needsAlwaysOnBanner =>
      _perms.hasWhenInUsePermissionCache && !_perms.hasAlwaysPermissionCache;

  /// wipes everything
  Future<void> wipeAppData() async {
    available = false;
    _stopTimers();
    try {
      await _ws.deregister();
    } catch (_) {}
    try {
      await _ws.disconnect();
    } catch (_) {}
    try {
      await _notif.stopOnlineService();
    } catch (_) {}

    await _data.clearAll();

    driver = null;
    seenOnboarding = false;
    _lastDropoffAt = null;
    activeTrip = null;
    queuedTrip = null;
    _history = [];
    _breaks = [];
    _motivationMessages = [];
    _accumulatedMinutesForMotivation = 0;

    notifyListeners();
  }

  // === goals API ===
  Future<void> setGoals({
    double? earnings,
    int? trips,
    int? driveMinutes,
    int? breakMinutes,
    int? breaks,
  }) async {
    if (earnings != null) goalEarnings = earnings;
    if (trips != null) goalTrips = trips;
    if (driveMinutes != null) goalDriveMinutes = driveMinutes;
    if (breakMinutes != null) goalBreakMinutes = breakMinutes;
    if (breaks != null) goalBreaks = breaks;
    await _data.setGoals(
      earnings: earnings,
      trips: trips,
      driveMinutes: driveMinutes,
      breakMinutes: breakMinutes,
      breaks: breaks,
    );
    notifyListeners();
  }

  // Called after seeding to refresh local caches immediately (no app restart)
  Future<void> reloadLocalCaches() async {
    _history = await _data.loadTripHistory();
    _breaks = await _data.loadBreakSessions();
    notifyListeners();
  }

  // Pull-to-refresh hook
  Future<void> refreshAll() async {
    await refreshPermissions();
    hasNetwork = await InternetConnection().hasInternetAccess;
    if (!hasNetwork) {
      setError('No internet connection detected.');
    } else {
      if (lastError != null && lastError!.contains('internet')) {
        setError(null);
      }
    }
    await reloadLocalCaches();
  }

  @override
  void dispose() {
    _connSub?.cancel();
    _telemetryTimer?.cancel();
    _watchdogTimer?.cancel();
    _locServiceSub?.cancel();
    super.dispose();
  }
}
