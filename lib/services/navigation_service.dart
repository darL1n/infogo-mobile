// services/navigation_service.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:map_launcher/map_launcher.dart' as ml;
import 'package:flutter_svg/flutter_svg.dart';

class NavigationService {
  NavigationService._();

  static Future<void> openRoute({
    required double latitude,
    required double longitude,
    String? label,
    BuildContext? context,
  }) async {
    final title = (label ?? '').trim().isNotEmpty ? label!.trim() : 'Маршрут';

    try {
      final maps = await ml.MapLauncher.installedMaps;

      if (context != null && maps.isNotEmpty) {
        await showModalBottomSheet(
          context: context,
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    'Открыть маршрут в',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ...maps.map(
                  (m) => ListTile(
                    leading: SizedBox(
                      width: 28,
                      height: 28,
                      child: m.icon.toLowerCase().endsWith('.svg')
                          ? SvgPicture.asset(
                              m.icon,
                              fit: BoxFit.contain,
                            )
                          : Image.asset(
                              m.icon,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.map);
                              },
                            ),
                    ),
                    title: Text(m.mapName),
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      await m.showDirections(
                        destination: ml.Coords(latitude, longitude),
                        destinationTitle: title,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
        return;
      }

      // фолбек на Google Maps в браузере
      final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=$latitude,$longitude',
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }

      throw Exception('Нет подходящих приложений');
    } catch (e, st) {
      debugPrint('NavigationService.openRoute error: $e\n$st');
      throw Exception('Не удалось открыть картографическое приложение');
    }
  }
}