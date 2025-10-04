class GeoPoint {
  final double lat;
  final double lon;
  final String? address;

  GeoPoint({required this.lat, required this.lon, this.address});

  factory GeoPoint.fromJson(Map<String, dynamic> j) => GeoPoint(
    lat: (j['lat'] as num).toDouble(),
    lon: (j['lon'] as num).toDouble(),
    address: j['address'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lon': lon,
    if (address != null) 'address': address,
  };
}
