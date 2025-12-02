class MapPlaceFilter {
  final int cityId;
  final int? categoryId;
  final String? query;
  final List<int>? placeIds; // ids конкретных мест

  const MapPlaceFilter({
    required this.cityId,
    this.categoryId,
    this.query,
    this.placeIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'city_id': cityId,
      if (categoryId != null) 'category_id': categoryId,
      if (query != null && query!.trim().isNotEmpty) 'q': query!.trim(),
      if (placeIds != null && placeIds!.isNotEmpty)
        'ids': placeIds!.join(','), // backend ждёт ids=1,2,3
    };
  }
}
