import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/map_place_card.dart';
import 'package:mobile/utils/image_path.dart';

class MapPlaceMainContent extends StatelessWidget {
  final MapPlaceCardModel place;
  final VoidCallback onRoutePressed;
  final VoidCallback? onOpenDetails;
  final VoidCallback? onClose;

  final VoidCallback? onShare;
  final VoidCallback? onToggleFavorite;
  final bool isFavorite;

  final bool showHandle;
  final bool showImage;
  final bool showDescription;
  final bool showActions;
  final EdgeInsetsGeometry padding;

  const MapPlaceMainContent({
    super.key,
    required this.place,
    required this.onRoutePressed,
    this.onOpenDetails,
    this.onClose,
    this.onShare,
    this.onToggleFavorite,
    this.isFavorite = false,
    this.showHandle = false,
    this.showImage = false,
    this.showDescription = false,
    this.showActions = true,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Собираем сырые урлы

    // 🔥 1) Берём только images; main — первым
    final sortedImages = [...place.images];
    sortedImages.sort((a, b) {
      if (a.isMain == b.isMain) return 0;
      return a.isMain ? -1 : 1; // main вверх
    });

    final imageUrls =
        sortedImages
            .map((img) => getFullImageUrl(img.image))
            .where((u) => u.isNotEmpty)
            .toList();

    final hasImage = showImage && imageUrls.isNotEmpty;
    final hasDescription =
        showDescription && (place.description ?? '').trim().isNotEmpty;

    final hasPhone = (place.contactPhone ?? '').trim().isNotEmpty;
    final hasWebsite = (place.website ?? '').trim().isNotEmpty;

    final hasDistance = place.distanceKm != null && place.distanceKm! > 0;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ───── хэндл ─────
          if (showHandle) ...[
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],

          // ───── заголовок + иконки ─────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  place.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // компактный ряд из иконок справа
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onShare != null)
                    _HeaderIconButton(
                      icon: Icons.ios_share_outlined,
                      onPressed: onShare!,
                    ),

                  if (onToggleFavorite != null) ...[
                    const SizedBox(width: 8),
                    _HeaderIconButton(
                      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                      onPressed: onToggleFavorite!,
                      color: isFavorite ? Colors.red : null,
                    ),
                  ],

                  if (onClose != null) ...[
                    const SizedBox(width: 8),
                    _HeaderIconButton(icon: Icons.close, onPressed: onClose!),
                  ],
                ],
              ),
            ],
          ),

          const SizedBox(height: 4),

          // ───── рейтинг + кол-во отзывов + расстояние ─────
          if (place.rating != null || hasDistance) ...[
            Row(
              children: [
                if (place.rating != null) ...[
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    place.rating!.toStringAsFixed(1),
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (place.totalReviews != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      '(${place.totalReviews})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
                if (hasDistance) ...[
                  if (place.rating != null) const SizedBox(width: 8),
                  Text(
                    '· ${place.distanceKm!.toStringAsFixed(place.distanceKm! >= 10 ? 0 : 1)} км',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
          ],

          // 🔹 Категория под рейтингом
          if ((place.categoryName ?? '').isNotEmpty) ...[
            Text(
              place.categoryName!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // 🔹 Статус работы (как в Google Maps)
          if ((place.workStatusPrimary ?? '').isNotEmpty) ...[
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: place.isOpenNow == true ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  place.workStatusPrimary!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        place.isOpenNow == true
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if ((place.workStatusSecondary ?? '').isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                place.workStatusSecondary!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],

          // ───── адрес под заголовком ─────
          // if (place.address != null && place.address!.isNotEmpty) ...[
          //   Text(
          //     place.address!,
          //     style: theme.textTheme.bodySmall?.copyWith(
          //       color: Colors.grey[600],
          //     ),
          //     maxLines: 2,
          //     overflow: TextOverflow.ellipsis,
          //   ),
          //   const SizedBox(height: 12),
          // ],

          // ───── большой фотоблок ─────
          if (hasImage) ...[
            _BigGallery(imageUrls: imageUrls, onTap: onOpenDetails),
            const SizedBox(height: 16),
          ],

          // ───── кнопки действий (верхние, как в Google Maps) ─────
          if (showActions) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onRoutePressed,
                    icon: const Icon(Icons.directions),
                    label: const Text('Маршрут'),
                  ),
                ),
                const SizedBox(width: 8),
                if (onOpenDetails != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onOpenDetails,
                      child: const Text('Открыть место'),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // ───── блоки-инфокарточки, как на скрине ─────
          if (hasPhone || hasWebsite) ...[
            _InfoSectionTitle(title: 'Информация'),
            const SizedBox(height: 8),
          ],

          if (hasPhone)
            _InfoCardRow(
              icon: Icons.phone,
              title: place.contactPhone!,
              subtitle: 'Телефон',
              onTap: () {
                // по желанию можно сразу дернуть звонок через url_launcher
              },
            ),

          if (hasWebsite)
            _InfoCardRow(
              icon: Icons.language,
              title: place.website!,
              subtitle: 'Сайт',
              onTap: () {
                // по желанию открыть сайт
              },
            ),

          if (hasDescription) ...[
            const SizedBox(height: 16),
            _InfoSectionTitle(title: 'О месте'),
            const SizedBox(height: 4),
            Text(
              place.description!.trim(),
              style: theme.textTheme.bodyMedium,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Большой фотоблок: слева большая, справа 1–2 маленьких (как у Google Maps)
class _BigGallery extends StatelessWidget {
  final List<String> imageUrls;
  final VoidCallback? onTap;

  const _BigGallery({required this.imageUrls, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final first = imageUrls.first;
    final others = imageUrls.skip(1).take(2).toList();

    Widget buildImage(String url) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, _) => Container(color: Colors.grey.shade200),
          errorWidget:
              (context, _, __) => Container(
                color: Colors.grey.shade300,
                child: Icon(
                  Icons.image_not_supported,
                  size: 18,
                  color: theme.disabledColor,
                ),
              ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Row(
          children: [
            // большая слева
            Expanded(flex: 2, child: buildImage(first)),
            if (others.isNotEmpty) ...[
              const SizedBox(width: 4),
              // две маленьких справа столбиком
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: buildImage(others[0])),
                    if (others.length > 1) ...[
                      const SizedBox(height: 4),
                      Expanded(child: buildImage(others[1])),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Заголовок блока ("Информация", "О месте")
class _InfoSectionTitle extends StatelessWidget {
  final String title;

  const _InfoSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

/// Строка-карточка с иконкой, заголовком и подзаголовком
class _InfoCardRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _InfoCardRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.bodyMedium),
              if (subtitle != null && subtitle!.isNotEmpty)
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child:
          onTap != null
              ? InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: content,
              )
              : content,
    );
  }
}
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceVariant.withOpacity(0.9),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Icon(
              icon,
              size: 22,
              color: color ?? theme.iconTheme.color,
            ),
          ),
        ),
      ),
    );
  }
}
