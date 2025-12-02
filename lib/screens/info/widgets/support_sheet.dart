// lib/screens/profile/support_sheet.dart
import 'package:flutter/material.dart';
import 'package:mobile/utils/support_utils.dart';

void showSupportSheet(BuildContext context) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;

  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    useSafeArea: true, // можно оставить
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final bottomInset = MediaQuery.of(ctx).padding.bottom;

      return Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          20 + bottomInset, // 👈 учитываем safe area снизу
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Написать в поддержку',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Опишите проблему, мы постараемся ответить в течение 1–2 рабочих дней.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.outline,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: scheme.surfaceVariant.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.send_rounded),
                    title: const Text('Написать в Telegram'),
                    subtitle: const Text('@InfoGO_official'),
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      await SupportUtils.openTelegram(context);
                    },
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Написать на email'),
                    subtitle: const Text('support@infogo.uz'),
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      await SupportUtils.openEmail(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
