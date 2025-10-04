import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/customer_request.dart';
import '../models/websocket_message.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  String? _driverId;
  String? _wsUrl;

  void Function(CustomerRequest req)? onOffer;
  void Function(String error)? onError;
  void Function()? onDisconnected;

  Future<void> connect(String url, {required String driverId}) async {
    _wsUrl = url;
    _driverId = driverId;

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
    } catch (e) {
      onError?.call('Failed to connect: $e');
      rethrow;
    }

    _channel!.stream.listen(_onMessage, onError: (e) {
      onError?.call('WebSocket error: $e');
    }, onDone: () async {
      // notify disconnection
      onDisconnected?.call();
      // simple auto-reconnect
      if (_wsUrl != null && _driverId != null) {
        try {
          await reconnect(_wsUrl!);
        } catch (_) {}
      }
    });
  }

  Future<void> reconnect(String url) async {
    await disconnect();
    await connect(url, driverId: _driverId!);
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
  }

  void _onMessage(dynamic message) {
    try {
      final Map<String, dynamic> j = jsonDecode(message.toString());
      if (j['type'] == 'ride_request' && j['request'] != null) {
        final req = CustomerRequest.fromJson(j['request'] as Map<String, dynamic>);
        onOffer?.call(req);
      }
    } catch (e) {
      onError?.call('Bad message: $e');
    }
  }

  Future<void> sendRegister({double? lat, double? lon, double? restMinutes}) async {
    if (_driverId == null) return;
    final msg = WsMsg.register(driverId: _driverId!, lat: lat, lon: lon, restTime: restMinutes);
    _channel?.sink.add(jsonEncode(msg.toJson()));
  }

  Future<void> deregister() async {
    if (_driverId == null) return;
    final msg = WsMsg.deregister(driverId: _driverId!);
    _channel?.sink.add(jsonEncode(msg.toJson()));
  }

  Future<void> sendUpdate({double? lat, double? lon, double? restMinutes}) async {
    if (_driverId == null) return;
    final msg = WsMsg.update(driverId: _driverId!, lat: lat, lon: lon, restTime: restMinutes);
    _channel?.sink.add(jsonEncode(msg.toJson()));
  }

  Future<void> sendResponse({
    required String customerId,
    required bool accept,
    double? lat,
    double? lon,
    double? restMinutes,
  }) async {
    if (_driverId == null) return;
    final msg = WsMsg.response(
      driverId: _driverId!, customerId: customerId, accept: accept,
      lat: lat, lon: lon, restTime: restMinutes,
    );
    _channel?.sink.add(jsonEncode(msg.toJson()));
  }
}
