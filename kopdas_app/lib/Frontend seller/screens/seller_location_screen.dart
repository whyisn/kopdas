import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants.dart';
import '../../models/crowd.dart';
import '../../models/location.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/geocoding_service.dart';
import '../../services/seller_api.dart';
import '../../widgets/app_states.dart';
import '../../widgets/status_badge.dart';
import '../widgets/seller_map/seller_map_controller.dart';
import '../widgets/seller_map/seller_map_view.dart';

/// Halaman Lokasi Seller: peta interaktif (Leaflet/OSM di web), pencarian
/// alamat, GPS, heatmap keramaian (estimasi SIMULASI), dan penyimpanan
/// titik jualan milik seller yang login.
class SellerLocationScreen extends StatefulWidget {
  const SellerLocationScreen({super.key});

  @override
  State<SellerLocationScreen> createState() => _SellerLocationScreenState();
}

class _SellerLocationScreenState extends State<SellerLocationScreen> {
  final _api = SellerApi(sessionController.api);
  final _geo = GeocodingService();
  final _mapController = SellerMapController();
  final _searchCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  // Titik default: pusat Kota Padang (area operasi seed).
  static const _defaultLat = -0.9210;
  static const _defaultLng = 100.3540;

  bool _loading = true;
  String? _error;

  List<LocationModel> _saved = [];
  LocationModel? _focusedSaved;

  double _pinLat = _defaultLat;
  double _pinLng = _defaultLng;
  String? _address;
  bool _resolvingAddress = false;

  CrowdReport? _crowd;
  bool _crowdLoading = false;
  String? _crowdError;
  bool _heatVisible = true;
  int? _previewHour;

  bool _mapReady = false;
  bool _saving = false;
  bool _gpsBusy = false;

  bool _showResults = false;
  bool _searching = false;
  String? _searchError;
  List<GeoResult> _searchResults = [];

  int _crowdReq = 0;
  int _addrReq = 0;
  Timer? _reverseTimer;
  Timer? _gpsGuard;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  @override
  void initState() {
    super.initState();
    _mapController.onEvent = _onMapEvent;
    _nameCtrl.text = 'Lapak Saya';
    _load();
  }

