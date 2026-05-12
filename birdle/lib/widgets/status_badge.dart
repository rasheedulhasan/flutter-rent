import 'package:flutter/material.dart';
import 'package:birdle/core/app_theme.dart';

/// Reusable status badge widget with color-coded states.
class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  final EdgeInsets padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: config.color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'paid':
      case 'delivered':
      case 'completed':
      case 'confirmed':
        return _StatusConfig(label: status.toUpperCase(), color: AppTheme.success);
      case 'pending':
      case 'processing':
        return _StatusConfig(label: status.toUpperCase(), color: AppTheme.warning);
      case 'inactive':
      case 'unpaid':
      case 'cancelled':
      case 'refunded':
        return _StatusConfig(label: status.toUpperCase(), color: AppTheme.error);
      case 'shipped':
        return _StatusConfig(label: status.toUpperCase(), color: AppTheme.info);
      case 'vip':
      case 'lead':
        return _StatusConfig(label: status.toUpperCase(), color: AppTheme.primary);
      case 'overdue':
        return _StatusConfig(label: status.toUpperCase(), color: AppTheme.error);
      default:
        return _StatusConfig(label: status.toUpperCase(), color: AppTheme.textSecondaryLight);
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  _StatusConfig({required this.label, required this.color});
}
