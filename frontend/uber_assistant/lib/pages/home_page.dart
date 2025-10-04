import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_assistant/l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../widgets/rounded_card.dart';
import '../widgets/trip_progress_card.dart';
import '../widgets/ride_request_sheet.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Consumer<AppState>(builder: (context, app, _) {
        // if there is a pending offer, open the sheet exactly once using captured data
        if (app.pendingOffer != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // don't open if a sheet/dialog is already on top
            final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
            if (!isCurrent) return;

            // 👉 capture immutable values NOW, so the sheet doesn't depend on provider rebuilds
            final req = app.pendingOffer!;
            final customer = app.customers[req.customerId];

            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => RideRequestSheet(
                request: req,
                customer: customer,
                onSkip: () {
                  app.declineOffer(req);
                  // the sheet closes itself; see ride_request_sheet.dart
                },
                onAccept: () {
                  app.acceptOffer(req);
                  // the sheet closes itself; see ride_request_sheet.dart
                },
              ),
            ).whenComplete(() {
              // if the user dismissed the sheet without responding, clear safely
              if (app.pendingOffer != null) {
                app.clearPendingOffer();
              }
            });
          });
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _availabilityCard(context, app),
            const SizedBox(height: 16),
            if (!app.available) _emptyState(t.unavailable, t.statusBreak),
            if (app.available && app.activeTrip == null && app.queuedTrip == null)
              _emptyState(t.statusNothing, t.statusWaiting),
            if (app.activeTrip != null) ...[
              TripProgressCard(trip: app.activeTrip!, onArrived: () => app.iArrived()),
              if (app.queuedTrip != null) ...[
                const SizedBox(height: 12),
                RoundedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.upcoming),
                        const SizedBox(width: 6),
                        Text(t.queued, style: Theme.of(context).textTheme.titleMedium),
                      ]),
                      const SizedBox(height: 8),
                      Text(app.queuedTrip!.to.address ??
                          '(${app.queuedTrip!.to.lat}, ${app.queuedTrip!.to.lon})'),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: () => app.cancelQueued(),
                          icon: const Icon(Icons.cancel),
                          label: Text(t.cancel),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        );
      }),
    );
  }

  Widget _availabilityCard(BuildContext context, AppState app) {
    final t = AppLocalizations.of(context)!;
    return RoundedCard(
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(app.available ? t.available : t.unavailable,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(app.available ? t.statusWaiting : t.statusBreak),
            ]),
          ),
          Switch(
            value: app.available,
            onChanged: app.driver == null ? null : (v) => app.setAvailable(v),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String title, String subtitle) {
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle),
          const SizedBox(height: 8),
          const AspectRatio(
            aspectRatio: 3,
            child: Center(child: Icon(Icons.hourglass_empty, size: 56)),
          ),
        ],
      ),
    );
  }
}
