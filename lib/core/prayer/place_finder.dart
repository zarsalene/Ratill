import 'package:geolocator/geolocator.dart';

import 'prayer_times.dart';

enum PlaceError { serviceOff, denied, deniedForever, failed }

/// Either a [place] or the [error] that stopped it.
class PlaceResult {
  const PlaceResult.found(Place this.place) : error = null;
  const PlaceResult.failed(PlaceError this.error) : place = null;
  final Place? place;
  final PlaceError? error;
}

/// Finds the phone's place once, at city level (coarse permission, low
/// accuracy), rounded to about 1 km. Nothing is sent over the network by this
/// app: the position is only used to compute prayer times on the phone.
/// Shows the system permission prompt when needed: explain why before calling.
Future<PlaceResult> findPlace() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return const PlaceResult.failed(PlaceError.serviceOff);
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) return const PlaceResult.failed(PlaceError.deniedForever);
    if (permission == LocationPermission.denied) return const PlaceResult.failed(PlaceError.denied);
    // A last fix is fine only when it is fresh: an old one may be another city.
    final last = await Geolocator.getLastKnownPosition();
    final fresh = last != null && DateTime.now().difference(last.timestamp) < const Duration(hours: 1);
    final pos = (fresh ? last : null) ??
        await Geolocator.getCurrentPosition(
          locationSettings: AndroidSettings(accuracy: LocationAccuracy.low, timeLimit: const Duration(seconds: 30)),
        );
    return PlaceResult.found(Place.rounded(pos.latitude, pos.longitude));
  } catch (_) {
    return const PlaceResult.failed(PlaceError.failed);
  }
}
