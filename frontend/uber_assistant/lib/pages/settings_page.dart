import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';
import '../widgets/rating_stars.dart';
import '../constants.dart';
import '../main.dart';

import '../services/local_data_service.dart';
import '../services/notification_service.dart';
import '../services/websocket_service.dart';
import '../services/permission_service.dart';
import '../services/location_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = AppLocalizations.of(context)!;

    final driverItems = app.drivers.values.toList()
      ..sort((a,b) => a.name.compareTo(b.name));

    final canShowSystemLang = ['en','nl'].contains(Localizations.localeOf(context).languageCode.toLowerCase());
    final langOptions = <DropdownMenuItem<AppLanguage>>[
      if (canShowSystemLang)
        DropdownMenuItem(value: AppLanguage.system, child: Text(t.langSystem)),
      DropdownMenuItem(value: AppLanguage.en, child: const Text('English')),
      DropdownMenuItem(value: AppLanguage.nl, child: const Text('Nederlands')),
    ];

    final themeOptions = <DropdownMenuItem<AppThemeMode>>[
      DropdownMenuItem(value: AppThemeMode.system, child: Text(t.themeSystem)),
      DropdownMenuItem(value: AppThemeMode.light, child: Text(t.themeLight)),
      DropdownMenuItem(value: AppThemeMode.dark, child: Text(t.themeDark)),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t.settingsGeneral, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          // language
          ListTile(
            title: Text(t.language),
            trailing: IntrinsicWidth(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<AppLanguage>(
                  value: app.language,
                  alignment: Alignment.centerRight,
                  isDense: true,
                  onChanged: (v) { if (v != null) app.setLanguage(v); },
                  items: langOptions,
                ),
              ),
            ),
          ),
          // theme
          ListTile(
            title: Text(t.theme),
            trailing: IntrinsicWidth(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<AppThemeMode>(
                  value: app.themeMode,
                  alignment: Alignment.centerRight,
                  isDense: true,
                  onChanged: (v) { if (v != null) app.setThemeMode(v); },
                  items: themeOptions,
                ),
              ),
            ),
          ),

          // server ip
          ListTile(
            title: Text(t.serverIp),
            subtitle: Text(app.serverIp),
            trailing: OutlinedButton(
              onPressed: () async {
                final ctrl = TextEditingController(text: app.serverIp);
                final v = await showDialog<String>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(t.serverIp),
                    content: TextField(controller: ctrl, decoration: InputDecoration(hintText: K.defaultServerIp)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
                      FilledButton(onPressed: () => Navigator.pop(context, ctrl.text), child: Text(t.save)),
                    ],
                  ),
                );
                if (v != null) { await app.setServerIp(v); }
              },
              child: Text(t.edit),
            ),
          ),

          // driver select (pretty dropdown)
          ListTile(
            title: Text(t.selectDriver),
            subtitle: app.driver == null ? Text(t.none) : Row(
              children: [
                Expanded(child: Text(app.driver!.name)),
                RatingStars(rating: app.driver!.rating),
              ],
            ),
            onTap: () async {
              final v = await showModalBottomSheet<String>(
                context: context,
                showDragHandle: true,
                builder: (_) => ListView(
                  padding: const EdgeInsets.all(16),
                  children: driverItems.map((d) => ListTile(
                    title: Row(
                      children: [
                        Expanded(child: Text(d.name)),
                        RatingStars(rating: d.rating),
                      ],
                    ),
                    onTap: () => Navigator.pop(context, d.id),
                  )).toList(),
                ),
              );
              if (v != null) {
                final d = app.drivers[v]!;
                await app.setDriver(d);
              }
            },
          ),

          const Divider(height: 32),

          // about & privacy
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

          const Divider(height: 32),

          // wipe app data
          ListTile(
            title: Text(t.wipeData, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            trailing: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(t.wipeConfirmTitle),
                  content: Text(t.wipeConfirmBody),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.cancel)),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(t.delete, style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (ok == true) {
                await app.wipeAppData();

                if (context.mounted) {
                  // fresh services & state (avoid reusing old instances)
                  final data = LocalDataService();
                  final notif = NotificationService();
                  final ws = WebSocketService();
                  final perms = PermissionService();
                  final loc = LocationService();

                  final newApp = AppState(data, notif, ws, perms, loc);
                  await notif.init();
                  await newApp.init();

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider<AppState>.value(
                        value: newApp,
                        child: const UberAssistantApp(),
                      ),
                    ),
                        (_) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
