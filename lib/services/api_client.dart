import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/config/app_config.dart';
import 'auth_service.dart';
import 'token_storage.dart'; // Файл с реализацией TokenStorage

class ApiClient {
  static final Dio dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: Duration(milliseconds: 5000),
        receiveTimeout: Duration(milliseconds: 3000),
      ),
    )
    ..interceptors.add(
      InterceptorsWrapper(
        // Перед каждым запросом добавляем access_token, если он сохранён
        onRequest: (options, handler) async {
          final bool withAuth = options.extra["withAuth"] ?? false;
          if (withAuth) {
            final token = await TokenStorage().getAccessToken();
            if (token != null) {
              options.headers['Authorization'] =
                  'Bearer $token'; // 🔥 ВСТАВИТЬ ЗАГОЛОВОК
            } else {
              debugPrint('[API] ❌ Токен не найден');
            }
          }

          handler.next(options);
        },
        // Здесь можно добавить обработку ошибок (например, 401 и автоматическое обновление токена)
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          final response = error.response;
          final options = error.requestOptions;

          // 0. Для auth-эндпоинтов не пытаемся рефрешить
          final path = options.path;
          final isAuthEndpoint =
              path.contains('auth/refresh-token') ||
              path.contains('auth/send-code') ||
              path.contains('auth/verify-code');

          if (!isAuthEndpoint &&
              (response?.statusCode == 401 ||
                  (response?.statusCode == 403 &&
                      response?.data?["error_key"] ==
                          'authentication_failed'))) {
            if (options.extra["retry"] == true) {
              return handler.reject(error);
            }

            options.extra["retry"] = true;

            try {
              final authService = AuthService();
              final tokens = await authService.refreshToken();

              options.headers['Authorization'] =
                  'Bearer ${tokens['access_token']}';

              final newResponse = await dio.fetch(options);
              return handler.resolve(newResponse);
            } catch (e) {
              // тут можно ещё почистить токены и выкинуть юзера на логин
              return handler.reject(error);
            }
          }

          // 2. Обрабатываем кастомные ошибки с `error_key`
          if (response != null && response.data is Map) {
            final errorKey = response.data?["error_key"] ?? "unknown_error";
            final errorMessage = response.data?["detail"] ?? "Произошла ошибка";

            switch (errorKey) {
              case "code_send_await":
                return handler.reject(
                  DioException(
                    requestOptions: error.requestOptions,
                    response: error.response,
                    type: DioExceptionType.badResponse,
                    error: "Подождите перед повторной отправкой кода.",
                  ),
                );
              case "invalid_phone":
                return handler.reject(
                  DioException(
                    requestOptions: error.requestOptions,
                    response: error.response,
                    type: DioExceptionType.badResponse,
                    error: "Некорректный номер телефона.",
                  ),
                );
              default:
                debugPrint(errorMessage);
                debugPrint(errorKey);
                debugPrint(response.statusCode.toString());
                return handler.reject(
                  DioException(
                    requestOptions: error.requestOptions,
                    response: error.response,
                    type: DioExceptionType.badResponse,
                    error: errorMessage,
                  ),
                );
            }
          }

          // 3. Если ошибка не обработана → просто передаем дальше
          return handler.next(error);
        },
      ),
    );
}
