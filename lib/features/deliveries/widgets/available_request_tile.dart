import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import './route_map_bottom_sheet.dart';

class AvailableRequestTile extends StatelessWidget {
  final dynamic request;

  const AvailableRequestTile({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final productName = request['product_name'] ?? 'Unknown Product';
    final quantity = request['quantity'] ?? 0;
    final totalValue = double.tryParse(request['total_price']?.toString() ?? '0') ?? 0.0;
    final fee = (totalValue * 0.1).clamp(5.0, double.infinity);
    final farmerWilaya = request['farmer_wilaya'] ?? 'Unknown';
    final buyerWilaya = request['buyer_wilaya'] ?? 'Unknown';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.textMuted.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_shipping_outlined, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Order #${request['id']}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Available',
                  style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Locations
          Row(
            children: [
              _LocationInfo(icon: Icons.agriculture_rounded, label: farmerWilaya, color: Colors.green),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward_rounded, color: AppTheme.textMuted, size: 14),
              ),
              _LocationInfo(icon: Icons.shopping_cart_rounded, label: buyerWilaya, color: Colors.blue),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFF2A3545)),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Delivery Fee', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  Text(
                    '${fee.toStringAsFixed(0)} DA',
                    style: const TextStyle(color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => RouteMapBottomSheet(order: request),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.bgSurface,
                  foregroundColor: AppTheme.textPrimary,
                  elevation: 0,
                  side: BorderSide(color: AppTheme.textMuted.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('View Route', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _LocationInfo({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color.withOpacity(0.7), size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
