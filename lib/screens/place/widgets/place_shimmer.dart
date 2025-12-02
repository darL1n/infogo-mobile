import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PlaceDetailShimmer extends StatelessWidget {
  const PlaceDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // hero
            Container(width: double.infinity, height: 250, color: Colors.white),
            const SizedBox(height: 16),

            // заголовок
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(width: 200, height: 20, color: Colors.white),
            ),
            const SizedBox(height: 8),

            // подзаголовок
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(width: 150, height: 16, color: Colors.white),
            ),
            const SizedBox(height: 16),

            // строки текста
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      width: double.infinity,
                      height: 14,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            // кнопки
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(child: Container(height: 50, color: Colors.white)),
                  const SizedBox(width: 12),
                  Expanded(child: Container(height: 50, color: Colors.white)),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
