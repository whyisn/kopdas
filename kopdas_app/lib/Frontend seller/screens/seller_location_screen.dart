import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../models/location.dart';
import '../../services/geocoding_service.dart';
import '../../services/location_storage.dart';
import '../../services/seller_repository.dart';
import '../../widgets/app_states.dart';
import '../../widgets/crowd_density.dart';
import '../../widgets/search_field.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_badge.dart';

class SellerLocationScreen extends StatefulWidget {
  const SellerLocationScreen({super.key});

  @override
  State<SellerLocationScreen> createState() => _SellerLocationScreenState();
}

class _SellerLocationScreenState extends State<SellerLocationScreen> {
  final _repo = sellerRepository();
  final _geo = GeocodingService();
  final _storage = LocationStorage();
  final _mapController = MapController();
  final _mapKey = GlobalKey();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _searchController = TextEditingController();

  static const _defaultCenter = LatLng(-6.200000, 106.816666);
  static const _mapFlags = InteractiveFlag.drag |
      InteractiveFlag.flingAnimation |
      InteractiveFlag.pinchZoom |
      InteractiveFlag.doubleTapZoom |
      InteractiveFlag.scrollWheelZoom;

  bool _loading = true;
  bool _dragging = false;
  bool _reverseLoading = false;
  bool _searching = false;
  bool _locating = false;
  bool _saving = false;
  bool _hasSaved = false;

  LatLng _point = _defaultCenter;
  DateTime? _savedAt;
  Timer? _reverseTimer;

  List<LocationModel> _locations = [];
  String? _locationsError;
  List<GeoPlace> _searchResults = [];
  String? _searchMessage;

