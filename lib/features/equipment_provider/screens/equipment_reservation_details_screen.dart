import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/equipment_booking_model.dart';

class EquipmentReservationDetailsScreen extends StatelessWidget {
  final EquipmentBookingModel booking;

  const EquipmentReservationDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final statusColor = EquipmentBookingModel.statusColor(booking.status);

    String formatDate(String? raw) {
      if (raw == null || raw.isEmpty) return '—';
      try {
        final dt = DateTime.parse(raw);
        return DateFormat('MMM d, yyyy • HH:mm').format(dt.toLocal());
      } catch (_) {
        return raw;
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.textDark, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text('Reservation Details',
                        style: TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      booking.status,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Request ID Badge
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, Color(0xFF1DE9B6)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.agriculture_rounded, color: Colors.white, size: 32),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(booking.equipmentName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17)),
                            Text('Request #${booking.id}',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _InfoCard(
                    title: 'Farmer Details',
                    icon: Icons.person_outline_rounded,
                    rows: [
                      _Row('Farmer Name', booking.farmerName),
                      _Row('Booking ID', '#${booking.id}'),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _InfoCard(
                    title: 'Rental Information',
                    icon: Icons.info_outline_rounded,
                    rows: [
                      _Row('Units Requested', '${booking.requestedQuantity}'),
                      _Row('Rental Duration', '${booking.rentalDays} day(s)'),
                      if (booking.startDate != null)
                        _Row('Start Date', booking.startDate!),
                      if (booking.endDate != null)
                        _Row('End Date', booking.endDate!),
                      if (booking.expectedReturnDate != null)
                        _Row('Expected Return', formatDate(booking.expectedReturnDate)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _InfoCard(
                    title: 'Financial Summary',
                    icon: Icons.account_balance_wallet_outlined,
                    rows: [
                      if (booking.totalPrice != null)
                        _Row('Total Amount',
                            '${booking.totalPrice!.toStringAsFixed(0)} DA',
                            highlight: true),
                      _Row('Requested On', formatDate(booking.createdAt)),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_Row> rows;

  const _InfoCard({required this.title, required this.icon, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 20),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.label,
                        style: const TextStyle(
                            color: AppTheme.textMutedLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                    Text(r.value,
                        style: TextStyle(
                            color: r.highlight ? AppTheme.primary : AppTheme.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _Row {
  final String label;
  final String value;
  final bool highlight;
  const _Row(this.label, this.value, {this.highlight = false});
}
