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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderLight),
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
                        color: AppTheme.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Order #${request['id']}',
                      style: const TextStyle(color: AppTheme.textMutedLight, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'MARKET',
                  style: TextStyle(color: Colors.blue, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Locations
          Row(
            children: [
              _LocationInfo(icon: Icons.agriculture_rounded, label: farmerWilaya, color: const Color(0xFF065F46)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_forward_rounded, color: AppTheme.textMutedLight, size: 14),
              ),
              _LocationInfo(icon: Icons.location_on_rounded, label: buyerWilaya, color: Colors.blue),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppTheme.borderLight),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Expected Revenue', style: TextStyle(color: AppTheme.textMutedLight, fontSize: 11, fontWeight: FontWeight.w600)),
                  Text(
                    '${fee.toStringAsFixed(0)} DA',
                    style: const TextStyle(color: AppTheme.textDark, fontSize: 18, fontWeight: FontWeight.w800),
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
                  backgroundColor: AppTheme.bgLight,
                  foregroundColor: AppTheme.textDark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: const Text('View Route', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
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
          Icon(icon, color: color.withOpacity(0.8), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textMutedLight, fontSize: 13, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
