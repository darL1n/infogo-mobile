import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/favorite_place.dart';
import 'package:go_router/go_router.dart';

class FavoritePlaceCard extends StatelessWidget {
  final FavoritePlaceModel favorite;

  const FavoritePlaceCard({super.key, required this.favorite});

  @override
  Widget build(BuildContext context) {
    final place = favorite.place;

    return InkWell(
      onTap: () => context.push('/place/${place.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),

              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: Image.network(
                place.mainImageUrl,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 40),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          '${place.averageRating.toStringAsFixed(1)} (${place.totalReviews})',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${place.city.name}, ${place.category.name}',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Добавлено: ${DateFormat('dd.MM.yyyy').format(favorite.addedAt)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
