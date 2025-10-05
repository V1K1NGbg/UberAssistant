import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  bool hasWhenInUsePermissionCache = false;
  bool hasAlwaysPermissionCache = false;

  Future<void> refreshStatus() async {
    final whenInUse = await Permission.location.status;
    // On both Android/iOS, check the specific "Always" status
    final always = await Permission.locationAlways.status;

    hasWhenInUsePermissionCache = whenInUse.isGranted;
    hasAlwaysPermissionCache = always.isGranted;
  }

  Future<PermissionStatus> requestWhenInUse() async => Permission.location.request();

  Future<void> openAppSettingsScreen() async {
    await openAppSettings(); // opens app's settings page (plugin API)
  }
}
