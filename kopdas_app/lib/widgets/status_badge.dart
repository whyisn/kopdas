import 'package:flutter/material.dart';

import '../core/constants.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  factory StatusBadge.payment(String status) {
    return StatusBadge(label: status, color: _paymentColor(status));
  }

  factory StatusBadge.order(String status) {
    return StatusBadge(label: status, color: _orderColor(status));
  }

  static Color _paymentColor(String status) {
    switch (status) {
      case 'PAID':
        return AppConstants.statusSuccess;
      case 'PENDING':
        return AppConstants.statusPending;
      case 'REJECTED':
      case 'EXPIRED':
        return AppConstants.statusWarning;
      default:
        return Colors.blueGrey;
    }
  }

  static Color _orderColor(String status) {
    switch (status) {
      case 'PENDING_PAYMENT':
        return AppConstants.statusPending;
      case 'CONFIRMED':
        return const Color(0xFF3D6B99);
      case 'PREPARING':
        return AppConstants.primaryColor;
      case 'READY_FOR_PICKUP':
        return const Color(0xFF2A7F8F);
      case 'COMPLETED':
        return AppConstants.statusSuccess;
      case 'CANCELLED':
      case 'EXPIRED':
        return AppConstants.statusWarning;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}