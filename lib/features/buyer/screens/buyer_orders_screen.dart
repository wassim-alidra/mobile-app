import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/buyer_provider.dart';
import '../models/buyer_models.dart';
import 'package:url_launcher/url_launcher.dart';

class BuyerOrdersScreen extends StatefulWidget {
  const BuyerOrdersScreen({super.key});

  @override
  State<BuyerOrdersScreen> createState() => _BuyerOrdersScreenState();
}

class _BuyerOrdersScreenState extends State<BuyerOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BuyerProvider>();
      if (provider.orders.isEmpty) {
        provider.fetchOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Consumer<BuyerProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: provider.fetchOrders,
              child: CustomScrollView(
                slivers: [
                  _buildHeader(),
                  if (provider.loadingOrders)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                    )
                  else if (provider.orders.isEmpty)
                    SliverFillRemaining(child: _buildEmpty())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _OrderCard(order: provider.orders[index]),
                          childCount: provider.orders.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PROCUREMENT HISTORY',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'My Orders',
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Track and manage your agricultural acquisitions.',
              style: TextStyle(color: AppTheme.textMutedLight, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, color: AppTheme.textMutedLight, size: 56),
          SizedBox(height: 16),
          Text('No procurement records found.', style: TextStyle(color: AppTheme.textMutedLight)),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final BuyerOrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ORDER REF: #${order.id}',
                style: const TextStyle(color: AppTheme.textDark, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
                child: Text(
                  order.status,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(order.productName, style: const TextStyle(color: AppTheme.textDark, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.person_outline_rounded, label: order.farmerName),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.scale_outlined, label: '${order.quantity.toStringAsFixed(1)} KG — ${order.totalPrice.toStringAsFixed(0)} DA'),
          
          if (order.deliveryStatus != null) ...[
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.local_shipping_outlined, color: AppTheme.primary, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DELIVERY STATUS', style: TextStyle(color: AppTheme.textMutedLight, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      Text(order.deliveryStatus!, style: const TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {}, 
                  child: const Text('TRACK', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.primary))
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

  Color _getStatusColor(String s) {
    switch (s) {
      case 'ACCEPTED': return AppTheme.primary;
      case 'PENDING': return const Color(0xFFF59E0B);
      case 'CANCELLED': return Colors.red;
      case 'DELIVERED': return const Color(0xFF065F46);
      default: return AppTheme.textMutedLight;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textMutedLight, size: 16),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: AppTheme.textDark, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
