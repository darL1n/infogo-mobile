import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/place.dart';

class PlaceCard extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback onTap;

  const PlaceCard({
    super.key,
    required this.place,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardRadius = BorderRadius.circular(16);

    return Card(
      color: theme.cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Картинка + градиент + название
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: place.mainImageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[300]),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[400],
                      child: const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 52,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black54],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 12,
                  right: 12,
                  child: Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Инфо-блок
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${place.city.name}, ${place.address}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.amber[400],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${place.averageRating}',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${place.totalReviews})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
