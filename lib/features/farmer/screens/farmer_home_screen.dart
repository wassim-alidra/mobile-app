import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/farmer_provider.dart';
import '../widgets/farmer_stat_card.dart';
import '../widgets/farmer_order_card.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Consumer<FarmerProvider>(
            builder: (context, provider, _) {
              return RefreshIndicator(
                color: AppTheme.primary,
                backgroundColor: AppTheme.bgCard,
                onRefresh: () async {
                  await provider.fetchStats();
                  await provider.fetchOrders();
                },
                child: CustomScrollView(
                  slivers: [
                    _buildHeader(provider),
                    if (provider.hasFireAlert)
                      SliverToBoxAdapter(child: _buildFireAlert(provider)),
                    if (provider.error != null)
                      SliverToBoxAdapter(
                        child: _buildError(provider.error!),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: _buildStatsGrid(provider),
                      ),
                    ),
                    SliverToBoxAdapter(
                        child: _buildPendingOrdersSection(provider)),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.red, size: 20),
            onPressed: () {
              final p = context.read<FarmerProvider>();
              p.fetchStats();
              p.fetchOrders();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(FarmerProvider provider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.agriculture_rounded,
                  color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${provider.user?.username ?? 'Farmer'} (${provider.user?.role ?? 'Role'})',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Manage your farm operations',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (provider.hasFireAlert)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_fire_department_rounded,
                    color: Colors.red, size: 22),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFireAlert(FarmerProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_fire_department_rounded,
                  color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text(
                '🔥 FIRE ALERT — Immediate Action Required',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...provider.fireAlerts.map(
            (alert) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.place_rounded,
                      color: Colors.redAccent, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${alert.farmName} — Fire detected!',
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: () => provider.resolveFireAlert(alert.id),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                    ),
                    child: const Text('Resolve',
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(FarmerProvider provider) {
    if (provider.loadingStats) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    final stats = provider.stats;

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              FarmerStatCard(
                label: 'My Products',
                value: '${stats?.totalProducts ?? 0}',
                icon: Icons.inventory_2_rounded,
                color: AppTheme.primary,
              ),
              FarmerStatCard(
                label: 'Pending Orders',
                value: '${stats?.pendingOrders ?? 0}',
                icon: Icons.hourglass_empty_rounded,
                color: AppTheme.accent,
              ),
              FarmerStatCard(
                label: 'Completed',
                value: '${stats?.completedOrders ?? 0}',
                icon: Icons.check_circle_rounded,
                color: AppTheme.statusDelivered,
              ),
              FarmerStatCard(
                label: 'Revenue',
                value: '${(stats?.totalRevenue ?? 0).toStringAsFixed(0)} DA',
                icon: Icons.attach_money_rounded,
                color: AppTheme.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingOrdersSection(FarmerProvider provider) {
    final pending = provider.pendingOrders;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pending Orders (${pending.length})',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (provider.loadingOrders)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            )
          else if (pending.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.textMuted.withOpacity(0.15)),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_rounded,
                        color: AppTheme.textMuted, size: 40),
                    SizedBox(height: 8),
                    Text(
                      'No pending orders',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            ...pending.map(
              (order) => FarmerOrderCard(
                order: order,
                showActions: true,
                onAccept: () async {
                  final ok = await provider.updateOrderStatus(
                      order.id, 'ACCEPTED');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ok
                          ? 'Order #${order.id} accepted!'
                          : 'Failed to accept order'),
                      backgroundColor:
                          ok ? AppTheme.statusDelivered : AppTheme.statusCancelled,
                    ));
                  }
                },
                onReject: () async {
                  final ok = await provider.updateOrderStatus(
                      order.id, 'CANCELLED');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ok
                          ? 'Order #${order.id} rejected'
                          : 'Failed to reject order'),
                      backgroundColor: AppTheme.statusCancelled,
                    ));
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
