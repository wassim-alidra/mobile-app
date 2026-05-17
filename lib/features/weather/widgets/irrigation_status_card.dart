import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Banner card that shows the irrigation recommendation and pump status.
class IrrigationStatusCard extends StatelessWidget {
  final String recommendation;
  final bool irrigationNeeded;
  final bool? pumpOn;
  final bool loadingDevice;

  const IrrigationStatusCard({
    super.key,
    required this.recommendation,
    required this.irrigationNeeded,
    this.pumpOn,
    this.loadingDevice = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = irrigationNeeded
        ? const Color(0xFFFFF7ED) // warm orange tint
        : const Color(0xFFF0FDF4); // green tint
    final borderColor = irrigationNeeded
        ? const Color(0xFFFDBA74)
        : const Color(0xFF86EFAC);
    final iconColor = irrigationNeeded ? const Color(0xFFF97316) : AppTheme.primary;
    final icon =
        irrigationNeeded ? Icons.water_drop_rounded : Icons.check_circle_rounded;
    final statusLabel = irrigationNeeded ? 'ACTION REQUIRED' : 'OPTIMAL';

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Accent bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: iconColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'IRRIGATION: $statusLabel',
                          style: TextStyle(
                            color: iconColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recommendation,
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (pumpOn != null || loadingDevice) ...[
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.power_rounded,
                              size: 14, color: AppTheme.textMutedLight),
                          const SizedBox(width: 6),
                          const Text(
                            'PUMP STATUS:',
                            style: TextStyle(
                              color: AppTheme.textMutedLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (loadingDevice)
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: AppTheme.textMutedLight),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (pumpOn ?? false)
                                    ? AppTheme.primary.withOpacity(0.15)
                                    : AppTheme.textMutedLight.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                (pumpOn ?? false) ? 'ON' : 'OFF',
                                style: TextStyle(
                                  color: (pumpOn ?? false)
                                      ? AppTheme.primary
                                      : AppTheme.textMutedLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
