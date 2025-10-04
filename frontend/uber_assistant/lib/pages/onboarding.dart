import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uber_assistant/l10n/app_localizations.dart';
import '../constants.dart';
import '../services/permission_service.dart';
import '../providers/app_state.dart';
import 'package:provider/provider.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _ctrl = PageController();
  final _perm = PermissionService();

  int _ix = 0;
  bool _permOk = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _ix = i),
                children: [
                  _illustrated(
                    img: 'assets/images/onboarding_1.png',
                    title: t.onboardingTitle1,
                    body: t.onboardingBody1,
                  ),
                  _illustrated(
                    img: 'assets/images/onboarding_2.png',
                    title: t.onboardingTitle2,
                    body: t.onboardingBody2,
                  ),
                  _illustrated(
                    img: 'assets/images/onboarding_3.png',
                    title: t.onboardingTitle3,
                    body: t.onboardingBody3,
                  ),
                  _permissionsStep(context),
                  _allSet(t),
                ],
              ),
            ),
            _navBar(context),
          ],
        ),
      ),
    );
  }

  Widget _navBar(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          if (_ix > 0)
            TextButton(
              onPressed: () => _ctrl.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
              child: const Text('Back'),
            )
          else
            const SizedBox(width: 64),
          const Spacer(),
          TextButton(
            onPressed: () async {
              if (_ix == 3) {
                await _requestPerms(context);
              }
              if (_ix == 4) {
                await context.read<AppState>().setSeenOnboarding();
              }
              if (_ix < 4) {
                _ctrl.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
              }
            },
            child: Text(_ix == 4 ? t.letsGo : 'Next'),
          ),
        ],
      ),
    );
  }

  Widget _illustrated({required String img, required String title, required String body}) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Expanded(child: Center(child: Image.asset(img, fit: BoxFit.contain))),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _permissionsStep(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(t.permTitle, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(t.permBody),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(_permOk ? Icons.check_circle : Icons.location_on),
            title: Text(t.permAllow),
            trailing: FilledButton(
              onPressed: () => _requestPerms(context),
              child: Text(t.permAllow),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Future<void> _requestPerms(BuildContext context) async {
    final status = await _perm.requestLocation();
    if (status.isGranted) {
      setState(() => _permOk = true);
      _ctrl.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      return;
    }
    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => _deniedSheet(context),
      );
    }
  }

  Widget _deniedSheet(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t.permDeniedTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(t.permDeniedBody),
        const SizedBox(height: 12),
        Row(children: [
          OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(t.exitApp)),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: () async {
              if (Platform.isIOS || !await Permission.location.shouldShowRequestRationale) {
                await _perm.openAppSettingsScreen();
              }
              if (mounted) Navigator.pop(context);
            },
            child: Text(t.openSettings),
          ),
        ]),
        const SizedBox(height: 12),
      ]),
    );
  }

  Widget _allSet(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 16),
        Text(t.allSetTitle, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(t.allSetBody),
        const Spacer(),
      ]),
    );
  }
}
