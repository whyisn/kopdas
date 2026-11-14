import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../widgets/section_card.dart';

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 56, color: Colors.brown.shade200),
              const SizedBox(height: 16),
              const Text(
                'Pesanan belum tersedia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppConstants.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Backend belum menyediakan endpoint Orders untuk Seller. '
                'Modul ini menunggu konfirmasi Backend Engineer sebelum '
                'diintegrasikan. Tidak ada data pesanan yang ditampilkan '
                'agar tidak menyesatkan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Kebutuhan backend (NEED BACKEND CONFIRMATION)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _needItem(
                'GET /orders?seller_id={id}',
                'Daftar pesanan milik seller (nomor, waktu, pelanggan, '
                    'total, status order & pembayaran).',
              ),
              _needItem(
                'PATCH /orders/{id}/status',
                'Transisi status yang diizinkan backend: CONFIRMED → '
                    'PREPARING → READY_FOR_PICKUP → COMPLETED.',
              ),
              _needItem(
                'items[] pada detail order',
                'Daftar produk, kuantitas, dan subtotal pada response order.',
              ),
              const SizedBox(height: 8),
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
                        'Saat ini backend hanya mendukung pembuatan order oleh '
                        'Customer (POST /customer/orders) dan konfirmasi otomatis '
                        'via webhook pembayaran. Alur pemrosesan order oleh Seller '
                        'belum tersedia.',
                        style: TextStyle(
                            fontSize: 12, color: Colors.black54, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _needItem(String endpoint, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.api, size: 18, color: AppConstants.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  endpoint,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppConstants.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}