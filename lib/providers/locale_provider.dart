import 'package:flutter/material.dart';
import 'package:mobile/storages/hive_storage.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;
  bool get hasLocale => _locale != null;

  Future<void> loadLocale() async {
    final code = HiveStorage.getLocaleCode();
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
    }
    // если null — просто оставляем _locale = null (значит, язык ещё не выбран)
  }

  void setLocale(Locale locale) {
    _locale = locale;
    HiveStorage.saveLocaleCode(locale.languageCode);
    notifyListeners();
  }
}
