import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/customer.dart';
import '../models/customer_request.dart';
import '../models/driver.dart';
import '../models/trip.dart';
import '../services/local_data_service.dart';
import '../services/notification_service.dart';
import '../services/websocket_service.dart';

enum AppLanguage { system, en, nl }

class AppState extends ChangeNotifier {
  final LocalDataService data;
  final NotificationService notifications;
  final WebSocketService ws;

  AppState(this.data, this.notifications, this.ws);

  bool _seenOnboarding = false;
  bool get seenOnboarding => _seenOnboarding;

  AppLanguage _lang = AppLanguage.system;
  AppLanguage get language => _lang;

  String _serverIp = '192.168.0.2';
  String get serverIp => _serverIp;

  Driver? _driver;
  Driver? get driver => _driver;

  bool _available = false;
  bool get available => _available;

  Trip? _active;
  Trip? get activeTrip => _active;

  CustomerRequest? _queued;
  CustomerRequest? get queuedTrip => _queued;

  Timer? _ticker;
  DateTime? _lastDropoffAt;

  Map<String, Customer> get customers => data.customers;
  Map<String, Driver> get drivers => data.drivers;

  Future<void> init() async {
    await data.load();

    final sp = await SharedPreferences.getInstance();
    _seenOnboarding = sp.getBool(K.keySeenOnboarding) ?? false;
    _serverIp = sp.getString(K.keyServerIp) ?? _serverIp;

    final langStr = sp.getString(K.keyLanguage) ?? 'system';
    _lang = switch (langStr) { 'en' => AppLanguage.en, 'nl' => AppLanguage.nl, _ => AppLanguage.system };

    final id = sp.getString(K.keyDriverId);
    if (id != null && drivers.containsKey(id)) _driver = drivers[id];

    notifyListeners();
  }

  Future<void> setSeenOnboarding() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(K.keySeenOnboarding, true);
    _seenOnboarding = true;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage lang) async {
    final sp = await SharedPreferences.getInstance();
    _lang = lang;
    await sp.setString(K.keyLanguage, switch (lang) { AppLanguage.en => 'en', AppLanguage.nl => 'nl', _ => 'system' });
    notifyListeners();
  }

  Future<void> setServerIp(String ip) async {
    final sp = await SharedPreferences.getInstance();
    _serverIp = ip;
    await sp.setString(K.keyServerIp, ip);
    notifyListeners();
  }

  Future<void> setDriver(Driver d) async {
    final sp = await SharedPreferences.getInstance();
    _driver = d;
    await sp.setString(K.keyDriverId, d.id);
    notifyListeners();
  }

  Future<void> setAvailable(bool v) async {
    if (_driver == null) return;
    _available = v;
    notifyListeners();

    if (v) {
      await ws.connect(driverId: _driver!.id, serverIp: _serverIp);
      await notifications.startOnlineService();
      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      ws.incomingRequests.listen(_onIncomingRequest);
    } else {
      _ticker?.cancel();
      await notifications.stopOnlineService();
      await ws.disconnect();
    }
  }

  void _tick() {
    // restTime: negative when in trip, -99999999 when queued with active
    if (_active != null) {
      final remain = _active!.remaining(DateTime.now()).inSeconds / 60.0;
      ws.updateRest(-remain);
      if (_active!.isDone) _finishActive();
    } else if (_queued != null) {
      ws.updateRest(-99999999);
    } else {
      final since = _lastDropoffAt ?? DateTime.now();
      final rest = DateTime.now().difference(since).inSeconds / 60.0;
      ws.updateRest(rest);
    }
  }

  void _onIncomingRequest(CustomerRequest r) {
    notifications.showOffer(
      title: r.advice?.toLowerCase() == 'yes' ? 'Recommended request' : 'New request',
      body:
      '${customers[r.customerId]?.name ?? 'Unknown'} · ${(r.durationMins).toStringAsFixed(0)} min · €${r.price.toStringAsFixed(2)}',
    );
    // show in UI via provider consumers
    _pendingOffer = r;
    notifyListeners();
  }

  CustomerRequest? _pendingOffer;
  CustomerRequest? get pendingOffer => _pendingOffer;
  void clearPendingOffer() {
    _pendingOffer = null;
    notifyListeners();
  }

  void acceptOffer(CustomerRequest r) {
    ws.respond(customerId: r.customerId, accept: true);
    if (_active == null) {
      _active = Trip(
        request: r,
        startedAt: DateTime.now(),
        duration: Duration(minutes: r.durationMins.round()),
      );
    } else {
      // queue it
      _queued = r;
    }
    _pendingOffer = null;
    notifyListeners();
  }

  void declineOffer(CustomerRequest r) {
    ws.respond(customerId: r.customerId, accept: false);
    _pendingOffer = null;
    notifyListeners();
  }

  void iArrived() {
    if (_active == null) return;
    _finishActive(force: true);
  }

  void cancelQueued() {
    _queued = null;
    notifyListeners();
  }

  void _finishActive({bool force = false}) {
    _active = null;
    _lastDropoffAt = DateTime.now();
    if (_queued != null) {
      // start queued after 10s "arrived" banner
      final q = _queued!;
      _queued = null;
      Future.delayed(const Duration(seconds: K.arrivedBannerSeconds), () {
        _active = Trip(
          request: q,
          startedAt: DateTime.now(),
          duration: Duration(minutes: q.durationMins.round()),
        );
        notifyListeners();
      });
    }
    notifyListeners();
  }
}
