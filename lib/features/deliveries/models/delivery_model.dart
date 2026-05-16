class DeliveryModel {
  final int id;
  final int orderId;
  final String status;
  final double deliveryFee;
  final String? pickupDate;
  final String? deliveryDate;
  final OrderInfo order;
  final TransporterInfo? transporter;
  final String? farmerPhone;
  final String? buyerPhone;

  const DeliveryModel({
    required this.id,
    required this.orderId,
    required this.status,
    required this.deliveryFee,
    this.pickupDate,
    this.deliveryDate,
    required this.order,
    this.transporter,
    this.farmerPhone,
    this.buyerPhone,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    final orderData = json['order'] as Map<String, dynamic>? ?? {};
    return DeliveryModel(
      id: json['id'] as int,
      orderId: json['order_id'] as int? ?? orderData['id'] as int? ?? (json['order'] is int ? json['order'] as int : 0),
      status: json['status'] as String? ?? 'ASSIGNED',
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      pickupDate: json['pickup_date'] as String?,
      deliveryDate: json['delivery_date'] as String?,
      farmerPhone: json['farmer_phone'] as String?,
      buyerPhone: json['buyer_phone'] as String?,
      order: OrderInfo.fromJson(orderData),
      transporter: json['transporter'] != null
          ? TransporterInfo.fromJson(json['transporter'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isActive => ['ASSIGNED', 'ON_WAY', 'CHARGING', 'NEAR_ARRIVAL'].contains(status);
  bool get isCompleted => status == 'DELIVERED';
  bool get isCancelled => status == 'CANCELLED';
}

class OrderInfo {
  final int id;
  final String status;
  final double quantity;
  final double totalPrice;
  final String createdAt;
  final ProductInfo? product;
  final BuyerInfo? buyer;

  const OrderInfo({
    required this.id,
    required this.status,
    required this.quantity,
    required this.totalPrice,
    required this.createdAt,
    this.product,
    this.buyer,
  });

  factory OrderInfo.fromJson(Map<String, dynamic> json) {
    return OrderInfo(
      id: json['id'] as int? ?? 0,
      status: json['status'] as String? ?? 'PENDING',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at'] as String? ?? '',
      product: json['product'] != null
          ? ProductInfo.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      buyer: json['buyer'] != null
          ? BuyerInfo.fromJson(json['buyer'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ProductInfo {
  final int id;
  final String name;
  final double pricePerKg;
  final String? image;
  final String? farmerUsername;
  final String? farmerWilaya;

  const ProductInfo({
    required this.id,
    required this.name,
    required this.pricePerKg,
    this.image,
    this.farmerUsername,
    this.farmerWilaya,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown Product',
      pricePerKg: double.tryParse(json['price_per_kg']?.toString() ?? '0') ?? 0.0,
      image: json['image'] as String?,
      farmerUsername: json['farmer_username'] as String?,
      farmerWilaya: json['farmer_wilaya'] as String?,
    );
  }
}

class BuyerInfo {
  final int id;
  final String username;
  final String? wilaya;

  const BuyerInfo({
    required this.id,
    required this.username,
    this.wilaya,
  });

  factory BuyerInfo.fromJson(Map<String, dynamic> json) {
    return BuyerInfo(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? 'Unknown',
      wilaya: json['wilaya'] as String?,
    );
  }
}

class TransporterInfo {
  final int id;
  final String username;

  const TransporterInfo({required this.id, required this.username});

  factory TransporterInfo.fromJson(Map<String, dynamic> json) {
    return TransporterInfo(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
    );
  }
}
