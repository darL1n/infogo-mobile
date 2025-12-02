import 'package:url_launcher/url_launcher.dart';

class UrlHelper {
  static Future<void> launchPhoneCall(String phone) async {
    final uri = Uri.parse("tel:$phone");
    if (!await launchUrl(uri)) {
      throw "Не удалось совершить звонок";
    }
  }

  static Future<void> launchWebsite(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw "Не удалось открыть сайт: $url";
    }
  }

  static Future<void> openMap(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      throw "Не удалось открыть карту";
    }
  }
}
