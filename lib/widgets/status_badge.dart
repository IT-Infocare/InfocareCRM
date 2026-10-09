import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final Color? customColor;

  const StatusBadge({
    super.key,
    required this.status,
    this.customColor,
  });

  Color _getStatusColor(String s) {
    if (customColor != null) return customColor!;
    switch (s.toLowerCase()) {
      case 'new':
      case 'pending':
      case 'draft':
        return const Color(0xFF3B82F6);
      case 'contacted':
      case 'in_progress':
      case 'pending_approval':
        return const Color(0xFF8B5CF6);
      case 'qualified':
      case 'approved':
      case 'accepted':
      case 'completed':
      case 'converted':
      case 'won':
        return const Color(0xFF10B981);
      case 'disqualified':
      case 'rejected':
      case 'lost':
      case 'overdue':
      case 'expired':
        return const Color(0xFFEF4444);
      case 'sent':
        return const Color(0xFF0F766E);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    final label = AppFormatters.enumToHuman(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
