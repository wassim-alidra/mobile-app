import 'package:flutter/material.dart';

class EquipmentBookingModel {
  final int id;
  final int equipment;
  final String equipmentName;
  final int farmer;
  final String farmerName;
  final String providerName;
  final int equipmentTotalQuantity;
  final int requestedQuantity;
  final int rentalDays;
  final String status;
  final String? startDate;
  final String? endDate;
  final String? expectedReturnDate;
  final double? totalPrice;
  final String createdAt;
  final String updatedAt;

  const EquipmentBookingModel({
    required this.id,
    required this.equipment,
    required this.equipmentName,
    required this.farmer,
    required this.farmerName,
    required this.providerName,
    required this.equipmentTotalQuantity,
    required this.requestedQuantity,
    required this.rentalDays,
    required this.status,
    this.startDate,
    this.endDate,
    this.expectedReturnDate,
    this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EquipmentBookingModel.fromJson(Map<String, dynamic> json) {
    return EquipmentBookingModel(
      id: json['id'] as int? ?? 0,
      equipment: json['equipment'] as int? ?? 0,
      equipmentName: json['equipment_name'] as String? ?? '',
      farmer: json['farmer'] as int? ?? 0,
      farmerName: json['farmer_name'] as String? ?? '',
      providerName: json['provider_name'] as String? ?? '',
      equipmentTotalQuantity: json['equipment_total_quantity'] as int? ?? 0,
      requestedQuantity: json['requested_quantity'] as int? ?? 1,
      rentalDays: json['rental_days'] as int? ?? 1,
      status: json['status'] as String? ?? 'PENDING',
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      expectedReturnDate: json['expected_return_date'] as String?,
      totalPrice: json['total_price'] != null
          ? double.tryParse(json['total_price'].toString())
          : null,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  bool get isPending => status == 'PENDING';
  bool get isAccepted => status == 'ACCEPTED';
  bool get isRejected => status == 'REJECTED';
  bool get isCompleted => status == 'COMPLETED';

  static Color statusColor(String status) {
    switch (status) {
      case 'PENDING':
        return const Color(0xFFF59E0B);
      case 'ACCEPTED':
        return const Color(0xFF10B981);
      case 'REJECTED':
        return const Color(0xFFEF4444);
      case 'COMPLETED':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
