class ProductCatalogModel {
  final int id;
  final String name;
  final String? categoryName;
  final String description;
  final String unit;
  final double? minPrice;
  final double? maxPrice;
  final String season;
  final int year;
  final String? imageUrl;

  ProductCatalogModel({
    required this.id,
    required this.name,
    this.categoryName,
    required this.description,
    required this.unit,
    this.minPrice,
    this.maxPrice,
    required this.season,
    required this.year,
    this.imageUrl,
  });

  factory ProductCatalogModel.fromJson(Map<String, dynamic> json) {
    return ProductCatalogModel(
      id: json['id'],
      name: json['name'] ?? '',
      categoryName: json['category_name'],
      description: json['description'] ?? '',
      unit: json['unit'] ?? 'kg',
      minPrice: double.tryParse(json['min_price']?.toString() ?? ''),
      maxPrice: double.tryParse(json['max_price']?.toString() ?? ''),
      season: json['season'] ?? 'SPRING',
      year: json['year'] ?? 2024,
      imageUrl: json['image'],
    );
  }
}

class FarmerProductModel {
  final int id;
  final int catalogId;
  final String name;
  final String description;
  final int farmId;
  final String farmName;
  final String farmWilaya;
  final double pricePerKg;
  final double quantityAvailable;
  final String qualityGrade;
  final String? imageUrl;
  final String? catalogImageUrl;
  final double avgRating;
  final int ratingCount;

  FarmerProductModel({
    required this.id,
    required this.catalogId,
    required this.name,
    required this.description,
    required this.farmId,
    required this.farmName,
    required this.farmWilaya,
    required this.pricePerKg,
    required this.quantityAvailable,
    required this.qualityGrade,
    this.imageUrl,
    this.catalogImageUrl,
    required this.avgRating,
    required this.ratingCount,
  });

  factory FarmerProductModel.fromJson(Map<String, dynamic> json) {
    return FarmerProductModel(
      id: json['id'],
      catalogId: json['catalog'] ?? 0,
      name: json['catalog_name'] ?? json['name'] ?? 'Unnamed Product',
      description: json['description'] ?? '',
      farmId: json['farm'] ?? 0,
      farmName: json['farm_name'] ?? '',
      farmWilaya: json['farm_wilaya'] ?? '',
      pricePerKg: double.tryParse(json['price_per_kg']?.toString() ?? '0') ?? 0.0,
      quantityAvailable: double.tryParse(json['quantity_available']?.toString() ?? '0') ?? 0.0,
      qualityGrade: json['quality_grade'] ?? 'HIGH',
      imageUrl: json['product_image'] ?? json['image'],
      catalogImageUrl: json['catalog_image'],
      avgRating: double.tryParse(json['avg_rating']?.toString() ?? '0') ?? 0.0,
      ratingCount: json['rating_count'] ?? 0,
    );
  }
}
