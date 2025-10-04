import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:geolocator/geolocator.dart';
import '../constants.dart';
import '../models/customer_request.dart';
import '../models/geo_point.dart';
import '../models/websocket_message.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  Timer? _heartbeat;
  final _incomingCtrl = StreamController<CustomerRequest>.broadcast();
  Stream<CustomerRequest> get incomingRequests => _incomingCtrl.stream;

  String serverWs = K.wsDefault;
  String driverId = '';
  double restTimeMinutes = 0;

  Future<void> connect({required String driverId, required String serverIp}) async {
    this.driverId = driverId;
    serverWs = 'ws://$serverIp:3000';
    _channel?.sink.close();
    _channel = WebSocketChannel.connect(Uri.parse(serverWs));
    _channel!.stream.listen(_onMessage, onError: (_) => _reconnect(), onDone: () => _reconnect());

    // send register immediately
    final loc = await _getLocation();
    _send(WsMsg(
      type: 'register',
      driverId: driverId,
      location: loc,
      restTime: restTimeMinutes,
    ));

    // heartbeat every 10 sec
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(const Duration(seconds: K.wsHeartbeatSeconds), (_) async {
      final l = await _getLocation();
      _send(WsMsg(type: 'update', driverId: driverId, location: l, restTime: restTimeMinutes));
    });
  }

  Future<void> disconnect() async {
    _heartbeat?.cancel();
    _send(WsMsg(type: 'deregister', driverId: driverId));
    await _channel?.sink.close(ws_status.normalClosure);
    _channel = null;
  }

  void _reconnect() {
    // lite: leave reconnecting to caller (app toggles), or implement backoff if needed
  }

  void _send(WsMsg msg) {
    final msgStr = msg.toString();
    print('Sent: $msgStr');
    _channel?.sink.add(jsonEncode(msg.toJson()));
  }

  Future<GeoPoint> _getLocation() async {
    final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    return GeoPoint(lat: p.latitude, lon: p.longitude);
  }

  void _onMessage(dynamic message) {
    final msgStr = message.toString();
    print('Received: $msgStr');
    try {
      final Map<String, dynamic> j = jsonDecode(message as String);
      final msg = WsMsg.fromJson(j);
      if (msg.type == 'ride_request' && msg.request != null) {
        _incomingCtrl.add(msg.request!);
      }
    } catch (_) {}
  }

  void respond({required String customerId, required bool accept}) async {
    final l = await _getLocation();
    _send(WsMsg(
      type: 'response',
      driverId: driverId,
      customerId: customerId,
      response: accept ? 'accept' : 'deny',
      location: l,
      restTime: accept ? -1 : restTimeMinutes,
    ));
  }

  void updateRest(double minutes) {
    restTimeMinutes = minutes;
  }
}
