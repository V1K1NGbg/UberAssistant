class Customer {
  final String id;
  final String name;
  final double rating;

  Customer({required this.id, required this.name, required this.rating});

  factory Customer.fromJson(Map<String, dynamic> j) =>
      Customer(id: j['customer_id'], name: j['customer_name'], rating: (j['customer_rating'] as num).toDouble());
}
