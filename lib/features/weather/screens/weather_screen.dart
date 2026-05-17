import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';
import '../widgets/weather_metric_tile.dart';
import '../widgets/weather_forecast_strip.dart';
import '../widgets/irrigation_status_card.dart';

import '../../notifications/providers/notification_provider.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<WeatherProvider>();
      if (!p.hasData && !p.loadingWeather && !p.loadingFarms) {
        _fetchInitialData(p);
      }
    });
  }

  Future<void> _fetchInitialData(WeatherProvider provider) async {
    final notifProvider = context.read<NotificationProvider>();
    await provider.fetchFarms();
    if (mounted) {
      // Fetch notifications to sync any newly generated backend weather notifications
      notifProvider.fetchNotifications(silent: true);
    }
  }

  Future<void> _refreshAll(WeatherProvider provider) async {
    final notifProvider = context.read<NotificationProvider>();
    await provider.refresh();
    if (mounted) {
      await notifProvider.fetchNotifications(silent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Consumer<WeatherProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: () => _refreshAll(provider),
              child: CustomScrollView(
                slivers: [
                  // ── Header ──────────────────────────────────────
                  SliverToBoxAdapter(child: _buildHeader(provider)),

                  // ── Farm Selector ────────────────────────────────
                  if (provider.farms.isNotEmpty)
                    SliverToBoxAdapter(child: _buildFarmSelector(provider)),

                  // ── Error Banner ─────────────────────────────────
                  if (provider.error != null)
                    SliverToBoxAdapter(child: _buildError(provider)),

                  // ── Loading ──────────────────────────────────────
                  if (provider.loadingFarms || provider.loadingWeather)
                    const SliverFillRemaining(child: _LoadingState()),

                  // ── Empty / No farms ─────────────────────────────
                  if (!provider.loadingFarms &&
                      !provider.loadingWeather &&
                      provider.farms.isEmpty &&
                      provider.error == null)
                    const SliverFillRemaining(child: _EmptyState()),

                  // ── Content ──────────────────────────────────────
                  if (!provider.loadingFarms &&
                      !provider.loadingWeather &&
                      provider.hasData)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildCurrentWeatherCard(provider.weatherData!),
                          const SizedBox(height: 20),
                          _buildMetricsGrid(provider.weatherData!),
                          const SizedBox(height: 20),
                          _buildSoilSection(provider.weatherData!.soil),
                          const SizedBox(height: 20),
                          IrrigationStatusCard(
                            recommendation:
                                provider.weatherData!.soil.irrigationRecommendation,
                            irrigationNeeded:
                                provider.weatherData!.soil.isNeeded,
                            pumpOn: provider.deviceStatus?.pumpOn,
                            loadingDevice: provider.loadingDevice,
                          ),
                          const SizedBox(height: 20),
                          _buildForecastSection(provider.weatherData!.forecast),
                          const SizedBox(height: 32),
                          _buildLastUpdated(provider.weatherData!.lastUpdated),
                          const SizedBox(height: 24),
                        ]),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────

  Widget _buildHeader(WeatherProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WEATHER & IRRIGATION',
                  style: TextStyle(
                    color: AppTheme.textMutedLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  provider.selectedFarm?.name ?? 'Weather Dashboard',
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (provider.selectedFarm != null)
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 13, color: AppTheme.textMutedLight),
                      const SizedBox(width: 3),
                      Text(
                        provider.selectedFarm!.wilaya,
                        style: const TextStyle(
                          color: AppTheme.textMutedLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Refresh button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  color: AppTheme.primary, size: 20),
              onPressed: () => _refreshAll(provider),
            ),
          ),
        ],
      ),
    );
  }

  // ── Farm Selector ───────────────────────────────────────────────────

  Widget _buildFarmSelector(WeatherProvider provider) {
    if (provider.farms.length <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: provider.farms.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final farm = provider.farms[index];
            final isSelected = provider.selectedFarm?.id == farm.id;
            return GestureDetector(
              onTap: () async {
                final notifProvider = context.read<NotificationProvider>();
                await provider.selectFarm(farm);
                if (!mounted) return;
                notifProvider.fetchNotifications(silent: true);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isSelected ? AppTheme.primary : AppTheme.borderLight,
                  ),
                ),
                child: Text(
                  farm.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textMutedLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Current Weather Card ────────────────────────────────────────────

  Widget _buildCurrentWeatherCard(WeatherDashboardModel data) {
    return Container(
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
            color: AppTheme.primary.withOpacity(0.25),
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
                const Text(
                  'CURRENT CONDITIONS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${data.weather.temp.toStringAsFixed(1)}°C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.weather.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_rounded, color: Colors.white70, size: 60),
            ],
          ),
        ],
      ),
    );
  }

  // ── Metrics 2×2 Grid ───────────────────────────────────────────────

  Widget _buildMetricsGrid(WeatherDashboardModel data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: [
        WeatherMetricTile(
          icon: Icons.thermostat_rounded,
          iconColor: const Color(0xFFF97316),
          label: 'Temperature',
          value: '${data.weather.temp.toStringAsFixed(1)}°C',
        ),
        WeatherMetricTile(
          icon: Icons.water_drop_outlined,
          iconColor: const Color(0xFF3B82F6),
          label: 'Humidity',
          value: '${data.weather.humidity}%',
        ),
        WeatherMetricTile(
          icon: Icons.grass_rounded,
          iconColor: const Color(0xFF059669),
          label: 'Soil Moisture',
          value: data.soil.moisturePercent,
        ),
        WeatherMetricTile(
          icon: Icons.device_thermostat_rounded,
          iconColor: const Color(0xFF8B5CF6),
          label: 'Surface Temp',
          value: '${data.soil.surfaceTemp.toStringAsFixed(1)}°C',
        ),
      ],
    );
  }

  // ── Soil Section ───────────────────────────────────────────────────

  Widget _buildSoilSection(SoilData soil) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Soil Analysis',
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: Column(
            children: [
              _SoilRow(
                label: 'Soil Moisture',
                value: soil.moisturePercent,
                progress: soil.moisture.clamp(0.0, 1.0),
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(height: 14),
              _SoilRow(
                label: 'Saturation Level',
                value: _moistureLabel(soil.moisture),
                progress: soil.moisture.clamp(0.0, 1.0),
                color: soil.moisture < 0.4
                    ? const Color(0xFFF97316)
                    : AppTheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _moistureLabel(double moisture) {
    if (moisture < 0.3) return 'Dry';
    if (moisture < 0.5) return 'Low';
    if (moisture < 0.7) return 'Optimal';
    return 'Saturated';
  }

  // ── Forecast Section ───────────────────────────────────────────────

  Widget _buildForecastSection(List<ForecastItem> forecast) {
    if (forecast.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3-Day Forecast',
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        WeatherForecastStrip(forecast: forecast),
      ],
    );
  }

  // ── Error Banner ───────────────────────────────────────────────────

  Widget _buildError(WeatherProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              provider.error!,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppTheme.primary, size: 20),
            onPressed: () => provider.fetchFarms(),
          ),
        ],
      ),
    );
  }

  // ── Last Updated ───────────────────────────────────────────────────

  Widget _buildLastUpdated(String lastUpdated) {
    return Center(
      child: Text(
        'Last updated: $lastUpdated',
        style: const TextStyle(
          color: AppTheme.textMutedLight,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── Soil Progress Row ──────────────────────────────────────────────────

class _SoilRow extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final Color color;

  const _SoilRow({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMutedLight,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppTheme.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ── Loading State ──────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppTheme.primary),
          SizedBox(height: 16),
          Text(
            'Fetching weather data...',
            style: TextStyle(
              color: AppTheme.textMutedLight,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  color: AppTheme.primary, size: 48),
            ),
            const SizedBox(height: 20),
            const Text(
              'No farms registered',
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Register and get your farm approved to view\nweather and irrigation data.',
              textAlign: TextAlign.center,
              style: TextStyle(
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
