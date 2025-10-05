import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../widgets/rounded_card.dart';
import '../widgets/trip_progress_card.dart';
import '../widgets/ride_request_sheet.dart';
import '../widgets/daily_report.dart';
import '../widgets/analytics_graphs.dart';
import '../widgets/emergency_button.dart';
import '../constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // App icon next to title; tint to black in light mode
            Image.asset(
              'assets/images/app_icon_new.png',
              height: 24,
              color: isDark ? null : Colors.black,
              colorBlendMode: isDark ? null : BlendMode.srcIn,
            ),
            const SizedBox(width: 8),
            Text(t.homeTitle),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.bar_chart_outlined),
              onPressed: () => Navigator.pushNamed(context, '/heatmap')),
          IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => Navigator.pushNamed(context, '/history')),
          IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, '/settings')),
        ],
      ),
      body: Consumer<AppState>(builder: (context, app, _) {
        // show motivational after app sets it
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final msg = app.motivationalMessage;
          if (msg != null) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Keep it up!'),
                content: Text(msg),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close')),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      app.setAvailable(false); // "Take a break"
                    },
                    child: const Text('Take a break'),
                  ),
                ],
              ),
            ).then((_) => app.clearMotivation());
          }
        });

        final content = <Widget>[];

        // permissions
        if (!app.hasMinimumLocationPermission) {
          content.add(_errorCard(context, Text(t.errNoLocationPermission),
              trailing: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/location-help'),
                  child: Text(t.learnHow),
                ),
              )));
        }

        if (app.needsAlwaysOnBanner) {
          content.add(
            Container(
              decoration: BoxDecoration(
                color: K.warnOrange,
                borderRadius: const BorderRadius.all(Radius.circular(K.corner)),
                border: Border.all(color: Colors.orange.withOpacity(0.25)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(child: Text(t.permAlwaysBanner)),
                        ]),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/location-help'),
                        child: Text(t.learnHow),
                      ),
                    ),
                  ]),
            ),
          );
        }
        if (!app.hasNetwork) {
          content.add(
            RoundedCard(
              child:
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.wifi_off),
                const SizedBox(width: 12),
                Expanded(child: Text(t.errNoInternet)),
              ]),
            ),
          );
        }
        if (app.lastError != null) {
          content.add(_errorCard(context, Text(app.lastError!),
              trailing: TextButton(
                  onPressed: () => app.setError(null),
                  child: Text(t.dismiss))));
        }

        // offer sheet
        if (app.pendingOffer != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
            if (!isCurrent) return;

            final req = app.pendingOffer!;
            final customer = app.customers[req.customerId];

            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => RideRequestSheet(
                request: req,
                customer: customer,
                onSkip: () {
                  app.declineOffer(req);
                  Navigator.of(ctx).maybePop();
                },
                onAccept: () {
                  app.acceptOffer(req);
                  Navigator.of(ctx).maybePop();
                },
              ),
            ).whenComplete(() {
              if (app.pendingOffer != null) app.clearPendingOffer();
            });
          });
        }

        // availability + content
        content.add(_availabilityCard(context, app, t));
        content.add(const SizedBox(height: 16));

        if (!app.available) {
          content.add(_emptyState(t.unavailable, t.statusBreak, Icons.coffee));
        } else if (app.activeTrip == null && app.queuedTrip == null) {
          content.add(_emptyState(
              t.statusNothing, t.statusWaiting, Icons.hourglass_empty));
        }

        if (app.activeTrip != null) {
          content.addAll([
            TripProgressCard(
                trip: app.activeTrip!, onArrived: () => app.iArrived()),
            if (app.queuedTrip != null) ...[
              const SizedBox(height: 12),
              RoundedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.upcoming),
                      const SizedBox(width: 6),
                      Text(t.queued,
                          style: Theme.of(context).textTheme.titleMedium)
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
                    )
                  ],
                ),
              ),
            ],
          ]);
        }

        // reports + graphs
        content.add(const SizedBox(height: 16));
        content.add(const DailyReport());
        content.add(const SizedBox(height: 12));
        content.add(const AnalyticsGraphs());
        content.add(const SizedBox(height: 12));
        content.add(
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.public),
              label: const Text('Open Heat Map'),
              onPressed: () => Navigator.pushNamed(context, '/heatmap'),
            ),
          ),
        );
        content.add(const SizedBox(height: 80)); // leave space for emergency button

        final list = ListView(padding: const EdgeInsets.all(16), children: content);

        return Stack(
          children: [
            // Pull to refresh (reloads warnings, errors, graphs, stats, connectivity, permissions)
            RefreshIndicator(
              onRefresh: () => context.read<AppState>().refreshAll(),
              child: PrimaryScrollController(
                controller: ScrollController(),
                child: list,
              ),
            ),
            // emergency button bottom-left
            Positioned(
              left: 16,
              bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
              child: const EmergencyButton(),
            ),
          ],
        );
      }),
    );
  }

  Widget _availabilityCard(
      BuildContext context, AppState app, AppLocalizations t) {
    return RoundedCard(
      child: Row(
        children: [
          Expanded(
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(app.available ? t.available : t.unavailable,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(app.available ? t.statusWaiting : t.statusBreak),
            ]),
          ),
          Switch(
            value: app.available,
            onChanged: app.driver == null
                ? null
                : (v) async {
              // if turning on and any known connection error happens, force back off
              if (v) {
                final ok = await app.tryGoOnline();
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'Could not go online. Check server IP / network.')));
                }
              } else {
                await app.setAvailable(false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String title, String subtitle, IconData icon) {
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle),
          const SizedBox(height: 8),
          AspectRatio(
              aspectRatio: 3, child: Center(child: Icon(icon, size: 56))),
        ],
      ),
    );
  }

  // slightly narrower error card consistent with other cards
  Widget _errorCard(BuildContext context, Widget child, {Widget? trailing}) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: K.cardRadius,
          side: BorderSide(
              color: Theme.of(context).colorScheme.error.withOpacity(0.25))),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(child: child),
          ]),
          if (trailing != null) ...[
            const SizedBox(height: 12),
            trailing,
          ],
        ]),
      ),
    );
  }
}
