import 'package:flutter/material.dart';

import '../core/constants.dart';

class ModulePlaceholder extends StatelessWidget {
  final String moduleName;

  const ModulePlaceholder({super.key, required this.moduleName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_top, size: 48, color: Colors.brown.shade200),
          const SizedBox(height: 12),
          Text(
            moduleName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppConstants.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Modul ini sedang dibangun.',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}