import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/models/place_detail.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/screens/place/widgets/review_form_widget.dart';
import 'package:provider/provider.dart';

class ReviewsWidget extends StatelessWidget {
  final PlaceDetailModel place;
  final int maxVisibleReviews;

  const ReviewsWidget({
    super.key,
    required this.place,
    this.maxVisibleReviews = 4, // можно потом крутить
  });

  void _openReviewForm(BuildContext context) {
    final isAuthenticated = context.read<UserProvider>().isAuthenticated;

    if (!isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Войдите, чтобы оставить отзыв'),
          action: SnackBarAction(
            label: 'Войти',
            onPressed: () => context.push('/login'),
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => ReviewFormWidget(placeId: place.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reviews = place.reviews;
    final hasReviews = reviews.isNotEmpty;

    double? avgRating;
    if (hasReviews) {
      final sum = reviews.fold<double>(
        0,
        (prev, r) => prev + (r.rating.toDouble()),
      );
      avgRating = sum / reviews.length;
    }

    final visible = hasReviews
        ? reviews.take(maxVisibleReviews).toList()
        : const [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── заголовок + кнопка ────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Отзывы',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (hasReviews && avgRating != null)
                        Row(
                          children: [
                            _RatingStars(
                              rating: avgRating,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${avgRating.toStringAsFixed(1)} • ${reviews.length} отзыв${_plural(reviews.length)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withOpacity(0.75),
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          'Пока никто не делился впечатлениями',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.75),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: () => _openReviewForm(context),
                  icon: const Icon(Icons.rate_review_outlined, size: 18),
                  label: const Text('Оставить'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── содержимое ────────────────────────────────────────
            if (!hasReviews)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Пока нет отзывов — будьте первым и расскажите о месте 🙂',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.85),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  for (final review in visible)
                    _ReviewCard(
                      review: review,
                    ),
                  if (reviews.length > visible.length)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Показаны последние ${visible.length} из ${reviews.length} отзыв${_plural(reviews.length)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.6),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _plural(int count) {
    // простое склонение "отзывов"
    final mod10 = count % 10;
    final mod100 = count % 100;
    if (mod10 == 1 && mod100 != 11) return '';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) {
      return 'а';
    }
    return 'ов';
  }
}

String formatReviewDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inMinutes < 1) return 'Только что';
  if (diff.inMinutes < 60) return '${diff.inMinutes} мин назад';
  if (diff.inHours < 24) return '${diff.inHours} ч назад';
  if (diff.inDays == 1) return 'Вчера';
  if (diff.inDays < 7) return '${diff.inDays} дн назад';

  if (now.year == date.year) {
    return '${date.day} ${_monthShortName(date.month)}';
  }

  // если год другой — покажем полностью
  return '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';
}

String _monthShortName(int month) {
  const names = [
    'янв',
    'фев',
    'мар',
    'апр',
    'май',
    'июн',
    'июл',
    'авг',
    'сен',
    'окт',
    'ноя',
    'дек',
  ];
  if (month < 1 || month > 12) return '';
  return names[month - 1];
}


// ───────────────── карточка одного отзыва ─────────────────

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 👇 имя / аватар
    final reviewer = review.reviewer;
    final fullName = reviewer.fullName; // учитываем fullName
    final displayName = (fullName != null && fullName.trim().isNotEmpty)
        ? fullName.trim()
        : 'Пользователь';

    final avatarUrl = reviewer.avatar;

    // 👇 красивая подпись даты
    final createdAt = review.createdAt; // DateTime
    final dateLabel = formatReviewDate(createdAt);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.4),
          width: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // верхняя строка: аватар + имя + рейтинг + дата
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    theme.colorScheme.primary.withOpacity(0.08),
                backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? CachedNetworkImageProvider(
                        avatarUrl,
                        headers: const {'User-Agent': 'Mozilla/5.0'},
                      )
                    : null,
                child: (avatarUrl == null || avatarUrl.isEmpty)
                    ? Icon(
                        Icons.person,
                        size: 18,
                        color:
                            theme.colorScheme.onSurface.withOpacity(0.7),
                      )
                    : null,
              ),
              const SizedBox(width: 10),

              // имя + рейтинг
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _RatingStars(
                          rating: review.rating.toDouble(),
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          review.rating.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 👈 справа компактная дата
              const SizedBox(width: 8),
              Text(
                dateLabel,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // текст отзыва
          Text(
            review.comment,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ───────────────── виджет звёздочек ─────────────────

class _RatingStars extends StatelessWidget {
  final double rating; // 0..5
  final double size;
  final Color? color;

  const _RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;

    final filledStars = rating.floor();
    final hasHalf = (rating - filledStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData icon;
        if (index < filledStars) {
          icon = Icons.star_rounded;
        } else if (index == filledStars && hasHalf) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }

        return Padding(
          padding: const EdgeInsets.only(right: 1),
          child: Icon(
            icon,
            size: size,
            color: c,
          ),
        );
      }),
    );
  }
}
