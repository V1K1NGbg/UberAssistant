class Customer {
  final String id;
  final String name;
  final double rating;

  Customer({required this.id, required this.name, required this.rating});

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
    id: j['customer_id'] as String,
    name: j['customer_name'] as String,
    rating: (j['customer_rating'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() =>
      {'customer_id': id, 'customer_name': name, 'customer_rating': rating};
}
