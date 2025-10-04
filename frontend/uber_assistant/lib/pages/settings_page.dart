import 'package:flutter/material.dart';
import 'package:uber_assistant/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/driver.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t.driver, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: app.driver?.id,
            items: app.drivers.values
                .map((Driver d) => DropdownMenuItem(value: d.id, child: Text('${d.name} (${d.rating.toStringAsFixed(1)})')))
                .toList(),
            onChanged: (v) {
              if (v != null) app.setDriver(app.drivers[v]!);
            },
          ),
          const SizedBox(height: 16),
          Text(t.language, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<AppLanguage>(
            value: app.language,
            items: const [
              DropdownMenuItem(value: AppLanguage.system, child: Text('System')),
              DropdownMenuItem(value: AppLanguage.en, child: Text('English')),
              DropdownMenuItem(value: AppLanguage.nl, child: Text('Nederlands')),
            ],
            onChanged: (v) => v != null ? app.setLanguage(v) : null,
          ),
          const SizedBox(height: 16),
          Text(t.serverIp, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: app.serverIp,
            keyboardType: TextInputType.url,
            onChanged: (v) => app.setServerIp(v),
          ),
          const SizedBox(height: 24),
          ListTile(
            title: Text(t.about),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/about'),
          ),
          ListTile(
            title: Text(t.privacy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/privacy'),
          ),
        ],
      ),
    );
  }
}
