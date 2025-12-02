import 'package:dio/dio.dart';
import 'package:mobile/config/app_config.dart';

const String baseUrl = AppConfig.baseUrl; // 🔥 Укажи свой `baseUrl`

String getFullImageUrl(String? url) {
  if (url == null || url.isEmpty) {
    // return "$baseUrl/media/images/default.png"; // ✅ Заглушка, если URL пустой
    return '';
  }
  if (url.startsWith("http")) {
    return url; // ✅ Если URL уже полный, не меняем
  }
  return "$baseUrl$url"; // ✅ Добавляем `baseUrl`, если его нет
}


Future<void> fetchImageBytes(String url) async {
  try {
    final response = await Dio().get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    print('Content-Type: ${response.headers.value("content-type")}');
    print('Длина данных: ${response.data.length}');
  } catch (e) {
    print('Ошибка загрузки: $e');
  }
}