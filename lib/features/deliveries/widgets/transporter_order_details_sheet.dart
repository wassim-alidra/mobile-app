import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../models/delivery_model.dart';
import 'package:provider/provider.dart';
import '../providers/delivery_provider.dart';

class TransporterOrderDetailsSheet extends StatelessWidget {
  final DeliveryModel delivery;

  const TransporterOrderDetailsSheet({super.key, required this.delivery});

  Future<void> _downloadPdf(BuildContext context) async {
    // TODO: Connect this to actual backend PDF endpoint
    // Connect to actual backend PDF endpoint for deliveries
    final url = Uri.parse('$kBaseUrl/api/market/deliveries/${delivery.id}/download_pdf/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open PDF')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.getStatusColor(delivery.status);
    final order = delivery.order;
    final product = order.product;
    final buyer = order.buyer;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Details #${delivery.orderId}',
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Delivery Mission #${delivery.id}',
                        style: const TextStyle(
                          color: AppTheme.textMutedLight,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textMutedLight),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppTheme.borderLight),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Info Section
                  _SectionTitle(title: 'PRODUCT INFO'),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(label: 'Product', value: product?.name ?? 'Unknown'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: AppTheme.borderLight),
                        ),
                        _InfoRow(label: 'Quantity', value: '${order.quantity.toStringAsFixed(0)} kg', valueColor: Colors.amber.shade700),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: AppTheme.borderLight),
                        ),
                        _InfoRow(label: 'Total Value', value: '${order.totalPrice.toStringAsFixed(0)} DA', valueColor: Colors.orange.shade700),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: AppTheme.borderLight),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Status', style: TextStyle(color: AppTheme.textMutedLight, fontSize: 13)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                AppTheme.getStatusLabel(delivery.status),
                                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contact Info Section
                  _SectionTitle(title: 'CONTACT INFORMATION'),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _ContactCard(
                          role: 'Farmer / Seller',
                          name: product?.farmerUsername ?? 'Unknown',
                          phone: delivery.farmerPhone ?? 'Not Provided',
                          location: product?.farmerWilaya ?? 'Unknown',
                          icon: Icons.agriculture_rounded,
                          color: const Color(0xFF065F46),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ContactCard(
                          role: 'Buyer / Customer',
                          name: buyer?.username ?? 'Unknown',
                          phone: delivery.buyerPhone ?? 'Not Provided',
                          location: buyer?.wilaya ?? 'Unknown',
                          icon: Icons.person_rounded,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Delivery Info Section
                  _SectionTitle(title: 'DELIVERY INFO'),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(label: 'Pickup', value: product?.farmerWilaya ?? 'Unknown'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: AppTheme.borderLight),
                        ),
                        _InfoRow(label: 'Destination', value: buyer?.wilaya ?? 'Unknown'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: AppTheme.borderLight),
                        ),
                        _InfoRow(label: 'Delivery Fee', value: '${delivery.deliveryFee.toStringAsFixed(0)} DA', valueColor: AppTheme.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.borderLight)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppTheme.borderLight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Close', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadPdf(context),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Download PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textMutedLight,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMutedLight, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppTheme.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  final String role;
  final String name;
  final String phone;
  final String location;
  final IconData icon;
  final Color color;

  const _ContactCard({
    required this.role,
    required this.name,
    required this.phone,
    required this.location,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                role,
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(color: AppTheme.textDark, fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.phone_rounded, size: 12, color: AppTheme.textMutedLight),
              const SizedBox(width: 4),
              Text(phone, style: const TextStyle(color: AppTheme.textMutedLight, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 12, color: AppTheme.textMutedLight),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(color: AppTheme.textMutedLight, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
