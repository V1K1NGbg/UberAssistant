import 'dart:convert';

import 'customer_request.dart';
import 'geo_point.dart';

class WsMsg {
  final String type; // register | update | deregister | response | ride_request
  final String driverId;
  final GeoPoint? location;
  final double? restTime;
  final CustomerRequest? request;
  final String? customerId;
  final String? response; // accept | deny

  WsMsg({
    required this.type,
    required this.driverId,
    this.location,
    this.restTime,
    this.request,
    this.customerId,
    this.response,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'driverId': driverId,
    if (location != null) 'location': {'lat': location!.lat, 'lon': location!.lon},
    if (restTime != null) 'restTime': restTime,
    if (request != null)
      'request': {
        'customer_id': request!.customerId,
        'from_location': {
          'lat': request!.from.lat,
          'lon': request!.from.lon,
          'address': request!.from.address,
        },
        'to_location': {
          'lat': request!.to.lat,
          'lon': request!.to.lon,
          'address': request!.to.address,
        },
        'duration_mins': request!.durationMins,
        'price': request!.price,
        if (request!.advice != null) 'advice': request!.advice,
      },
    if (customerId != null) 'customerId': customerId,
    if (response != null) 'response': response,
  };

  factory WsMsg.fromJson(Map<String, dynamic> j) => WsMsg(
    type: j['type'],
    driverId: j['driverId'],
    location: j['location'] != null ? GeoPoint.fromJson(j['location']) : null,
    restTime: j['restTime'] != null ? (j['restTime'] as num).toDouble() : null,
    request: j['request'] != null ? CustomerRequest.fromJson(j['request']) : null,
    customerId: j['customerId'],
    response: j['response'],
  );
  @override
  String toString() => jsonEncode(toJson());
}
