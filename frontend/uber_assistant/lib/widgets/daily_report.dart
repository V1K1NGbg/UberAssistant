import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/app_state.dart';
import 'rounded_card.dart';

class DailyReport extends StatelessWidget {
  const DailyReport({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = app.todayStats;

    Widget bar(Color color, double value, double goal, String label, String suffix) {
      final pct = goal <= 0 ? 1.0 : (value / goal).clamp(0, 1);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct.toDouble(),
              minHeight: 12,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          Text('${value.toStringAsFixed(0)}$suffix  /  ${goal.toStringAsFixed(0)}$suffix', style: Theme.of(context).textTheme.bodySmall),
        ],
      );
    }

    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          Center(child: Text('Daily Report', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
          const SizedBox(height: 16),

          // money
          Row(
            children: [
              const Icon(Icons.euro),
              const SizedBox(width: 8),
              Text('Money earned since 00:00', style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 8),
          Text('€${s.earnings.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),

          // progress bars
          bar(K.progressBlue, s.earnings, K.dailyGoalEarnings, 'Daily gains', '€'),
          const SizedBox(height: 12),
          bar(K.progressGreen, s.completedTrips.toDouble(), K.dailyGoalTrips.toDouble(), 'Completed trips', ''),
          const SizedBox(height: 12),
          bar(K.progressPurple, s.driveMinutes, K.dailyGoalDriveMinutes.toDouble(), 'Drive time', 'm'),
          const SizedBox(height: 12),
          bar(K.progressOrange, s.breakMinutes, K.dailyGoalBreakMinutes.toDouble(), 'Break time', 'm'),
          const SizedBox(height: 12),
          bar(K.progressRed, s.breakCount.toDouble(), K.dailyGoalBreaks.toDouble(), 'Break amount', ''),
        ],
      ),
    );
  }
}
