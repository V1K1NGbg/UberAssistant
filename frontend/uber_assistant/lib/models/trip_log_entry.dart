import 'geo_point.dart';
import 'trip.dart';
import 'customer_request.dart';

class TripLogEntry {
  final String customerId;
  final GeoPoint from;
  final GeoPoint to;
  final DateTime start;
  final DateTime? end;
  final double price;
  final bool cancelled;

  Duration get duration => Duration(milliseconds: end == null ? 0 : end!.difference(start).inMilliseconds);

  TripLogEntry({
    required this.customerId,
    required this.from,
    required this.to,
    required this.start,
    required this.end,
    required this.price,
    required this.cancelled,
  });

  factory TripLogEntry.fromTrip(Trip t, {required String customerId, required bool cancelled}) {
    return TripLogEntry(
      customerId: customerId,
      from: t.request.from,
      to: t.request.to,
      start: t.start,
      end: t.completedAt ?? t.start.add(t.duration),
      price: t.request.price,
      cancelled: cancelled,
    );
  }

  factory TripLogEntry.fromJson(Map<String, dynamic> j) => TripLogEntry(
    customerId: j['customerId'] as String,
    from: GeoPoint.fromJson(Map<String, dynamic>.from(j['from'] as Map)),
    to: GeoPoint.fromJson(Map<String, dynamic>.from(j['to'] as Map)),
    start: DateTime.parse(j['start'] as String),
    end: j['end'] == null ? null : DateTime.parse(j['end'] as String),
    price: (j['price'] as num).toDouble(),
    cancelled: j['cancelled'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'customerId': customerId,
    'from': from.toJson(),
    'to': to.toJson(),
    'start': start.toIso8601String(),
    'end': end?.toIso8601String(),
    'price': price,
    'cancelled': cancelled,
  };
}
