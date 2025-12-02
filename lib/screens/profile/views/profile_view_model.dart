import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/providers/city_provider.dart';
import 'package:mobile/providers/locale_provider.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserProvider _userProvider;
  final CityProvider _cityProvider;
  final LocaleProvider _localeProvider;

  ProfileViewModel(
    this._userProvider,
    this._cityProvider,
    this._localeProvider,
  ) {
    // 👇 Подписываемся на изменения всех трёх провайдеров
    _userProvider.addListener(_onDepsChanged);
    _cityProvider.addListener(_onDepsChanged);
    _localeProvider.addListener(_onDepsChanged);
  }

  /// Когда что-то из зависимостей меняется — дёргаем notifyListeners,
  /// и экран профиля сразу перерисуется.
  void _onDepsChanged() {
    notifyListeners();
  }

  // ========= Публичные геттеры, которыми пользуется профиль =========

  bool get isAuthenticated => _userProvider.isAuthenticated;

  UserModel? get user => _userProvider.user;

  String get phone => user?.phone ?? 'Гость';

  String get avatar => user?.profile.avatar ?? '';

  /// Красивое отображаемое имя
  String get displayName {
    final fullName = user?.profile.fullName;
    if (fullName != null && fullName.trim().isNotEmpty) {
      return fullName.trim();
    }
    final phone = user?.phone;
    if (phone != null && phone.isNotEmpty) {
      return phone;
    }
    return 'Пользователь';
  }

  /// Метка языка — из LocaleProvider
  String get languageLabel {
    final code = (_localeProvider.locale?.languageCode ?? 'ru').toLowerCase();

    switch (code) {
      case 'uz':
        return 'O‘zbek tili';
      case 'ru':
      default:
        return 'Русский';
    }
  }

  /// Город — сначала из CityProvider.currentCity,
  /// если нет — из профиля по cityId, если и там пусто — "Не выбран"
  String get cityName {
    final city = _cityProvider.currentCity;
    if (city != null) return city.name;

    final cityId = user?.profile.cityId;
    if (cityId != null) {
      final byId = _cityProvider.getCityById(cityId);
      if (byId != null) return byId.name;
    }

    return 'Не выбран';
  }

  /// Выход из аккаунта
  Future<void> logout() async {
    await _userProvider.logout();
    // теоретически _userProvider сам вызовет notifyListeners,
    // но мы дополнительно дергаем на всякий случай
    notifyListeners();
  }

  Future<bool> updateProfile({String? fullName, File? avatarFile}) async {
    return _userProvider.updateProfile(
      fullName: fullName,
      avatarFile: avatarFile,
    );
  }

  /// Обновление данных для pull-to-refresh на экране профиля
  Future<void> refresh() async {
    // Обновляем пользователя с сервера принудительно
    await _userProvider.loadUser(forceRefresh: true);

    // При желании можно обновить город/список городов:
    // await _cityProvider.loadCities(forceNetwork: true);

    // notifyListeners тут по сути не обязателен,
    // т.к. UserProvider сам дёрнет, но лишним не будет
    notifyListeners();
  }

  @override
  void dispose() {
    // Не забываем отписаться
    _userProvider.removeListener(_onDepsChanged);
    _cityProvider.removeListener(_onDepsChanged);
    _localeProvider.removeListener(_onDepsChanged);
    super.dispose();
  }
}
