import 'package:flutter/material.dart';
import 'package:uber_assistant/l10n/app_localizations.dart';
import '../models/trip.dart';
import '../constants.dart';
import 'rounded_card.dart';

class TripProgressCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onArrived;
  const TripProgressCard({super.key, required this.trip, required this.onArrived});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final p = trip.progress(now);
    final remain = trip.remaining(now);
    final t = AppLocalizations.of(context)!;

    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.directions_car),
            const SizedBox(width: 8),
            Text(
              t.tripInTransit,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text('${remain.inMinutes}m left'),
          ]),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: p),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_pin),
              const SizedBox(width: 6),
              Expanded(child: Text(trip.request.from.address ?? '(${trip.request.from.lat}, ${trip.request.from.lon})')),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.flag),
              const SizedBox(width: 6),
              Expanded(child: Text(trip.request.to.address ?? '(${trip.request.to.lat}, ${trip.request.to.lon})')),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: onArrived,
              style: FilledButton.styleFrom(backgroundColor: K.safetyBlue),
              child: Text(t.imThere),
            ),
          ),
        ],
      ),
    );
  }
}
