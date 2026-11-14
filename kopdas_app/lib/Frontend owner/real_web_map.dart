// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class RealLiveGoogleMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final int zoom;
  final List<Map<String, dynamic>> staffList;
  final String focusedStaffId;
  final ValueChanged<String>? onStaffSelected;

  const RealLiveGoogleMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 14,
    this.staffList = const [],
    this.focusedStaffId = '',
    this.onStaffSelected,
  });

  @override
  State<RealLiveGoogleMap> createState() => _RealLiveGoogleMapState();
}

class _RealLiveGoogleMapState extends State<RealLiveGoogleMap> {
  late final String _viewId;
  html.IFrameElement? _iframeElement;
  StreamSubscription<html.MessageEvent>? _messageSub;

  @override
  void initState() {
    super.initState();
    _viewId = 'leaflet-map-${DateTime.now().microsecondsSinceEpoch}';
    _registerMap();

    // Listen to messages from inside the map iframe
    _messageSub = html.window.onMessage.listen((event) {
      try {
        final data = event.data;
        if (data is Map && data['type'] == 'KOPDAS_SELECT_STAFF') {
          final String staffId = data['id']?.toString() ?? '';
          if (staffId.isNotEmpty && widget.onStaffSelected != null) {
            widget.onStaffSelected!(staffId);
          }
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    super.dispose();
  }

  String _buildMapHtml() {
    final teamsData = widget.staffList.map((s) => {
      'id': s['id']?.toString() ?? '',
      'name': s['name']?.toString() ?? '',
      'cart_id': s['cart_id']?.toString() ?? '',
      'location': s['location']?.toString() ?? '',
      'role': s['role']?.toString() ?? '',
      'operational_status': s['operational_status']?.toString() ?? 'ACTIVE_SELLING',
      'clock_in': s['clock_in']?.toString() ?? '',
      'current_stock': s['current_stock'] is num ? s['current_stock'] : 0,
      'morning_stock': s['morning_stock'] is num ? s['morning_stock'] : 0,
      'cups_sold': s['cups_sold'] is num ? s['cups_sold'] : 0,
      'cash': s['cash'] is num ? s['cash'] : 0,
      'qris': s['qris'] is num ? s['qris'] : 0,
      'lat': (s['lat'] is num) ? (s['lat'] as num).toDouble() : -6.2000,
      'lng': (s['lng'] is num) ? (s['lng'] as num).toDouble() : 106.8200,
      'phone': s['phone']?.toString() ?? '',
    }).toList();

    final teamsJson = jsonEncode(teamsData);
    final focusedId = jsonEncode(widget.focusedStaffId);
    final centerLat = widget.latitude;
    final centerLng = widget.longitude;
    final zoom = widget.zoom;

    return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    html, body, #map { width: 100%; height: 100%; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; overflow: hidden; }
    .custom-pin {
      display: flex;
      flex-direction: column;
      align-items: center;
      cursor: pointer;
    }
    .pin-badge {
      background: #1E3932;
      color: #ffffff;
      font-size: 11px;
      font-weight: 700;
      padding: 3px 8px;
      border-radius: 6px;
      box-shadow: 0 2px 6px rgba(0,0,0,0.3);
      white-space: nowrap;
      border: 1.5px solid #ffffff;
      margin-bottom: 3px;
      transition: transform 0.15s ease;
    }
    .custom-pin:hover .pin-badge {
      transform: scale(1.08);
    }
    .pin-badge.low {
      background: #DC2626;
      border-color: #FEE2E2;
    }
    .pin-badge.standby {
      background: #475569;
    }
    .pin-icon {
      width: 32px;
      height: 32px;
      border-radius: 50%;
      background: #1E3932;
      border: 2.5px solid #ffffff;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 3px 8px rgba(0,0,0,0.35);
      color: #ffffff;
      font-size: 14px;
    }
    .pin-icon.low {
      background: #DC2626;
    }
    .pin-icon.standby {
      background: #64748B;
    }
    .leaflet-popup-content-wrapper {
      border-radius: 10px;
      padding: 0;
      overflow: hidden;
      box-shadow: 0 8px 24px rgba(0,0,0,0.25);
    }
    .leaflet-popup-content {
      margin: 0 !important;
      line-height: 1.5;
      font-size: 12px;
      width: 270px;
    }
    .pop-head {
      background: #1E3932;
      color: #ffffff;
      padding: 10px 14px;
      font-weight: bold;
      font-size: 13px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .pop-body {
      padding: 12px 14px;
      background: #ffffff;
      color: #1F2937;
    }
    .pop-row {
      display: flex;
      justify-content: space-between;
      margin-bottom: 6px;
      font-size: 11.5px;
    }
    .pop-lbl {
      color: #6B7280;
    }
    .pop-val {
      font-weight: 600;
      color: #111827;
      text-align: right;
    }
    .pop-alert {
      color: #DC2626 !important;
      font-weight: 700 !important;
    }
  </style>
</head>
<body>
  <div id="map"></div>
  <script>
    var map = L.map('map', { zoomControl: true }).setView([$centerLat, $centerLng], $zoom);
    L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
      maxZoom: 19,
      attribution: '© OpenStreetMap, © CARTO'
    }).addTo(map);

    var markers = {};
    var staff = $teamsJson;
    var focusedId = $focusedId;

    staff.forEach(function(s) {
      var isLow = s.current_stock < 20 && s.operational_status === 'ACTIVE_SELLING';
      var isStandby = s.operational_status !== 'ACTIVE_SELLING';
      var badgeCls = isLow ? 'pin-badge low' : (isStandby ? 'pin-badge standby' : 'pin-badge');
      var iconCls = isLow ? 'pin-icon low' : (isStandby ? 'pin-icon standby' : 'pin-icon');

      var cartName = s.cart_id ? s.cart_id.split(' ')[0] : 'GRB';
      var myIcon = L.divIcon({
        className: 'custom-pin',
        html: '<div class="' + badgeCls + '">' + cartName + ' • ' + s.name + '</div>' +
              '<div class="' + iconCls + '">☕</div>',
        iconSize: [140, 56],
        iconAnchor: [70, 52]
      });

      var marker = L.marker([s.lat, s.lng], { icon: myIcon }).addTo(map);
      markers[s.id] = marker;

      var popHtml = '<div class="pop-head">' +
        '<span>' + s.name + ' (' + cartName + ')</span>' +
        '<span style="font-size:10px;background:rgba(255,255,255,0.25);padding:2px 6px;border-radius:4px;">' + (isStandby ? 'Standby' : 'Jualan') + '</span>' +
        '</div>' +
        '<div class="pop-body">' +
        '<div class="pop-row"><span class="pop-lbl">Titik Lapak:</span><span class="pop-val">' + s.location + '</span></div>' +
        '<div class="pop-row"><span class="pop-lbl">Sisa Stok:</span><span class="pop-val ' + (isLow ? 'pop-alert' : '') + '">' + s.current_stock + ' Cup ' + (isLow ? '(Menipis!)' : '') + '</span></div>' +
        '<div class="pop-row"><span class="pop-lbl">Total Terjual:</span><span class="pop-val">' + s.cups_sold + ' Cup</span></div>' +
        '<div class="pop-row"><span class="pop-lbl">Kas Tunai:</span><span class="pop-val">Rp ' + Number(s.cash).toLocaleString('id-ID') + '</span></div>' +
        '<div class="pop-row"><span class="pop-lbl">QRIS Masuk:</span><span class="pop-val">Rp ' + Number(s.qris).toLocaleString('id-ID') + '</span></div>' +
        '<div class="pop-row"><span class="pop-lbl">Mulai Shift:</span><span class="pop-val">' + s.clock_in + '</span></div>' +
        '<div class="pop-row"><span class="pop-lbl">No. Telepon:</span><span class="pop-val">' + s.phone + '</span></div>' +
        '<div class="pop-row"><span class="pop-lbl">Koordinat GPS:</span><span class="pop-val" style="font-size:10px;">' + s.lat + ', ' + s.lng + '</span></div>' +
        '</div>';

      marker.bindPopup(popHtml);

      marker.on('click', function() {
        if (window.parent) {
          window.parent.postMessage({ type: 'KOPDAS_SELECT_STAFF', id: s.id }, '*');
        }
      });
    });

    if (focusedId && markers[focusedId]) {
      setTimeout(function() {
        markers[focusedId].openPopup();
      }, 400);
    }

    window.addEventListener('message', function(e) {
      if (e.data && e.data.type === 'FOCUS_PIN' && e.data.id && markers[e.data.id]) {
        var m = markers[e.data.id];
        map.setView(m.getLatLng(), 17, { animate: true });
        m.openPopup();
      }
    });
  </script>
</body>
</html>''';
  }

  void _registerMap() {
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final iframe = html.IFrameElement()
        ..srcdoc = _buildMapHtml()
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true;
      _iframeElement = iframe;
      return iframe;
    });
  }

  @override
  void didUpdateWidget(covariant RealLiveGoogleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedStaffId != widget.focusedStaffId) {
      // Send message to focus without reloading iframe
      if (_iframeElement != null && _iframeElement!.contentWindow != null) {
        _iframeElement!.contentWindow!.postMessage({
          'type': 'FOCUS_PIN',
          'id': widget.focusedStaffId,
        }, '*');
      }
    } else if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude ||
        oldWidget.zoom != widget.zoom) {
      if (_iframeElement != null) {
        _iframeElement!.srcdoc = _buildMapHtml();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
