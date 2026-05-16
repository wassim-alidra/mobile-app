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
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order['id']} — Route Details',
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Review the delivery route before accepting',
                        style: TextStyle(
                          color: AppTheme.textDark.withOpacity(0.5),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.bgLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, color: AppTheme.textDark, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Details Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          _InfoRow(label: 'Product', value: order['product_name'] ?? '—'),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1, color: AppTheme.borderLight),
                          ),
                          _InfoRow(
                            label: 'Quantity',
                            value: '${order['quantity']} kg',
                            valueColor: const Color(0xFFF59E0B),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1, color: AppTheme.borderLight),
                          ),
                          _InfoRow(
                            label: 'Total Value',
                            value: '${totalValue.toStringAsFixed(0)} DA',
                            valueColor: const Color(0xFF10B981),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1, color: AppTheme.borderLight),
                          ),
                          _InfoRow(
                            label: 'Estimated Fee',
                            value: '${estimatedFee.toStringAsFixed(0)} DA',
                            valueColor: AppTheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Route Row & Chips
                  if (_routeData != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Wilaya Badges Row
                          Row(
                            children: [
                              _WilayaBadge(
                                label: order['farmer_wilaya'] ?? 'Unknown',
                                color: const Color(0xFF065F46),
                                icon: Icons.agriculture_rounded,
                              ),
                              const Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Icon(Icons.arrow_forward_rounded, color: AppTheme.borderLight, size: 20),
                                ),
                              ),
                              _WilayaBadge(
                                label: order['buyer_wilaya'] ?? 'Unknown',
                                color: Colors.blue,
                                icon: Icons.location_on_rounded,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Stats Chips
                          Row(
                            children: [
                              _StatChip(
                                icon: Icons.straighten_rounded,
                                label: '${_routeData!['distance_km']} km',
                              ),
                              const SizedBox(width: 12),
                              _StatChip(
                                icon: Icons.timer_outlined,
                                label: '${_routeData!['duration_mins']} min',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 24),

                  // Map Preview
                  Container(
                    height: 280,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppTheme.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
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
                                Text(_error!, style: const TextStyle(color: AppTheme.textMutedLight)),
                                TextButton(onPressed: _fetchRoute, child: const Text('Retry')),
                              ],
                            ),
                          )
                        else if (_routeData != null)
                          FlutterMap(
                            options: MapOptions(
                              initialCameraFit: CameraFit.bounds(
                                bounds: LatLngBounds.fromPoints([
                                  latlong.LatLng(
                                    _routeData!['farmer_coords']['lat'],
                                    _routeData!['farmer_coords']['lng'],
                                  ),
                                  latlong.LatLng(
                                    _routeData!['buyer_coords']['lat'],
                                    _routeData!['buyer_coords']['lng'],
                                  ),
                                ]),
                                padding: const EdgeInsets.all(50),
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                                subdomains: const ['a', 'b', 'c', 'd'],
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
                                      strokeWidth: 5,
                                      isDotted: false,
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
                                    width: 40,
                                    height: 40,
                                    child: const _MapMarker(color: Color(0xFF065F46), icon: Icons.agriculture),
                                  ),
                                  Marker(
                                    point: latlong.LatLng(
                                      _routeData!['buyer_coords']['lat'],
                                      _routeData!['buyer_coords']['lng'],
                                    ),
                                    width: 40,
                                    height: 40,
                                    child: const _MapMarker(color: Colors.blue, icon: Icons.location_on),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.borderLight)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: AppTheme.bgLight,
                    ),
                    child: const Text('Close', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
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
                                    const SnackBar(
                                      content: Text('Mission accepted! Check your active deliveries.'),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: AppTheme.primary,
                                    ),
                                  );
                                } else if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(provider.errorMessage ?? 'Error accepting mission'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: AppTheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: provider.isAccepting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Accept Mission', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                      );
                    },
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
        Text(label, style: TextStyle(color: AppTheme.textDark.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w600)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppTheme.textDark,
            fontSize: 15,
            fontWeight: FontWeight.w800,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: AppTheme.textDark, fontSize: 13, fontWeight: FontWeight.w800)),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900)),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

