import 'geo_point.dart';

enum TripStatus { completed, canceled }

class TripRecord {
  final String? customerId;
  final String? customerName;
  final double? customerRating;

  final GeoPoint from;
  final GeoPoint to;

  final DateTime start;
  final DateTime end;
  final double durationMinutes;
  final double price;
  final TripStatus status;

  TripRecord({
    this.customerId,
    this.customerName,
    this.customerRating,
    required this.from,
    required this.to,
    required this.start,
    required this.end,
    required this.durationMinutes,
    required this.price,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'customerId': customerId,
    'customerName': customerName,
    'customerRating': customerRating,
    'from': from.toJson(),
    'to': to.toJson(),
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'durationMinutes': durationMinutes,
    'price': price,
    'status': status.name,
  };

  factory TripRecord.fromJson(Map<String, dynamic> j) => TripRecord(
    customerId: j['customerId'] as String?,
    customerName: j['customerName'] as String?,
    customerRating: (j['customerRating'] as num?)?.toDouble(),
    from: GeoPoint.fromJson(j['from'] as Map<String, dynamic>),
    to: GeoPoint.fromJson(j['to'] as Map<String, dynamic>),
    start: DateTime.parse(j['start'] as String),
    end: DateTime.parse(j['end'] as String),
    durationMinutes: (j['durationMinutes'] as num).toDouble(),
    price: (j['price'] as num).toDouble(),
    status: (j['status'] as String) == 'canceled' ? TripStatus.canceled : TripStatus.completed,
  );
}
