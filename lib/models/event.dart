import 'package:intl/intl.dart';

class EventModel {
  final int id;
  final String title;
  final String? categoryName;
  final String? placeName;
  final DateTime startAt;
  final DateTime? endAt;
  final bool isAllDay;
  final bool isPublished;
  final bool isFeatured;
  final int? priceFrom;
  final int? priceTo;
  final bool isFree;

  EventModel({
    required this.id,
    required this.title,
    required this.categoryName,
    required this.placeName,
    required this.startAt,
    required this.endAt,
    required this.isAllDay,
    required this.isPublished,
    required this.isFeatured,
    required this.priceFrom,
    required this.priceTo,
    required this.isFree,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as int,
      title: json['title'] as String,
      categoryName: json['category_name'] as String?,
      placeName: json['place_name'] as String?,
      startAt: DateTime.parse(json['start_at'] as String),
      endAt: json['end_at'] != null
          ? DateTime.parse(json['end_at'] as String)
          : null,
      isAllDay: json['is_all_day'] as bool,
      isPublished: json['is_published'] as bool,
      isFeatured: json['is_featured'] as bool,
      priceFrom: json['price_from'] as int?,
      priceTo: json['price_to'] as int?,
      isFree: json['is_free'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category_name': categoryName,
      'place_name': placeName,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt?.toIso8601String(),
      'is_all_day': isAllDay,
      'is_published': isPublished,
      'is_featured': isFeatured,
      'price_from': priceFrom,
      'price_to': priceTo,
      'is_free': isFree,
    };
  }

  /// Красивый формат даты/времени для списка
  String get dateLabel {
    if (isAllDay) {
      final d = DateFormat('d MMMM', 'ru').format(startAt);
      return '$d • весь день';
    }

    final date = DateFormat('d MMM', 'ru').format(startAt);
    final time = DateFormat('HH:mm', 'ru').format(startAt);

    if (endAt != null && !isAllDay) {
      final endTime = DateFormat('HH:mm', 'ru').format(endAt!);
      return '$date • $time–$endTime';
    }

    return '$date • $time';
  }

  /// Диапазон цены / "Бесплатно"
  String get priceLabel {
    if (isFree) return 'Бесплатно';
    if (priceFrom != null && priceTo != null) {
      return '${_fmt(priceFrom!)} – ${_fmt(priceTo!)} сум';
    }
    if (priceFrom != null) {
      return 'от ${_fmt(priceFrom!)} сум';
    }
    return 'Без указания цены';
  }

  String _fmt(int value) {
    final f = NumberFormat.decimalPattern('ru');
    return f.format(value);
  }
}



class EventFilter {
  final int? cityId;
  final int? placeId;
  final int? categoryId;
  final bool? isPublished;
  final bool? isFeatured;
  final bool? isFree;
  final String? query;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const EventFilter({
    this.cityId,
    this.placeId,
    this.categoryId,
    this.isPublished,
    this.isFeatured,
    this.isFree,
    this.query,
    this.dateFrom,
    this.dateTo,
  });

  EventFilter copyWith({
    int? cityId,
    int? placeId,
    int? categoryId,
    bool? isPublished,
    bool? isFeatured,
    bool? isFree,
    String? query,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool resetCityId = false,
    bool resetPlaceId = false,
    bool resetCategoryId = false,
    bool resetQuery = false,
    bool resetDateFrom = false,
    bool resetDateTo = false,
  }) {
    return EventFilter(
      cityId: resetCityId ? null : (cityId ?? this.cityId),
      placeId: resetPlaceId ? null : (placeId ?? this.placeId),
      categoryId: resetCategoryId ? null : (categoryId ?? this.categoryId),
      isPublished: isPublished ?? this.isPublished,
      isFeatured: isFeatured ?? this.isFeatured,
      isFree: isFree ?? this.isFree,
      query: resetQuery ? null : (query ?? this.query),
      dateFrom: resetDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: resetDateTo ? null : (dateTo ?? this.dateTo),
    );
  }

  /// По дефолту: только опубликованные, только будущие
  static EventFilter defaultForCity(int? cityId) {
    final now = DateTime.now();
    return EventFilter(
      cityId: cityId,
      isPublished: true,
      dateFrom: DateTime(now.year, now.month, now.day),
    );
  }
}
