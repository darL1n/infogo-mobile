import 'package:mobile/models/place.dart';
import 'package:mobile/utils/image_path.dart';

class PlaceDetailModel {
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
  double averageRating;        // оставляем не final — ты его обновляешь после отзыва
  int totalReviews;
  final DateTime createdAt;

  final List<PlaceImage> images;
  final List<WorkingHour> workingHours;
  final List<Review> reviews;

  /// 🔹 Новое: секции места (features/services/price_list/info/how_to_get/...)
  final List<PlaceSection> sections;

  /// 🔹 Новое: ближайшие события, привязанные к этому месту
  final List<EventShort> upcomingEvents;

  PlaceDetailModel({
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
    required this.images,
    required this.workingHours,
    required this.reviews,
    required this.sections,
    required this.upcomingEvents,
  });

  factory PlaceDetailModel.fromJson(Map<String, dynamic> json) {
    return PlaceDetailModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: CategorySimple.fromJson(json['category'] ?? {}),
      city: CitySimple.fromJson(json['city'] ?? {}),
      address: json['address'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      website: json['website'] ?? '',
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      mainImageUrl: getFullImageUrl(json['main_image_url'] ?? ''),
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      totalReviews: (json['total_reviews'] ?? 0) as int,
      createdAt: DateTime.parse(json['created_at']),

      // 🖼️ изображения
      images: (json['images'] as List<dynamic>?)
              ?.map((img) => PlaceImage.fromJson(img))
              .toList() ??
          [],

      // ⏰ часы работы
      workingHours: (json['working_hours'] as List<dynamic>?)
              ?.map((wh) => WorkingHour.fromJson(wh))
              .toList() ??
          [],


      // ⭐ отзывы
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((review) => Review.fromJson(review))
              .toList() ??
          [],

      // 🔹 секции
      sections: (json['sections'] as List<dynamic>?)
              ?.map((s) => PlaceSection.fromJson(s))
              .toList() ??
          [],

      // 🔹 ближайшие события
      upcomingEvents: (json['upcoming_events'] as List<dynamic>?)
              ?.map((e) => EventShort.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// 🖼️ Модель изображений заведения
class PlaceImage {
  final int id;
  final String imageUrl;
  final bool isMain;

  PlaceImage({
    required this.id,
    required this.imageUrl,
    required this.isMain,
  });

  factory PlaceImage.fromJson(Map<String, dynamic> json) {
    return PlaceImage(
      id: json['id'],
      imageUrl: getFullImageUrl(json['image']),
      isMain: json['is_main'] ?? false,
    );
  }
}

/// ⏰ Часы работы
class WorkingHour {
  final String dayOfWeek;
  final String? openTime;
  final String? closeTime;
  final bool isClosed;

  WorkingHour({
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    required this.isClosed,
  });

  factory WorkingHour.fromJson(Map<String, dynamic> json) {
    return WorkingHour(
      dayOfWeek: json['day_of_week'],
      openTime: json['open_time'],
      closeTime: json['close_time'],
      isClosed: json['is_closed'] ?? false,
    );
  }
}

/// ⭐ Отзыв
class Review {
  final int id;
  final Reviewer reviewer;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.reviewer,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      reviewer: Reviewer.fromJson(json['reviewer']),
      rating: json['rating'],
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

/// 👤 Рецензент
class Reviewer {
  final int id;
  final String phone;
  final String? avatar;   // <-- nullable
  final int? cityId;
  final String? fullName;

  Reviewer({
    required this.id,
    required this.phone,
    this.avatar,
    this.cityId,
    this.fullName
  });

  factory Reviewer.fromJson(Map<String, dynamic> json) {
    final rawAvatar = json['avatar'];

    return Reviewer(
      id: json['id'] as int,
      phone: json['phone'] ?? '',
      avatar: rawAvatar != null && (rawAvatar as String).isNotEmpty
          ? getFullImageUrl(rawAvatar)
          : null,
      cityId: json['city_id'] as int?,
      fullName: json['full_name']
    );
  }
}



/// 🔹 Секция места (PlaceSection из бэка)
class PlaceSection {
  final int id;
  final String type;                // features / services / price_list / info / ...
  final String title;
  final String slug;
  final int sortOrder;
  final Map<String, dynamic> payload;
  final bool isActive;

  PlaceSection({
    required this.id,
    required this.type,
    required this.title,
    required this.slug,
    required this.sortOrder,
    required this.payload,
    required this.isActive,
  });

  factory PlaceSection.fromJson(Map<String, dynamic> json) {
    return PlaceSection(
      id: json['id'],
      type: json['type'],
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      sortOrder: json['sort_order'] ?? 0,
      payload: (json['payload'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      isActive: json['is_active'] ?? true,
    );
  }
}

/// 🔹 Короткая модель события для блока "Ближайшие события"
class EventShort {
  final int id;
  final String title;
  final DateTime startAt;
  final DateTime? endAt;
  final bool isFree;
  final int? priceFrom;
  final int? priceTo;

  EventShort({
    required this.id,
    required this.title,
    required this.startAt,
    this.endAt,
    required this.isFree,
    this.priceFrom,
    this.priceTo,
  });

  factory EventShort.fromJson(Map<String, dynamic> json) {
    return EventShort(
      id: json['id'],
      title: json['title'] ?? '',
      startAt: DateTime.parse(json['start_at']),
      endAt: json['end_at'] != null ? DateTime.parse(json['end_at']) : null,
      isFree: json['is_free'] ?? false,
      priceFrom:
          json['price_from'] != null ? (json['price_from'] as num).toInt() : null,
      priceTo:
          json['price_to'] != null ? (json['price_to'] as num).toInt() : null,
    );
  }
}
