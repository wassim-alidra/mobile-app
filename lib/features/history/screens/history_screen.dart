import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../deliveries/providers/delivery_provider.dart';
import '../../deliveries/models/delivery_model.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryProvider>().fetchDeliveries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeliveryProvider>();
    final completed = provider.completedDeliveries;

    // Compute totals
    final totalFee = completed.fold<double>(
        0.0, (sum, d) => sum + d.deliveryFee);
    final totalKg = completed.fold<double>(
        0.0, (sum, d) => sum + d.order.quantity);

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
                      'Delivery History',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Summary cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        label: 'Completed',
                        value: '${completed.length}',
                        icon: Icons.check_circle_rounded,
                        color: AppTheme.statusDelivered,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        label: 'Earnings',
                        value: '${totalFee.toStringAsFixed(0)} DA',
                        icon: Icons.payments_rounded,
                        color: AppTheme.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        label: 'Total kg',
                        value: '${totalKg.toStringAsFixed(0)}',
                        icon: Icons.scale_rounded,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // List
              Expanded(
                child: provider.state == DeliveryLoadState.loading &&
                        provider.deliveries.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primary))
                    : completed.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history_rounded,
                                    color: AppTheme.textMuted, size: 56),
                                SizedBox(height: 16),
                                Text(
                                  'No completed deliveries yet',
                                  style: TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: AppTheme.primary,
                            backgroundColor: AppTheme.bgCard,
                            onRefresh: () =>
                                provider.fetchDeliveries(),
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              itemCount: completed.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _HistoryTile(
                                    delivery: completed[index]);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final DeliveryModel delivery;

  const _HistoryTile({required this.delivery});

  @override
  Widget build(BuildContext context) {
    final product = delivery.order.product;
    String dateStr = '';
    if (delivery.deliveryDate != null) {
      try {
        final dt = DateTime.parse(delivery.deliveryDate!);
        dateStr = DateFormat('MMM d, yyyy').format(dt.toLocal());
      } catch (_) {}
    }

    return GestureDetector(
      onTap: () => context.push('/delivery/${delivery.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppTheme.statusDelivered.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.statusDelivered.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppTheme.statusDelivered, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product?.name ?? 'Order #${delivery.order.id}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dateStr.isNotEmpty ? dateStr : 'Delivered',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${delivery.deliveryFee.toStringAsFixed(0)} DA',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${delivery.order.quantity.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
