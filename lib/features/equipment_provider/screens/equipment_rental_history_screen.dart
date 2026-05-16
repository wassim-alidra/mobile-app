import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/equipment_booking_model.dart';
import '../providers/equipment_provider_provider.dart';
import 'equipment_reservation_details_screen.dart';

class EquipmentRentalHistoryScreen extends StatelessWidget {
  const EquipmentRentalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ep = context.watch<EquipmentProviderProvider>();
    final history = ep.historyBookings;
    final stats = ep.stats;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RENTAL RECORDS', style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                  SizedBox(height: 2),
                  Text('Rental History', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                ],
              ),
            ),

            // Summary
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, Color(0xFF1DE9B6)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _SumItem(label: 'Completed', value: '${stats.completedBookings}'),
                    _Divider(),
                    _SumItem(label: 'Total Revenue', value: '${stats.totalRevenue.toStringAsFixed(0)} DA'),
                    _Divider(),
                    _SumItem(label: 'Total Bookings', value: '${stats.totalBookings}'),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ep.isLoading && ep.bookings.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : history.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history_rounded, color: AppTheme.textMutedLight, size: 60),
                              SizedBox(height: 16),
                              Text('No completed or rejected rentals', style: TextStyle(color: AppTheme.textMutedLight, fontSize: 15, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: AppTheme.primary,
                          onRefresh: () => ep.fetchBookings(),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: history.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final b = history[index];
                              return _HistoryCard(
                                booking: b,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EquipmentReservationDetailsScreen(booking: b),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SumItem extends StatelessWidget {
  final String label;
  final String value;
  const _SumItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: Colors.white.withOpacity(0.3));
  }
}

class _HistoryCard extends StatelessWidget {
  final EquipmentBookingModel booking;
  final VoidCallback onTap;

  const _HistoryCard({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = EquipmentBookingModel.statusColor(booking.status);
    String dateStr = '';
    try {
      final dt = DateTime.parse(booking.createdAt);
      dateStr = DateFormat('MMM d, yyyy').format(dt.toLocal());
    } catch (_) {}

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                booking.isCompleted ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: statusColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.equipmentName,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
                  Text('${booking.farmerName} • ${booking.rentalDays} days',
                      style: const TextStyle(color: AppTheme.textMutedLight, fontSize: 12)),
                  Text(dateStr, style: const TextStyle(color: AppTheme.textMutedLight, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (booking.totalPrice != null)
                  Text(
                    '${booking.totalPrice!.toStringAsFixed(0)} DA',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: booking.isCompleted ? AppTheme.primary : AppTheme.textMutedLight),
                  ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
