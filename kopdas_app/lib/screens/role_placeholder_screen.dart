import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../services/auth_service.dart';

class RolePlaceholderScreen extends StatelessWidget {
  final String roleLabel;

  const RolePlaceholderScreen({super.key, required this.roleLabel});

  @override
  Widget build(BuildContext context) {
    final session = sessionController;
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        backgroundColor: AppConstants.primaryDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: () => session.logout(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction, size: 56, color: Colors.brown.shade200),
              const SizedBox(height: 16),
              Text(
                'Area $roleLabel',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppConstants.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Modul $roleLabel sedang dikembangkan oleh tim terkait.\n'
                'Anda masuk sebagai ${session.name ?? '-'} (${session.role ?? '-'}).',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}