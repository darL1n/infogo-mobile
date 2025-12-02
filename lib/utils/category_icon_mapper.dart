import 'package:flutter/material.dart';

final Map<String, IconData> categoryIcons = {
  // ==== ВЕРХНИЙ УРОВЕНЬ (root categories) ====

  'food': Icons.restaurant_menu,          // Еда и напитки
  'entertainment_root': Icons.movie,      // Развлечения (root)
  'nightlife_root': Icons.nightlife,      // Ночная жизнь (root)
  'outdoor': Icons.park,                  // Прогулки и парки
  'culture': Icons.museum,                // Культура и искусство
  'sport_activity': Icons.fitness_center, // Спорт и активный отдых
  'kids_root': Icons.family_restroom,     // Для детей
  'beauty_health': Icons.spa,             // Красота и здоровье
  'shopping_root': Icons.shopping_bag,    // Шопинг
  'travel_stay': Icons.travel_explore,    // Жильё и путешествия
  'services_root': Icons.handyman,        // Сервисы, коворкинги
  'education_root': Icons.school,         // Образование
  'auto_root': Icons.directions_car,      // Авто
  'gov_root': Icons.account_balance,      // Госуслуги / клиники

  // ==== ПОДКАТЕГОРИИ (часть уже есть, часть добавим) ====

  // Еда
  'restaurants': Icons.restaurant_menu,
  'cafes_coffeeshops': Icons.local_cafe,
  'fast_food': Icons.fastfood,
  'street_food': Icons.lunch_dining,
  'bakeries': Icons.bakery_dining,
  'teahouses': Icons.local_drink,
  'shashlik': Icons.outdoor_grill,
  'lounges': Icons.weekend,
  'desserts_sweets': Icons.icecream,
  'delivery_only': Icons.delivery_dining,

  // Развлечения
  'cinema': Icons.movie,
  'karaoke': Icons.mic,
  'game_centers': Icons.sports_esports,
  'bowling': Icons.sports_baseball,
  'billiards': Icons.sports_basketball,
  'quests': Icons.psychology,
  'vr_clubs': Icons.vrpano,
  'boardgames_cafes': Icons.groups_2,
  'amusement_parks': Icons.attractions,

  // Ночная жизнь
  'bars': Icons.local_bar,
  'pubs': Icons.liquor,
  'night_clubs': Icons.nightlife,
  'rooftops': Icons.roofing,
  'wine_bars': Icons.wine_bar,
  'hookah_bars': Icons.smoking_rooms,

  // Прогулки
  'city_parks': Icons.park,
  'squares': Icons.crop_square,
  'boulevards': Icons.route,
  'embankments': Icons.water,
  'botanical_gardens': Icons.local_florist,
  'viewpoints': Icons.landscape,
  'nature_spots': Icons.terrain,

  // Культура
  'museums': Icons.museum,
  'galleries': Icons.brush,
  'theaters': Icons.theaters,
  'concert_halls': Icons.audiotrack,
  'historical_sites': Icons.account_balance,
  'monuments': Icons.assistant_photo,
  'libraries': Icons.menu_book,

  // Спорт
  'fitness_clubs': Icons.fitness_center,
  'yoga_pilates': Icons.self_improvement,
  'swimming_pools': Icons.pool,
  'football_fields': Icons.sports_soccer,
  'gyms': Icons.sports_gymnastics,
  'skate_parks': Icons.skateboarding,
  'rope_parks': Icons.hub,
  'karting': Icons.sports_motorsports,
  'ice_rinks': Icons.ac_unit,
  'shooting_ranges': Icons.sports_martial_arts,
  'paintball_lasertag': Icons.sports_kabaddi,

  // Дети
  'kids_playgrounds': Icons.toys,
  'kids_centers': Icons.celebration,
  'kids_education': Icons.escalator_warning,
  'kids_events': Icons.emoji_events,
  'zoos': Icons.pets,
  'aquaparks': Icons.water,
  'kids_parks': Icons.park,

  // Красота и здоровье
  'beauty_salons': Icons.spa,
  'barbershops': Icons.content_cut,
  'spa_centers': Icons.spa,
  'massage': Icons.self_improvement,
  'nail_bars': Icons.back_hand,
  'cosmetology': Icons.science,

  // Шопинг
  'malls': Icons.store_mall_directory,
  'boutiques': Icons.checkroom,
  'markets': Icons.storefront,
  'souvenirs': Icons.card_giftcard,
  'food_markets': Icons.local_grocery_store,
  'electronics_shops': Icons.devices,
  'home_goods': Icons.chair_alt,

  // Жильё / travel
  'hotels': Icons.hotel,
  'hostels': Icons.bed,
  'guest_houses': Icons.house,
  'apartments': Icons.apartment,
  'tour_agencies': Icons.card_travel,

  // Сервисы / коворкинг
  'coworking': Icons.meeting_room,
  'photo_studios': Icons.photo_camera,
  'education_centers': Icons.school,
  'event_spaces': Icons.event,
  'conference_halls': Icons.meeting_room,

  // Авто
  'car_services': Icons.handyman,
  'car_wash': Icons.local_car_wash,
  'gas_station': Icons.local_gas_station,
  'car_dealerships': Icons.directions_car,
  'tire_fitting': Icons.build,
  'car_rental': Icons.car_rental,

  // Гос/медицина
  'government_services': Icons.account_balance,
  'public_service_centers': Icons.people,
  'hospitals_clinics': Icons.local_hospital,
  'private_clinics': Icons.medical_services,
  'diagnostic_centers': Icons.biotech,

  // + твои старые ключи (entertainment, restaurants_cafe, shopping, travel_explore, cars, education, government_institutions, и т.д.)
  // ...

  // Fallback
  'default': Icons.category,
};
