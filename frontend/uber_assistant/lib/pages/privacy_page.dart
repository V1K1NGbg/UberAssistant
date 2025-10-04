import 'package:flutter/material.dart';
import 'package:uber_assistant/l10n/app_localizations.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.privacy)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(t.privacyBody),
      ),
    );
  }
}
