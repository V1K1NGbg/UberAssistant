import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/trip_record.dart';
import '../constants.dart';

enum HistoryRange { today, week, month, year }
enum HistorySort { statusCompleted, statusCanceled, earningsLowHigh, earningsHighLow, startNewest, startOldest }

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  HistoryRange _range = HistoryRange.today;
  HistorySort _sort = HistorySort.startNewest;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    var items = app.historyForRange(_range);

    items.sort((a,b) {
      switch (_sort) {
        case HistorySort.statusCompleted:
          if (a.status == b.status) return b.start.compareTo(a.start);
          return a.status == TripStatus.completed ? -1 : 1;
        case HistorySort.statusCanceled:
          if (a.status == b.status) return b.start.compareTo(a.start);
          return a.status == TripStatus.canceled ? -1 : 1;
        case HistorySort.earningsLowHigh: return a.price.compareTo(b.price);
        case HistorySort.earningsHighLow: return b.price.compareTo(a.price);
        case HistorySort.startNewest: return b.start.compareTo(a.start);
        case HistorySort.startOldest: return a.start.compareTo(b.start);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Trip history')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              // filter gets less width to prevent overflow on sort
              Flexible(
                flex: 1,
                child: DropdownButtonFormField<HistoryRange>(
                  isExpanded: true,
                  decoration: const InputDecoration(),
                  value: _range,
                  items: const [
                    DropdownMenuItem(value: HistoryRange.today, child: Text('Today')),
                    DropdownMenuItem(value: HistoryRange.week, child: Text('This week')),
                    DropdownMenuItem(value: HistoryRange.month, child: Text('This month')),
                    DropdownMenuItem(value: HistoryRange.year, child: Text('This year')),
                  ],
                  onChanged: (v) => setState(() => _range = v ?? _range),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                flex: 2,
                child: DropdownButtonFormField<HistorySort>(
                  isExpanded: true,
                  decoration: const InputDecoration(),
                  value: _sort,
                  items: const [
                    DropdownMenuItem(value: HistorySort.startNewest, child: Text('Newest')),
                    DropdownMenuItem(value: HistorySort.startOldest, child: Text('Oldest')),
                    DropdownMenuItem(value: HistorySort.statusCompleted, child: Text('Completed first')),
                    DropdownMenuItem(value: HistorySort.statusCanceled, child: Text('Canceled first')),
                    DropdownMenuItem(value: HistorySort.earningsHighLow, child: Text('Earnings high → low')),
                    DropdownMenuItem(value: HistorySort.earningsLowHigh, child: Text('Earnings low → high')),
                  ],
                  onChanged: (v) => setState(() => _sort = v ?? _sort),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((h) => _historyTile(context, h)),
        ],
      ),
    );
  }

  Widget _historyTile(BuildContext context, TripRecord r) {
    final statusColor = r.status == TripStatus.completed ? Colors.green : Colors.red;
    final dest = r.to.address ?? '(${r.to.lat.toStringAsFixed(5)}, ${r.to.lon.toStringAsFixed(5)})';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(K.corner)),
      child: ListTile(
        title: Text('${_fmtHm(r.start)} → ${_fmtHm(r.end)}'),
        subtitle: Text(dest, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('€${r.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(r.status == TripStatus.completed ? 'Completed' : 'Canceled', style: TextStyle(color: statusColor)),
          ],
        ),
        onTap: () => showModalBottomSheet(
          context: context,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (_) => _details(r),
        ),
      ),
    );
  }

  String _fmtHm(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Widget _kv(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      SizedBox(width: 140, child: Text(k, style: Theme.of(context).textTheme.bodySmall)),
      Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600))),
    ]),
  );

  Widget _details(TripRecord r) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16 + MediaQuery.of(context).viewPadding.bottom, top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(r.customerName ?? r.customerId ?? '—'),
            subtitle: r.customerRating != null ? Text('★ ${r.customerRating!.toStringAsFixed(1)}') : null,
          ),
          const SizedBox(height: 6),
          _kv('Start', '${r.from.address ?? '(${r.from.lat}, ${r.from.lon})'}'),
          _kv('Destination', '${r.to.address ?? '(${r.to.lat}, ${r.to.lon})'}'),
          _kv('Departure', _fmtHm(r.start)),
          _kv('Arrival', _fmtHm(r.end)),
          _kv('Duration', '${r.durationMinutes.toStringAsFixed(1)} min'),
          _kv('Earnings', '€${r.price.toStringAsFixed(2)}'),
          _kv('Status', r.status == TripStatus.completed ? 'Completed' : 'Canceled'),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
