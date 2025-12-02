enum PlaceSort {
  popular,
  rating,
  distance,
}

class PlaceFilter {
  final String query;
  final int? categoryId;
  final int? cityId;

  /// Чипы
  final bool openNow;     // «Открыто сейчас»
  final bool nearby;      // «Рядом»
  final bool highRated;   // «Высокий рейтинг»

  /// Сортировка
  final PlaceSort sort;

  const PlaceFilter({
    this.query = '',
    this.categoryId,
    this.cityId,
    this.openNow = false,
    this.nearby = false,
    this.highRated = false,
    this.sort = PlaceSort.popular,
  });

  PlaceFilter copyWith({
    String? query,
    int? categoryId,
    int? cityId,
    bool? openNow,
    bool? nearby,
    bool? highRated,
    PlaceSort? sort,
  }) {
    return PlaceFilter(
      query: query ?? this.query,
      categoryId: categoryId ?? this.categoryId,
      cityId: cityId ?? this.cityId,
      openNow: openNow ?? this.openNow,
      nearby: nearby ?? this.nearby,
      highRated: highRated ?? this.highRated,
      sort: sort ?? this.sort,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'query': query,
      'category_id': categoryId,
      'city_id': cityId,
      if (openNow) 'open_now': 1,
      if (nearby) 'nearby': 1,
      if (highRated) 'high_rated': 1,
      'sort': switch (sort) {
        PlaceSort.popular => 'popular',
        PlaceSort.rating => 'rating',
        PlaceSort.distance => 'distance',
      },
    };

    // чтобы null не улетали в запрос
    map.removeWhere((_, value) => value == null);
    return map;
  }

  @override
  String toString() {
    return 'PlaceFilter('
        'query: $query, '
        'categoryId: $categoryId, '
        'cityId: $cityId, '
        'openNow: $openNow, '
        'nearby: $nearby, '
        'highRated: $highRated, '
        'sort: $sort'
        ')';
  }
}
