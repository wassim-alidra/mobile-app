import 'package:flutter/foundation.dart';

class BuyerProductModel {
  final int id;
  final String name;
  final String category;
  final double price;
  final double stock;
  final String unit;
  final String farmerName;
  final String farmerWilaya;
  final String? imageUrl;

  BuyerProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.unit,
    required this.farmerName,
    required this.farmerWilaya,
    this.imageUrl,
  });

  factory BuyerProductModel.fromJson(Map<String, dynamic> json) {
    // Try to get image from multiple possible fields found in logs
    dynamic rawImage = json['product_image'] ?? json['catalog_image'] ?? json['image'];
    
    return BuyerProductModel(
      id: json['id'],
      name: json['name'] ?? 'Unknown Product',
      category: json['catalog_name'] ?? 'General',
      price: double.tryParse(json['price_per_kg']?.toString() ?? '0') ?? 0.0,
      stock: double.tryParse(json['quantity_available']?.toString() ?? '0') ?? 0.0,
      unit: json['catalog_unit'] ?? 'kg',
      farmerName: json['farmer_name'] ?? 'Certified Producer',
      farmerWilaya: json['farmer_wilaya'] ?? json['farm_wilaya'] ?? 'Unknown Wilaya',
      imageUrl: (rawImage is Map) ? rawImage['url']?.toString() : rawImage?.toString(),
    );
  }
}

class BuyerOrderModel {
  final int id;
  final String productName;
  final double quantity;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final String farmerName;
  final String? deliveryStatus;

  BuyerOrderModel({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.farmerName,
    this.deliveryStatus,
  });

  factory BuyerOrderModel.fromJson(Map<String, dynamic> json) {
    return BuyerOrderModel(
      id: json['id'],
      productName: json['product_name'] ?? 'Unknown Product',
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'PENDING',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      farmerName: json['farmer_name'] ?? 'Farmer',
      deliveryStatus: json['delivery_status'],
    );
  }
}
