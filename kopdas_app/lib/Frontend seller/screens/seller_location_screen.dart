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
                  color: const Color(0xFF1E3932).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.storefront,
                    color: Color(0xFF1E3932)),
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
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline,
                    size: 18, color: Color(0xFF6B7280)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Titik jualan aktif gerobak kopi keliling terdaftar di sistem. '
                    'Informasi koordinat GPS disinkronkan secara realtime.',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280), height: 1.4),
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