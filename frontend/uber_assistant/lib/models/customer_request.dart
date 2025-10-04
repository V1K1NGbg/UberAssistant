import 'geo_point.dart';

class CustomerRequest {
  final String customerId;
  final GeoPoint from;
  final GeoPoint to;
  final double durationMins;
  final double price;
  final String? advice; // "yes" | "no" | null

  CustomerRequest({
    required this.customerId,
    required this.from,
    required this.to,
    required this.durationMins,
    required this.price,
    this.advice,
  });

  factory CustomerRequest.fromJson(Map<String, dynamic> j) => CustomerRequest(
    customerId: j['customer_id'],
    from: GeoPoint.fromJson(j['from_location']),
    to: GeoPoint.fromJson(j['to_location']),
    durationMins: (j['duration_mins'] as num).toDouble(),
    price: (j['price'] as num).toDouble(),
    advice: j['advice'],
  );
}
