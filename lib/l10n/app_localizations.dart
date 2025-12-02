import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Местный Гид'**
  String get appTitle;

  /// No description provided for @splash_title.
  ///
  /// In ru, this message translates to:
  /// **'Местный Гид'**
  String get splash_title;

  /// No description provided for @home_search_placeholder.
  ///
  /// In ru, this message translates to:
  /// **'Куда сходить сегодня?'**
  String get home_search_placeholder;

  /// Приветствие на главной
  ///
  /// In ru, this message translates to:
  /// **'Доброй ночи, {name} 👋'**
  String home_greeting_night(String name);

  /// Подзаголовок под приветствием, с названием города
  ///
  /// In ru, this message translates to:
  /// **'Сегодня в {city} — давай выберем, куда сходить?'**
  String home_hero_subtitle(String city);

  /// No description provided for @location_setup_title.
  ///
  /// In ru, this message translates to:
  /// **'Давайте настроим ваш город'**
  String get location_setup_title;

  /// No description provided for @location_setup_description.
  ///
  /// In ru, this message translates to:
  /// **'Чтобы показывать места рядом с вами, нам нужно знать ваш город. Вы можете разрешить определение по геолокации или выбрать город из списка.'**
  String get location_setup_description;

  /// No description provided for @location_setup_auto.
  ///
  /// In ru, this message translates to:
  /// **'Определить автоматически'**
  String get location_setup_auto;

  /// No description provided for @location_setup_auto_loading.
  ///
  /// In ru, this message translates to:
  /// **'Определяем город...'**
  String get location_setup_auto_loading;

  /// No description provided for @location_setup_manual_title.
  ///
  /// In ru, this message translates to:
  /// **'Или выберите город вручную'**
  String get location_setup_manual_title;

  /// No description provided for @location_setup_autodetect_failed_default.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось определить город автоматически. Выберите его вручную.'**
  String get location_setup_autodetect_failed_default;

  /// No description provided for @location_setup_autodetect_failed_reason.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось определить город: {reason}'**
  String location_setup_autodetect_failed_reason(String reason);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
