import 'dart:async';
import 'package:geolocator/geolocator.dart';

class SosService {
  static final SosService _instance = SosService._internal();
  factory SosService() => _instance;
  SosService._internal();

  /// Request location permission and get current position.
  /// Returns null if permission denied or location unavailable.
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// Build Google Maps URL from position.
  String mapsUrl(Position pos) =>
      'https://maps.google.com/?q=${pos.latitude},${pos.longitude}';

  /// Build SMS body with optional location.
  String buildSmsBody({Position? location, String patientName = ''}) {
    final who = patientName.isNotEmpty ? patientName : 'Someone';
    final loc = location != null
        ? '\nLocation: ${mapsUrl(location)}'
        : '\n(Location unavailable)';
    return 'SOS ALERT — $who needs immediate help!$loc\n\nSent via CareSync';
  }
}
