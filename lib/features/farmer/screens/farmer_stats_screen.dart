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
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Consumer<FarmerProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: provider.fetchChartStats,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                children: [
                  // Header
                  const Row(
                    children: [
                      Icon(Icons.query_stats_rounded,
                          color: AppTheme.primary, size: 28),
                      SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Business Intelligence',
                            style: TextStyle(
                              color: AppTheme.textDark,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'STRATEGIC ANALYTICS PORTAL',
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
                  const SizedBox(height: 32),

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
                    const SizedBox(height: 24),
                    _buildWeeklySales(provider.chartStats!.weeklySales),
                    const SizedBox(height: 24),
                    _buildTopRated(provider.chartStats!.topRated),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.insert_chart_outlined_rounded, color: AppTheme.textMutedLight, size: 56),
            SizedBox(height: 16),
            Text(
              'No Analytics Available',
              style: TextStyle(
                  color: AppTheme.textDark, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text(
              'Business data will populate after order fulfillment.',
              style: TextStyle(color: AppTheme.textMutedLight, fontSize: 12, fontWeight: FontWeight.w500),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title.toUpperCase(),
                        style: const TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5)),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppTheme.textMutedLight, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
      const Color(0xFF0F172A),
      const Color(0xFF1E293B),
      const Color(0xFF334155),
      const Color(0xFF475569),
    ];

    return _buildCard(
      title: 'Market Performance',
      subtitle: 'Inventory throughput by volume',
      icon: Icons.inventory_rounded,
      color: AppTheme.primary,
      child: Column(
        children: data.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          final pct = total > 0 ? e.value / total : 0.0;
          final color = colors[i % colors.length];

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.name,
                        style: const TextStyle(
                            color: AppTheme.textDark, fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('${e.value.toStringAsFixed(0)} KG',
                        style: TextStyle(
                            color: color,
                            fontSize: 13,
                            fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 10),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.bgLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: pct,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
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

  Widget _buildWeeklySales(List<ChartEntry> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    final maxVal = data.fold<double>(0, (m, e) => e.value > m ? e.value : m);

    return _buildCard(
      title: 'Weekly Velocity',
      subtitle: 'Official throughput metrics',
      icon: Icons.timeline_rounded,
      color: const Color(0xFF0F172A),
      child: Container(
        height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: data.map((e) {
            final ratio = maxVal > 0 ? e.value / maxVal : 0.0;
            final barH = 100.0 * ratio + 8;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (e.value > 0)
                      Text(
                        e.value.toStringAsFixed(0),
                        style: const TextStyle(
                            color: AppTheme.textDark, fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      height: barH,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e.name.substring(0, 3).toUpperCase(),
                      style: const TextStyle(
                          color: AppTheme.textMutedLight, fontSize: 9, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTopRated(List<RatingEntry> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    return _buildCard(
      title: 'Quality Assurance',
      subtitle: 'Stakeholder satisfaction index',
      icon: Icons.verified_rounded,
      color: const Color(0xFFF59E0B),
      child: Column(
        children: data.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    e.name,
                    style: const TextStyle(
                        color: AppTheme.textDark, fontSize: 14, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppTheme.bgLight,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: e.rating / 5.0,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFF59E0B), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      e.rating.toStringAsFixed(1),
                      style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 13,
                          fontWeight: FontWeight.w900),
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
