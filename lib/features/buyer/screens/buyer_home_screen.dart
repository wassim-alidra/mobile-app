import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import '../providers/buyer_provider.dart';
import '../models/buyer_models.dart';

class BuyerHomeScreen extends StatefulWidget {
  /// Called by the parent [DashboardScreen] to switch the bottom nav tab.
  final void Function(int index) onNavigate;

  const BuyerHomeScreen({super.key, required this.onNavigate});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<BuyerProvider>();
      if (p.orders.isEmpty) p.fetchOrders();
      if (p.products.isEmpty) p.fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Consumer2<BuyerProvider, AuthProvider>(
          builder: (context, buyer, auth, _) {
            return RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: () async {
                await buyer.fetchOrders();
                await buyer.fetchProducts();
              },
              child: CustomScrollView(
                slivers: [
                  // ── Header ──────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _buildHeader(auth.user?.displayName ?? auth.user?.username ?? 'Buyer'),
                  ),

                  // ── Hero Banner ──────────────────────────────────
                  SliverToBoxAdapter(
                    child: _buildHeroBanner(buyer),
                  ),

                  // ── Stats Grid ───────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: _buildStatsGrid(buyer),
                    ),
                  ),

                  // ── Quick Actions ────────────────────────────────
                  SliverToBoxAdapter(
                    child: _buildQuickActions(),
                  ),

                  // ── Recent Orders ────────────────────────────────
                  SliverToBoxAdapter(
                    child: _buildRecentOrders(buyer),
                  ),

                  // ── Featured Products ────────────────────────────
                  SliverToBoxAdapter(
                    child: _buildFeaturedProducts(buyer),
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

  // ── Header ────────────────────────────────────────────────────────

  Widget _buildHeader(String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Row(
        children: [
          // Logo
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Image.asset('assets/images/logo.PNG', fit: BoxFit.contain),
          ),
          const SizedBox(width: 14),
          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AGRIGOV BUYER HUB',
                  style: TextStyle(
                    color: AppTheme.textMutedLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Welcome, $name',
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Notification bell
          Consumer<NotificationProvider>(
            builder: (context, notif, _) {
              final unread = notif.unreadCount;
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
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppTheme.textDark,
                      ),
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
                            minWidth: 16, minHeight: 16),
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
        ],
      ),
    );
  }

  // ── Hero Banner ───────────────────────────────────────────────────

  Widget _buildHeroBanner(BuyerProvider buyer) {
    final hasActive = buyer.activeOrders > 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00C853), Color(0xFF1DE9B6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasActive
                        ? 'ACTIVE DELIVERIES'
                        : 'NATIONAL MARKETPLACE',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hasActive
                        ? '${buyer.activeOrders} order${buyer.activeOrders > 1 ? 's' : ''} in transit'
                        : 'Source certified produce',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasActive
                        ? 'Track your deliveries in real-time.'
                        : 'Browse ${buyer.products.length} verified products.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => widget.onNavigate(hasActive ? 3 : 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        hasActive ? 'TRACK NOW' : 'BROWSE MARKET',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              hasActive
                  ? Icons.local_shipping_rounded
                  : Icons.storefront_rounded,
              color: Colors.white.withValues(alpha: 0.3),
              size: 72,
            ),
          ],
        ),
      ),
    );
  }

  // ── Stats Grid ────────────────────────────────────────────────────

  Widget _buildStatsGrid(BuyerProvider buyer) {
    if (buyer.loadingOrders) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Procurement Overview',
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _StatCard(
              label: 'Total Orders',
              value: '${buyer.totalOrders}',
              icon: Icons.receipt_long_rounded,
              color: AppTheme.primary,
            ),
            _StatCard(
              label: 'Pending',
              value: '${buyer.pendingOrders}',
              icon: Icons.hourglass_top_rounded,
              color: const Color(0xFFF59E0B),
            ),
            _StatCard(
              label: 'Delivered',
              value: '${buyer.deliveredOrders}',
              icon: Icons.task_alt_rounded,
              color: const Color(0xFF065F46),
            ),
            _StatCard(
              label: 'Total Spent',
              value: '${buyer.totalSpent.toStringAsFixed(0)} DA',
              icon: Icons.account_balance_wallet_rounded,
              color: const Color(0xFF0F172A),
            ),
          ],
        ),
      ],
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────────

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
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.storefront_rounded,
                  label: 'Browse\nMarket',
                  color: AppTheme.primary,
                  onTap: () => widget.onNavigate(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.receipt_long_rounded,
                  label: 'My\nOrders',
                  color: const Color(0xFF3B82F6),
                  onTap: () => widget.onNavigate(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.local_shipping_rounded,
                  label: 'Track\nDelivery',
                  color: const Color(0xFF8B5CF6),
                  onTap: () => widget.onNavigate(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notif-\nications',
                  color: const Color(0xFFF59E0B),
                  onTap: () => context.push('/notifications'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Recent Orders ─────────────────────────────────────────────────

  Widget _buildRecentOrders(BuyerProvider buyer) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Orders',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextButton(
                onPressed: () => widget.onNavigate(2),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (buyer.loadingOrders)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            )
          else if (buyer.recentOrders.isEmpty)
            _emptyCard(
              Icons.receipt_long_rounded,
              'No orders yet.\nBrowse the marketplace to place your first order.',
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                children: buyer.recentOrders
                    .map((o) => _RecentOrderRow(order: o))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  // ── Featured Products ─────────────────────────────────────────────

  Widget _buildFeaturedProducts(BuyerProvider buyer) {
    if (buyer.products.isEmpty) return const SizedBox.shrink();

    final featured = buyer.products.take(6).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured Products',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextButton(
                onPressed: () => widget.onNavigate(1),
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: featured.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _FeaturedProductCard(product: featured[index]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper ────────────────────────────────────────────────────────

  Widget _emptyCard(IconData icon, String message) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, color: AppTheme.textMutedLight, size: 40),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textMutedLight,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.textMutedLight,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Quick Action Tile ─────────────────────────────────────────────────

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
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.borderLight),
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
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Recent Order Row ──────────────────────────────────────────────────

class _RecentOrderRow extends StatelessWidget {
  final BuyerOrderModel order;
  const _RecentOrderRow({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.borderLight.withValues(alpha: 0.6)),
        ),
      ),
      child: Row(
        children: [
          // Product icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.agriculture_rounded,
                color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.productName,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.quantity.toStringAsFixed(1)} kg · ${order.totalPrice.toStringAsFixed(0)} DA',
                  style: const TextStyle(
                    color: AppTheme.textMutedLight,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Status chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              order.status,
              style: TextStyle(
                color: statusColor,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'DELIVERED':
        return const Color(0xFF065F46);
      case 'PENDING':
        return const Color(0xFFF59E0B);
      case 'CANCELLED':
        return Colors.red;
      case 'ACCEPTED':
      case 'ON_WAY':
      case 'CHARGING':
        return AppTheme.primary;
      default:
        return AppTheme.textMutedLight;
    }
  }
}

// ── Featured Product Card ─────────────────────────────────────────────

class _FeaturedProductCard extends StatelessWidget {
  final BuyerProductModel product;
  const _FeaturedProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / placeholder
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              child: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!.startsWith('http')
                          ? product.imageUrl!
                          : '$kBaseUrl${product.imageUrl}',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => const _PlaceholderIcon(),
                    )
                  : const _PlaceholderIcon(),
            ),
          ),
          // Labels
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.price.toStringAsFixed(0)} DA/${product.unit}',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.bgLight,
      child: const Center(
        child: Icon(Icons.agriculture_rounded,
            color: AppTheme.primary, size: 32),
      ),
    );
  }
}
