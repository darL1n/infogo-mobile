// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Местный Гид';

  @override
  String get splash_title => 'Местный Гид';

  @override
  String get home_search_placeholder => 'Куда сходить сегодня?';

  @override
  String home_greeting_night(String name) {
    return 'Доброй ночи, $name 👋';
  }

  @override
  String home_hero_subtitle(String city) {
    return 'Сегодня в $city — давай выберем, куда сходить?';
  }

  @override
  String get location_setup_title => 'Давайте настроим ваш город';

  @override
  String get location_setup_description =>
      'Чтобы показывать места рядом с вами, нам нужно знать ваш город. Вы можете разрешить определение по геолокации или выбрать город из списка.';

  @override
  String get location_setup_auto => 'Определить автоматически';

  @override
  String get location_setup_auto_loading => 'Определяем город...';

  @override
  String get location_setup_manual_title => 'Или выберите город вручную';

  @override
  String get location_setup_autodetect_failed_default =>
      'Не удалось определить город автоматически. Выберите его вручную.';

  @override
  String location_setup_autodetect_failed_reason(String reason) {
    return 'Не удалось определить город: $reason';
  }
}
