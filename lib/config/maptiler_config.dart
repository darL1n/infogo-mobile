class MapTilerConfig {
  // TODO: положи ключ в .env/secure storage,
  // тут для простоты — хардкод.
  static const String apiKey = 'X4zUPfHlUU7JiKWdVw9u';

  // streets-v4 или streets-v2 — что ты выбрал в MapTiler
  static const String tilesUrl =
      // 'https://api.maptiler.com/maps/streets-v4/256/{z}/{x}/{y}.png?key=$apiKey';
      // 'https://api.maptiler.com/maps/streets-v4/{z}/{x}/{y}.png?key=$apiKey';
      // 'https://api.maptiler.com/maps/streets-v4/{z}/{x}/{y}.png?key=$apiKey';
      // 'https://api.maptiler.com/maps/019ac9b5-cae0-714c-aee9-2b65a153b470/{z}/{x}/{y}.jpg?key=$apiKey';
      'https://api.maptiler.com/maps/019ac9b5-cae0-714c-aee9-2b65a153b470/{z}/{x}/{y}@2x.jpg?key=$apiKey';
}
