import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/farmer_provider.dart';
import '../widgets/farmer_stat_card.dart';
import '../widgets/farmer_order_card.dart';
import '../../notifications/providers/notification_provider.dart';

class FarmerHomeScreen extends StatefulWidget {
  final void Function(int index) onNavigate;

  const FarmerHomeScreen({super.key, required this.onNavigate});

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
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Consumer<FarmerProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              color: AppTheme.primary,
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
                    child: _buildQuickActions(),
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
    );
  }

  Widget _buildError(String message) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppTheme.textDark, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary, size: 20),
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
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Image.asset('assets/images/logo.PNG', fit: BoxFit.contain),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.user?.username ?? 'Farmer',
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'INSTITUTIONAL FARMER HUB',
                    style: TextStyle(
                      color: AppTheme.textMutedLight,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Consumer<NotificationProvider>(
              builder: (context, notifProvider, _) {
                final unread = notifProvider.unreadCount;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textDark),
                        onPressed: () => context.push('/notifications'),
                      ),
                    ),
                    if (unread > 0)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unread > 9 ? '9+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            if (provider.hasFireAlert)
              const SizedBox(width: 8),
            if (provider.hasFireAlert)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
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
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'EMERGENCY ALERT: FIRE DETECTED',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...provider.fireAlerts.map(
                      (alert) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Critical detection at ${alert.farmName}',
                                style: const TextStyle(
                                    color: AppTheme.textDark, fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 32,
                              child: ElevatedButton(
                                onPressed: () => provider.resolveFireAlert(alert.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade50,
                                  foregroundColor: Colors.red.shade700,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                                child: const Text('Resolve',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(FarmerProvider provider) {
    if (provider.loadingStats) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    final stats = provider.stats;

    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Operational Overview',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.1,
            children: [
              FarmerStatCard(
                label: 'Market Inventory',
                value: '${stats?.totalProducts ?? 0}',
                icon: Icons.inventory_2_rounded,
                color: AppTheme.primary,
              ),
              FarmerStatCard(
                label: 'Awaiting Action',
                value: '${stats?.pendingOrders ?? 0}',
                icon: Icons.assignment_late_rounded,
                color: const Color(0xFFF59E0B),
              ),
              FarmerStatCard(
                label: 'Fulfillment Rate',
                value: '${stats?.completedOrders ?? 0}',
                icon: Icons.task_alt_rounded,
                color: const Color(0xFF065F46),
              ),
              FarmerStatCard(
                label: 'Gross Revenue',
                value: '${(stats?.totalRevenue ?? 0).toStringAsFixed(0)} DA',
                icon: Icons.account_balance_wallet_rounded,
                color: const Color(0xFF0F172A),
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Strategic Fulfillment (${pending.length})',
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (provider.loadingOrders)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            )
          else if (pending.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_rounded,
                        color: AppTheme.textMutedLight, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'No orders requiring action.',
                      style: TextStyle(
                          color: AppTheme.textMutedLight, fontSize: 14, fontWeight: FontWeight.w600),
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
                          : 'Action failed.'),
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
                          ? 'Order #${order.id} rejected.'
                          : 'Action failed.'),
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

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.agriculture_rounded,
                  label: 'My\nFarms',
                  color: const Color(0xFF10B981),
                  onTap: () => context.push('/my-farms'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.cloud_rounded,
                  label: 'Weather\nForecast',
                  color: const Color(0xFF8B5CF6),
                  onTap: () => widget.onNavigate(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.handyman_rounded,
                  label: 'Equipment\nRental',
                  color: const Color(0xFF3B82F6),
                  onTap: () => widget.onNavigate(3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.receipt_long_rounded,
                  label: 'My Orders',
                  color: AppTheme.primary,
                  onTap: () => widget.onNavigate(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.bar_chart_rounded,
                  label: 'Analytics Stats',
                  color: const Color(0xFF0F172A),
                  onTap: () => widget.onNavigate(5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.inventory_2_rounded,
                  label: 'My\nProducts',
                  color: const Color(0xFFD97706),
                  onTap: () => context.push('/my-products'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

