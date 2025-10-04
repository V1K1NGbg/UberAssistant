import 'package:flutter/material.dart';
import 'package:uber_assistant/l10n/app_localizations.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.about)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(t.aboutBody),
      ),
    );
  }
}
