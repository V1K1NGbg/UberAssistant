import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<PermissionStatus> requestLocation() async {
    final status = await Permission.location.status;
    if (status.isGranted) return status;

    final result = await Permission.location.request();
    return result;
  }

  Future<bool> isPermanentlyDenied() async {
    return (await Permission.location.status).isPermanentlyDenied;
  }

  /// Opens the OS app settings screen so the user can manually grant permission.
  Future<void> openAppSettingsScreen() async {
    await openAppSettings();
  }
}
