import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/farmer_provider.dart';
import '../../equipment_provider/models/equipment_model.dart';
import '../../equipment_provider/models/equipment_booking_model.dart';

class FarmerEquipmentScreen extends StatefulWidget {
  const FarmerEquipmentScreen({super.key});

  @override
  State<FarmerEquipmentScreen> createState() => _FarmerEquipmentScreenState();
}

class _FarmerEquipmentScreenState extends State<FarmerEquipmentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FarmerProvider>().fetchEquipmentAndBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Consumer<FarmerProvider>(
          builder: (context, provider, _) {
            if (provider.loadingEquipment && provider.equipment.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
            }

            return RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: provider.fetchEquipmentAndBookings,
              child: CustomScrollView(
                slivers: [
                  _buildHeader(),
                  if (provider.equipmentBookings.isNotEmpty)
                    _buildBookingsSection(provider.equipmentBookings),
                  _buildEquipmentSection(provider),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RESOURCES',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Equipment Rental',
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Access professional agricultural equipment.',
              style: TextStyle(
                color: AppTheme.textDark.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsSection(List<EquipmentBookingModel> bookings) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Requests',
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            ...bookings.map((b) => _BookingCard(booking: b)),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentSection(FarmerProvider provider) {
    if (provider.equipment.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Text(
              'No equipment available right now.',
              style: TextStyle(color: AppTheme.textMutedLight),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.55,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final eq = provider.equipment[index];
            return _EquipmentCard(
              equipment: eq,
              onBook: () => _handleBook(context, provider, eq),
            );
          },
          childCount: provider.equipment.length,
        ),
      ),
    );
  }

  void _handleBook(BuildContext context, FarmerProvider provider, EquipmentModel eq) async {
    int quantity = 1;
    int duration = 1;

    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Confirm Request', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Request ${eq.name}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                const Text('Quantity', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMutedLight)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    IconButton(
                      onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      onPressed: quantity < eq.quantityAvailable ? () => setState(() => quantity++) : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Duration (Days)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMutedLight)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    IconButton(
                      onPressed: duration > 1 ? () => setState(() => duration--) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$duration', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      onPressed: () => setState(() => duration++),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Estimated Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primary)),
                      Text('${(eq.pricePerDay * quantity * duration).toStringAsFixed(0)} DA', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primary)),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: const Text('Cancel', style: TextStyle(color: AppTheme.textMutedLight)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, {'quantity': quantity, 'duration': duration}),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                child: const Text('Confirm'),
              ),
            ],
          );
        }
      ),
    );

    if (result != null) {
      final success = await provider.bookEquipment(eq.id, result['quantity']!, result['duration']!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Equipment requested successfully!' : 'Failed to request equipment.'),
            backgroundColor: success ? AppTheme.primary : Colors.red,
          ),
        );
      }
    }
  }
}

class _EquipmentCard extends StatelessWidget {
  final EquipmentModel equipment;
  final VoidCallback onBook;

  const _EquipmentCard({required this.equipment, required this.onBook});

  @override
  Widget build(BuildContext context) {
    final isAvailable = equipment.isActuallyAvailable;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: equipment.images.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        equipment.images.first.image.startsWith('http')
                            ? equipment.images.first.image
                            : '$kBaseUrl${equipment.images.first.image}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(Icons.handyman_rounded, size: 48, color: AppTheme.primary.withOpacity(0.5)),
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(Icons.handyman_rounded, size: 48, color: AppTheme.primary.withOpacity(0.5)),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  equipment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  equipment.equipmentType,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMutedLight),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: AppTheme.textMutedLight),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        equipment.location?.isNotEmpty == true ? equipment.location! : "Nearby",
                        style: const TextStyle(fontSize: 10, color: AppTheme.textMutedLight),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.inventory, size: 12, color: AppTheme.textMutedLight),
                    const SizedBox(width: 4),
                    Text(
                      '${equipment.quantityAvailable} Available',
                      style: const TextStyle(fontSize: 10, color: AppTheme.textMutedLight),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.person, size: 12, color: AppTheme.textMutedLight),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        equipment.providerName ?? 'Provider',
                        style: const TextStyle(fontSize: 10, color: AppTheme.textMutedLight),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${equipment.pricePerDay} DA/day',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isAvailable ? onBook : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAvailable ? AppTheme.primary : AppTheme.borderLight,
                      foregroundColor: isAvailable ? Colors.white : AppTheme.textMutedLight,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text(isAvailable ? 'Request' : 'Unavailable', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final EquipmentBookingModel booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (booking.status) {
      case 'ACCEPTED': statusColor = const Color(0xFF10B981); break;
      case 'REJECTED': statusColor = Colors.red; break;
      case 'COMPLETED': statusColor = const Color(0xFF3B82F6); break;
      default: statusColor = const Color(0xFFF59E0B);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.handyman_rounded, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.equipmentName ?? 'Equipment',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  'Provider: ${booking.providerName ?? 'Unknown'}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMutedLight),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              booking.status,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
