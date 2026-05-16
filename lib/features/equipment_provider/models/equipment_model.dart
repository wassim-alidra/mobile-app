class EquipmentImage {
  final int id;
  final String image;

  const EquipmentImage({required this.id, required this.image});

  factory EquipmentImage.fromJson(Map<String, dynamic> json) {
    return EquipmentImage(
      id: json['id'] as int? ?? 0,
      image: json['image'] as String? ?? '',
    );
  }
}

class EquipmentModel {
  final int id;
  final int provider;
  final String providerName;
  final String name;
  final String equipmentType;
  final double pricePerDay;
  final int quantityAvailable;
  final double? depositAmount;
  final String? horsepower;
  final String? weight;
  final int? yearOfManufacture;
  final String? transmission;
  final String? maxSpeed;
  final String? fuelType;
  final String? hoursOfUse;
  final String? location;
  final String? description;
  final String condition;
  final String? usageInstructions;
  final bool isAvailable;
  final String? expectedAvailableDate;
  final String createdAt;
  final String updatedAt;
  final List<EquipmentImage> images;
  final String? earliestReturnDate;

  const EquipmentModel({
    required this.id,
    required this.provider,
    required this.providerName,
    required this.name,
    required this.equipmentType,
    required this.pricePerDay,
    required this.quantityAvailable,
    this.depositAmount,
    this.horsepower,
    this.weight,
    this.yearOfManufacture,
    this.transmission,
    this.maxSpeed,
    this.fuelType,
    this.hoursOfUse,
    this.location,
    this.description,
    required this.condition,
    this.usageInstructions,
    required this.isAvailable,
    this.expectedAvailableDate,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
    this.earliestReturnDate,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    final imagesList = (json['images'] as List<dynamic>? ?? [])
        .map((e) => EquipmentImage.fromJson(e as Map<String, dynamic>))
        .toList();

    return EquipmentModel(
      id: json['id'] as int? ?? 0,
      provider: json['provider'] as int? ?? 0,
      providerName: json['provider_name'] as String? ?? '',
      name: json['name'] as String? ?? '',
      equipmentType: json['equipment_type'] as String? ?? '',
      pricePerDay: double.tryParse(json['price_per_day']?.toString() ?? '0') ?? 0.0,
      quantityAvailable: json['quantity_available'] as int? ?? 0,
      depositAmount: json['deposit_amount'] != null
          ? double.tryParse(json['deposit_amount'].toString())
          : null,
      horsepower: json['horsepower'] as String?,
      weight: json['weight'] as String?,
      yearOfManufacture: json['year_of_manufacture'] as int?,
      transmission: json['transmission'] as String?,
      maxSpeed: json['max_speed'] as String?,
      fuelType: json['fuel_type'] as String?,
      hoursOfUse: json['hours_of_use'] as String?,
      location: json['location'] as String?,
      description: json['description'] as String?,
      condition: json['condition'] as String? ?? '',
      usageInstructions: json['usage_instructions'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      expectedAvailableDate: json['expected_available_date'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      images: imagesList,
      earliestReturnDate: json['earliest_return_date'] as String?,
    );
  }

  String? get firstImageUrl => images.isNotEmpty ? images.first.image : null;

  bool get isActuallyAvailable => isAvailable && quantityAvailable > 0;
}
