import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../widgets/rating_stars.dart';
import '../widgets/rounded_card.dart';
import '../constants.dart';
import 'package:permission_handler/permission_handler.dart';
// add seeder
import '../dev/mock_seed.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _ctrl = PageController();
  int _ix = 0;
  bool _permOk = false;
  String? _selectedDriverId;

  // toggle to seed mock data (default ON)
  bool _seedMockData = true;

  // local goal sliders
  double _gEarnings = K.dailyGoalEarnings;
  double _gTrips = K.dailyGoalTrips.toDouble();
  double _gDrive = K.dailyGoalDriveMinutes.toDouble();
  double _gBreak = K.dailyGoalBreakMinutes.toDouble();
  double _gBreaks = K.dailyGoalBreaks.toDouble();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final app = context.read<AppState>();
      await app.refreshPermissions();
      setState(() {
        _permOk = app.hasMinimumLocationPermission;
        // init local goals from persisted/app state
        _gEarnings = app.goalEarnings;
        _gTrips = app.goalTrips.toDouble();
        _gDrive = app.goalDriveMinutes.toDouble();
        _gBreak = app.goalBreakMinutes.toDouble();
        _gBreaks = app.goalBreaks.toDouble();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final app = context.watch<AppState>();

    // dark bg consistent with rest of app
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0A0A) : Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _ix = i),
                children: [
                  _introSlide(t.onboardingTitle1, t.onboardingBody1, 'assets/images/onboarding_1.png'),
                  _introSlide(t.onboardingTitle2, t.onboardingBody2, 'assets/images/onboarding_2.png'),
                  _introSlide(t.onboardingTitle3, t.onboardingBody3, 'assets/images/onboarding_3.png'),
                  _permissionsStep(context, t, app),              // 3
                  _goalsStep(context),                            // 4 (updated)
                  _driverPickStep(context, app),                  // 5
                  _allSet(context, t, 'assets/images/onboarding_4.png'), // 6
                ],
              ),
            ),
            _navBar(context, app, t),
          ],
        ),
      ),
    );
  }

  Widget _navBar(BuildContext context, AppState app, AppLocalizations t) {
    // enable "Next" on driver step only when a driver is selected
    final canNext = switch (_ix) {
      5 => _selectedDriverId != null,
      _ => true,
    };
    final last = _ix >= 6;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          if (_ix > 0)
            TextButton(
              onPressed: () => _ctrl.previousPage(duration: const Duration(milliseconds: 220), curve: Curves.easeOut),
              child: Text(t.back),
            )
          else
            const SizedBox(width: 64),
          const Spacer(),
          TextButton(
            onPressed: !canNext
                ? null
                : () async {
              if (_ix == 3) {
                // permissions step: if already granted, go next; else prompt
                if (_permOk) {
                  _ctrl.nextPage(duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
                } else {
                  await _handlePermissionFlow(context);
                }
                return;
              }
              if (_ix == 4) {
                // save goals to app state
                await app.setGoals(
                  earnings: _gEarnings.roundToDouble(),
                  trips: _gTrips.round(),
                  driveMinutes: _gDrive.round(),
                  breakMinutes: _gBreak.round(),
                  breaks: _gBreaks.round(),
                );
              }
              if (_ix == 5) {
                // save driver selection
                final id = _selectedDriverId!;
                final d = app.drivers[id]!;
                await app.setDriver(d);
              }
              if (last) {
                // seed mock data if user kept the toggle ON (default)
                if (_seedMockData) {
                  await MockSeed.seedIfEmpty(data: app.dataService, customers: app.customers);
                  await app.reloadLocalCaches(); // reflect immediately
                }
                await app.setSeenOnboarding();
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, '/home');
              } else {
                _ctrl.nextPage(duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
              }
            },
            child: Text(last ? t.letsGo : t.next),
          ),
        ],
      ),
    );
  }

  Widget _introSlide(String title, String body, String img) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Center(child: Image.asset(img, fit: BoxFit.contain))),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _permissionsStep(BuildContext context, AppLocalizations t, AppState app) {
    final showWarn = app.needsAlwaysOnBanner;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.permTitle, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(t.permBody),
          const SizedBox(height: 16),

          // main permission card (rounded, no squish)
          RoundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(_permOk ? Icons.check_circle : Icons.location_on_outlined,
                      color: _permOk ? Colors.green : null),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_permOk ? t.permGranted : t.permAllow,
                            style: Theme.of(context).textTheme.titleMedium),
                        if (!_permOk) ...[
                          const SizedBox(height: 4),
                          Text(t.permAllowSubtitle, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _handlePermissionFlow(context),
                    child: Text(_permOk ? t.checkAgain : t.permAllow),
                  ),
                ),
              ],
            ),
          ),

          if (showWarn) ...[
            const SizedBox(height: 12),
            _alwaysOnCard(context, t),
          ],
          const Spacer(),
        ],
      ),
    );
  }

  Widget _alwaysOnCard(BuildContext context, AppLocalizations t) {
    return Container(
      decoration: BoxDecoration(
        color: K.warnOrange,
        borderRadius: const BorderRadius.all(Radius.circular(K.corner)),
        border: Border.all(color: Colors.orange.withOpacity(0.25)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.error_outline, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(child: Text(t.permAlwaysBanner)),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/location-help'),
            child: Text(t.learnHow),
          ),
        ),
      ]),
    );
  }

  // ---------- GOALS STEP (updated formatting) ----------
  String _fmtValue({
    required double value,
    String? prefix,
    String? suffix,
  }) {
    final iv = value.round();
    if (prefix != null) return '$prefix$iv';
    if (suffix != null) return '$iv $suffix';
    return '$iv';
  }

  Widget _goalSlider({
    required BuildContext context,
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    String? unitPrefix,
    String? unitSuffix,
    required ValueChanged<double> onChanged,
  }) {
    final labelStyle = Theme.of(context).textTheme.labelLarge;
    final valueStyle = labelStyle?.copyWith(fontWeight: FontWeight.w600);

    final labelText = _fmtValue(value: value, prefix: unitPrefix, suffix: unitSuffix);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: labelStyle)),
            Text(
              labelText,
              style: valueStyle,
              textAlign: TextAlign.right,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          // This shows on the value indicator (for discrete sliders) and updates live.
          label: labelText,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _goalsStep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Personal goals', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('Adjust your daily targets to your preference.'),
        const SizedBox(height: 16),

        RoundedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _goalSlider(
                context: context,
                title: 'Daily gains',
                value: _gEarnings,
                min: 0,
                max: 200,
                divisions: 200,
                unitPrefix: '€',
                onChanged: (v) => setState(() => _gEarnings = v),
              ),
              const SizedBox(height: 8),
              _goalSlider(
                context: context,
                title: 'Completed trips',
                value: _gTrips,
                min: 0,
                max: 30,
                divisions: 30,
                onChanged: (v) => setState(() => _gTrips = v),
              ),
              const SizedBox(height: 8),
              _goalSlider(
                context: context,
                title: 'Drive time',
                value: _gDrive,
                min: 0,
                max: 600,
                divisions: 120,
                unitSuffix: 'min',
                onChanged: (v) => setState(() => _gDrive = v),
              ),
              const SizedBox(height: 8),
              _goalSlider(
                context: context,
                title: 'Break time',
                value: _gBreak,
                min: 0,
                max: 240,
                divisions: 80,
                unitSuffix: 'min',
                onChanged: (v) => setState(() => _gBreak = v),
              ),
              const SizedBox(height: 8),
              _goalSlider(
                context: context,
                title: 'Breaks',
                value: _gBreaks,
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: (v) => setState(() => _gBreaks = v),
              ),
            ],
          ),
        ),
        const Spacer(),
      ]),
    );
  }
  // ---------- end GOALS STEP ----------

  Widget _driverPickStep(BuildContext context, AppState app) {
    final t = AppLocalizations.of(context)!;
    final items = app.drivers.values.toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t.selectDriver, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(t.selectDriverBody),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedDriverId,
          isExpanded: true,
          decoration: const InputDecoration(),
          items: items.map((d) {
            return DropdownMenuItem<String>(
              value: d.id,
              child: Row(
                children: [
                  Expanded(child: Text(d.name, style: const TextStyle(fontSize: 16))),
                  RatingStars(rating: d.rating),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() => _selectedDriverId = v),
        ),
        const Spacer(),
      ]),
    );
  }

  Widget _allSet(BuildContext context, AppLocalizations t, String img) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Center(child: Image.asset(img, fit: BoxFit.contain))),
        const SizedBox(height: 24),
        Text(t.allSetTitle, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Text(t.allSetBody),
        const SizedBox(height: 12),

        // toggle to seed mock/demo data
        RoundedCard(
          child: SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(t.seedMockTitle),
            subtitle: Text(t.seedMockSubtitle),
            value: _seedMockData,
            onChanged: (v) => setState(() => _seedMockData = v),
            secondary: const Icon(Icons.auto_awesome),
          ),
        ),

        const SizedBox(height: 8),
      ]),
    );
  }

  Future<void> _handlePermissionFlow(BuildContext context) async {
    final app = context.read<AppState>();
    final status = await app.requestWhenInUse();
    await app.refreshPermissions();

    if (status.isGranted) {
      setState(() => _permOk = true);
      return;
    }

    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      if (!mounted) return;
      // explain that "Allow all the time" is in system settings
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(AppLocalizations.of(context)!.permDeniedTitle,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.permDeniedBody),
            const SizedBox(height: 12),
            Row(children: [
              OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.exitApp)),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: () async {
                  await app.openAppSettings(); // opens app settings page
                  if (mounted) Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.openSettings),
              ),
            ]),
            const SizedBox(height: 12),
          ]),
        ),
      );
    }
  }
}
