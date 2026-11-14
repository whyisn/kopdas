// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import '../../../models/location.dart';
import 'seller_map_controller.dart';

const _channel = 'KOPDAS_SELLER_MAP';

/// Peta interaktif Leaflet + OpenStreetMap dalam iframe (web).
/// Pin dapat digeser, peta dapat diketuk, heatmap keramaian & GPS tersedia.
/// Komunikasi dua arah via postMessage dengan [SellerMapController].
class SellerMapView extends StatefulWidget {
  final SellerMapController controller;
  final double initialLat;
  final double initialLng;
  final int initialZoom;
  final double? pinLat;
  final double? pinLng;
  final List<LocationModel> initialSaved;

  const SellerMapView({
    super.key,
    required this.controller,
    required this.initialLat,
    required this.initialLng,
    this.initialZoom = 15,
    this.pinLat,
    this.pinLng,
    this.initialSaved = const [],
  });

  @override
  State<SellerMapView> createState() => _SellerMapViewState();
}

class _SellerMapViewState extends State<SellerMapView> {
  late final String _viewId;
  html.IFrameElement? _iframe;
  StreamSubscription<html.MessageEvent>? _messageSub;
  bool _ready = false;
  final List<Map<String, dynamic>> _pendingCommands = [];

  @override
  void initState() {
    super.initState();
    _viewId = 'kopdas-seller-map-${DateTime.now().microsecondsSinceEpoch}';
    widget.controller.sendCommand = _sendOrQueue;
    _registerView();
    _messageSub = html.window.onMessage.listen(_onMessage);
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    if (widget.controller.sendCommand == _sendOrQueue) {
      widget.controller.sendCommand = null;
    }
    super.dispose();
  }

  void _sendOrQueue(Map<String, dynamic> command) {
    if (!_ready || _iframe?.contentWindow == null) {
      _pendingCommands.add(command);
      return;
    }
    _iframe!.contentWindow!.postMessage(command, '*');
  }

  void _flushPending() {
    for (final command in _pendingCommands) {
      _iframe?.contentWindow?.postMessage(command, '*');
    }
    _pendingCommands.clear();
  }

  void _onMessage(html.MessageEvent event) {
    final data = event.data;
    if (data is! Map) return;
    if (data['channel'] != _channel || data['id'] != _viewId) return;
    final type = data['type'] as String? ?? '';
    if (type == 'READY') {
      setState(() => _ready = true);
      _flushPending();
      return;
    }
    final map = <String, dynamic>{};
    data.forEach((key, value) => map[key.toString()] = value);
    widget.controller.onEvent?.call(SellerMapEvent.fromJson(map));
  }

