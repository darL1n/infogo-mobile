// lib/utils/support_utils.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportUtils {
  // static const _supportEmail = 'support@infogo.uz';
  static const _supportEmail = 'infogouzbekistan@gmail.com';
  static const _telegramUsername = 'InfoGO_official'; // поменяешь на свой

  static Future<String> _buildTechInfo() async {
    final info = await PackageInfo.fromPlatform();
    final platform = kIsWeb
        ? 'Web'
        : Platform.isAndroid
            ? 'Android'
            : Platform.isIOS
                ? 'iOS'
                : Platform.operatingSystem;

    return '''
---
Тех. информация:
Приложение: InfoGo
Версия: ${info.version} (${info.buildNumber})
Платформа: $platform
''';
  }

  static Future<void> openEmail(BuildContext context) async {
    final tech = await _buildTechInfo();

    final subject = Uri.encodeComponent('Обращение в поддержку InfoGo');
    final body = Uri.encodeComponent(
      'Опишите, что произошло, и какие действия вы выполняли:\n\n$tech',
    );

    final uri = Uri.parse('mailto:$_supportEmail?subject=$subject&body=$body');

    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть почтовое приложение')),
      );
    }
  }

  static Future<void> openTelegram(BuildContext context) async {
    final tgLink = 'https://t.me/$_telegramUsername';
    final uri = Uri.parse(tgLink);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть Telegram')),
      );
    }
  }
}
