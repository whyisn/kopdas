import '../../../models/crowd.dart';
import '../../../models/location.dart';

/// Kejadian dari peta (iframe Leaflet) ke Flutter.
class SellerMapEvent {
  final String type; // READY, PIN_MOVED, GPS_OK, GPS_ERR, SAVED_CLICK
  final double? lat;
  final double? lng;
  final double? accuracy;
  final String? id;
  final String? message;
  final String? cause;

  const SellerMapEvent({
    required this.type,
    this.lat,
    this.lng,
    this.accuracy,
    this.id,
    this.message,
    this.cause,
  });

  factory SellerMapEvent.fromJson(Map<String, dynamic> json) {
    return SellerMapEvent(
      type: json['type'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      id: json['id'] as String?,
      message: json['message'] as String?,
      cause: json['cause'] as String?,
    );
  }
}

/// Jembatan dua arah antara halaman Lokasi Seller dan widget peta.
/// Widget web memasang [sendCommand] selama hidup; command lain diabaikan
/// dengan aman pada platform non-web (stub).
class SellerMapController {
  void Function(Map<String, dynamic> command)? sendCommand;
  void Function(SellerMapEvent event)? onEvent;

  bool get isAttached => sendCommand != null;

  void setPin(double lat, double lng, {bool fly = false, int? zoom}) {
    sendCommand?.call({
      'type': 'SET_PIN',
      'lat': lat,
      'lng': lng,
      'fly': fly,
      'zoom': ?zoom,
    });
  }

  void setHeat(List<CrowdGridPoint> points, {required bool visible}) {
    sendCommand?.call({
      'type': 'SET_HEAT',
      'visible': visible,
      'points': [
        for (final p in points) {'lat': p.lat, 'lng': p.lng, 'intensity': p.intensity},
      ],
    });
  }

  void setHeatVisible(bool visible) {
    sendCommand?.call({'type': 'SET_HEAT_VISIBLE', 'visible': visible});
  }

  void setSaved(List<LocationModel> locations) {
    sendCommand?.call({
      'type': 'SET_SAVED',
      'locations': [
        for (final l in locations)
          {'id': l.id, 'name': l.name, 'lat': l.latitude, 'lng': l.longitude, 'active': l.isActive},
      ],
    });
  }

  void focus(double lat, double lng, {int zoom = 16}) {
    sendCommand?.call({'type': 'FOCUS', 'lat': lat, 'lng': lng, 'zoom': zoom});
  }

  void zoomBy(int delta) {
    sendCommand?.call({'type': 'ZOOM_BY', 'delta': delta});
  }

  void requestGps() {
    sendCommand?.call({'type': 'GET_GPS'});
  }
}
