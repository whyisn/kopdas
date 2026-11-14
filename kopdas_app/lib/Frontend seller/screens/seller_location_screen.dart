import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../models/location.dart';
import '../../services/auth_service.dart';
import '../../services/seller_api.dart';
import '../../widgets/app_states.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_badge.dart';

class SellerLocationScreen extends StatefulWidget {
  const SellerLocationScreen({super.key});

  @override
  State<SellerLocationScreen> createState() => _SellerLocationScreenState();
}

class _SellerLocationScreenState extends State<SellerLocationScreen> {
  final _api = SellerApi(sessionController.api);

  bool _loading = true;
  String? _error;
  List<LocationModel> _locations = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _api.myLocations(sessionController.userId!);
      if (!mounted) return;
      setState(() {
        _locations = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView(message: 'Memuat lokasi...');
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_locations.isEmpty) {
      return const EmptyView(
        icon: Icons.location_off_outlined,
        title: 'Belum ada lokasi',
        message: 'Lokasi jualan untuk akun ini belum tersedia dari backend.',
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppConstants.primaryColor,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final loc in _locations) ...[
            _buildLocationCard(loc),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationCard(LocationModel loc) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.storefront,
                    color: AppConstants.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppConstants.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    StatusBadge(
                      label: loc.isActive ? 'AKTIF' : 'NONAKTIF',
                      color: loc.isActive
                          ? AppConstants.statusSuccess
                          : Colors.blueGrey,
                    ),
                  ],
                ),
              ),
              if (loc.dataLabel == 'SIMULASI')
                const StatusBadge(label: 'SIMULASI', color: Colors.blueGrey),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _infoRow(Icons.place_outlined, 'Alamat',
              loc.address ?? 'Alamat belum tersedia'),
          _infoRow(
            Icons.my_location,
            'Koordinat',
            '${loc.latitude.toStringAsFixed(5)}, ${loc.longitude.toStringAsFixed(5)}',
          ),
          _infoRow(Icons.category_outlined, 'Tipe lokasi', loc.sourceType),
          const SizedBox(height: 8),
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
                    'Jam operasional, kontak, dan peta interaktif belum tersedia '
                    'dari backend. Informasi lokasi bersifat read-only.',
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