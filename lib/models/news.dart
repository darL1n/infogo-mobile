// lib/models/news.dart
import 'package:mobile/utils/image_path.dart';

class NewsModel {
  final int id;
  final String title;
  final String? categoryName;
  final String? placeName;
  final String? lead;
  final DateTime? publishedAt;
  final bool isFeatured;

  NewsModel({
    required this.id,
    required this.title,
    this.categoryName,
    this.placeName,
    this.lead,
    this.publishedAt,
    required this.isFeatured,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    final publishedRaw = json['published_at'];
    DateTime? publishedAt;
    if (publishedRaw is String && publishedRaw.isNotEmpty) {
      publishedAt = DateTime.parse(publishedRaw);
    }

    return NewsModel(
      id: json['id'] as int,
      title: json['title'] as String,
      categoryName: json['category_name'] as String?,
      placeName: json['place_name'] as String?,
      lead: json['lead'] as String?,
      publishedAt: publishedAt,
      isFeatured: (json['is_featured'] as bool?) ?? false,
    );
  }
}

class NewsDetailModel {
  final int id;
  final String title;
  final String? lead;
  final String body;
  final String? image;      // абсолютный или относительный URL
  final String cityName;
  final String? categoryName;
  final String? placeName;
  final DateTime? publishedAt;
  final bool isFeatured;

  NewsDetailModel({
    required this.id,
    required this.title,
    this.lead,
    required this.body,
    this.image,
    required this.cityName,
    this.categoryName,
    this.placeName,
    this.publishedAt,
    required this.isFeatured,
  });

  factory NewsDetailModel.fromJson(Map<String, dynamic> json) {
    final publishedRaw = json['published_at'];
    DateTime? publishedAt;
    if (publishedRaw is String && publishedRaw.isNotEmpty) {
      publishedAt = DateTime.parse(publishedRaw);
    }
    final rawImage = json["image"] as String?;
    return NewsDetailModel(
      id: json['id'] as int,
      title: json['title'] as String,
      lead: json['lead'] as String?,
      body: json['body'] as String,
      image: getFullImageUrl(rawImage),
      cityName: json['city_name'] as String,
      categoryName: json['category_name'] as String?,
      placeName: json['place_name'] as String?,
      publishedAt: publishedAt,
      isFeatured: (json['is_featured'] as bool?) ?? false,
    );
  }
}
