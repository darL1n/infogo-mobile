import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/screens/news/news_screen.dart';
import 'package:provider/provider.dart';

import 'package:mobile/models/news.dart';
import 'package:mobile/providers/news_provider.dart';
import 'package:mobile/widgets/base_layout.dart';
import 'package:flutter_markdown/flutter_markdown.dart';


class NewsDetailScreen extends StatefulWidget {
  final int newsId;

  /// Необязательный превью-объект (из списка /news или главной),
  /// чтобы не мигало, пока грузим деталку
  final NewsModel? preview;

  const NewsDetailScreen({
    super.key,
    required this.newsId,
    this.preview,
  });

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  NewsDetailModel? _detail;
  bool _loading = false;
  String? _error;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) return;
    _requested = true;

    // грузим после первого кадра, чтобы не ловить setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prov = context.read<NewsProvider>();
      final detail = await prov.fetchDetail(widget.newsId);
      if (!mounted) return;
      setState(() {
        _detail = detail;
      });
    } catch (e, st) {
      debugPrint('❌ Ошибка загрузки новости: $e\n$st');
      if (!mounted) return;
      setState(() {
        _error = 'Не удалось загрузить новость';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _detail?.title ?? widget.preview?.title ?? 'Новость';

    return BaseLayout(
      title: title,
      showBackButton: true,
      fallbackRoute: '/news',
      currentIndex: 0,
      showBottomNavigation: false,
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
  final detail = _detail;
  final preview = widget.preview;
  final hasPreview = preview != null;

  // 1) Если есть ошибка и нет ни деталки, ни превью — показываем ошибку
  if (_error != null && detail == null && !hasPreview) {
    return _ErrorState(
      message: _error!,
      onRetry: _load,
    );
  }

  // 2) Ничего ещё не загрузили и превью тоже нет — просто лоадер
  if (detail == null && !hasPreview) {
    return const _FullPageLoader();
  }

  // 3) Здесь ГАРАНТИРОВАНО есть либо detail, либо preview
  final effectiveTitle = detail?.title ?? preview!.title;
  final category = detail?.categoryName ?? preview?.categoryName;
  final cityName = detail?.cityName ?? '';
  final placeName = detail?.placeName ?? preview?.placeName;
  final publishedAt = detail?.publishedAt ?? preview?.publishedAt;
  final isFeatured = detail?.isFeatured ?? preview?.isFeatured ?? false;
  final lead = detail?.lead ?? preview?.lead;
  final body = detail?.body ?? '';
  final image = detail?.image;

  // // если у тебя есть _getRelatedNews — оставляем как было
  // final related = _getRelatedNews(
  //   context,
  //   currentId: detail?.id ?? widget.newsId,
  //   category: category,
  // );

  return CustomScrollView(
    slivers: [
      SliverToBoxAdapter(
        child: _HeaderImageBlock(
          imageUrl: image,
          categoryName: category,
          cityName: cityName,
          placeName: placeName,
          publishedAt: publishedAt,
          isFeatured: isFeatured,
        ),
      ),
      SliverToBoxAdapter(
        child: _TitleBlock(
          title: effectiveTitle,
          lead: lead,
        ),
      ),
      SliverToBoxAdapter(
        child: _BodyBlock(body: body),
      ),
      // if (related.isNotEmpty)
      //   SliverToBoxAdapter(
      //     child: _RelatedNewsBlock(news: related),
      //   ),
      const SliverToBoxAdapter(
        child: SizedBox(height: 24),
      ),
    ],
  );
}

}


class _HeaderImageBlock extends StatelessWidget {
  final String? imageUrl;
  final String? categoryName;
  final String cityName;
  final String? placeName;
  final DateTime? publishedAt;
  final bool isFeatured;

  const _HeaderImageBlock({
    required this.imageUrl,
    required this.categoryName,
    required this.cityName,
    required this.placeName,
    required this.publishedAt,
    required this.isFeatured,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final dateLabel = formatNewsDateLabel(publishedAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Картинка / заглушка
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl != null && imageUrl!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: scheme.surfaceVariant.withValues(alpha: 0.6),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: scheme.surfaceVariant.withValues(alpha: 0.6),
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: scheme.outline,
                        size: 40,
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          scheme.primary.withValues(alpha: 0.20),
                          scheme.primary.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.article_rounded,
                      size: 64,
                      color: scheme.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),

                // затемняющий градиент снизу
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.40),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // метки поверх картинки
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (categoryName != null &&
                          categoryName!.trim().isNotEmpty)
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              categoryName!.trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: scheme.primary,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Главная новость',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // подписи под картинкой: город, место, дата
        Padding(
          padding:
              const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _MetaChip(
                icon: Icons.location_city_outlined,
                label: cityName,
              ),
              if (placeName != null && placeName!.trim().isNotEmpty)
                _MetaChip(
                  icon: Icons.place_outlined,
                  label: placeName!,
                ),
              if (dateLabel.isNotEmpty)
                _MetaChip(
                  icon: Icons.schedule_outlined,
                  label: dateLabel,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: scheme.outline.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}


class _TitleBlock extends StatelessWidget {
  final String title;
  final String? lead;

  const _TitleBlock({
    required this.title,
    this.lead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          if (lead != null && lead!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              lead!.trim(),
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.4,
                color: theme.textTheme.bodyLarge?.color
                    ?.withValues(alpha: 0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


class _BodyBlock extends StatelessWidget {
  final String body;

  const _BodyBlock({required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final text = body.trim();
    if (text.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Text(
          'Подробностей по этой новости пока нет.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      );
    }

    final baseSheet = MarkdownStyleSheet.fromTheme(theme);

    // базовые стили, которые точно не null
    final baseBody =
        theme.textTheme.bodyMedium ?? baseSheet.p ?? const TextStyle();

    final baseH1 = theme.textTheme.headlineSmall ??
        baseSheet.h1 ??
        const TextStyle(fontSize: 22, fontWeight: FontWeight.w700);

    final baseH2 = theme.textTheme.titleLarge ??
        baseSheet.h2 ??
        const TextStyle(fontSize: 20, fontWeight: FontWeight.w700);

    final baseH3 = theme.textTheme.titleMedium ??
        baseSheet.h3 ??
        const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: MarkdownBody(
        data: text,
        styleSheet: baseSheet.copyWith(
          // основной текст
          p: baseBody.copyWith(height: 1.5),
          // заголовки в тексте, если они есть
          h1: baseH1.copyWith(fontWeight: FontWeight.w700),
          h2: baseH2.copyWith(fontWeight: FontWeight.w700),
          h3: baseH3.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}



class _FullPageLoader extends StatelessWidget {
  const _FullPageLoader();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: scheme.primary,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 40,
              color: scheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.outline,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}

