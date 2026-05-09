import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/delivery_provider.dart';
import '../models/delivery_model.dart';
import '../widgets/route_map_bottom_sheet.dart';

class DeliveryDetailScreen extends StatefulWidget {
  final int deliveryId;

  const DeliveryDetailScreen({super.key, required this.deliveryId});

  @override
  State<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends State<DeliveryDetailScreen> {
  DeliveryModel? _delivery;
  bool _loading = true;
  bool _updating = false;

  // Ordered pipeline of statuses
  static const List<String> _pipeline = [
    'ASSIGNED', 'ON_WAY', 'CHARGING', 'DELIVERED'
  ];

  @override
  void initState() {
    super.initState();
    _loadDelivery();
  }

  Future<void> _loadDelivery() async {
    setState(() => _loading = true);
    final provider = context.read<DeliveryProvider>();
    final d = await provider.fetchDelivery(widget.deliveryId);
    if (mounted) setState(() { _delivery = d; _loading = false; });
  }

  String? _getNextStatus(String current) {
    final idx = _pipeline.indexOf(current);
    if (idx == -1 || idx >= _pipeline.length - 1) return null;
    return _pipeline[idx + 1];
  }

  Future<void> _advanceStatus() async {
    if (_delivery == null) return;
    final next = _getNextStatus(_delivery!.status);
    if (next == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Update',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Change status to:\n"${AppTheme.getStatusLabel(next)}"?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _updating = true);
    final ok = await context
        .read<DeliveryProvider>()
        .updateStatus(widget.deliveryId, next);
    if (mounted) {
      setState(() => _updating = false);
      if (ok) {
        await _loadDelivery();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Status updated to ${AppTheme.getStatusLabel(next)}'),
          backgroundColor: AppTheme.bgSurface,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Update failed. Try again.'),
          backgroundColor: AppTheme.statusCancelled,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primary))
                    : _delivery == null
                        ? const Center(
                            child: Text('Delivery not found',
                                style: TextStyle(
                                    color: AppTheme.textSecondary)))
                        : _buildContent(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _delivery != null && !_loading
          ? _buildActionBar()
          : null,
    );
  }

  Widget _buildAppBar() {
    return Padding(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delivery Detail',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (_delivery != null)
                Text(
                  'Order #${_delivery!.order.id}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final d = _delivery!;
    return RefreshIndicator(
      color: AppTheme.primary,
      backgroundColor: AppTheme.bgCard,
      onRefresh: _loadDelivery,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildStatusBanner(d),
          const SizedBox(height: 20),
          _buildProgressStepper(d),
          const SizedBox(height: 20),
          _buildOrderInfoCard(d),
          const SizedBox(height: 16),
          _buildProductCard(d),
          const SizedBox(height: 16),
          _buildPartiesCard(d),
          const SizedBox(height: 16),
          _buildMapCard(d),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMapCard(DeliveryModel d) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.map_outlined, color: AppTheme.primary, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Delivery Route',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    Text('View pickup and destination locations',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => RouteMapBottomSheet(order: {
                    'id': d.order.id,
                    'product_name': d.order.product?.name,
                    'quantity': d.order.quantity,
                    'total_price': d.order.totalPrice,
                    'farmer_name': d.order.product?.farmerUsername,
                    'buyer_name': d.order.buyer?.username,
                    'farmer_wilaya': d.order.product?.farmerWilaya,
                    'buyer_wilaya': d.order.buyer?.wilaya,
                  }),
                );
              },
              icon: const Icon(Icons.navigation_outlined, size: 18),
              label: const Text('Open Route Map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary.withOpacity(0.15),
                foregroundColor: AppTheme.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStatusBanner(DeliveryModel d) {
    final color = AppTheme.getStatusColor(d.status);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(AppTheme.getStatusIcon(d.status),
                color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTheme.getStatusLabel(d.status),
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Delivery #${d.id}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            '${d.deliveryFee.toStringAsFixed(0)} DA',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStepper(DeliveryModel d) {
    final currentIdx = _pipeline.indexOf(d.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.textMuted.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Progress',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(_pipeline.length, (i) {
            final status = _pipeline[i];
            final isDone = i <= currentIdx;
            final isCurrent = i == currentIdx;
            final color = isDone
                ? AppTheme.getStatusColor(status)
                : AppTheme.textMuted;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDone
                            ? color.withOpacity(0.2)
                            : AppTheme.bgSurface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDone ? color : AppTheme.textMuted,
                          width: isCurrent ? 2.5 : 1.5,
                        ),
                      ),
                      child: Icon(
                        isDone
                            ? (i < currentIdx
                                ? Icons.check_rounded
                                : AppTheme.getStatusIcon(status))
                            : AppTheme.getStatusIcon(status),
                        color: isDone ? color : AppTheme.textMuted,
                        size: 16,
                      ),
                    ),
                    if (i < _pipeline.length - 1)
                      Container(
                        width: 2,
                        height: 28,
                        color: i < currentIdx
                            ? AppTheme.primary.withOpacity(0.5)
                            : AppTheme.textMuted.withOpacity(0.2),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    AppTheme.getStatusLabel(status),
                    style: TextStyle(
                      color: isDone ? AppTheme.textPrimary : AppTheme.textMuted,
                      fontSize: 13,
                      fontWeight:
                          isCurrent ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(DeliveryModel d) {
    return _InfoCard(
      title: 'Order Information',
      icon: Icons.receipt_long_rounded,
      children: [
        _InfoRow('Order ID', '#${d.order.id}'),
        _InfoRow('Quantity', '${d.order.quantity.toStringAsFixed(2)} kg'),
        _InfoRow('Total Price',
            '${d.order.totalPrice.toStringAsFixed(2)} DA'),
        _InfoRow('Delivery Fee',
            '${d.deliveryFee.toStringAsFixed(2)} DA'),
      ],
    );
  }

  Widget _buildProductCard(DeliveryModel d) {
    final p = d.order.product;
    if (p == null) return const SizedBox.shrink();

    return _InfoCard(
      title: 'Product',
      icon: Icons.inventory_2_rounded,
      children: [
        _InfoRow('Name', p.name),
        _InfoRow('Price/kg', '${p.pricePerKg.toStringAsFixed(2)} DA'),
        if (p.farmerUsername != null)
          _InfoRow('Farmer', p.farmerUsername!),
        if (p.farmerWilaya != null) _InfoRow('Wilaya', p.farmerWilaya!),
      ],
    );
  }

  Widget _buildPartiesCard(DeliveryModel d) {
    final buyer = d.order.buyer;
    return _InfoCard(
      title: 'Buyer',
      icon: Icons.person_outline_rounded,
      children: [
        _InfoRow('Username', buyer?.username ?? '—'),
        if (buyer?.wilaya != null) _InfoRow('Wilaya', buyer!.wilaya!),
      ],
    );
  }

  Widget _buildActionBar() {
    final d = _delivery!;
    final next = _getNextStatus(d.status);
    if (next == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        color: AppTheme.bgCard,
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppTheme.statusDelivered, size: 22),
              const SizedBox(width: 10),
              const Text(
                'Delivery Completed!',
                style: TextStyle(
                  color: AppTheme.statusDelivered,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(
          top: BorderSide(color: AppTheme.textMuted.withOpacity(0.15)),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: _updating
              ? Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _advanceStatus,
                      borderRadius: BorderRadius.circular(14),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(AppTheme.getStatusIcon(next),
                                color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Mark as ${AppTheme.getStatusLabel(next)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard(
      {required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: AppTheme.textMuted.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
