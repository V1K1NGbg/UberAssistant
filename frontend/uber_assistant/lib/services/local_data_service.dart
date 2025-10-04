import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/customer.dart';
import '../models/driver.dart';

class LocalDataService {
  Map<String, Customer> _customers = {};
  Map<String, Driver> _drivers = {};

  Map<String, Customer> get customers => _customers;
  Map<String, Driver> get drivers => _drivers;

  Future<void> load() async {
    final c = await rootBundle.loadString('assets/data/customers.json');
    final d = await rootBundle.loadString('assets/data/drivers.json');

    final cl = (jsonDecode(c) as List).cast<Map<String, dynamic>>();
    final dl = (jsonDecode(d) as List).cast<Map<String, dynamic>>();

    _customers = {for (final j in cl) j['customer_id']: Customer.fromJson(j)};
    _drivers = {for (final j in dl) j['driver_id']: Driver.fromJson(j)};
  }
}
