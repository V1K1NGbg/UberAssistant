class Driver {
  final String id;
  final String name;
  final double rating;

  Driver({required this.id, required this.name, required this.rating});

  factory Driver.fromJson(Map<String, dynamic> j) =>
      Driver(id: j['driver_id'], name: j['driver_name'], rating: (j['driver_rating'] as num).toDouble());
}
