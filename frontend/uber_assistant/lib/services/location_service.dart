import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<({double lat, double lon})?> getPositionOrNull() async {
    try {
      final hasService = await Geolocator.isLocationServiceEnabled();
      if (!hasService) return null;

      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.deniedForever || p == LocationPermission.denied) {
        return null;
      }

      // try fast, then fallback to last known
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: const Duration(seconds: 3),
        );
        return (lat: pos.latitude, lon: pos.longitude);
      } catch (_) {
        final last = await Geolocator.getLastKnownPosition();
        if (last == null) return null;
        return (lat: last.latitude, lon: last.longitude);
      }
    } catch (_) {
      return null;
    }
  }
}
