import 'package:mobile/utils/image_path.dart';

class PlaceModel {
  final int id;
  final String name;
  final String description;
  final CategorySimple category;
  final CitySimple city;
  final String address;
  final String contactPhone;
  final String website;
  final double? latitude;
  final double? longitude;
  final String mainImageUrl;
  final double averageRating;
  final int totalReviews;
  final DateTime createdAt;

  PlaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.city,
    required this.address,
    required this.contactPhone,
    required this.website,
    this.latitude,
    this.longitude,
    required this.mainImageUrl,
    required this.averageRating,
    required this.totalReviews,
    required this.createdAt,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: CategorySimple.fromJson(json['category']),
      city: CitySimple.fromJson(json['city']),
      address: json['address'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      website: json['website'] ?? '',
      latitude:
          json['latitude'] != null
              ? (json['latitude'] as num).toDouble()
              : null,
      longitude:
          json['longitude'] != null
              ? (json['longitude'] as num).toDouble()
              : null,
      mainImageUrl: getFullImageUrl(json["main_image_url"] ?? ""),
      
      averageRating: (json['average_rating'] as num).toDouble(),
      totalReviews: json['total_reviews'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// 🔽 Добавь это после него
class PlaceShortModel {
  final int id;
  final String name;
  final String mainImageUrl;
  final double averageRating;
  final int totalReviews;
  final CategorySimple category;
  final CitySimple city;

  PlaceShortModel({
    required this.id,
    required this.name,
    required this.mainImageUrl,
    required this.averageRating,
    required this.totalReviews,
    required this.category,
    required this.city,
  });

  factory PlaceShortModel.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category'];
    final rawCity = json['city'];

    return PlaceShortModel(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      mainImageUrl: getFullImageUrl(json['main_image_url'] ?? ""),
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['total_reviews'] as int?) ?? 0,

      // 👇 аккуратно работаем с nullable / странным форматом
      category: rawCategory is Map<String, dynamic>
          ? CategorySimple.fromJson(rawCategory)
          : CategorySimple.empty(),

      city: rawCity is Map<String, dynamic>
          ? CitySimple.fromJson(rawCity)
          : CitySimple.empty(),
    );
  }
}


class CitySimple {
  final int id;
  final String name;

  CitySimple({
    required this.id,
    required this.name,
  });

  factory CitySimple.fromJson(Map<String, dynamic> json) {
    return CitySimple(
      id: json['id'] as int? ?? 0,
      name: (json['name'] ?? '') as String,
    );
  }

  factory CitySimple.empty() => CitySimple(id: 0, name: '');
}

class CategorySimple {
  final int id;
  final String name;

  CategorySimple({
    required this.id,
    required this.name,
  });

  factory CategorySimple.fromJson(Map<String, dynamic> json) {
    return CategorySimple(
      id: json['id'] as int? ?? 0,
      name: (json['name'] ?? '') as String,
    );
  }

  factory CategorySimple.empty() => CategorySimple(id: 0, name: '');
}

