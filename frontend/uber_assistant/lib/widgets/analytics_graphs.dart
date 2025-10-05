import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../constants.dart';
import 'rounded_card.dart';

class AnalyticsGraphs extends StatelessWidget {
  const AnalyticsGraphs({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final tm = app.timeSeriesLastDays(7);  // {date: (drive, break)}
    final er = app.earningsSeriesLastDays(14); // {date: earnings}

    return Column(
      children: [
        RoundedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Time Management', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i < 0 || i >= tm.length) return const SizedBox.shrink();
                          final label = app.shortDayLabel(tm.keys.elementAt(i));
                          return Padding(padding: const EdgeInsets.only(top: 6), child: Text(label, style: const TextStyle(fontSize: 10)));
                        },
                      )),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(tm.length, (i) {
                      final day = tm.values.elementAt(i);
                      final drive = day.$1 / 60.0; // to hours
                      final br = day.$2 / 60.0;
                      return BarChartGroupData(x: i, barsSpace: 6, barRods: [
                        BarChartRodData(
                          toY: drive + br,
                          rodStackItems: [
                            BarChartRodStackItem(0, br, K.progressOrange),
                            BarChartRodStackItem(br, br + drive, K.progressPurple),
                          ],
                          width: 14,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ]);
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (_) {
                  // verdict based on average break ratio, but only if enough data
                  double totalBreak = 0, totalOnline = 0;
                  for (final v in tm.values) { totalBreak += v.$2; totalOnline += (v.$1 + v.$2); }
                  if (totalOnline < 60) {
                    // not enough data (less than 60 minutes total)
                    return const SizedBox.shrink();
                  }
                  final ratio = totalOnline == 0 ? 0 : totalBreak / totalOnline;
                  final good = ratio >= 0.167; // ~45m / 4.5h
                  return Text(
                    good
                        ? 'Great balance today — you’re meeting healthy break ratios.'
                        : 'Try to add more short breaks; aim for ~45 min per 4.5 hours of driving.',
                    style: TextStyle(color: good ? K.progressGreen : K.progressOrange),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        RoundedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Earnings', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    minY: 0, // never go under x-axis
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i < 0 || i >= er.length) return const SizedBox.shrink();
                          final label = app.shortDayLabel(er.keys.elementAt(i));
                          return Padding(padding: const EdgeInsets.only(top: 6), child: Text(label, style: const TextStyle(fontSize: 10)));
                        },
                      )),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(er.length, (i) => FlSpot(i.toDouble(), er.values.elementAt(i))),
                        isCurved: false, // avoid overshoot under 0
                        dotData: FlDotData(show: true),
                        color: K.progressBlue,
                        barWidth: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ],
    );
  }
}
