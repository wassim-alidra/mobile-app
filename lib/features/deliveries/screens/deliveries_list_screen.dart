import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../deliveries/providers/delivery_provider.dart';
import '../../deliveries/models/delivery_model.dart';
import '../widgets/available_request_tile.dart';

class DeliveriesListScreen extends StatefulWidget {
  const DeliveriesListScreen({super.key});

  @override
  State<DeliveriesListScreen> createState() => _DeliveriesListScreenState();
}

class _DeliveriesListScreenState extends State<DeliveriesListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryProvider>().fetchDeliveries();
      context.read<DeliveryProvider>().fetchAvailableRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.textDark, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Market & Deliveries',
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppTheme.textMutedLight,
                  labelStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                  dividerColor: Colors.transparent,
                  padding: const EdgeInsets.all(4),
                  tabs: const [
                    Tab(text: 'Available'),
                    Tab(text: 'Active'),
                    Tab(text: 'Completed'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tab content
            Expanded(
              child: Consumer<DeliveryProvider>(
                builder: (context, provider, _) {
                  if (provider.state == DeliveryLoadState.loading &&
                      provider.deliveries.isEmpty && provider.availableRequests.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primary),
                    );
                  }

                  if (provider.state == DeliveryLoadState.error && provider.deliveries.isEmpty) {
                    return _ErrorView(
                      message: provider.errorMessage ?? 'Failed to load',
                      onRetry: () {
                        provider.fetchDeliveries();
                        provider.fetchAvailableRequests();
                      },
                    );
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _AvailableRequestsList(
                        requests: provider.availableRequests,
                        onRefresh: () => provider.fetchAvailableRequests(),
                      ),
                      _DeliveryList(
                        deliveries: provider.activeDeliveries,
                        emptyMessage: 'No active deliveries',
                        onRefresh: () => provider.fetchDeliveries(),
                      ),
                      _DeliveryList(
                        deliveries: provider.completedDeliveries,
                        emptyMessage: 'No completed deliveries yet',
                        onRefresh: () => provider.fetchDeliveries(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailableRequestsList extends StatelessWidget {
  final List<dynamic> requests;
  final Future<void> Function() onRefresh;

  const _AvailableRequestsList({required this.requests, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: onRefresh,
        child: ListView(
          children: [
            const SizedBox(height: 80),
            const Icon(Icons.request_page_outlined, color: AppTheme.textMutedLight, size: 56),
            const SizedBox(height: 16),
            const Text(
              'No delivery requests available\nin the market right now.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMutedLight, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: requests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return AvailableRequestTile(request: requests[index]);
        },
      ),
    );
  }
}

class _DeliveryList extends StatelessWidget {
  final List<DeliveryModel> deliveries;
  final String emptyMessage;
  final Future<void> Function() onRefresh;

  const _DeliveryList({
    required this.deliveries,
    required this.emptyMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (deliveries.isEmpty) {
      return RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: onRefresh,
        child: ListView(
          children: [
            const SizedBox(height: 80),
            const Icon(Icons.local_shipping_outlined,
                color: AppTheme.textMutedLight, size: 56),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.textMutedLight, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: deliveries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _DeliveryListTile(delivery: deliveries[index]);
        },
      ),
    );
  }
}

class _DeliveryListTile extends StatelessWidget {
  final DeliveryModel delivery;

  const _DeliveryListTile({required this.delivery});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.getStatusColor(delivery.status);
    final statusLabel = AppTheme.getStatusLabel(delivery.status);
    final product = delivery.order.product;
    final buyer = delivery.order.buyer;

    return GestureDetector(
      onTap: () => context.push('/delivery/${delivery.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(AppTheme.getStatusIcon(delivery.status),
                      color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product?.name ?? 'Order #${delivery.order.id}',
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: #TX-${delivery.id}',
                        style: const TextStyle(
                          color: AppTheme.textMutedLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppTheme.borderLight),
            const SizedBox(height: 14),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.location_on_outlined,
                  label: buyer?.wilaya ?? 'Central Hub',
                ),
                const SizedBox(width: 12),
                _InfoChip(
                  icon: Icons.scale_rounded,
                  label: '${delivery.order.quantity.toStringAsFixed(1)} kg',
                ),
                const Spacer(),
                Text(
                  '${delivery.deliveryFee.toStringAsFixed(0)} DA',
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.textMutedLight, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
              color: AppTheme.textMutedLight, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: AppTheme.textMutedLight, size: 48),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(
                  color: AppTheme.textMutedLight, fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
