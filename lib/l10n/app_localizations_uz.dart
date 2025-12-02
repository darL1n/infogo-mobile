// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'Mahalliy Gid';

  @override
  String get splash_title => 'Mahalliy Gid';

  @override
  String get home_search_placeholder => 'Bugun qayerga boramiz?';

  @override
  String home_greeting_night(String name) {
    return 'Xayrli tun, $name 👋';
  }

  @override
  String home_hero_subtitle(String city) {
    return 'Bugun $city shahrida — qayerga boramiz?';
  }

  @override
  String get location_setup_title => 'Keling, shahringizni tanlaymiz';

  @override
  String get location_setup_description =>
      'Yaqiningizdagi joylarni ko‘rsatish uchun shahringizni bilishimiz kerak. Geolokatsiyani yoqishingiz yoki ro‘yxatdan tanlashingiz mumkin.';

  @override
  String get location_setup_auto => 'Avtomatik aniqlash';

  @override
  String get location_setup_auto_loading => 'Shahar aniqlanmoqda...';

  @override
  String get location_setup_manual_title =>
      'Yoki shaharingizni ro‘yxatdan tanlang';

  @override
  String get location_setup_autodetect_failed_default =>
      'Shaharni avtomatik aniqlab bo‘lmadi. Iltimos, ro‘yxatdan tanlang.';

  @override
  String location_setup_autodetect_failed_reason(String reason) {
    return 'Shaharni aniqlash imkoni bo‘lmadi: $reason';
  }
}
