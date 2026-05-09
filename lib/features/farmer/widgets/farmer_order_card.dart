import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/farmer_order_model.dart';

class FarmerOrderCard extends StatelessWidget {
  final FarmerOrderModel order;
  final bool showActions;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const FarmerOrderCard({
    super.key,
    required this.order,
    this.showActions = false,
    this.onAccept,
    this.onReject,
  });

  Color _statusColor(String s) {
    switch (s) {
      case 'PENDING':
        return AppTheme.statusPending;
      case 'ACCEPTED':
        return AppTheme.statusAssigned;
      case 'DELIVERED':
        return AppTheme.statusDelivered;
      case 'CANCELLED':
        return AppTheme.statusCancelled;
      default:
        return AppTheme.textMuted;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'PENDING':
        return 'Pending';
      case 'ACCEPTED':
        return 'Accepted';
      case 'DELIVERED':
        return 'Delivered';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id}',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(order.status),
                  style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Product & Buyer
          _Row(
              icon: Icons.inventory_2_rounded,
              label: order.productName,
              iconColor: AppTheme.primary),
          const SizedBox(height: 6),
          _Row(
              icon: Icons.person_rounded,
              label: '${order.buyerName} · ${order.buyerWilaya}',
              iconColor: AppTheme.secondary),
          const SizedBox(height: 6),
          _Row(
              icon: Icons.scale_rounded,
              label:
                  '${order.quantity.toStringAsFixed(1)} kg — ${order.totalPrice.toStringAsFixed(0)} DA',
              iconColor: AppTheme.accent),
          // Actions for pending orders
          if (showActions && order.status == 'PENDING') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.statusCancelled.withOpacity(0.15),
                      foregroundColor: AppTheme.statusCancelled,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;

  const _Row(
      {required this.icon, required this.label, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
