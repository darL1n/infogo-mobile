import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/services/token_storage.dart';
import 'package:mobile/services/user_service.dart';
import 'package:mobile/storages/hive_storage.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;

  // UserProvider() {
  //   _loadCachedUser(); // ✅ Загружаем пользователя при старте
  // }

  Future<void> loadUser({bool forceRefresh = false}) async {
  debugPrint('🔄 loadUser вызван (forceRefresh=$forceRefresh)');

  if (!forceRefresh) {
    // 1) если уже есть в памяти — выходим
    if (_user != null) {
      debugPrint('✅ Пользователь уже в памяти');
      return;
    }

    // 2) пробуем достать из Hive
    final cached = HiveStorage.getUserData();
    if (cached != null) {
      _user = cached;
      debugPrint('✅ Пользователь найден в кэше');
      notifyListeners();
      return;
    }
  }

  // 3) либо forceRefresh = true, либо кэша нет — идём на сервер
  await _fetchUser();
}


  /// **3. Загружаем пользователя с сервера (только если есть токен)**
  Future<void> _fetchUser() async {
    debugPrint('🌍 _fetchUser вызван');

    final token = await TokenStorage().getAccessToken();
    if (token == null) {
      debugPrint('❌ Токен отсутствует, не загружаем пользователя');
      return;
    }

    try {
      final userData = await UserService.fetchUserFromApi();
      if (userData != null) {
        _user = userData;
        await HiveStorage.saveUserData(userData);
        notifyListeners();
        debugPrint('✅ Пользователь успешно загружен с сервера');
      }
    } catch (e) {
      debugPrint('❌ Ошибка загрузки пользователя: $e');
    }
  }

  /// **4. Логин (после успешной верификации)**
  Future<void> login() async {
    await loadUser(forceRefresh: true);
  }

  /// 🔹 Обновление профиля (имя + фото)
  Future<bool> updateProfile({String? fullName, File? avatarFile}) async {
    final updated = await UserService.updateUserProfile(
      fullName: fullName,
      avatarFile: avatarFile,
    );

    if (updated == null) return false;

    _user = updated;
    await HiveStorage.saveUserData(updated);
    notifyListeners();
    return true;
  }

  /// **5. Выход из аккаунта**
  Future<void> logout() async {
    await TokenStorage().deleteTokens();
    await HiveStorage.clearUserData();
    _user = null;
    notifyListeners();
  }
}
