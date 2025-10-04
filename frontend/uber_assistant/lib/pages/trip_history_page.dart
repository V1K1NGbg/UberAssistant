import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/trip_log_entry.dart';
import '../widgets/rating_stars.dart';
import '../constants.dart';

enum HistoryFilter { today, week, month, year }
enum HistorySort { earningsHighLow, earningsLowHigh, statusCompleted, statusCancelled }

class TripHistoryPage extends StatefulWidget {
  const TripHistoryPage({super.key});

  @override
  State<TripHistoryPage> createState() => _TripHistoryPageState();
}

class _TripHistoryPageState extends State<TripHistoryPage> {
  HistoryFilter filter = HistoryFilter.today;
  HistorySort sort = HistorySort.earningsHighLow;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final app = context.watch<AppState>();

    final items = _filter(app.history);
    items.sort((a,b) {
      switch (sort) {
        case HistorySort.earningsHighLow: return b.price.compareTo(a.price);
        case HistorySort.earningsLowHigh: return a.price.compareTo(b.price);
        case HistorySort.statusCompleted:  return (a.cancelled ? 1 : 0) - (b.cancelled ? 1 : 0);
        case HistorySort.statusCancelled:  return (b.cancelled ? 1 : 0) - (a.cancelled ? 1 : 0);
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(t.tripHistory)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<HistoryFilter>(
                    value: filter,
                    decoration: InputDecoration(labelText: t.filter),
                    items: [
                      DropdownMenuItem(value: HistoryFilter.today, child: Text(t.filterToday)),
                      DropdownMenuItem(value: HistoryFilter.week,  child: Text(t.filterWeek)),
                      DropdownMenuItem(value: HistoryFilter.month, child: Text(t.filterMonth)),
                      DropdownMenuItem(value: HistoryFilter.year,  child: Text(t.filterYear)),
                    ],
                    onChanged: (v) => setState(() => filter = v ?? filter),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<HistorySort>(
                    value: sort,
                    decoration: InputDecoration(labelText: t.sort),
                    items: [
                      DropdownMenuItem(value: HistorySort.earningsHighLow, child: Text(t.sortEarningsHighLow)),
                      DropdownMenuItem(value: HistorySort.earningsLowHigh, child: Text(t.sortEarningsLowHigh)),
                      DropdownMenuItem(value: HistorySort.statusCompleted,  child: Text(t.sortCompleted)),
                      DropdownMenuItem(value: HistorySort.statusCancelled,  child: Text(t.sortCancelled)),
                    ],
                    onChanged: (v) => setState(() => sort = v ?? sort),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final e = items[i];
                final timeDep = _fmtTime(e.start);
                final timeArr = e.end == null ? '-' : _fmtTime(e.end!);
                final addr = e.to.address ?? '(${e.to.lat.toStringAsFixed(5)}, ${e.to.lon.toStringAsFixed(5)})';
                final status = e.cancelled ? t.statusCancelled : t.statusCompleted;
                final color  = e.cancelled ? Theme.of(context).colorScheme.error : K.successGreen;

                return InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _TripDetails(entry: e))),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: K.cardRadius,
                      border: Border.all(color: Colors.grey.withOpacity(0.15)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${t.depart}: $timeDep'),
                            Text('${t.arrive}: $timeArr'),
                            const SizedBox(height: 4),
                            Text(addr, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ]),
                        ),
                        const SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('€${e.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(status, style: TextStyle(color: color)),
                        ]),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<TripLogEntry> _filter(List<TripLogEntry> all) {
    final now = DateTime.now();
    late DateTime start;
    switch (filter) {
      case HistoryFilter.today:
        start = DateTime(now.year, now.month, now.day); break;
      case HistoryFilter.week:
        final monday = now.subtract(Duration(days: (now.weekday - DateTime.monday)));
        start = DateTime(monday.year, monday.month, monday.day); break;
      case HistoryFilter.month:
        start = DateTime(now.year, now.month, 1); break;
      case HistoryFilter.year:
        start = DateTime(now.year, 1, 1); break;
    }
    return all.where((e) => (e.end ?? e.start).isAfter(start)).toList();
  }

  String _fmtTime(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

class _TripDetails extends StatelessWidget {
  final TripLogEntry entry;
  const _TripDetails({required this.entry});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final app = context.read<AppState>();
    final customer = app.customers[entry.customerId];
    final name = customer?.name ?? t.customer;
    final rating = customer?.rating;

    return Scaffold(
      appBar: AppBar(title: Text(t.details)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            Expanded(child: Text(name, style: Theme.of(context).textTheme.titleLarge)),
            if (rating != null) RatingStars(rating: rating),
          ]),
          const SizedBox(height: 12),
          _kv(t.status, entry.cancelled ? t.statusCancelled : t.statusCompleted),
          const Divider(height: 28),
          _kv(t.pickup, entry.from.address ?? '(${entry.from.lat}, ${entry.from.lon})',
              sub: '(${entry.from.lat.toStringAsFixed(5)}, ${entry.from.lon.toStringAsFixed(5)})'),
          _kv(t.dropoff, entry.to.address ?? '(${entry.to.lat}, ${entry.to.lon})',
              sub: '(${entry.to.lat.toStringAsFixed(5)}, ${entry.to.lon.toStringAsFixed(5)})'),
          const SizedBox(height: 12),
          _kv(t.depart, _fmt(entry.start)),
          _kv(t.arrive, entry.end == null ? '-' : _fmt(entry.end!)),
          _kv(t.durationLabel, _fmtDur(entry.duration)),
          _kv(t.earningsLabel, '€${entry.price.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, {String? sub}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(k, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(v),
              if (sub != null) Text(sub, style: const TextStyle(fontSize: 12)),
            ]),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _fmtDur(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h}h ${m}m';
  }
}