  @override
  void dispose() {
    _reverseTimer?.cancel();
    _gpsGuard?.cancel();
    _mapController.onEvent = null;
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ===========================================================================
  // DATA
  // ===========================================================================

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final locs = await _api.myLocations(sessionController.userId!);
      if (!mounted) return;
      LocationModel? first;
      for (final l in locs) {
        if (l.isActive) {
          first = l;
          break;
        }
      }
      first ??= locs.isNotEmpty ? locs.first : null;

      setState(() {
        _saved = locs;
        _focusedSaved = first;
        _pinLat = first?.latitude ?? _defaultLat;
        _pinLng = first?.longitude ?? _defaultLng;
        _address = first?.address;
        _nameCtrl.text = first?.name ?? 'Lapak Saya';
        _loading = false;
      });
      _fetchCrowd();
      if (_address == null || _address!.isEmpty) {
        _resolveAddress(_pinLat, _pinLng);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _fetchCrowd() async {
    final req = ++_crowdReq;
    final lat = _pinLat;
    final lng = _pinLng;
    setState(() {
      _crowdLoading = true;
      _crowdError = null;
    });
    try {
      final report = await _api.crowdDensity(
        latitude: lat,
        longitude: lng,
        hour: _previewHour,
      );
      if (!mounted || req != _crowdReq) return;
      setState(() {
        _crowd = report;
        _crowdLoading = false;
      });
      _mapController.setHeat(report.grid, visible: _heatVisible);
    } catch (e) {
      if (!mounted || req != _crowdReq) return;
      setState(() {
        _crowdError = e.toString();
        _crowdLoading = false;
      });
    }
  }

  void _selectPoint(double lat, double lng, {String? address}) {
    _reverseTimer?.cancel();
    setState(() {
      _pinLat = lat;
      _pinLng = lng;
      _address = address;
      _resolvingAddress = address == null;
    });
    _fetchCrowd();
    if (address == null) {
      _reverseTimer = Timer(const Duration(milliseconds: 700), () {
        _resolveAddress(lat, lng);
      });
    }
  }

  Future<void> _resolveAddress(double lat, double lng) async {
    final req = ++_addrReq;
    final result = await _geo.reverse(lat, lng);
    if (!mounted || req != _addrReq) return;
    if ((lat - _pinLat).abs() > 1e-6 || (lng - _pinLng).abs() > 1e-6) return;
    setState(() {
      _address = result;
      _resolvingAddress = false;
    });
  }

  void _focusSaved(LocationModel loc) {
    setState(() {
      _focusedSaved = loc;
      _pinLat = loc.latitude;
      _pinLng = loc.longitude;
      _address = loc.address;
      _nameCtrl.text = loc.name;
    });
    _mapController.setPin(loc.latitude, loc.longitude, fly: true, zoom: 17);
    _fetchCrowd();
    if (loc.address == null || loc.address!.isEmpty) {
      _resolveAddress(loc.latitude, loc.longitude);
    }
  }

  // ===========================================================================
  // AKSI PETA
  // ===========================================================================

  void _onMapEvent(SellerMapEvent event) {
    if (!mounted) return;
    switch (event.type) {
      case 'READY':
        setState(() => _mapReady = true);
        if (_crowd != null) {
          _mapController.setHeat(_crowd!.grid, visible: _heatVisible);
        }
        break;
      case 'PIN_MOVED':
        if (event.lat != null && event.lng != null) {
          _selectPoint(event.lat!, event.lng!);
        }
        break;
      case 'GPS_OK':
        _gpsGuard?.cancel();
        setState(() => _gpsBusy = false);
        if (event.lat != null && event.lng != null) {
          _selectPoint(event.lat!, event.lng!);
          final acc = event.accuracy;
          _snack(acc != null
              ? 'Lokasi perangkat ditemukan (akurasi ±${acc.round()} m).'
              : 'Lokasi perangkat ditemukan.');
        }
        break;
      case 'GPS_ERR':
        _gpsGuard?.cancel();
        setState(() => _gpsBusy = false);
        _snack(event.message ?? 'Gagal mendapatkan lokasi perangkat.',
            isError: true);
        break;
      case 'SAVED_CLICK':
        final id = event.id;
        if (id == null) break;
        for (final l in _saved) {
          if (l.id == id) {
            _focusSaved(l);
            break;
          }
        }
        break;
    }
  }

  void _requestGps() {
    if (_gpsBusy) return;
    if (!_mapController.isAttached) {
      _snack('Lokasi GPS tersedia pada versi web aplikasi.', isError: true);
      return;
    }
    setState(() => _gpsBusy = true);
    _mapController.requestGps();
    _gpsGuard?.cancel();
    _gpsGuard = Timer(const Duration(seconds: 16), () {
      if (!mounted) return;
      setState(() => _gpsBusy = false);
      _snack('Permintaan lokasi tidak direspons. Coba lagi.', isError: true);
    });
  }

  void _toggleHeat() {
    setState(() => _heatVisible = !_heatVisible);
    _mapController.setHeatVisible(_heatVisible);
  }

  // ===========================================================================
  // PENCARIAN ALAMAT
  // ===========================================================================

  Future<void> _search() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty || _searching) return;
    setState(() {
      _searching = true;
      _showResults = true;
      _searchError = null;
      _searchResults = [];
    });
    try {
      final results = await _geo.search(q);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _searching = false;
      });
    } on GeocodingException catch (e) {
      if (!mounted) return;
      setState(() {
        _searchError = e.message;
        _searching = false;
      });
    }
  }

  void _selectResult(GeoResult r) {
    _searchFocus.unfocus();
    setState(() {
      _showResults = false;
      _searchCtrl.text = r.name;
    });
    _mapController.setPin(r.lat, r.lng, fly: true, zoom: 16);
    _selectPoint(r.lat, r.lng, address: r.displayName);
  }

  // ===========================================================================
  // SIMPAN LOKASI
  // ===========================================================================

  Future<void> _save({required bool asNew}) async {
    if (_saving) return;
    final name = _nameCtrl.text.trim().isEmpty ? 'Lapak Saya' : _nameCtrl.text.trim();
    final wasUpdate = !asNew && _focusedSaved != null;
    setState(() => _saving = true);
    try {
      final LocationModel result;
      if (wasUpdate) {
        result = await _api.updateMyLocation(
          _focusedSaved!.id,
          name: name,
          latitude: _pinLat,
          longitude: _pinLng,
          address: _address,
        );
      } else {
        result = await _api.saveMyLocation(
          name: name,
          latitude: _pinLat,
          longitude: _pinLng,
          address: _address,
        );
      }
      if (!mounted) return;
      setState(() {
        final idx = _saved.indexWhere((l) => l.id == result.id);
        if (idx >= 0) {
          _saved[idx] = result;
        } else {
          _saved = [..._saved, result];
        }
        _focusedSaved = result;
        _saving = false;
      });
      _mapController.setSaved(_saved);
      _snack(wasUpdate ? 'Lokasi berhasil diperbarui.' : 'Lokasi berhasil disimpan.');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack(e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('Gagal menyimpan lokasi: $e', isError: true);
    }
  }

  void _copyCoords() {
    Clipboard.setData(ClipboardData(
      text: '${_pinLat.toStringAsFixed(6)}, ${_pinLng.toStringAsFixed(6)}',
    ));
    _snack('Koordinat disalin ke clipboard.');
  }

  void _snack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppConstants.statusDanger : AppConstants.primaryDark,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ));
  }

  int get _wibHour => DateTime.now().toUtc().add(const Duration(hours: 7)).hour;

  String _fmtDateTime(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_months[d.month - 1]} ${d.year}, $hh:$mm';
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView(message: 'Memuat lokasi jualan...');
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final mapArea = _buildMapArea();
        if (isWide) {
          return Row(
            children: [
              Expanded(child: mapArea),
              const VerticalDivider(width: 1, thickness: 1),
              SizedBox(
                width: 400,
                child: Container(
                  color: AppConstants.surfaceColor,
                  child: _buildPanel(showHandle: false),
                ),
              ),
            ],
          );
        }
        return Stack(
          children: [
            Positioned.fill(child: mapArea),
            DraggableScrollableSheet(
              initialChildSize: 0.42,
              minChildSize: 0.18,
              maxChildSize: 0.92,
              snap: true,
              snapSizes: const [0.18, 0.42, 0.92],
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppConstants.surfaceColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 24,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: _buildPanel(
                      scrollController: scrollController, showHandle: true),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // AREA PETA + OVERLAY
  // ---------------------------------------------------------------------------

  Widget _buildMapArea() {
    return Stack(
      children: [
        Positioned.fill(
          child: SellerMapView(
            controller: _mapController,
            initialLat: _pinLat,
            initialLng: _pinLng,
            initialZoom: _focusedSaved != null ? 16 : 14,
            pinLat: _pinLat,
            pinLng: _pinLng,
            initialSaved: _saved,
          ),
        ),
        if (!_mapReady)
          const Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: _MapLoadingChip(),
              ),
            ),
          ),
        // Kartu pencarian
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: _buildSearchBar(),
        ),
        if (_showResults)
          Positioned(
            top: 74,
            left: 12,
            right: 12,
            child: Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _buildSearchResults(),
              ),
            ),
          ),
        // Legenda heatmap + kredit peta
        if (_heatVisible && !_showResults)
          Positioned(
            top: 74,
            left: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegend(),
                const SizedBox(height: 6),
                _buildCredit(),
              ],
            ),
          ),
        if (!_heatVisible)
          Positioned(top: 74, left: 12, child: _buildCredit()),
        // Tombol aksi peta
        Positioned(
          top: 74,
          right: 12,
          child: _buildFabColumn(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Material(
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(14),
      color: Colors.white,
      child: SizedBox(
        height: 54,
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search, color: AppConstants.primaryColor.withValues(alpha: 0.7)),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _search(),
                style: const TextStyle(fontSize: 14.5, color: AppConstants.textDark),
                decoration: InputDecoration(
                  hintText: 'Cari tempat atau alamat…',
                  hintStyle: TextStyle(color: Colors.brown.shade300, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (_searchCtrl.text.isNotEmpty)
              IconButton(
                tooltip: 'Bersihkan',
                icon: const Icon(Icons.close, size: 20),
                color: Colors.brown.shade300,
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _showResults = false);
                },
              ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _searching
                  ? const SizedBox(
                      width: 38,
                      height: 38,
                      child: Padding(
                        padding: EdgeInsets.all(9),
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: AppConstants.primaryColor),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Cari lokasi',
                      style: IconButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.arrow_forward, size: 20),
                      onPressed: _search,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Material(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.28),
      borderRadius: BorderRadius.circular(14),
      color: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_searching)
              const Padding(
                padding: EdgeInsets.all(18),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2, color: AppConstants.primaryColor),
                    ),
                    SizedBox(width: 12),
                    Text('Mencari lokasi…',
                        style: TextStyle(fontSize: 13, color: Colors.black54)),
                  ],
                ),
              )
            else if (_searchError != null)
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, size: 18, color: AppConstants.statusDanger),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_searchError!,
                          style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                    ),
                    TextButton(onPressed: _search, child: const Text('Ulangi')),
                  ],
                ),
              )
            else if (_searchResults.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.location_off_outlined, size: 18, color: Colors.black38),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tidak ada hasil. Coba kata kunci lain, mis. "Kampus UNP Padang".',
                        style: TextStyle(fontSize: 12.5, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, indent: 16, endIndent: 16, color: Colors.brown.shade50),
                  itemBuilder: (context, i) {
                    final r = _searchResults[i];
                    return ListTile(
                      dense: true,
                      leading: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppConstants.backgroundColor,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(Icons.place_outlined,
                            size: 18, color: AppConstants.primaryColor),
                      ),
                      title: Text(r.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13.5, fontWeight: FontWeight.w700)),
                      subtitle: Text(r.displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11.5, color: Colors.black54)),
                      onTap: () => _selectResult(r),
                    );
                  },
                ),
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor.withValues(alpha: 0.45),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(14)),
              ),
              child: const Text(
                'Pencarian: Nominatim · Data © OpenStreetMap contributors',
                style: TextStyle(fontSize: 10, color: Colors.black45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFabColumn() {
    return Column(
      children: [
        _MapFab(
          tooltip: 'Lokasi saya (GPS)',
          icon: Icons.my_location,
          busy: _gpsBusy,
          onTap: _requestGps,
        ),
        const SizedBox(height: 10),
        _MapFab(
          tooltip: _heatVisible ? 'Sembunyikan heatmap' : 'Tampilkan heatmap',
          icon: _heatVisible ? Icons.layers : Icons.layers_outlined,
          active: _heatVisible,
          onTap: _toggleHeat,
        ),
        const SizedBox(height: 10),
        _MapFab(
          tooltip: 'Perbesar',
          icon: Icons.add,
          onTap: () => _mapController.zoomBy(1),
        ),
        const SizedBox(height: 10),
        _MapFab(
          tooltip: 'Perkecil',
          icon: Icons.remove,
          onTap: () => _mapController.zoomBy(-1),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final level in CrowdLevel.values) ...[
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: level.color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              level == CrowdLevel.sangatRamai ? 'Sangat ramai' : level.label,
              style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600, color: AppConstants.textDark),
            ),
            if (level != CrowdLevel.sangatRamai) const SizedBox(width: 9),
          ],
        ],
      ),
    );
  }

  Widget _buildCredit() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        '© OpenStreetMap contributors',
        style: TextStyle(fontSize: 9.5, color: Colors.black54),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PANEL INFORMASI (bottom sheet / side panel)
  // ---------------------------------------------------------------------------

  Widget _buildPanel({ScrollController? scrollController, bool showHandle = false}) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
      children: [
        if (showHandle)
          Center(
            child: Container(
              width: 42,
              height: 4.5,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.brown.shade200,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Titik Jualan',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppConstants.textDark,
                ),
              ),
            ),
            StatusBadge(
              label: _focusedSaved != null ? 'TERSIMPAN' : 'TITIK BARU',
              color: _focusedSaved != null
                  ? AppConstants.statusSuccess
                  : AppConstants.statusPending,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _focusedSaved != null
              ? 'Mengelola: ${_focusedSaved!.name}'
              : 'Geser pin, ketuk peta, cari alamat, atau pakai GPS.',
          style: TextStyle(fontSize: 12, color: Colors.brown.shade400),
        ),
        const SizedBox(height: 14),
        _buildPointCard(),
        const SizedBox(height: 14),
        _buildCrowdPanel(),
        const SizedBox(height: 16),
        _buildSaveActions(),
        const SizedBox(height: 22),
        _buildSavedSection(),
      ],
    );
  }

  Widget _buildPointCard() {
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.place_outlined, size: 18, color: AppConstants.primaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: _resolvingAddress
                    ? Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                                strokeWidth: 1.6, color: Colors.brown.shade300),
                          ),
                          const SizedBox(width: 8),
                          Text('Mencari alamat…',
                              style: TextStyle(fontSize: 13, color: Colors.brown.shade300)),
                        ],
                      )
                    : Text(
                        (_address == null || _address!.isEmpty)
                            ? 'Alamat belum tersedia untuk titik ini.'
                            : _address!,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: (_address == null || _address!.isEmpty)
                              ? Colors.black38
                              : AppConstants.textDark,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.my_location, size: 16, color: AppConstants.primaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${_pinLat.toStringAsFixed(6)}, ${_pinLng.toStringAsFixed(6)}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textDark,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Salin koordinat',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.copy, size: 16),
                color: Colors.brown.shade300,
                onPressed: _copyCoords,
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            maxLength: 100,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: 'Nama lokasi',
              labelStyle: TextStyle(fontSize: 12.5, color: Colors.brown.shade300),
              counterText: '',
              isDense: true,
              filled: true,
              fillColor: AppConstants.backgroundColor.withValues(alpha: 0.4),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppConstants.primaryColor, width: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrowdPanel() {
    final crowd = _crowd;
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Keramaian Sekitar',
                  style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppConstants.textDark),
                ),
              ),
              if (_crowdLoading && crowd != null)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 13,
                    height: 13,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.8, color: AppConstants.primaryColor),
                  ),
                ),
              if (crowd != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: crowd.isSimulation
                        ? const Color(0xFFFEF3C7)
                        : const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: crowd.isSimulation
                          ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
                          : const Color(0xFF16A34A).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        crowd.isSimulation
                            ? Icons.science_outlined
                            : Icons.verified_outlined,
                        size: 12,
                        color: crowd.isSimulation
                            ? const Color(0xFF92400E)
                            : const Color(0xFF14532D),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        crowd.isSimulation ? 'DATA SIMULASI' : 'DATA OBSERVASI',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: crowd.isSimulation
                              ? const Color(0xFF92400E)
                              : const Color(0xFF14532D),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_crowdLoading && crowd == null)
            const _CrowdSkeleton()
          else if (_crowdError != null)
            _CrowdError(message: _crowdError!, onRetry: _fetchCrowd)
          else if (crowd != null)
            _buildCrowdBody(crowd),
        ],
      ),
    );
  }

  Widget _buildCrowdBody(CrowdReport crowd) {
    final level = crowd.point.level;
    final people = crowd.point.estimatedPeople;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Level keramaian
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: level.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: level.color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(level.icon, color: level.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: level.foregroundColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      level.description,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        color: level.foregroundColor.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Statistik ringkas
        Row(
          children: [
            _StatTile(
              icon: Icons.groups_outlined,
              value: people != null ? '±$people' : '—',
              label: 'orang (est.)',
            ),
            const SizedBox(width: 8),
            _StatTile(
              icon: Icons.radar,
              value: '±150',
              label: 'meter radius',
            ),
            const SizedBox(width: 8),
            _StatTile(
              icon: Icons.percent,
              value: '${(crowd.point.intensity * 100).round()}%',
              label: 'intensitas',
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Potensi lokasi
        Row(
          children: [
            const Icon(Icons.storefront_outlined,
                size: 16, color: AppConstants.primaryColor),
            const SizedBox(width: 8),
            const Text('Potensi berjualan',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text(
              '${crowd.point.potentialDisplay} · ${crowd.point.potentialScore}/100',
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppConstants.primaryColor),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(end: crowd.point.potentialScore / 100),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(height: 8, color: AppConstants.backgroundColor),
                FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    height: 8,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppConstants.primaryColor, AppConstants.accentColor],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Waktu pengamatan
        Row(
          children: [
            Icon(Icons.schedule, size: 14, color: Colors.brown.shade300),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Diperbarui ${_fmtDateTime(crowd.point.observedAt)} · '
                '${_previewHour == null ? 'kondisi' : 'pratinjau'} jam '
                '${crowd.hourUsed.toString().padLeft(2, '0')}:00 WIB',
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildHourSlider(crowd),
        const SizedBox(height: 8),
        // Faktor penjelas
        for (final f in crowd.point.factors)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.brown.shade300, shape: BoxShape.circle),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(f,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black54, height: 1.4)),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        // Disclaimer wajib
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: crowd.isSimulation
                ? const Color(0xFFFEF3C7).withValues(alpha: 0.6)
                : const Color(0xFFDCFCE7).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: crowd.isSimulation
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
                  : const Color(0xFF16A34A).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline,
                  size: 14,
                  color: crowd.isSimulation
                      ? const Color(0xFF92400E)
                      : const Color(0xFF14532D)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  crowd.disclaimer,
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.45,
                    color: crowd.isSimulation
                        ? const Color(0xFF92400E)
                        : const Color(0xFF14532D),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHourSlider(CrowdReport crowd) {
    final hour = (_previewHour ?? _wibHour).clamp(0, 23);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.tune, size: 14, color: AppConstants.primaryColor),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Pratinjau keramaian per jam',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${hour.toString().padLeft(2, '0')}:00',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppConstants.primaryColor,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: _previewHour == null
                    ? null
                    : () {
                        setState(() => _previewHour = null);
                        _fetchCrowd();
                      },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _previewHour == null
                        ? Colors.transparent
                        : AppConstants.primaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Sekarang',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _previewHour == null
                          ? Colors.brown.shade300
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppConstants.primaryColor,
              inactiveTrackColor: AppConstants.accentColor.withValues(alpha: 0.35),
              thumbColor: AppConstants.primaryColor,
              overlayColor: AppConstants.primaryColor.withValues(alpha: 0.12),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: hour.toDouble(),
              min: 0,
              max: 23,
              divisions: 23,
              label: '${hour.toString().padLeft(2, '0')}:00',
              onChanged: (v) => setState(() => _previewHour = v.round()),
              onChangeEnd: (v) {
                setState(() => _previewHour = v.round());
                _fetchCrowd();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveActions() {
    final updating = _focusedSaved != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: _saving ? null : () => _save(asNew: false),
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.2, color: Colors.white),
                  )
                : Icon(updating ? Icons.update : Icons.add_location_alt_outlined,
                    size: 20),
            label: Text(
              _saving
                  ? 'Menyimpan…'
                  : (updating ? 'Perbarui Lokasi Ini' : 'Pilih Lokasi Ini'),
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        if (updating) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppConstants.primaryColor,
                side: BorderSide(
                    color: AppConstants.primaryColor.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saving ? null : () => _save(asNew: true),
              icon: const Icon(Icons.add_location_outlined, size: 18),
              label: const Text('Simpan sebagai Lokasi Baru',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          updating
              ? 'Titik pada peta akan memperbarui lokasi yang dipilih di atas.'
              : 'Lokasi disimpan ke akun Anda dan muncul kembali saat aplikasi dibuka.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10.5, color: Colors.brown.shade300, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildSavedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'LOKASI TERSIMPAN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: Colors.brown.shade300,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_saved.length}',
                style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppConstants.primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_saved.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppConstants.backgroundColor.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppConstants.accentColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline,
                    size: 18, color: AppConstants.primaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Belum ada lokasi tersimpan. Tentukan titik di peta '
                    '(geser pin, ketuk peta, cari alamat, atau GPS), lihat '
                    'estimasi keramaiannya, lalu tekan "Pilih Lokasi Ini".',
                    style: TextStyle(
                        fontSize: 12, height: 1.5, color: Colors.brown.shade600),
                  ),
                ),
              ],
            ),
          )
        else
          for (final loc in _saved) ...[
            _SavedLocationCard(
              location: loc,
              selected: _focusedSaved?.id == loc.id,
              onTap: () => _focusSaved(loc),
            ),
            const SizedBox(height: 8),
          ],
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.lock_outline, size: 12, color: Colors.brown.shade200),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Setiap seller hanya dapat mengelola lokasi miliknya sendiri.',
                style: TextStyle(fontSize: 10.5, color: Colors.brown.shade300),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// WIDGET PENDUKUNG
// =============================================================================

class _PanelCard extends StatelessWidget {
  final Widget child;
  const _PanelCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.primaryColor.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MapFab extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final bool busy;

  const _MapFab({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.active = false,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        elevation: 5,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(13),
        color: active ? AppConstants.primaryColor : Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: busy ? null : onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: busy
                ? const Padding(
                    padding: EdgeInsets.all(13),
                    child: CircularProgressIndicator(
                        strokeWidth: 2.4, color: AppConstants.primaryColor),
                  )
                : Icon(icon,
                    size: 22,
                    color: active ? Colors.white : AppConstants.primaryColor),
          ),
        ),
      ),
    );
  }
}

