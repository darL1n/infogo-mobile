// place_image_gallery.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/models/place_detail.dart';
import 'package:shimmer/shimmer.dart';

class PlaceImageCarousel extends StatefulWidget {
  final List<PlaceImage> images;

  const PlaceImageCarousel({super.key, required this.images});

  @override
  State<PlaceImageCarousel> createState() => _PlaceImageCarouselState();
}

class _PlaceImageCarouselState extends State<PlaceImageCarousel> {
  int _currentIndex = 0;
  late List<PlaceImage> _sortedImages;

  @override
  void initState() {
    super.initState();
    _sortImages();
  }

  @override
  void didUpdateWidget(covariant PlaceImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.images != widget.images) {
      _sortImages();
    }
  }

  void _sortImages() {
    _sortedImages = List.of(widget.images);
    _sortedImages.sort((a, b) {
      if (a.isMain && !b.isMain) return -1;
      if (!a.isMain && b.isMain) return 1;
      return 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_sortedImages.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('Нет фотографий')),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 240,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                itemCount: _sortedImages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final image = _sortedImages[index];
                  return GestureDetector(
                    onTap: () => _openFullscreenGallery(
                      context,
                      _sortedImages,
                      index,
                    ),
                    child: Hero(
                      tag: image.imageUrl,
                      child: CachedNetworkImage(
                        imageUrl: image.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(color: Colors.white),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image),
                      ),
                    ),
                  );
                },
              ),

              // индикаторы
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_sortedImages.length, (index) {
                    final isActive = _currentIndex == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isActive ? 10 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant
                                .withOpacity(0.6),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFullscreenGallery(
    BuildContext context,
    List<PlaceImage> images,
    int initialIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullscreenGallery(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}


class FullscreenGallery extends StatefulWidget {
  final List<PlaceImage> images;
  final int initialIndex;

  const FullscreenGallery({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<FullscreenGallery> {
  late final PageController _pageController;
  late int _currentIndex;
  double _verticalDrag = 0;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Обновляем вертикальный драг и вычисляем непрозрачность для плавного эффекта исчезновения
  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _verticalDrag += details.primaryDelta ?? 0;
      _opacity = (1 - (_verticalDrag.abs() / 300)).clamp(0.5, 1.0);
    });
  }

  // При окончании драг-жеста проверяем, достигнут ли порог для закрытия
  void _handleDragEnd(DragEndDetails details) {
    if (_verticalDrag > 100) {
      Navigator.pop(context);
    } else {
      setState(() {
        _verticalDrag = 0;
        _opacity = 1.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(_opacity),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        title: Text(
          '${_currentIndex + 1} из ${widget.images.length}',
          style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        centerTitle: true,
        
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        
      ),
      body: GestureDetector(
        onVerticalDragUpdate: _handleDragUpdate,
        onVerticalDragEnd: _handleDragEnd,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _opacity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final image = widget.images[index];
              return Center(
                child: Hero(
                  tag: image.imageUrl,
                  child: CachedNetworkImage(
                    imageUrl: image.imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: double.infinity,
                        height: 250,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image, color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
