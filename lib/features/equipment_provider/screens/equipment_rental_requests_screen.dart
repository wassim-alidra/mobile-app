import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/equipment_booking_model.dart';
import '../providers/equipment_provider_provider.dart';
import 'equipment_reservation_details_screen.dart';

class EquipmentRentalRequestsScreen extends StatelessWidget {
  const EquipmentRentalRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ep = context.watch<EquipmentProviderProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BOOKING LOGISTICS', style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                        SizedBox(height: 2),
                        Text('Rental Requests', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                      ],
                    ),
                  ),
                  if (ep.pendingBookings.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${ep.pendingBookings.length} Pending',
                        style: const TextStyle(color: Color(0xFFD97706), fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ),
                ],
              ),
            ),
            // List
            Expanded(
              child: ep.isLoading && ep.bookings.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : ep.bookings.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pending_actions_rounded, color: AppTheme.textMutedLight, size: 60),
                              SizedBox(height: 16),
                              Text('No rental requests yet', style: TextStyle(color: AppTheme.textMutedLight, fontSize: 15, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: AppTheme.primary,
                          onRefresh: () => ep.fetchBookings(),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            itemCount: ep.bookings.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final b = ep.bookings[index];
                              return _BookingCard(
                                booking: b,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EquipmentReservationDetailsScreen(booking: b),
                                  ),
                                ),
                                onAccept: b.isPending
                                    ? () => _updateStatus(context, ep, b.id, 'ACCEPTED')
                                    : null,
                                onReject: b.isPending
                                    ? () => _updateStatus(context, ep, b.id, 'REJECTED')
                                    : null,
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

  Future<void> _updateStatus(BuildContext context, EquipmentProviderProvider ep, int id, String status) async {
    final ok = await ep.updateBookingStatus(id, status);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            ok
                ? status == 'ACCEPTED'
                    ? 'Booking accepted!'
                    : 'Booking rejected'
                : ep.errorMessage ?? 'Failed',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: ok
            ? (status == 'ACCEPTED' ? AppTheme.primary : Colors.orange)
            : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }
}

class _BookingCard extends StatelessWidget {
  final EquipmentBookingModel booking;
  final VoidCallback onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const _BookingCard({
    required this.booking,
    required this.onTap,
    this.onAccept,
    this.onReject,
  });

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.agriculture_rounded, color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.equipmentName,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textDark)),
                      Text('Farmer: ${booking.farmerName}',
                          style: const TextStyle(color: AppTheme.textMutedLight, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoPill(icon: Icons.numbers_rounded, label: '${booking.requestedQuantity} unit(s)'),
                const SizedBox(width: 8),
                _InfoPill(icon: Icons.calendar_today_rounded, label: '${booking.rentalDays} days'),
                const Spacer(),
                Text(
                  dateStr,
                  style: const TextStyle(color: AppTheme.textMutedLight, fontSize: 11),
                ),
              ],
            ),
            if (booking.totalPrice != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, size: 14, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Total: ${booking.totalPrice!.toStringAsFixed(0)} DA',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.primary),
                  ),
                ],
              ),
            ],
            if (onAccept != null && onReject != null) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.bgLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.textMutedLight),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMutedLight, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
