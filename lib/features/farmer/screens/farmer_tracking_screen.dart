import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/farmer_provider.dart';
import '../models/farmer_order_model.dart';
import 'package:url_launcher/url_launcher.dart';

class FarmerTrackingScreen extends StatefulWidget {
  const FarmerTrackingScreen({super.key});

  @override
  State<FarmerTrackingScreen> createState() => _FarmerTrackingScreenState();
}

class _FarmerTrackingScreenState extends State<FarmerTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FarmerProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Consumer<FarmerProvider>(
          builder: (context, provider, _) {
            // Filter orders that are being handled by a transporter
            final activeLogistics = provider.orders.where((o) => 
              o.status == 'ACCEPTED' || 
              o.deliveryStatus == 'ON_WAY' || 
              o.deliveryStatus == 'CHARGING' ||
              (o.status == 'DELIVERED' && o.createdAt.isAfter(DateTime.now().subtract(const Duration(hours: 24))))
            ).toList();

            return RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: () => provider.fetchOrders(),
              child: CustomScrollView(
                slivers: [
                  _buildHeader(),
                  if (provider.loadingOrders && activeLogistics.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                    )
                  else if (activeLogistics.isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _FarmerTrackingCard(order: activeLogistics[index]),
                          childCount: activeLogistics.length,
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
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LOGISTICS HUB',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Shipment Status',
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Track transporter arrival and delivery completion.',
              style: TextStyle(
                color: AppTheme.textDark.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.local_shipping_outlined, size: 48, color: AppTheme.textMutedLight),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Shipments Active',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Accepted orders will appear here once\na transporter is assigned.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textMutedLight,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmerTrackingCard extends StatelessWidget {
  final FarmerOrderModel order;
  const _FarmerTrackingCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order.deliveryStatus ?? 'ASSIGNED';
    final progress = _getStatusProgress(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.inventory_2_rounded, color: AppTheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        'Deliver to: ${order.buyerName} (${order.buyerWilaya})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: status),
                const SizedBox(width: 8),
                IconButton(
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
                  icon: const Icon(Icons.download_rounded, color: AppTheme.primary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStep('Assigned', progress >= 1),
                    _buildStep('On Way', progress >= 2),
                    _buildStep('Loading', progress >= 3),
                    _buildStep('Delivered', progress >= 4),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress / 4,
                    backgroundColor: AppTheme.bgLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.bgLight.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getStatusMessage(status),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String label, bool isDone) {
    return Column(
      children: [
        Icon(
          isDone ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
          size: 16,
          color: isDone ? AppTheme.primary : AppTheme.textMutedLight,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isDone ? FontWeight.w800 : FontWeight.w500,
            color: isDone ? AppTheme.textDark : AppTheme.textMutedLight,
          ),
        ),
      ],
    );
  }

  int _getStatusProgress(String status) {
    switch (status) {
      case 'ASSIGNED': return 1;
      case 'ON_WAY': return 2;
      case 'CHARGING': return 3;
      case 'DELIVERED': return 4;
      default: return 1;
    }
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'ASSIGNED': return 'Transporter has been assigned. Please prepare your cargo.';
      case 'ON_WAY': return 'The transporter is currently moving to your farm.';
      case 'CHARGING': return 'Transporter has arrived. Cargo is being loaded.';
      case 'DELIVERED': return 'Shipment has reached the buyer successfully.';
      default: return 'Waiting for transporter coordination.';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label = status;
    switch (status) {
      case 'ON_WAY': 
        color = const Color(0xFF3B82F6); 
        label = 'On Way';
        break;
      case 'CHARGING':
        color = const Color(0xFF8B5CF6);
        label = 'Loading';
        break;
      case 'DELIVERED': 
        color = const Color(0xFF10B981); 
        label = 'Delivered';
        break;
      case 'ASSIGNED': 
        color = const Color(0xFFF59E0B); 
        label = 'Assigned';
        break;
      default: 
        color = AppTheme.textMutedLight;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