  // Sumber data keramaian nyata belum tersedia (backend belum mengekspos
  // footfall/aktivitas pengunjung berkoordinat). Daftar ini sengaja kosong:
  // tidak ada angka/heatmap yang dikarang. Lihat laporan kebutuhan API.
  final List<CrowdPoint> _crowdPoints = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _reverseTimer?.cancel();
    _nameController.dispose();
    _addressController.dispose();
    _searchController.dispose();
    _mapController.dispose();
    _geo.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _locationsError = null;
    });

    SavedLocation? saved;
    try {
      saved = await _storage.load();
    } catch (_) {
      saved = null;
    }

    List<LocationModel> locs = [];
    String? locErr;
    try {
      locs = await _repo.myLocations();
    } catch (e) {
      locErr = e.toString();
    }

    if (!mounted) return;
    final seedLoc = locs.isNotEmpty ? locs.first : null;
    setState(() {
      _locations = locs;
      _locationsError = locErr;
      _hasSaved = saved != null;
      _savedAt = saved?.updatedAt;
      _point = saved != null
          ? LatLng(saved.latitude, saved.longitude)
          : (seedLoc != null
              ? LatLng(seedLoc.latitude, seedLoc.longitude)
              : _defaultCenter);
      _nameController.text = saved?.name ?? seedLoc?.name ?? 'Lokasi Jualan';
      _addressController.text =
          saved?.address ?? seedLoc?.address ?? '';
      _loading = false;
    });

    if (_addressController.text.isEmpty) _scheduleReverse();
  }

  void _setPoint(LatLng point, {bool reverse = true}) {
    setState(() => _point = point);
    if (reverse) _scheduleReverse();
  }

  void _scheduleReverse() {
    _reverseTimer?.cancel();
    _reverseTimer = Timer(const Duration(milliseconds: 700), _doReverse);
  }

  Future<void> _doReverse() async {
    if (!mounted) return;
    setState(() => _reverseLoading = true);
    final addr = await _geo.reverse(_point.latitude, _point.longitude);
    if (!mounted) return;
    setState(() {
      _reverseLoading = false;
      if (addr != null && addr.isNotEmpty) _addressController.text = addr;
    });
  }

  Future<void> _search() async {
    final q = _searchController.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _searching = true;
      _searchResults = [];
      _searchMessage = null;
    });
    final results = await _geo.search(q);
    if (!mounted) return;
    setState(() {
      _searching = false;
      _searchResults = results;
      _searchMessage = results.isEmpty
          ? 'Tidak ada hasil. Periksa koneksi atau coba kata kunci lain.'
          : null;
    });
  }

  void _selectPlace(GeoPlace place) {
    final ll = LatLng(place.latitude, place.longitude);
    setState(() {
      _searchResults = [];
      _searchMessage = null;
      _searchController.text = place.displayName;
      _addressController.text = place.displayName;
    });
    _setPoint(ll, reverse: false);
    _mapController.move(ll, 16);
  }

  void _focusLocation(LocationModel loc) {
    final ll = LatLng(loc.latitude, loc.longitude);
    setState(() {
      _nameController.text = loc.name;
      _addressController.text = loc.address ?? '';
    });
    _setPoint(ll, reverse: loc.address == null || loc.address!.isEmpty);
    _mapController.move(ll, 16);
  }

  Future<void> _currentLocation() async {
    setState(() => _locating = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _snack('Layanan lokasi perangkat nonaktif. Aktifkan lokasi lalu coba lagi.');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _snack('Izin lokasi ditolak. Berikan izin lokasi untuk memakai fitur ini.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        ),
      );
      if (!mounted) return;
      final ll = LatLng(pos.latitude, pos.longitude);
      _setPoint(ll);
      _mapController.move(ll, 16);
    } catch (_) {
      _snack('Tidak dapat mengambil lokasi saat ini. Pastikan izin lokasi diberikan dan coba lagi.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _snack('Nama lokasi tidak boleh kosong.');
      return;
    }
    setState(() => _saving = true);
    final loc = SavedLocation(
      name: name,
      address: _addressController.text.trim(),
      latitude: _point.latitude,
      longitude: _point.longitude,
      updatedAt: DateTime.now().toUtc(),
    );
    try {
      await _storage.save(loc);
      if (!mounted) return;
      setState(() {
        _savedAt = loc.updatedAt;
        _hasSaved = true;
      });
      _snack('Lokasi "$name" tersimpan.');
    } catch (_) {
      _snack('Gagal menyimpan lokasi. Coba lagi.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _endDrag() {
    setState(() => _dragging = false);
    _scheduleReverse();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView(message: 'Memuat lokasi...');

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1000;
        final mapHeight = wide ? 480.0 : 340.0;
        final picker = _buildPicker(mapHeight);
        final info = _buildInfoPane();

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: picker,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                  child: info,
                ),
              ),
            ],
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [picker, const SizedBox(height: 16), info],
        );
      },
    );
  }

  Widget _buildPicker(double mapHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSearchBar(),
        if (_searchResults.isNotEmpty) _buildSearchResults(),
        if (_searchMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _searchMessage!,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        const SizedBox(height: 12),
        _buildMap(mapHeight),
        const SizedBox(height: 12),
        _buildCoordinateRow(),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          decoration: _fieldDecoration('Nama lokasi', Icons.storefront_outlined),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _addressController,
          maxLines: 2,
          decoration: _fieldDecoration('Alamat', Icons.place_outlined),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_saving ? 'Menyimpan...' : 'Simpan lokasi'),
            style: FilledButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: SearchField(
            hint: 'Cari alamat / nama tempat...',
            controller: _searchController,
            onChanged: (_) {},
            onSubmitted: (_) => _search(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: _searching ? null : _search,
          style: IconButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
          ),
          icon: _searching
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.search),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SectionCard(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            for (final p in _searchResults)
              ListTile(
                dense: true,
                leading: const Icon(Icons.place_outlined,
                    color: AppConstants.primaryColor),
                title: Text(
                  p.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
                onTap: () => _selectPlace(p),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(double mapHeight) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: mapHeight,
        child: Stack(
          children: [
            FlutterMap(
              key: _mapKey,
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _point,
                initialZoom: 15,
                minZoom: 3,
                maxZoom: 19,
                interactionOptions: InteractionOptions(
                  flags: _dragging ? InteractiveFlag.none : _mapFlags,
                ),
                onTap: (_, ll) => _setPoint(ll),
                onLongPress: (_, ll) => _setPoint(ll),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'id.kopicerdas.app',
                  maxNativeZoom: 19,
                ),
                CrowdDensityOverlay(points: _crowdPoints),
                MarkerLayer(
                  markers: [
                    Marker(
                      key: const ValueKey('seller-pin'),
                      point: _point,
                      width: 44,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: _buildMarker(),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              left: 12,
              top: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Ketuk peta atau geser pin untuk memilih titik',
                  style: TextStyle(fontSize: 11, color: AppConstants.textDark),
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: FloatingActionButton.small(
                heroTag: null,
                onPressed: _locating ? null : _currentLocation,
                backgroundColor: AppConstants.surfaceColor,
                tooltip: 'Lokasi saya saat ini',
                child: _locating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppConstants.primaryColor),
                      )
                    : const Icon(Icons.my_location,
                        color: AppConstants.primaryColor),
              ),
            ),
            Positioned(
              left: 8,
              bottom: 4,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.white.withValues(alpha: 0.7),
                child: const Text(
                  '© OpenStreetMap',
                  style: TextStyle(fontSize: 9, color: Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarker() {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: GestureDetector(
        onPanDown: (_) => setState(() => _dragging = true),
        onPanUpdate: (d) {
          final box =
              _mapKey.currentContext?.findRenderObject() as RenderBox?;
          if (box == null) return;
          final local = box.globalToLocal(d.globalPosition);
          final ll = _mapController.camera.screenOffsetToLatLng(local);
          setState(() => _point = ll);
        },
        onPanEnd: (_) => _endDrag(),
        onPanCancel: _endDrag,
        child: const Icon(
          Icons.location_pin,
          size: 44,
          color: AppConstants.statusWarning,
          shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
        ),
      ),
    );
  }

  Widget _buildCoordinateRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.my_location,
              size: 18, color: AppConstants.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Lat ${_point.latitude.toStringAsFixed(6)}, '
              'Lng ${_point.longitude.toStringAsFixed(6)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppConstants.textDark,
              ),
            ),
          ),
          if (_reverseLoading)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppConstants.primaryColor),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoPane() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSavedCard(),
        const SizedBox(height: 16),
        _buildCrowdCard(),
        const SizedBox(height: 16),
        _buildRegisteredCard(),
      ],
    );
  }

  Widget _buildSavedCard() {
    return SectionCard(
      title: 'Lokasi jualan',
      trailing: const StatusBadge(
          label: 'AKTIF', color: AppConstants.statusSuccess),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(Icons.storefront_outlined, 'Nama',
              _nameController.text.trim().isEmpty
                  ? 'Lokasi Jualan'
                  : _nameController.text.trim()),
          _infoRow(
              Icons.place_outlined,
              'Alamat',
              _addressController.text.trim().isEmpty
                  ? 'Alamat belum tersedia'
                  : _addressController.text.trim()),
          _infoRow(
              Icons.my_location,
              'Koordinat',
              '${_point.latitude.toStringAsFixed(6)}, '
              '${_point.longitude.toStringAsFixed(6)}'),
          _infoRow(Icons.groups_outlined, 'Tingkat keramaian',
              'Belum tersedia'),
          _infoRow(
              Icons.schedule_outlined,
              'Pembaruan terakhir',
              _savedAt == null ? 'Belum disimpan' : formatWib(_savedAt!)),
          if (!_hasSaved)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 18, color: Colors.brown.shade300),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Titik belum disimpan. Tentukan titik di peta lalu tekan '
                      '"Simpan lokasi". Lokasi tersimpan akan dimuat kembali '
                      'saat halaman dibuka.',
                      style: TextStyle(
                          fontSize: 12, color: Colors.black54, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCrowdCard() {
    return SectionCard(
      title: 'Keramaian lokasi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legenda tingkat keramaian',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          const CrowdDensityLegend(),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.backgroundColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    size: 18, color: Colors.brown.shade300),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Data keramaian belum tersedia. Overlay heatmap akan aktif '
                    'setelah sumber data kepadatan yang dapat '
                    'dipertanggungjawabkan (footfall / aktivitas pengunjung '
                    'berkoordinat beserta periode observasi) terhubung.',
                    style: TextStyle(
                        fontSize: 12, color: Colors.black54, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisteredCard() {
    return SectionCard(
      title: 'Lokasi terdaftar',
      trailing: Text(
        '${_locations.length}',
        style: TextStyle(fontSize: 12, color: Colors.brown.shade300),
      ),
      child: _locationsError != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informasi lokasi terdaftar belum dapat dimuat.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Coba lagi'),
                  ),
                ),
              ],
            )
          : _locations.isEmpty
              ? const Text(
                  'Belum ada lokasi terdaftar.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                )
              : Column(
                  children: [
                    for (final loc in _locations)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => _focusLocation(loc),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.brown.shade100),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.storefront_outlined,
                                    size: 20,
                                    color: AppConstants.primaryColor),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        loc.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppConstants.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        loc.address ??
                                            'Alamat belum tersedia',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black54),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${loc.latitude.toStringAsFixed(5)}, '
                                        '${loc.longitude.toStringAsFixed(5)}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black45),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge(
                                  label: loc.sourceType,
                                  color: AppConstants.primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppConstants.primaryColor),
      filled: true,
      fillColor: AppConstants.surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.brown.shade100),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.brown.shade100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppConstants.primaryColor, width: 1.5),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppConstants.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppConstants.textDark,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}