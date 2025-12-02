import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:mobile/models/user.dart';
import 'api_client.dart';


class UserService {
  final Dio dio = ApiClient.dio;

  // 🔹 Получаем пользователя только с API (без кэша)
  static Future<UserModel?> fetchUserFromApi() async {
    try {
      final response = await ApiClient.dio.get(
        'users/request-user/',
        options: Options(extra: {"withAuth": true}),
      );

      return UserModel.fromJson(response.data['results']); // ✅ Конвертируем в `UserModel`
    } catch (e) {
      return null; // ❌ Ошибка загрузки данных
    }
  }

   /// 🔹 Обновление профиля (имя + аватар)
  static Future<UserModel?> updateUserProfile({
    String? fullName,
    File? avatarFile,
  }) async {
    try {
      final formData = FormData();

      if (fullName != null && fullName.trim().isNotEmpty) {
        formData.fields.add(MapEntry('full_name', fullName.trim()));
      }

      if (avatarFile != null) {
        final fileName = avatarFile.path.split('/').last;
        formData.files.add(
          MapEntry(
            'avatar',
            await MultipartFile.fromFile(
              avatarFile.path,
              filename: fileName,
            ),
          ),
        );
      }

      final response = await ApiClient.dio.post(
        'users/update/', // <-- путь подправь под свой URL
        data: formData,
        options: Options(
          extra: {"withAuth": true},
          contentType: 'multipart/form-data',
        ),
      );

      return UserModel.fromJson(response.data['results']);
    } catch (e) {
      debugPrint('❌ updateUserProfile error: $e');
      return null;
    }
  }
}