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
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
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
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Orders',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Accept, track and manage sales',
                style:
                    TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppTheme.textMuted.withOpacity(0.2)),
        ),
        child: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'Completed'),
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
      backgroundColor: AppTheme.bgCard,
      onRefresh: provider.fetchOrders,
      child: orders.isEmpty
          ? ListView(
              children: [
                const SizedBox(height: 80),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        pending
                            ? Icons.hourglass_empty_rounded
                            : Icons.inbox_rounded,
                        color: AppTheme.textMuted,
                        size: 56,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        pending
                            ? 'No pending orders'
                            : 'No orders here',
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
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
                                  ? 'Order #${order.id} accepted!'
                                  : 'Failed to accept order'),
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
                                  ? 'Order #${order.id} rejected'
                                  : 'Failed to reject'),
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
