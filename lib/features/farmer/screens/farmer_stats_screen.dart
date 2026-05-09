import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/farmer_provider.dart';
import '../models/farmer_order_model.dart';

class FarmerStatsScreen extends StatefulWidget {
  const FarmerStatsScreen({super.key});

  @override
  State<FarmerStatsScreen> createState() => _FarmerStatsScreenState();
}

class _FarmerStatsScreenState extends State<FarmerStatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FarmerProvider>().fetchChartStats();
    });
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
                onRefresh: provider.fetchChartStats,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  children: [
                    // Header
                    const Row(
                      children: [
                        Icon(Icons.bar_chart_rounded,
                            color: AppTheme.primary, size: 26),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Business Insights',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Sales performance & ratings',
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    if (provider.loadingChart)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(60),
                          child: CircularProgressIndicator(
                              color: AppTheme.primary),
                        ),
                      )
                    else if (provider.chartStats == null)
                      _buildEmpty()
                    else ...[
                      _buildTopSelling(provider.chartStats!.topSelling),
                      const SizedBox(height: 20),
                      _buildWeeklySales(provider.chartStats!.weeklySales),
                      const SizedBox(height: 20),
                      _buildTopRated(provider.chartStats!.topRated),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.bar_chart_rounded, color: AppTheme.textMuted, size: 56),
            SizedBox(height: 12),
            Text(
              'No statistics yet',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 15),
            ),
            SizedBox(height: 6),
            Text(
              'Stats will appear after you have completed orders',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required String subtitle,
      required IconData icon, required Color color, required Widget child}) {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTopSelling(List<ChartEntry> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    final total = data.fold<double>(0, (s, e) => s + e.value);
    final colors = [
      AppTheme.primary,
      AppTheme.secondary,
      AppTheme.accent,
      AppTheme.statusAssigned,
      AppTheme.statusOnWay,
    ];

    return _buildCard(
      title: 'Top Selling Products',
      subtitle: 'Total quantity sold per product',
      icon: Icons.shopping_bag_rounded,
      color: AppTheme.primary,
      child: Column(
        children: data.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          final pct = total > 0 ? e.value / total : 0.0;
          final color = colors[i % colors.length];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.name,
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 13)),
                    Text('${e.value.toStringAsFixed(0)} kg',
                        style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppTheme.bgSurface,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeeklySales(List<ChartEntry> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    final maxVal = data.fold<double>(0, (m, e) => e.value > m ? e.value : m);

    return _buildCard(
      title: 'Weekly Sales Volume',
      subtitle: 'Quantity sold this week',
      icon: Icons.trending_up_rounded,
      color: AppTheme.secondary,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((e) {
          final ratio = maxVal > 0 ? e.value / maxVal : 0.0;
          final barH = 80.0 * ratio + 6;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (e.value > 0)
                    Text(
                      e.value.toStringAsFixed(0),
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 9),
                    ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    height: barH,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    e.name,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 10),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopRated(List<RatingEntry> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    return _buildCard(
      title: 'Product Ratings',
      subtitle: 'Average customer feedback',
      icon: Icons.star_rounded,
      color: AppTheme.accent,
      child: Column(
        children: data.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    e.name,
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: e.rating / 5.0,
                      backgroundColor: AppTheme.bgSurface,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.accent),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppTheme.accent, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      e.rating.toStringAsFixed(1),
                      style: const TextStyle(
                          color: AppTheme.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
