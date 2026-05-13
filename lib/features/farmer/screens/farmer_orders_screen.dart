import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/farmer_provider.dart';
import '../widgets/farmer_order_card.dart';

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({super.key});

  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FarmerProvider>().fetchOrders();
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
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: Consumer<FarmerProvider>(
                builder: (context, provider, _) {
                  if (provider.loadingOrders) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primary),
                    );
                  }
                  if (provider.error != null) {
                    return _buildError(provider.error!, provider);
                  }
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrdersList(
                          provider.pendingOrders, provider, pending: true),
                      _buildOrdersList(provider.acceptedOrders, provider),
                      _buildOrdersList(provider.completedOrders, provider),
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

  Widget _buildError(String message, FarmerProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: AppTheme.textDark, fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: provider.fetchOrders,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.assignment_rounded,
                color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Orders Management',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'STRATEGIC FULFILLMENT LEDGER',
                style: TextStyle(
                  color: AppTheme.textMutedLight,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          indicatorPadding: const EdgeInsets.all(4),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textMutedLight,
          labelStyle: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          tabs: const [
            Tab(text: 'PENDING'),
            Tab(text: 'ACCEPTED'),
            Tab(text: 'HISTORY'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(
    List orders,
    FarmerProvider provider, {
    bool pending = false,
  }) {
    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: provider.fetchOrders,
      child: orders.isEmpty
          ? ListView(
              children: [
                const SizedBox(height: 100),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        pending
                            ? Icons.hourglass_empty_rounded
                            : Icons.inbox_rounded,
                        color: AppTheme.textMutedLight,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        pending
                            ? 'No Pending Strategic Orders'
                            : 'No Order Records Found',
                        style: const TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Updates will appear in real-time.',
                        style: TextStyle(
                            color: AppTheme.textMutedLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return FarmerOrderCard(
                  order: order,
                  showActions: pending,
                  onAccept: pending
                      ? () async {
                          final ok = await provider.updateOrderStatus(
                              order.id, 'ACCEPTED');
                          if (mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                              content: Text(ok
                                  ? 'Order #${order.id} approved!'
                                  : 'Action failed.'),
                              backgroundColor: ok
                                  ? AppTheme.statusDelivered
                                  : AppTheme.statusCancelled,
                            ));
                          }
                        }
                      : null,
                  onReject: pending
                      ? () async {
                          final ok = await provider.updateOrderStatus(
                              order.id, 'CANCELLED');
                          if (mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                              content: Text(ok
                                  ? 'Order #${order.id} rejected.'
                                  : 'Action failed.'),
                              backgroundColor:
                                  AppTheme.statusCancelled,
                            ));
                          }
                        }
                      : null,
                );
              },
            ),
    );
  }
}
