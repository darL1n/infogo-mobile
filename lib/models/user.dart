import 'package:hive/hive.dart';
import 'package:mobile/utils/image_path.dart';

part 'user.g.dart'; // 🔥 ОБЯЗАТЕЛЬНО добавить!

@HiveType(typeId: 1) // ✅ Уникальный идентификатор модели в Hive
class UserModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String phone;

  @HiveField(2)
  final int? telegramId;

  @HiveField(3)
  final UserProfile profile;

  UserModel({
    required this.id,
    required this.phone,
    this.telegramId,
    required this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"] ?? 0,
      phone: json["phone"] ?? "",
      telegramId: json["telegram_id"],
      profile: UserProfile.fromJson(json["profile"] ?? {}),
    );
  }
}

@HiveType(typeId: 2) // ✅ Уникальный typeId для вложенной модели
class UserProfile extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String avatar;

  @HiveField(2)
  final int cityId;

  @HiveField(3)
  final String language;

  @HiveField(4)
  final String? fullName;
  UserProfile({
    required this.id,
    required this.avatar,
    required this.cityId,
    required this.language,
    required this.fullName
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final rawAvatar = json["avatar"] as String?;
    return UserProfile(
      id: json["id"] ?? 0,
      avatar: getFullImageUrl(rawAvatar),
      cityId: json["city"]?["id"] ?? 0,
      language: json["language"] ?? "ru",
      fullName: json['full_name'] ?? ""
    );
  }
}
