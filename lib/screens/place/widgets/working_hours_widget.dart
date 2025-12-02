// working_hours_widget.dart

import 'package:flutter/material.dart';
import 'package:mobile/models/place_detail.dart';

class WorkingHoursWidget extends StatelessWidget {
  final PlaceDetailModel place;

  const WorkingHoursWidget({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    if (place.workingHours.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final rows = place.workingHours.map((day) {
      final isToday = _isToday(day.dayOfWeek);
      final textStyle = theme.textTheme.bodyMedium?.copyWith(
        fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
      );
      final timeStyle = theme.textTheme.bodyMedium?.copyWith(
        color: isToday ? scheme.primary : null,
      );

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_dayName(day.dayOfWeek), style: textStyle),
            Text(
              day.isClosed
                  ? 'Выходной'
                  : '${_formatTime(day.openTime)} — ${_formatTime(day.closeTime)}',
              style: timeStyle,
            ),
          ],
        ),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Режим работы',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            ...rows,
          ],
        ),
      ),
    );
  }

  bool _isToday(String day) {
    final now = DateTime.now();
    final todayName = _dayName(now.weekday.toString());
    return _dayName(day) == todayName;
  }

  String _dayName(String day) {
    const days = {
      "monday": "Понедельник",
      "tuesday": "Вторник",
      "wednesday": "Среда",
      "thursday": "Четверг",
      "friday": "Пятница",
      "saturday": "Суббота",
      "sunday": "Воскресенье",
      "1": "Понедельник",
      "2": "Вторник",
      "3": "Среда",
      "4": "Четверг",
      "5": "Пятница",
      "6": "Суббота",
      "7": "Воскресенье",
    };
    return days[day.toLowerCase()] ?? day;
  }

  String _formatTime(String? time) {
    if (time == null) return "—";
    return time.substring(0, 5);
  }
}
