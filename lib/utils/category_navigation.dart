import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/category.dart';
import 'package:mobile/models/place_filter.dart';
import 'package:mobile/providers/city_provider.dart';
import 'package:mobile/providers/place_provider.dart';
import 'package:provider/provider.dart';

class CategoryRedirectHandler {
  static void redirectIfLeaf({
    required BuildContext context,
    required CategoryModel category,
    required String fallbackRoute,
  }) {
    final currentLocation = GoRouterState.of(context).uri.toString();

    debugPrint('📦 redirectIfLeaf');
    debugPrint('🔹 categoryId: ${category.id}');
    debugPrint('🔹 isLeaf: ${category.children.isEmpty}');
    debugPrint('🔹 location: $currentLocation');

    if (category.children.isEmpty &&
        !currentLocation.endsWith('/places')) {
      debugPrint('🚀 Redirecting to /places');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final cityId = context.read<CityProvider>().currentCityId;
        context.read<PlaceProvider>().updateFilter(
          PlaceFilter(categoryId: category.id, cityId: cityId),
        );
        context.push('/places', extra: {'fallback': fallbackRoute});
      });
    } else {
      debugPrint('⛔ Not redirecting');
    }
  }
}

/// Переход при нажатии на категорию
// void handleCategoryTap(BuildContext context, CategoryModel category) {
//   final cityId = context.read<CityProvider>().currentCityId;

//   if (category.isLeafNode) {
//     // сразу устанавливаем фильтр и пушим на места
//     context.read<PlaceProvider>().updateFilter(
//       PlaceFilter(categoryId: category.id, cityId: cityId),
//     );
//     context.push('/places', extra: {
//       'fallback': category.parentId != null
//           ? '/catalog/${category.parentId}'
//           : '/catalog'
//     });
//   } else {
//     context.push('/catalog/${category.id}');
//   }
// }


void handleCategoryTap(BuildContext context, CategoryModel category) {
  context.push('/catalog/${category.id}');
}