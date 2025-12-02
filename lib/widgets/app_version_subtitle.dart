// lib/widgets/app_version_subtitle.dart
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionSubtitle extends StatelessWidget {
  const AppVersionSubtitle({super.key});

  static final Future<PackageInfo> _infoFuture =
      PackageInfo.fromPlatform(); // кешируем future

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<PackageInfo>(
      future: _infoFuture,
      builder: (context, snapshot) {
        final baseStyle = theme.textTheme.bodySmall;

        if (snapshot.connectionState != ConnectionState.done ||
            !snapshot.hasData) {
          // запасной вариант, пока грузится или ошибка
          return Text(
            'InfoGo',
            style: baseStyle,
          );
        }

        final info = snapshot.data!;
        final versionText = 'InfoGo • v${info.version}';

        // если хочешь ещё и билд:
        // final versionText = 'Местный Гид • v${info.version} (${info.buildNumber})';

        return Text(
          versionText,
          style: baseStyle,
        );
      },
    );
  }
}
