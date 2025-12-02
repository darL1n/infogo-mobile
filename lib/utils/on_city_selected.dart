import 'package:flutter/material.dart';
import 'package:mobile/models/city.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/city_provider.dart';
import 'package:mobile/providers/place_provider.dart';
import 'package:mobile/providers/category_provider.dart';

void onCitySelected(BuildContext context, CityModel city) {
  final cityProvider = context.read<CityProvider>();
  final placeProvider = context.read<PlaceProvider>();
  final categoryProvider = context.read<CategoryProvider>();

  // 1) обновляем текущий город (и Hive)
  cityProvider.setCurrentCity(city.id);

  // 2) чистим места и подтягиваем фильтр под новый город
  final currentFilter = placeProvider.filter;

  placeProvider.clearPlaces();
  placeProvider.updateFilter(
    currentFilter.copyWith(
      cityId: city.id,
      // categoryId НЕ трогаем — если юзер в категории, останется эта же категория,
      // просто данные подтянутся для нового города
    ),
  );

  // 3) если есть активная категория — сразу перезагрузим места
  // placeProvider.fetchPlaces(refresh: true);

  // 4) если категории на бэке зависят от города/страны (placeCount и т.п.)
  // — можно сделать принудительную перезагрузку
  categoryProvider.clear();
  categoryProvider.fetchCategoriesForCity(city.id, force: true); // см. ниже реализацию

  // 4) лёгкий SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Город изменён на ${city.name}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
      ),
    );
}
