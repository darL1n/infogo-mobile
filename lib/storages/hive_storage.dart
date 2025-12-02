// ignore: unnecessary_import
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/models/city.dart';
import 'package:mobile/models/user.dart';

class HiveStorage {
  // 🔹 Хранение истории поиска
  static const _searchKey = 'searchHistory';
  // 🔹 Язык
  static const _keyLocaleCode = 'locale_code';

  static Future<void> init() async {
    await Hive.initFlutter();

    // ✅ Регистрируем адаптеры
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(CityModelAdapter());

    // ✅ Открываем хранилища
    await Hive.openBox<UserModel>('userBox'); // ✅ Открываем хранилище профиля
    await Hive.openBox('appSettings'); // ✅ Открываем хранилище профиля
    await Hive.openBox<CityModel>('citiesBox');
    await Hive.openBox(
      'historyBox',
    ); // ✅ Открываем хранилище истории просмотров
    await Hive.openBox('favoritesBox'); // ✅ Открываем хранилище избранного
  }

  // 🔹 Хранение профиля
  static Future<void> saveUserData(UserModel user) async {
    final box = Hive.box<UserModel>('userBox');
    await box.put('user', user); // ✅ Сохраняем объект напрямую
  }

  static UserModel? getUserData() {
    final box = Hive.box<UserModel>('userBox');
    return box.get('user');
  }

  static Future<void> clearUserData() async {
    final box = Hive.box<UserModel>('userBox');
    await box.delete('user');
  }

  // 🔹 Хранение истории просмотров
  static Future<void> saveViewHistoryIds(List<int> ids) async {
    final box = Hive.box('historyBox');
    await box.put('history', ids);
  }

  static List<int> getViewHistoryIds() {
    final box = Hive.box('historyBox');
    return box.get('history', defaultValue: <int>[])!.cast<int>();
  }

  static Future<void> clearViewHistoryIds() async {
    final box = Hive.box('historyBox');
    await box.delete('history');
  }

  // 🔹 Хранение избранного
  static Future<void> saveFavoriteIds(List<int> ids) async {
    final box = Hive.box('favoritesBox');
    await box.put('favorites', ids);
  }

  static List<int> getFavoriteIds() {
    final box = Hive.box('favoritesBox');
    return box.get('favorites', defaultValue: <int>[])!.cast<int>();
  }

  static Future<void> clearFavoriteIds() async {
    final box = Hive.box('favoritesBox');
    await box.delete('favorites');
  }

  // 🔹 Хранение городов
  static Future<void> saveCities(List<CityModel> cities) async {
    final box = Hive.box<CityModel>('citiesBox');
    await box.clear();
    for (var city in cities) {
      box.put(city.id, city);
    }
  }

  static List<CityModel> getCities() {
    final box = Hive.box<CityModel>('citiesBox');
    return box.values.toList();
  }

  static CityModel? getCityById(int cityId) {
    final box = Hive.box<CityModel>('citiesBox');
    return box.get(cityId);
  }

  static Future<void> saveCurrentCityId(int cityId) async {
    final box = Hive.box('appSettings');
    await box.put('currentCityId', cityId);
  }

  static int? getCurrentCityId() {
    final box = Hive.box('appSettings');
    return box.get('currentCityId');
  }

  static Future<void> addSearchQuery(String query) async {
    final box = Hive.box('appSettings');
    final List<String> history = List<String>.from(
      box.get(_searchKey, defaultValue: []),
    );
    history.remove(query); // убираем дубликаты
    history.insert(0, query); // вставляем в начало
    if (history.length > 10) history.removeLast(); // ограничим 10 элементами
    await box.put(_searchKey, history);
  }

  static List<String> getSearchHistory() {
    final box = Hive.box('appSettings');
    return List<String>.from(box.get(_searchKey, defaultValue: []));
  }

  static Future<void> removeSearchQuery(String query) async {
    final box = Hive.box('appSettings');
    final List<String> history = List<String>.from(
      box.get(_searchKey, defaultValue: []),
    );
    history.remove(query);
    await box.put(_searchKey, history);
  }

  static Future<void> clearSearchHistory() async {
    final box = Hive.box('appSettings');
    await box.put(_searchKey, []);
  }

  // 🔹 Язык интерфейса (locale_code)
  static Future<void> saveLocaleCode(String code) async {
    final box = Hive.box('appSettings');
    await box.put(_keyLocaleCode, code);
  }

  static String? getLocaleCode() {
    final box = Hive.box('appSettings');
    return box.get(_keyLocaleCode) as String?;
  }
}
