import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/delivery_provider.dart';

class RouteMapBottomSheet extends StatefulWidget {
  final dynamic order;

  const RouteMapBottomSheet({super.key, required this.order});

  @override
  State<RouteMapBottomSheet> createState() => _RouteMapBottomSheetState();
}

class _RouteMapBottomSheetState extends State<RouteMapBottomSheet> {
  Map<String, dynamic>? _routeData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    final farmerWilaya = widget.order['farmer_wilaya'] ?? '';
    final buyerWilaya = widget.order['buyer_wilaya'] ?? '';

    if (farmerWilaya.isEmpty || buyerWilaya.isEmpty) {
      setState(() {
        _error = 'Missing wilaya data';
        _isLoading = false;
      });
      return;
    }

    final provider = context.read<DeliveryProvider>();
    final data = await provider.getRouteData(farmerWilaya, buyerWilaya);

    if (mounted) {
      setState(() {
        if (data != null) {
          _routeData = data;
          _error = null;
        } else {
          _error = 'Failed to calculate route';
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final totalValue = double.tryParse(order['total_price']?.toString() ?? '0') ?? 0.0;
    final estimatedFee = (totalValue * 0.1).clamp(5.0, double.infinity);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textMuted.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order['id']} — Route Details',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Review the delivery route before accepting',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Info Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.textMuted.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(label: 'Product', value: order['product_name'] ?? '—'),
                          const Divider(height: 24, color: Color(0xFF2A3545)),
                          _InfoRow(
                            label: 'Quantity',
                            value: '${order['quantity']} kg',
                            valueColor: Colors.amber,
                          ),
                          const Divider(height: 24, color: Color(0xFF2A3545)),
                          _InfoRow(
                            label: 'Total Value',
                            value: '${totalValue.toStringAsFixed(0)} DA',
                            valueColor: Colors.orange,
                          ),
                          const Divider(height: 24, color: Color(0xFF2A3545)),
                          _InfoRow(
                            label: 'Est. Fee (10%)',
                            value: '${estimatedFee.toStringAsFixed(0)} DA',
                            valueColor: AppTheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Route Stats
                  if (_routeData != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _StatChip(
                            icon: Icons.straighten_rounded,
                            label: '${_routeData!['distance_km']} km',
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            icon: Icons.timer_outlined,
                            label: '${_routeData!['duration_mins']} min',
                          ),
                        ],
                      ),
                    ),
                  
                  if (_routeData != null) const SizedBox(height: 12),

                  // Wilaya Badges
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _WilayaBadge(
                          label: order['farmer_wilaya'] ?? 'Unknown',
                          color: Colors.green,
                          icon: Icons.agriculture_rounded,
                        ),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Divider(color: AppTheme.textMuted),
                          ),
                        ),
                        _WilayaBadge(
                          label: order['buyer_wilaya'] ?? 'Unknown',
                          color: Colors.blue,
                          icon: Icons.shopping_cart_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Map
                  Container(
                    height: 300,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.textMuted.withOpacity(0.1)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                        else if (_error != null)
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 40),
                                const SizedBox(height: 8),
                                Text(_error!, style: const TextStyle(color: AppTheme.textSecondary)),
                                TextButton(onPressed: _fetchRoute, child: const Text('Retry')),
                              ],
                            ),
                          )
                        else if (_routeData != null)
                          FlutterMap(
                            options: MapOptions(
                              initialCenter: latlong.LatLng(
                                _routeData!['farmer_coords']['lat'],
                                _routeData!['farmer_coords']['lng'],
                              ),
                              initialZoom: 6,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.agrigov.transporter',
                              ),
                              if (_routeData!['geometry'] != null)
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: (_routeData!['geometry'] as List)
                                          .map((c) => latlong.LatLng(c[1], c[0]))
                                          .toList(),
                                      color: AppTheme.primary,
                                      strokeWidth: 4,
                                    ),
                                  ],
                                ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: latlong.LatLng(
                                      _routeData!['farmer_coords']['lat'],
                                      _routeData!['farmer_coords']['lng'],
                                    ),
                                    width: 80,
                                    height: 80,
                                    child: const _MapMarker(color: Colors.green, icon: Icons.agriculture),
                                  ),
                                  Marker(
                                    point: latlong.LatLng(
                                      _routeData!['buyer_coords']['lat'],
                                      _routeData!['buyer_coords']['lng'],
                                    ),
                                    width: 80,
                                    height: 80,
                                    child: const _MapMarker(color: Colors.blue, icon: Icons.shopping_cart),
                                  ),
                                ],
                              ),
                            ],

                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              border: Border.all(color: AppTheme.textMuted.withOpacity(0.1)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppTheme.textMuted.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),

                      child: const Text('Close', style: TextStyle(color: AppTheme.textPrimary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Consumer<DeliveryProvider>(
                      builder: (context, provider, _) {
                        return ElevatedButton(
                          onPressed: provider.isAccepting
                              ? null
                              : () async {
                                  final success = await provider.acceptRequest(order['id']);
                                  if (success && mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Mission accepted!')),
                                    );
                                  } else if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(provider.errorMessage ?? 'Error')),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: provider.isAccepting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Accept Mission', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.textMuted.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _WilayaBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _WilayaBadge({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _MapMarker({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)],
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        CustomPaint(
          size: const Size(10, 5),
          painter: _TrianglePainter(color: Colors.white),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
