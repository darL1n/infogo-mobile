import 'dart:async';

import 'package:flutter/material.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final _controller = PageController();
  int _currentPage = 0;

  final _banners = [
    'https://dummyimage.com/400x150/ccddee/000000?text=Добро+пожаловать',
    'https://dummyimage.com/400x150/ddcccc/000000?text=Открой+новые+места',
    'https://dummyimage.com/400x150/ccccdd/000000?text=Посмотри+на+карте',
  ];

  @override
  void initState() {
    super.initState();
    // 🔁 Автопрокрутка каждые 4 секунды
    Future.microtask(() {
      Timer.periodic(const Duration(seconds: 4), (timer) {
        if (!mounted) return timer.cancel();
        final nextPage = (_currentPage + 1) % _banners.length;
        _controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _controller,
            itemCount: _banners.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return Center(
                child: SizedBox(
                  width: screenWidth - 32,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _banners[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 10 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? Colors.blueAccent : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
