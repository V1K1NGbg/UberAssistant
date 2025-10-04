class WsMsg {
  final String type;
  final String driverId;
  final Map<String, dynamic>? location; // {lat, lon}
  final double? restTime;
  final Map<String, dynamic>? request; // only for inbound from server
  final String? customerId;
  final String? response; // 'accept' | 'deny'

  WsMsg({
    required this.type,
    required this.driverId,
    this.location,
    this.restTime,
    this.request,
    this.customerId,
    this.response,
  });

  factory WsMsg.register({required String driverId, double? lat, double? lon, double? restTime}) =>
      WsMsg(
        type: 'register',
        driverId: driverId,
        location: (lat != null && lon != null) ? {'lat': lat, 'lon': lon} : null,
        restTime: restTime,
      );

  factory WsMsg.update({required String driverId, double? lat, double? lon, double? restTime}) =>
      WsMsg(
        type: 'update',
        driverId: driverId,
        location: (lat != null && lon != null) ? {'lat': lat, 'lon': lon} : null,
        restTime: restTime,
      );

  factory WsMsg.deregister({required String driverId}) =>
      WsMsg(type: 'deregister', driverId: driverId);

  factory WsMsg.response({
    required String driverId,
    required String customerId,
    required bool accept,
    double? lat,
    double? lon,
    double? restTime,
  }) =>
      WsMsg(
        type: 'response',
        driverId: driverId,
        customerId: customerId,
        response: accept ? 'accept' : 'deny',
        location: (lat != null && lon != null) ? {'lat': lat, 'lon': lon} : null,
        restTime: restTime,
      );

  factory WsMsg.fromJson(Map<String, dynamic> j) => WsMsg(
    type: j['type'] as String,
    driverId: j['driverId'] as String? ?? '',
    location: j['location'] as Map<String, dynamic>?,
    restTime: (j['restTime'] as num?)?.toDouble(),
    request: j['request'] as Map<String, dynamic>?,
    customerId: j['customerId'] as String?,
    response: j['response'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'driverId': driverId,
    if (location != null) 'location': location,
    if (restTime != null) 'restTime': restTime,
    if (request != null) 'request': request,
    if (customerId != null) 'customerId': customerId,
    if (response != null) 'response': response,
  };

  @override
  String toString() => toJson().toString();
}
