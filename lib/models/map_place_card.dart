
class PlaceImageModel {
  final int id;
  /// Сырой путь, как пришёл с бэка (например `/media/...`)
  final String image;
  final bool isMain;

  PlaceImageModel({
    required this.id,
    required this.image,
    required this.isMain,
  });

  factory PlaceImageModel.fromJson(Map<String, dynamic> json) {
    return PlaceImageModel(
      id: json['id'] as int,
      image: json['image'] as String? ?? '',
      isMain: json['is_main'] as bool? ?? false,
    );
  }
}
class MapPlaceCardModel {
  final int id;
  final String name;
  final String? address;
  final double? latitude;
  final double? longitude;

  final double? rating;
  final int? totalReviews;
  final String? mainImageUrl;

  final String? description;
  final String? contactPhone;
  final String? website;

  final List<PlaceImageModel> images;

  // 🔥 новые поля
  final bool? isOpenNow;
  final String? workStatusPrimary;
  final String? workStatusSecondary;
  final String? todayHoursLabel;

  final String? categoryName;
  final double? distanceKm; // из distance_km

  MapPlaceCardModel({
    required this.id,
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.rating,
    this.totalReviews,
    this.mainImageUrl,
    this.description,
    this.contactPhone,
    this.website,
    this.images = const [],
    this.isOpenNow,
    this.workStatusPrimary,
    this.workStatusSecondary,
    this.todayHoursLabel,
    this.categoryName,
    this.distanceKm,
  });

  factory MapPlaceCardModel.fromJson(Map<String, dynamic> json) {
    return MapPlaceCardModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      rating: (json['average_rating'] as num?)?.toDouble(),
      totalReviews: json['total_reviews'] as int?,
      mainImageUrl: json['main_image_url'] as String?,
      description: json['description'] as String?,
      contactPhone: json['contact_phone'] as String?,
      website: json['website'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map(
                (e) => PlaceImageModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      isOpenNow: json['is_open_now'] as bool?,
      workStatusPrimary: json['work_status_primary'] as String?,
      workStatusSecondary: json['work_status_secondary'] as String?,
      todayHoursLabel: json['today_hours_label'] as String?,
      categoryName: json['category_name'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  // 🔹 вот это добавь
  MapPlaceCardModel copyWith({
    int? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    double? rating,
    int? totalReviews,
    String? mainImageUrl,
    String? description,
    String? contactPhone,
    String? website,
    List<PlaceImageModel>? images,
    bool? isOpenNow,
    String? workStatusPrimary,
    String? workStatusSecondary,
    String? todayHoursLabel,
    String? categoryName,
    double? distanceKm,
  }) {
    return MapPlaceCardModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      mainImageUrl: mainImageUrl ?? this.mainImageUrl,
      description: description ?? this.description,
      contactPhone: contactPhone ?? this.contactPhone,
      website: website ?? this.website,
      images: images ?? this.images,
      isOpenNow: isOpenNow ?? this.isOpenNow,
      workStatusPrimary: workStatusPrimary ?? this.workStatusPrimary,
      workStatusSecondary: workStatusSecondary ?? this.workStatusSecondary,
      todayHoursLabel: todayHoursLabel ?? this.todayHoursLabel,
      categoryName: categoryName ?? this.categoryName,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}
