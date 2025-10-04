import 'geo_point.dart';

class CustomerRequest {
  final String customerId;
  final GeoPoint from;
  final GeoPoint to;
  final double durationMins;
  final double price;
  final String? advice;

  CustomerRequest({
    required this.customerId,
    required this.from,
    required this.to,
    required this.durationMins,
    required this.price,
    this.advice,
  });

  factory CustomerRequest.fromJson(Map<String, dynamic> j) => CustomerRequest(
    customerId: j['customer_id'] as String,
    from: GeoPoint.fromJson(j['from_location'] as Map<String, dynamic>),
    to: GeoPoint.fromJson(j['to_location'] as Map<String, dynamic>),
    durationMins: (j['duration_mins'] as num).toDouble(),
    price: (j['price'] as num).toDouble(),
    advice: j['advice'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'customer_id': customerId,
    'from_location': from.toJson(),
    'to_location': to.toJson(),
    'duration_mins': durationMins,
    'price': price,
    if (advice != null) 'advice': advice,
  };
}
