import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<LocationPermission> _ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException('Службы геолокации отключены');
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationPermissionException(
        'Доступ к геолокации не предоставлен',
        canOpenSettings: false,
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionException(
        'Доступ к геолокации запрещён в настройках',
        canOpenSettings: true,
      );
    }

    return permission;
  }

  Future<void> openSystemLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<Position> getCurrentPosition() async {
    await _ensurePermission();
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}

class LocationServiceException implements Exception {
  final String message;
  const LocationServiceException(this.message);

  @override
  String toString() => message;
}

class LocationPermissionException implements Exception {
  final String message;
  final bool canOpenSettings;
  const LocationPermissionException(
    this.message, {
    this.canOpenSettings = false,
  });

  @override
  String toString() => message;
}