class _MapLoadingChip extends StatelessWidget {
  const _MapLoadingChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppConstants.primaryColor),
          ),
          SizedBox(width: 10),
          Text('Memuat peta…',
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textDark)),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: AppConstants.backgroundColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: AppConstants.primaryColor),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppConstants.textDark,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9.5, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}

class _CrowdSkeleton extends StatelessWidget {
  const _CrowdSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget box(double h, {double w = double.infinity}) => Container(
          height: h,
          width: w,
          decoration: BoxDecoration(
            color: Colors.brown.shade50,
            borderRadius: BorderRadius.circular(9),
          ),
        );
    return Column(
      children: [
        box(64),
        const SizedBox(height: 10),
        box(52),
        const SizedBox(height: 10),
        box(14),
        const SizedBox(height: 8),
        box(14, w: 220),
      ],
    );
  }
}

class _CrowdError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CrowdError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.statusDanger.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(11),
        border:
            Border.all(color: AppConstants.statusDanger.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_off, size: 16, color: AppConstants.statusDanger),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Data keramaian gagal dimuat',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: AppConstants.primaryColor),
                child: const Text('Coba lagi', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          Text(message,
              style: const TextStyle(fontSize: 11, color: Colors.black54, height: 1.4)),
        ],
      ),
    );
  }
}

class _SavedLocationCard extends StatelessWidget {
  final LocationModel location;
  final bool selected;
  final VoidCallback onTap;

  const _SavedLocationCard({
    required this.location,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppConstants.backgroundColor.withValues(alpha: 0.6)
          : Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected
                  ? AppConstants.primaryColor.withValues(alpha: 0.55)
                  : AppConstants.primaryColor.withValues(alpha: 0.12),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: selected
                      ? AppConstants.primaryColor
                      : AppConstants.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.storefront,
                  size: 19,
                  color: selected ? Colors.white : AppConstants.primaryColor,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location.address ??
                          '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (selected)
                const StatusBadge(label: 'DIPILIH', color: AppConstants.primaryColor)
              else
                StatusBadge(
                  label: location.isActive ? 'AKTIF' : 'NONAKTIF',
                  color: location.isActive
                      ? AppConstants.statusSuccess
                      : Colors.blueGrey,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
