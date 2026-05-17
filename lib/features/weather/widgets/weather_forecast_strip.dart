import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/weather_model.dart';

/// Horizontal scrollable 3-day forecast strip.
class WeatherForecastStrip extends StatelessWidget {
  final List<ForecastItem> forecast;

  const WeatherForecastStrip({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: forecast.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = forecast[index];
          return _ForecastCard(item: item);
        },
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  final ForecastItem item;
  const _ForecastCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.day,
            style: const TextStyle(
              color: AppTheme.textMutedLight,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          const Icon(Icons.wb_sunny_rounded, color: Color(0xFFF59E0B), size: 22),
          const SizedBox(height: 6),
          Text(
            item.temp,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
