import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/history_view_place.dart';

class HistoryPlaceCard extends StatelessWidget {
  final HistroyViewPlaceModel history;

  const HistoryPlaceCard({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final place = history.place;

    return InkWell(
      onTap: () => context.push('/place/${place.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 Картинка
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                place.mainImageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 160,
                  child: Center(child: Icon(Icons.image, size: 40)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 📍 Название
            Text(
              place.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            // 🧠 Категория + Город
            Text(
              '${place.category.name} · ${place.city.name}',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 6),
            // ⭐ Рейтинг
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  '${place.averageRating.toStringAsFixed(1)} (${place.totalReviews})',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // 👁 Просмотрено
            Row(
              children: [
                const Icon(Icons.remove_red_eye, size: 16, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Text(
                  'Просмотрено: ${DateFormat('dd.MM.yyyy').format(history.viewedAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
