import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../deliveries/providers/delivery_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final delivery = context.watch<DeliveryProvider>();
    final user = auth.user;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
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
                          color: AppTheme.bgSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.textMuted.withOpacity(0.2)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppTheme.textPrimary, size: 18),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'My Profile',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Avatar & Name
                    _buildProfileHero(user?.username ?? ''),

                    const SizedBox(height: 28),

                    // Approval status
                    if (user != null && !user.isApproved)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppTheme.accent.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: AppTheme.accent, size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Your account is pending admin approval.',
                                style: TextStyle(
                                    color: AppTheme.accent, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Account Info
                    _SectionCard(
                      title: 'Account Info',
                      icon: Icons.person_outline_rounded,
                      children: [
                        _ProfileRow('Username', user?.username ?? '—'),
                        _ProfileRow('Email', user?.email ?? '—'),
                        _ProfileRow('Role', user?.role ?? '—'),
                        _ProfileRow('Wilaya', user?.wilaya ?? '—'),
                        _ProfileRow('Status', user?.approvalStatus ?? '—',
                            valueColor: user?.isApproved == true
                                ? AppTheme.statusDelivered
                                : AppTheme.accent),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Vehicle Info
                    if (user != null)
                      _SectionCard(
                        title: 'Vehicle Info',
                        icon: Icons.local_shipping_outlined,
                        children: [
                          _ProfileRow('Vehicle Type', user.vehicleType),
                          _ProfileRow('License Plate', user.licensePlate),
                          _ProfileRow('Capacity',
                              '${user.capacity.toStringAsFixed(1)} tons'),
                        ],
                      ),

                    const SizedBox(height: 16),

                    // Stats
                    _SectionCard(
                      title: 'My Stats',
                      icon: Icons.bar_chart_rounded,
                      children: [
                        _ProfileRow('Total Deliveries',
                            '${delivery.deliveries.length}'),
                        _ProfileRow('Active',
                            '${delivery.activeDeliveries.length}'),
                        _ProfileRow('Completed',
                            '${delivery.completedDeliveries.length}'),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Logout button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppTheme.bgSurface,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              title: const Text('Sign Out',
                                  style: TextStyle(
                                      color: AppTheme.textPrimary)),
                              content: const Text(
                                  'Are you sure you want to sign out?',
                                  style: TextStyle(
                                      color: AppTheme.textSecondary)),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppTheme.statusCancelled),
                                  child: const Text('Sign Out'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            await context.read<AuthProvider>().logout();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.statusCancelled,
                          side: const BorderSide(
                              color: AppTheme.statusCancelled, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: const Text(
                          'Sign Out',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // App version
                    const Center(
                      child: Text(
                        'AgriGov Transporter v1.0.0',
                        style: TextStyle(
                            color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHero(String username) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.4),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Text(
                username.isNotEmpty
                    ? username[0].toUpperCase()
                    : 'T',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            username,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'TRANSPORTER',
              style: TextStyle(
                color: AppTheme.primaryLight,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.textMuted.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _ProfileRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
