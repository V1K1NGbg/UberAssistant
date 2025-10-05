// lib/dev/mock_seed.dart
import 'dart:math';
import 'package:uber_assistant/models/geo_point.dart';
import 'package:uber_assistant/models/customer.dart';
import 'package:uber_assistant/models/trip_record.dart';
import 'package:uber_assistant/models/break_session.dart';
import 'package:uber_assistant/services/local_data_service.dart';

class MockSeed {
  static Future<void> seedIfEmpty({
    required LocalDataService data,
    required Map<String, Customer> customers,
  }) async {
    // if your LocalDataService doesn't have these helpers yet, you can adapt
    final trips = await data.loadTripHistory();
    if (trips.isNotEmpty) return;

    final generated = _generate(customers);
    await data.saveTripHistory(generated.$1);
    await data.saveBreakSessions(generated.$2);
  }

  static (List<TripRecord>, List<BreakSession>) _generate(Map<String, Customer> customers) {
    final rnd = Random(42);

    final fallbackCustomers = <Customer>[
      Customer(id: 'C_100001', name: 'Michael Scott', rating: 3.9),
      Customer(id: 'C_100002', name: 'Leslie Knope', rating: 4.8),
      Customer(id: 'C_100003', name: 'Jon Snow', rating: 4.5),
      Customer(id: 'C_100004', name: 'Tony Stark', rating: 4.9),
      Customer(id: 'C_100005', name: 'Dwight Schrute', rating: 4.2),
      Customer(id: 'C_100006', name: 'Daenerys Targaryen', rating: 4.6),
    ];
    final customerPool = customers.isNotEmpty ? customers.values.toList() : fallbackCustomers;

    final places = <({String name, double lat, double lon})>[
      (name: 'Amsterdam Centraal', lat: 52.3791, lon: 4.9003),
      (name: 'Leidseplein', lat: 52.3647, lon: 4.8810),
      (name: 'Zuidas', lat: 52.3380, lon: 4.8736),
      (name: 'Museumplein', lat: 52.3584, lon: 4.8811),
      (name: 'Schiphol', lat: 52.3105, lon: 4.7683),
      (name: 'Rotterdam CS', lat: 51.9244, lon: 4.4687),
      (name: 'The Hague CS', lat: 52.0800, lon: 4.3242),
      (name: 'Utrecht CS', lat: 52.0908, lon: 5.1214),
      (name: 'Eindhoven Airport', lat: 51.4500, lon: 5.3745),
      (name: 'Haarlem', lat: 52.3874, lon: 4.6462),
    ];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final trips = <TripRecord>[];
    final breaks = <BreakSession>[];

    for (int d = 0; d < 60; d++) {
      final day = today.subtract(Duration(days: d));
      final weekday = day.weekday;

      int baseTrips = switch (weekday) {
        5 || 6 => 5 + rnd.nextInt(3),
        1 => 1 + rnd.nextInt(3),
        _ => 2 + rnd.nextInt(4),
      };

      final starts = <DateTime>[];
      for (int i = 0; i < baseTrips; i++) {
        final startMin = 7 * 60 + rnd.nextInt(14 * 60);
        starts.add(day.add(Duration(minutes: startMin)));
      }
      starts.sort();

      double totalDriveMinThisDay = 0;

      for (final start in starts) {
        final durationMin = 8 + rnd.nextInt(28);
        final end = start.add(Duration(minutes: durationMin));

        final fromIdx = rnd.nextInt(places.length);
        int toIdx = rnd.nextInt(places.length);
        if (toIdx == fromIdx) toIdx = (toIdx + 1) % places.length;

        final from = places[fromIdx];
        final to = places[toIdx];

        final c = customerPool[rnd.nextInt(customerPool.length)];
        final canceled = rnd.nextDouble() < (0.10 + rnd.nextDouble() * 0.10);

        final price = canceled ? 0.0 : (3.0 + 0.7 * durationMin + rnd.nextDouble() * 2.0);

        if (!canceled) totalDriveMinThisDay += durationMin.toDouble();

        trips.add(
          TripRecord(
            customerId: c.id,
            customerName: c.name,
            customerRating: c.rating,
            from: GeoPoint(lat: from.lat, lon: from.lon, address: from.name),
            to: GeoPoint(lat: to.lat, lon: to.lon, address: to.name),
            start: start,
            end: end,
            durationMinutes: durationMin.toDouble(),
            price: double.parse(price.toStringAsFixed(2)),
            status: canceled ? TripStatus.canceled : TripStatus.completed,
          ),
        );
      }

      if (totalDriveMinThisDay > 0) {
        final healthyDay = d % 4 == 0 || weekday == 7;
        final targetRatio = healthyDay ? (0.20 + rnd.nextDouble() * 0.10) : (0.06 + rnd.nextDouble() * 0.09);
        final targetBreakMin = (totalDriveMinThisDay * targetRatio).clamp(10, 120);

        int breakCount = 1 + rnd.nextInt(3);
        double remaining = targetBreakMin.toDouble();

        for (int i = 0; i < breakCount; i++) {
          final thisLen = (i == breakCount - 1)
              ? (remaining.round().clamp(8, 60))
              : (max(8, min(40, (remaining / (breakCount - i) * (0.7 + rnd.nextDouble() * 0.6)).round())));
          remaining -= thisLen;

          final startMin = 9 * 60 + rnd.nextInt(11 * 60);
          final bStart = day.add(Duration(minutes: startMin));
          final bEnd = bStart.add(Duration(minutes: thisLen));

          breaks.add(BreakSession(bStart, bEnd));
        }
      }
    }

    return (trips, breaks);
  }
}
