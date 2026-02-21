// lib/widgets/status_badge.dart
import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, text) = _getStatusInfo(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  (Color, String) _getStatusInfo(String status) {
    switch (status) {
      case 'created':
        return (Colors.blue, 'CREATED');
      case 'in_transit':
        return (Colors.orange, 'IN TRANSIT');
      case 'delivered':
        return (Colors.green, 'DELIVERED');
      case 'recalled':
        return (Colors.red, 'RECALLED');
      default:
        return (Colors.grey, 'UNKNOWN');
    }
  }
}
