import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'api_client.dart';
import 'token_storage.dart';

const String kGoogleServerClientId = '429807978591-3p03ici20npbokcm6109gb12mc5mli1a.apps.googleusercontent.com';

class AuthService {
  final Dio _dio = ApiClient.dio;

  // GoogleSignIn клиент
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;

    await _googleSignIn.initialize(
      // Если нужно — сюда потом добавим clientId / serverClientId
      // clientId: Env.googleClientId,
      serverClientId: kGoogleServerClientId,
    );

    _googleInitialized = true;
  }

  /// Отправка кода авторизации по номеру телефона.
  Future<bool> sendAuthCode(String phone) async {
    try {
      final response = await _dio.post(
        'auth/send-code/',
        data: {"phone": phone},
      );
      return response.data['results']['send'] == true;
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.error);
      }
      rethrow;
    }
  }

  /// Проверка кода авторизации.
  Future<Map<String, dynamic>> verifyAuthCode(String phone, int code) async {
    try {
      final response = await _dio.post(
        'auth/verify-code/',
        data: {"phone": phone, "code": code},
      );

      final data = response.data['results'];
      await TokenStorage().setTokens(
        data['access_token'],
        data['refresh_token'],
      );
      return data;
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.error);
      }
      rethrow;
    }
  }

  /// Обновление токенов.
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken = await TokenStorage().getRefreshToken();
      if (refreshToken == null) {
        throw Exception('Refresh token не найден');
      }

      final response = await _dio.post(
        'auth/refresh-token/',
        data: {"refresh_token": refreshToken},
      );

      final data = response.data['results'];
      await TokenStorage().setTokens(
        data['access_token'],
        data['refresh_token'],
      );
      return data;
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.error);
      }
      rethrow;
    }
  }

  /// 🔹 Логин через Google: получаем idToken и обмениваем на наши JWT
    /// 🔹 Логин через Google: получаем idToken и обмениваем на наши JWT
  Future<void> loginWithGoogle() async {
    await _ensureGoogleInitialized();

    // На всякий случай можно проверить поддержку (на web, desktop и т.п.)
    if (!_googleSignIn.supportsAuthenticate()) {
      throw Exception('Google Sign-In не поддерживается на этой платформе');
    }

    try {
      // 🔹 Стартуем интерактивный вход
      final GoogleSignInAccount account = await _googleSignIn.authenticate();

      // 🔹 Берём idToken для бэка
      final GoogleSignInAuthentication auth = account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        throw Exception('Не удалось получить idToken от Google');
      }

      final response = await _dio.post(
        'auth/google/login/',
        data: {'id_token': idToken},
      );

      final data = response.data['results'];

      await TokenStorage().setTokens(
        data['access_token'],
        data['refresh_token'],
      );
    } on GoogleSignInException catch (e) {
      // сюда можно повесить красивое сообщение, типа:
      // if (e.code == GoogleSignInErrorCode.canceled) ...
      rethrow;
    } catch (e) {
      rethrow;
    }
  }


  Future<bool> sendEmailCode(String email) async {
    try {
      final response = await _dio.post(
        'auth/email/send-code/',
        data: {"email": email},
      );

      return response.data['results']['send'] == true;
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.error);
      }
      rethrow;
    }
  }

  /// Подтверждение кода по email.
  Future<Map<String, dynamic>> verifyEmailCode(String email, int code) async {
    try {
      final response = await _dio.post(
        'auth/email/verify-code/',
        data: {"email": email, "code": code},
      );

      final data = response.data['results'];
      await TokenStorage().setTokens(
        data['access_token'],
        data['refresh_token'],
      );
      return data;
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.error);
      }
      rethrow;
    }
  }
}
