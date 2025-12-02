class MapScreenArgs {
  final int? highlightPlaceId; // подсветить конкретное место
  final int? categoryId;       // текущая категория (включая детей)
  final String? categoryTitle; // чтобы красиво написать "Шопинг · ТРЦ"

  const MapScreenArgs({
    this.highlightPlaceId,
    this.categoryId,
    this.categoryTitle,
  });
}
