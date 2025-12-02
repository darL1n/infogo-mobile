import 'package:flutter/material.dart';

const _primaryColor   = Color(0xFF2FB7C8); // бирюзово-синий (акцент)
const _secondaryColor = Color(0xFFFFC857); // тёплый жёлто-оранжевый
const _bgColor        = Color(0xFFF5F5F7); // светлый фон (почти белый)
const _cardColor      = Colors.white;

final ThemeData appTheme = ThemeData(
  useMaterial3: true, // можно убрать, если не хочешь M3

  // 🌈 Цветовая схема
  colorScheme: ColorScheme.fromSeed(
    seedColor: _primaryColor,
    primary: _primaryColor,
    secondary: _secondaryColor,
    surface: _cardColor,
  ),

  scaffoldBackgroundColor: _bgColor,
  cardColor: _cardColor,

  // ⚙️ Плотность
  visualDensity: VisualDensity.adaptivePlatformDensity,

  // 🔹 AppBar — белый, без тяжёлой тени
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: _cardColor,
    foregroundColor: Colors.black87,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
  ),

  // 🔹 Карточки (PlaceCard, блоки на главной)
  cardTheme: CardThemeData(
    color: _cardColor,
    elevation: 4,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),

  // 🔹 BottomNavigationBar
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: _cardColor,
    selectedItemColor: _primaryColor,
    unselectedItemColor: Colors.grey[500],
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),

  // 🔹 Чипы (фильтры, теги)
  chipTheme: ChipThemeData(
    backgroundColor: Colors.white,
    selectedColor: _primaryColor.withOpacity(0.12),
    disabledColor: Colors.grey[200],
    labelStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    ),
    secondaryLabelStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    shape: StadiumBorder(
      side: BorderSide(color: Colors.grey[300]!),
    ),
    brightness: Brightness.light,
  ),

  // 🔹 Текст
  textTheme: ThemeData.light().textTheme.copyWith(
    titleLarge: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
    bodyMedium: const TextStyle(
      fontSize: 14,
      color: Colors.black87,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: Colors.grey[600],
    ),
  ),

  // 🔹 Инпуты (поиск, логин и т.п.)
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.red.shade700, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.red.shade700, width: 2),
    ),
    errorStyle: TextStyle(
      color: Colors.red.shade700,
      fontWeight: FontWeight.w600,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),

  // 🔹 Иконки (как у тебя было – без лишнего сплэша)
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: WidgetStateProperty.all(EdgeInsets.zero),
    ),
  ),
);
