// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class RealLiveGoogleMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final int zoom;

  const RealLiveGoogleMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 15,
  });

  @override
  State<RealLiveGoogleMap> createState() => _RealLiveGoogleMapState();
}

class _RealLiveGoogleMapState extends State<RealLiveGoogleMap> {
  late final String _viewId;
  html.IFrameElement? _iframeElement;

  @override
  void initState() {
    super.initState();
    _viewId = 'google-maps-live-${DateTime.now().microsecondsSinceEpoch}';
    _registerMap();
  }

  void _registerMap() {
    final url = 'https://maps.google.com/maps?q=${widget.latitude},${widget.longitude}&z=${widget.zoom}&output=embed';
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = url
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
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude ||
        oldWidget.zoom != widget.zoom) {
      if (_iframeElement != null) {
        _iframeElement!.src = 'https://maps.google.com/maps?q=${widget.latitude},${widget.longitude}&z=${widget.zoom}&output=embed';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
