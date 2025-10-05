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
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'Daily Report',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Edit goals',
                onPressed: () => _openGoalsEditor(context),
                icon: const Icon(Icons.edit),
              ),
            ],
          ),
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

          // progress bars with personalized goals
          bar(K.progressBlue,  s.earnings,                       app.goalEarnings,       'Daily gains', '€'),
          const SizedBox(height: 12),
          bar(K.progressGreen, s.completedTrips.toDouble(),      app.goalTrips.toDouble(),'Completed trips', ''),
          const SizedBox(height: 12),
          bar(K.progressPurple,s.driveMinutes,                   app.goalDriveMinutes.toDouble(), 'Drive time', 'm'),
          const SizedBox(height: 12),
          bar(K.progressOrange,s.breakMinutes,                   app.goalBreakMinutes.toDouble(), 'Break time', 'm'),
          const SizedBox(height: 12),
          bar(K.progressRed,   s.breakCount.toDouble(),          app.goalBreaks.toDouble(), 'Break amount', ''),
        ],
      ),
    );
  }

  void _openGoalsEditor(BuildContext context) {
    final app = context.read<AppState>();
    double e = app.goalEarnings;
    double trips = app.goalTrips.toDouble();
    double drive = app.goalDriveMinutes.toDouble();
    double bmin = app.goalBreakMinutes.toDouble();
    double brk = app.goalBreaks.toDouble();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 8,
          bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSt) {
            Widget slider(String title, double value, double min, double max, int divisions, void Function(double) onCh, String Function(double) fmt) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                  Slider(
                    value: value, min: min, max: max, divisions: divisions, label: fmt(value),
                    onChanged: (v) => setSt(() => onCh(v)),
                  ),
                ],
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Personal goals', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                slider('Daily gains (€)', e, 0, 200, 200, (v) => e = v, (v) => '€${v.round()}'),
                slider('Completed trips', trips, 0, 30, 30, (v) => trips = v, (v) => '${v.round()}'),
                slider('Drive time (min)', drive, 0, 600, 120, (v) => drive = v, (v) => '${v.round()}'),
                slider('Break time (min)', bmin, 0, 240, 80, (v) => bmin = v, (v) => '${v.round()}'),
                slider('Breaks', brk, 0, 10, 10, (v) => brk = v, (v) => '${v.round()}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    const Spacer(),
                    FilledButton(
                      onPressed: () async {
                        await app.setGoals(
                          earnings: e.roundToDouble(),
                          trips: trips.round(),
                          driveMinutes: drive.round(),
                          breakMinutes: bmin.round(),
                          breaks: brk.round(),
                        );
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