  void _registerView() {
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final iframe = html.IFrameElement()
        ..srcdoc = _buildHtml()
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'geolocation'
        ..allowFullscreen = true;
      _iframe = iframe;
      return iframe;
    });
  }

  String _buildHtml() {
    final config = jsonEncode({
      'mapId': _viewId,
      'lat': widget.initialLat,
      'lng': widget.initialLng,
      'zoom': widget.initialZoom,
      'pin': (widget.pinLat != null && widget.pinLng != null)
          ? {'lat': widget.pinLat, 'lng': widget.pinLng}
          : null,
      'saved': [
        for (final l in widget.initialSaved)
          {'id': l.id, 'name': l.name, 'lat': l.latitude, 'lng': l.longitude, 'active': l.isActive},
      ],
    });

    return '''<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://unpkg.com/leaflet.heat@0.2.0/dist/leaflet-heat.js"></script>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  html, body, #map { width: 100%; height: 100%; overflow: hidden; background: #EDE4D3;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }
  .leaflet-container { cursor: grab; }
  .leaflet-container:active { cursor: grabbing; }

  /* Pin titik jualan (teardrop kopi) */
  .kp-wrap { position: relative; width: 120px; height: 80px; }
  .kp-label { position: absolute; top: 0; left: 50%; transform: translateX(-50%);
    background: #2B2118; color: #FAEDCD; font-size: 10px; font-weight: 700;
    letter-spacing: .3px; padding: 3px 9px; border-radius: 7px; white-space: nowrap;
    box-shadow: 0 3px 8px rgba(43,33,24,.35); border: 1px solid rgba(255,255,255,.25); }
  .kp-body { position: absolute; left: 39px; top: 24px; width: 42px; height: 42px;
    background: linear-gradient(135deg, #8A6A4F 0%, #6F4E37 45%, #4A3525 100%);
    border: 3px solid #ffffff; border-radius: 50% 50% 50% 0;
    transform: rotate(-45deg); box-shadow: 0 6px 16px rgba(43,33,24,.45);
    display: flex; align-items: center; justify-content: center; cursor: grab; }
  .kp-body:active { cursor: grabbing; }
  .kp-body svg { transform: rotate(45deg); width: 20px; height: 20px; fill: #FAEDCD; }
  .kp-pulse { position: absolute; left: 60px; top: 75px; width: 26px; height: 10px;
    transform: translate(-50%, -50%); border-radius: 50%;
    background: rgba(111,78,55,.40); animation: kp-pulse 2s ease-out infinite; }
  @keyframes kp-pulse {
    0% { transform: translate(-50%, -50%) scale(.6); opacity: .55; }
    100% { transform: translate(-50%, -50%) scale(2.4); opacity: 0; }
  }

  /* Marker lokasi tersimpan */
  .sv-wrap { position: relative; width: 120px; height: 54px; cursor: pointer; }
  .sv-badge { position: absolute; top: 0; left: 50%; transform: translateX(-50%);
    background: #ffffff; color: #2B2118; font-size: 10px; font-weight: 700;
    padding: 2px 8px; border-radius: 6px; white-space: nowrap; max-width: 116px;
    overflow: hidden; text-overflow: ellipsis; border: 1px solid rgba(111,78,55,.25);
    box-shadow: 0 2px 6px rgba(43,33,24,.22); }
  .sv-dot { position: absolute; left: 45px; top: 20px; width: 30px; height: 30px;
    border-radius: 50%; border: 2.5px solid #ffffff; display: flex; align-items: center;
    justify-content: center; box-shadow: 0 3px 8px rgba(43,33,24,.35);
    background: #2A9D8F; transition: transform .15s ease; }
  .sv-wrap:hover .sv-dot { transform: scale(1.12); }
  .sv-dot.inactive { background: #94A3B8; }
  .sv-dot svg { width: 15px; height: 15px; fill: #ffffff; }
</style>
</head>
<body>
<div id="map"></div>
<script>
(function () {
  var CFG = $config;
  var CH = '$_channel';
  function post(type, extra) {
    var msg = { channel: CH, id: CFG.mapId, type: type };
    if (extra) { for (var k in extra) { msg[k] = extra[k]; } }
    window.parent.postMessage(msg, '*');
  }

  var map = L.map('map', { zoomControl: false, attributionControl: false })
    .setView([CFG.lat, CFG.lng], CFG.zoom);
  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    crossOrigin: true
  }).addTo(map);

  var heat = L.heatLayer([], {
    radius: 38, blur: 32, max: 1.0, minOpacity: 0.35,
    gradient: { 0.20: '#16A34A', 0.45: '#EAB308', 0.68: '#EF4444', 0.88: '#7F1D1D' }
  });
  var heatOn = false;

  var savedLayer = L.layerGroup().addTo(map);
  var CAFE_SVG = '<svg viewBox="0 0 24 24"><path d="M20 3H4v10c0 2.21 1.79 4 4 4h6c2.21 0 4-1.79 4-4v-3h2c1.11 0 2-.89 2-2V5c0-1.11-.89-2-2-2zm0 5h-2V5h2v3zM4 19h16v2H4z"/></svg>';
  var STORE_SVG = '<svg viewBox="0 0 24 24"><path d="M20 4H4v2h16V4zm1 10v-2l-1-5H4l-1 5v2h1v6h10v-6h4v6h2v-6h1zm-9 4H6v-4h6v4z"/></svg>';

  function renderSaved(list) {
    savedLayer.clearLayers();
    (list || []).forEach(function (s) {
      var icon = L.divIcon({
        className: 'sv-wrap',
        html: '<div class="sv-badge"></div><div class="sv-dot' + (s.active ? '' : ' inactive') + '">' + STORE_SVG + '</div>',
        iconSize: [120, 54], iconAnchor: [60, 50]
      });
      var m = L.marker([s.lat, s.lng], { icon: icon, bubblingMouseEvents: false, keyboard: false });
      m.on('click', function () { post('SAVED_CLICK', { id: s.id }); });
      m.addTo(savedLayer);
      var el = m.getElement();
      if (el) { el.querySelector('.sv-badge').textContent = s.name; }
    });
  }

  var pin = null;
  var pinIcon = L.divIcon({
    className: 'kp-wrap',
    html: '<div class="kp-label">TITIK JUALAN</div><div class="kp-body">' + CAFE_SVG + '</div><div class="kp-pulse"></div>',
    iconSize: [120, 80], iconAnchor: [60, 76]
  });
  function setPin(lat, lng, fly, zoom) {
    if (!pin) {
      pin = L.marker([lat, lng], { icon: pinIcon, draggable: true, zIndexOffset: 1000, keyboard: false, bubblingMouseEvents: false }).addTo(map);
      pin.on('dragend', function () {
        var p = pin.getLatLng();
        post('PIN_MOVED', { lat: p.lat, lng: p.lng, cause: 'drag' });
      });
    } else {
      pin.setLatLng([lat, lng]);
    }
    if (fly) { map.flyTo([lat, lng], zoom || Math.max(map.getZoom(), 16), { duration: 0.8 }); }
  }

  map.on('click', function (e) {
    setPin(e.latlng.lat, e.latlng.lng, false);
    post('PIN_MOVED', { lat: e.latlng.lat, lng: e.latlng.lng, cause: 'tap' });
  });

  var gpsCircle = null;
  function handleGps() {
    if (!navigator.geolocation) {
      post('GPS_ERR', { message: 'Browser ini tidak mendukung layanan lokasi.' });
      return;
    }
    navigator.geolocation.getCurrentPosition(function (pos) {
      var lat = pos.coords.latitude, lng = pos.coords.longitude;
      var acc = pos.coords.accuracy || 30;
      if (gpsCircle) { map.removeLayer(gpsCircle); }
      gpsCircle = L.circle([lat, lng], {
        radius: Math.max(acc, 30), color: '#6F4E37', weight: 1.5,
        fillColor: '#6F4E37', fillOpacity: 0.10
      }).addTo(map);
      setPin(lat, lng, true, 17);
      post('GPS_OK', { lat: lat, lng: lng, accuracy: acc });
    }, function (err) {
      var msgs = {
        1: 'Izin lokasi ditolak. Aktifkan izin lokasi untuk situs ini di browser.',
        2: 'Posisi tidak dapat ditentukan saat ini. Coba lagi atau geser pin manual.',
        3: 'Permintaan lokasi melebihi batas waktu. Coba lagi.'
      };
      post('GPS_ERR', { message: msgs[err.code] || 'Gagal mendapatkan lokasi perangkat.' });
    }, { enableHighAccuracy: true, timeout: 12000, maximumAge: 30000 });
  }

  window.addEventListener('message', function (e) {
    var d = e.data;
    if (!d || d.channel !== CH || d.id !== CFG.mapId) { return; }
    switch (d.type) {
      case 'SET_PIN': setPin(d.lat, d.lng, !!d.fly, d.zoom); break;
      case 'SET_HEAT':
        heat.setLatLngs((d.points || []).map(function (p) { return [p.lat, p.lng, p.intensity]; }));
        if (d.visible && !heatOn) { heat.addTo(map); heatOn = true; }
        if (!d.visible && heatOn) { map.removeLayer(heat); heatOn = false; }
        break;
      case 'SET_HEAT_VISIBLE':
        if (d.visible && !heatOn) { heat.addTo(map); heatOn = true; }
        if (!d.visible && heatOn) { map.removeLayer(heat); heatOn = false; }
        break;
      case 'SET_SAVED': renderSaved(d.locations || []); break;
      case 'FOCUS': map.flyTo([d.lat, d.lng], d.zoom || 16, { duration: 0.8 }); break;
      case 'ZOOM_BY': map.setZoom(map.getZoom() + (d.delta || 1)); break;
      case 'GET_GPS': handleGps(); break;
    }
  });

  if (CFG.pin) { setPin(CFG.pin.lat, CFG.pin.lng, false); }
  renderSaved(CFG.saved || []);
  post('READY');
})();
</script>
</body>
</html>''';
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
