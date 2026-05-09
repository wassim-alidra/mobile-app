class FarmerOrderModel {
  final int id;
  final String status;
  final double quantity;
  final double totalPrice;
  final String productName;
  final String buyerName;
  final String buyerWilaya;
  final String? deliveryStatus;
  final DateTime createdAt;

  FarmerOrderModel({
    required this.id,
    required this.status,
    required this.quantity,
    required this.totalPrice,
    required this.productName,
    required this.buyerName,
    required this.buyerWilaya,
    this.deliveryStatus,
    required this.createdAt,
  });

  factory FarmerOrderModel.fromJson(Map<String, dynamic> json) {
    return FarmerOrderModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'PENDING',
      quantity: _toDouble(json['quantity']),
      totalPrice: _toDouble(json['total_price']),
      productName: json['product_name'] ?? json['product']?['name'] ?? '—',
      buyerName: json['buyer_name'] ??
          (json['buyer'] is Map ? json['buyer']['username'] : '—'),
      buyerWilaya: json['buyer_wilaya'] ??
          (json['buyer'] is Map ? json['buyer']['wilaya'] ?? '—' : '—'),
      deliveryStatus: json['delivery_status'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class FarmerStatsModel {
  final int totalProducts;
  final double totalQuantity;
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final double totalRevenue;

  FarmerStatsModel({
    required this.totalProducts,
    required this.totalQuantity,
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.totalRevenue,
  });

  factory FarmerStatsModel.fromJson(Map<String, dynamic> json) {
    return FarmerStatsModel(
      totalProducts: json['total_products'] ?? 0,
      totalQuantity: _toDouble(json['total_quantity']),
      totalOrders: json['total_orders'] ?? 0,
      pendingOrders: json['pending_orders'] ?? 0,
      completedOrders: json['completed_orders'] ?? 0,
      totalRevenue: _toDouble(json['total_revenue']),
    );
  }
}

class FarmerChartStats {
  final List<ChartEntry> topSelling;
  final List<ChartEntry> weeklySales;
  final List<RatingEntry> topRated;

  FarmerChartStats({
    required this.topSelling,
    required this.weeklySales,
    required this.topRated,
  });

  factory FarmerChartStats.fromJson(Map<String, dynamic> json) {
    return FarmerChartStats(
      topSelling: (json['top_selling'] as List? ?? [])
          .map((e) => ChartEntry.fromJson(e))
          .toList(),
      weeklySales: (json['weekly_sales'] as List? ?? [])
          .map((e) => ChartEntry.fromJson(e, valueKey: 'value'))
          .toList(),
      topRated: (json['top_rated'] as List? ?? [])
          .map((e) => RatingEntry.fromJson(e))
          .toList(),
    );
  }
}

class ChartEntry {
  final String name;
  final double value;
  ChartEntry({required this.name, required this.value});
  factory ChartEntry.fromJson(Map<String, dynamic> json,
      {String valueKey = 'value'}) {
    return ChartEntry(
      name: json['name'] ?? '',
      value: _toDouble(json[valueKey]),
    );
  }
}

class RatingEntry {
  final String name;
  final double rating;
  RatingEntry({required this.name, required this.rating});
  factory RatingEntry.fromJson(Map<String, dynamic> json) {
    return RatingEntry(
      name: json['name'] ?? '',
      rating: _toDouble(json['rating']),
    );
  }
}

class FireAlert {
  final int id;
  final String farmName;
  final DateTime timestamp;

  FireAlert({required this.id, required this.farmName, required this.timestamp});

  factory FireAlert.fromJson(Map<String, dynamic> json) {
    return FireAlert(
      id: json['id'] ?? 0,
      farmName: json['farm_name'] ?? 'Unknown Farm',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

