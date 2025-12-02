import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mobile/providers/category_provider.dart';
import 'package:mobile/providers/city_provider.dart';
import 'package:mobile/providers/event_provider.dart';
import 'package:mobile/providers/favorite_provider.dart';
import 'package:mobile/providers/history_provider.dart';
import 'package:mobile/providers/layout_provider.dart';
import 'package:mobile/providers/map_provider.dart';
import 'package:mobile/providers/news_provider.dart';
import 'package:mobile/providers/place_provider.dart';
import 'package:mobile/providers/search_provider.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/providers/locale_provider.dart';
import 'package:mobile/storages/hive_storage.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class AppInitializer {
  static Future<List<SingleChildWidget>> init() async {
    await HiveStorage.init();

    final userProvider = UserProvider();
    final cityProvider = CityProvider();
    final categoryProvider = CategoryProvider();
    final favoriteProvider = FavoriteProvider();
    final localeProvider = LocaleProvider();

    // 1) язык – локально, подождать окей
    await localeProvider.loadLocale();
    debugPrint('Locale loaded');

    // 2) фоновые задачи (не блокируют запуск UI)
    unawaited(userProvider.loadUser());          // без forceRefresh
    unawaited(favoriteProvider.load(userProvider));

    // 3) города + категории больше НЕ трогаем здесь
    

    return [
      ChangeNotifierProvider(create: (_) => userProvider),
      ChangeNotifierProvider(create: (_) => cityProvider),
      ChangeNotifierProvider(create: (_) => categoryProvider),
      ChangeNotifierProvider(create: (_) => favoriteProvider),
      ChangeNotifierProvider(create: (_) => PlaceProvider()),
      ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ChangeNotifierProvider(create: (_) => MapProvider()),
      ChangeNotifierProvider(create: (_) => LayoutVisibilityProvider()),
      ChangeNotifierProvider(create: (_) => localeProvider),
      ChangeNotifierProvider(create: (_) => SearchProvider()),
      ChangeNotifierProvider(create: (_) => EventProvider()),
      ChangeNotifierProvider(create: (_) => NewsProvider()), 
    ];
  }
}
