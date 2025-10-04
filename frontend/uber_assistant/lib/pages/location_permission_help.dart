import 'dart:io';

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/permission_service.dart';

class LocationPermissionHelpPage extends StatelessWidget {
  const LocationPermissionHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final perm = PermissionService();

    // Android 10+ requires users to grant “Allow all the time” from Settings for background location.
    // Official docs confirm the flow and terminology. :contentReference[oaicite:3]{index=3}

    return Scaffold(
      appBar: AppBar(title: Text(t.locationHelpTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.locationHelpBody, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          if (Platform.isAndroid)
            Text(t.locationHelpAndroid, style: Theme.of(context).textTheme.bodyMedium),
          if (Platform.isIOS)
            Text(t.locationHelpiOS, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              await perm.openAppSettingsScreen(); // opens app settings. :contentReference[oaicite:4]{index=4}
            },
            child: Text(t.openSettings),
          ),
        ]),
      ),
    );
  }
}
