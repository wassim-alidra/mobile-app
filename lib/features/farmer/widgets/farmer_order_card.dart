import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/farmer_order_model.dart';
import 'package:url_launcher/url_launcher.dart';

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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ORDER REF: #${order.id}',
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _statusLabel(order.status).toUpperCase(),
                  style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Product Info
          Text(
            order.productName,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          // Details
          _Row(
              icon: Icons.person_outline_rounded,
              label: '${order.buyerName} · ${order.buyerWilaya}',
              iconColor: AppTheme.textMutedLight),
          const SizedBox(height: 8),
          _Row(
              icon: Icons.scale_outlined,
              label: '${order.quantity.toStringAsFixed(1)} KG — ${order.totalPrice.toStringAsFixed(0)} DA',
              iconColor: AppTheme.textMutedLight),
          
          // Actions for pending orders
          if (showActions && order.status == 'PENDING') ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('APPROVE',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      foregroundColor: Colors.red.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('REJECT',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final url = Uri.parse('$kBaseUrl/api/market/orders/${order.id}/download_pdf/');
                if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                  // ignore: use_build_context_synchronously
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open PDF')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Download PDF', style: TextStyle(fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppTheme.borderLight),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
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
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
                color: AppTheme.textDark, fontSize: 13, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
