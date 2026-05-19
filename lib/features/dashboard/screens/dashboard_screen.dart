import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../deliveries/providers/delivery_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../deliveries/models/delivery_model.dart';
import '../../../core/constants/app_constants.dart';

// Farmer Screens
import '../../farmer/screens/farmer_home_screen.dart';
import '../../farmer/screens/farmer_orders_screen.dart';
import '../../farmer/screens/farmer_tracking_screen.dart';
import '../../farmer/screens/farmer_stats_screen.dart';
import '../../farmer/screens/farmer_equipment_screen.dart';
// Buyer Screens
import '../../buyer/screens/buyer_home_screen.dart';
import '../../buyer/screens/marketplace_screen.dart';
import '../../buyer/screens/buyer_orders_screen.dart';
import '../../buyer/screens/track_delivery_screen.dart';
import '../../profile/screens/profile_screen.dart';
// Equipment Provider
import '../../equipment_provider/screens/equipment_provider_dashboard_screen.dart';
// Weather
import '../../weather/screens/weather_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user?.role == 'TRANSPORTER') {
        context.read<DeliveryProvider>().fetchDeliveries();
      }
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isFarmer = user?.role == 'FARMER';
    final isBuyer = user?.role == 'BUYER';
    final isEquipmentProvider = user?.role == 'EQUIPMENT_PROVIDER';

    if (isFarmer) {
      return Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            FarmerHomeScreen(
              onNavigate: (index) => setState(() => _currentIndex = index),
            ),
            const FarmerOrdersScreen(),
            const FarmerTrackingScreen(),
            const FarmerEquipmentScreen(),
            const WeatherScreen(),
            const FarmerStatsScreen(),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: _buildFarmerBottomNav(),
      );
    }

    if (isBuyer) {
      return Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            BuyerHomeScreen(onNavigate: (i) => setState(() => _currentIndex = i)),
            const MarketplaceScreen(),
            const BuyerOrdersScreen(),
            const TrackDeliveryScreen(),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: _buildBuyerBottomNav(),
      );
    }

    if (isEquipmentProvider) {
      return const EquipmentProviderDashboardScreen();
    }

    // New Institutional Transporter View
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: _buildAppBar(user?.username ?? ''),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () async {
            await Future.wait([
              context.read<DeliveryProvider>().fetchDeliveries(),
              context.read<NotificationProvider>().fetchNotifications(),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeroSection(user?.username ?? 'Operator')),
              SliverToBoxAdapter(child: _buildActionButtons()),
              SliverToBoxAdapter(child: _buildStatsGrid()),
              SliverToBoxAdapter(child: _buildFocusedShipment()),
              SliverToBoxAdapter(child: _buildActiveQueueHeader()),
              _buildActiveQueueList(),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── App Bar ─────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(String username) {
    return AppBar(
      title: const Text('Transport Authority'),
      leading: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Image.asset('assets/images/logo.PNG', fit: BoxFit.contain),
      ),
      actions: [
        Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            final unread = provider.unreadCount;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  onPressed: () => context.push('/notifications'),
                ),
                if (unread > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unread > 9 ? '9+' : '$unread',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
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
        Container(
          margin: const EdgeInsets.only(right: 16, left: 8),
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              username.isNotEmpty ? username.substring(0, 2).toUpperCase() : 'JD',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Hero Section ────────────────────────────────────────────────

  Widget _buildHeroSection(String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OPERATOR DASHBOARD',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome back, $name',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'System status: All networks operational. 4 deliveries scheduled for today.',
            style: TextStyle(
              color: AppTheme.textMutedLight,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Action Buttons ──────────────────────────────────────────────

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.file_download_outlined, size: 18),
              label: const Text('Export Report'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('New Log'),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stats Grid ──────────────────────────────────────────────────

  Widget _buildStatsGrid() {
    final delivery = context.watch<DeliveryProvider>();
    final active = delivery.activeDeliveries.length;
    final completed = delivery.completedDeliveries.length;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        children: [
          _StatsCard(
            label: 'TOTAL EARNINGS',
            value: '\$12,840.50',
            subtext: '↑ +12% from last month',
            icon: Icons.account_balance_wallet_outlined,
            isGreenSub: true,
          ),
          const SizedBox(height: 16),
          _StatsCard(
            label: 'ACTIVE SHIPMENTS',
            value: active < 10 ? '0$active' : '$active',
            subtext: '$active shipments arriving today',
            icon: Icons.local_shipping_outlined,
          ),
          const SizedBox(height: 16),
          _StatsCard(
            label: 'COMPLETED LOGS',
            value: '$completed',
            subtext: '99.8% compliance rate',
            icon: Icons.check_circle_outline_rounded,
            isGreenSub: true,
          ),
        ],
      ),
    );
  }

  // ─── Focused Shipment Card ───────────────────────────────────────

  Widget _buildFocusedShipment() {
    final active = context.watch<DeliveryProvider>().activeDeliveries;
    if (active.isEmpty) return const SizedBox.shrink();
    
    final current = active.first;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Active Shipment:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      '#TRK-${current.id}-X',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Last updated: 2 minutes ago',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMutedLight,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'IN TRANSIT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StepItem(
                  label: 'Accepted', 
                  isActive: true, 
                  isDone: current.status == 'ON_WAY' || current.status == 'CHARGING' || current.status == 'DELIVERED',
                  isCurrent: current.status == 'ASSIGNED',
                ),
                _StepItem(
                  label: 'On Way', 
                  isActive: true, 
                  isDone: current.status == 'CHARGING' || current.status == 'DELIVERED',
                  isCurrent: current.status == 'ON_WAY',
                ),
                _StepItem(
                  label: 'Loading', 
                  isActive: true, 
                  isDone: current.status == 'DELIVERED',
                  isCurrent: current.status == 'CHARGING',
                ),
                _StepItem(
                  label: 'Delivered', 
                  isActive: true, 
                  isDone: false,
                  isCurrent: current.status == 'DELIVERED',
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFFF1F5F9),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'CURRENT LOCATION',
                  value: 'I-95 Northbound, Mile 42',
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.access_time_rounded,
                  label: 'EST. ARRIVAL',
                  value: '14:45 (Today)',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Active Queue ────────────────────────────────────────────────

  Widget _buildActiveQueueHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Active Queue',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          TextButton(
            onPressed: () => context.push('/deliveries'),
            child: const Text(
              'View All Shipments',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveQueueList() {
    final deliveries = context.watch<DeliveryProvider>().deliveries;
    
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 2, child: Text('ID', style: _tableHeaderStyle)),
                    Expanded(flex: 5, child: Text('CARGO DESCRIPTION', style: _tableHeaderStyle)),
                    Expanded(flex: 4, child: Text('DESTINATION', style: _tableHeaderStyle)),
                  ],
                ),
              ),
              // Table Rows
              ...deliveries.take(5).map((d) => _QueueRow(delivery: d)),
            ],
          ),
        ),
      ),
    );
  }

  static const _tableHeaderStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppTheme.textMutedLight,
    letterSpacing: 0.5,
  );

  // ─── Shared Navigation ──────────────────────────────────────────

  Widget _buildBuyerBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_filled, label: 'Home', isActive: _currentIndex == 0, onTap: () => setState(() => _currentIndex = 0)),
              _NavItem(icon: Icons.storefront_rounded, label: 'Market', isActive: _currentIndex == 1, onTap: () => setState(() => _currentIndex = 1)),
              _NavItem(icon: Icons.receipt_rounded, label: 'Orders', isActive: _currentIndex == 2, onTap: () => setState(() => _currentIndex = 2)),
              _NavItem(icon: Icons.local_shipping_rounded, label: 'Tracking', isActive: _currentIndex == 3, onTap: () => setState(() => _currentIndex = 3)),
              _NavItem(icon: Icons.person_rounded, label: 'Profile', isActive: _currentIndex == 4, onTap: () => setState(() => _currentIndex = 4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFarmerBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_filled, label: 'Home', isActive: _currentIndex == 0, onTap: () => setState(() => _currentIndex = 0)),
              _NavItem(icon: Icons.receipt_long_rounded, label: 'Orders', isActive: _currentIndex == 1, onTap: () => setState(() => _currentIndex = 1)),
              _NavItem(icon: Icons.local_shipping_rounded, label: 'Tracking', isActive: _currentIndex == 2, onTap: () => setState(() => _currentIndex = 2)),
              _NavItem(icon: Icons.bar_chart_rounded, label: 'Stats', isActive: _currentIndex == 5, onTap: () => setState(() => _currentIndex = 5)),
              _NavItem(icon: Icons.person_rounded, label: 'Profile', isActive: _currentIndex == 6, onTap: () => setState(() => _currentIndex = 6)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_filled, label: 'Home', isActive: true, onTap: () {}),
              _NavItem(icon: Icons.local_shipping_rounded, label: 'Deliveries', isActive: false, onTap: () => context.push('/deliveries')),
              _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Earnings', isActive: false, onTap: () => context.push('/history')),
              _NavItem(icon: Icons.person_rounded, label: 'Profile', isActive: false, onTap: () => context.push('/profile')),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Custom Widgets for New Design ─────────────────────────────────

class _StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtext;
  final IconData icon;
  final bool isGreenSub;

  const _StatsCard({
    required this.label,
    required this.value,
    required this.subtext,
    required this.icon,
    this.isGreenSub = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMutedLight, letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                const SizedBox(height: 4),
                Text(subtext, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isGreenSub ? AppTheme.primary : AppTheme.textMutedLight)),
              ],
            ),
          ),
          Icon(icon, color: AppTheme.primary, size: 28),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isDone;
  final bool isCurrent;

  const _StepItem({
    required this.label,
    this.isActive = false,
    this.isDone = false,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCurrent ? AppTheme.primary : (isDone ? const Color(0xFF065F46) : Colors.white),
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrent ? AppTheme.primary : (isDone ? const Color(0xFF065F46) : const Color(0xFFCBD5E1)),
              width: 2,
            ),
          ),
          child: Center(
            child: isDone 
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : (isCurrent ? const Icon(Icons.local_shipping, color: Colors.white, size: 16) : null),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: (isDone || isCurrent) ? FontWeight.w700 : FontWeight.w500, color: (isDone || isCurrent) ? AppTheme.textDark : AppTheme.textMutedLight)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textDark, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textMutedLight, letterSpacing: 0.5)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
          ],
        ),
      ],
    );
  }
}

class _QueueRow extends StatelessWidget {
  final DeliveryModel delivery;
  const _QueueRow({required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('#TX-${delivery.id}', style: const TextStyle(fontSize: 13, color: AppTheme.textMutedLight))),
          Expanded(
            flex: 5, 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(delivery.order.product?.name ?? 'Standard Cargo', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                const Text('(Class A)', style: TextStyle(fontSize: 11, color: AppTheme.textMutedLight)),
              ],
            )
          ),
          Expanded(flex: 4, child: Text(delivery.order.buyer?.wilaya ?? 'Central Hub', style: const TextStyle(fontSize: 13, color: AppTheme.textMutedLight))),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: isActive ? Colors.white : AppTheme.textMutedLight, size: 22),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isActive ? AppTheme.primary : AppTheme.textMutedLight, fontSize: 10, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyStateCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.textMutedLight, size: 36),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: AppTheme.textMutedLight,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

