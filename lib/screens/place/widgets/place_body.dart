// place_body.dart

import 'package:flutter/material.dart';
import 'package:mobile/models/place_detail.dart';
import 'package:mobile/screens/place/widgets/place_image_gallery.dart';
import 'package:mobile/screens/place/widgets/place_info.dart';
import 'package:mobile/screens/place/widgets/place_sections_widget.dart';
import 'package:mobile/screens/place/widgets/working_hours_widget.dart';
import 'package:mobile/screens/place/widgets/reviews_widget.dart';
import 'package:mobile/screens/place/widgets/place_quick_actions.dart';
import 'package:mobile/screens/place/widgets/place_map_section.dart';
import 'package:mobile/screens/place/widgets/place_events_section_place.dart';

class PlaceDetailBody extends StatelessWidget {
  final PlaceDetailModel place;

  const PlaceDetailBody({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Hero / галерея
        SliverToBoxAdapter(
          child: PlaceImageCarousel(images: place.images),
        ),

        // Инфо-карточка
        SliverToBoxAdapter(
          child: PlaceInfoWidget(place: place),
        ),

        // Быстрые действия
        // SliverToBoxAdapter(
        //   child: PlaceQuickActions(place: place),
        // ),

        // 🔹 НОВОЕ: секции места (фичи, прайс, инфо и т.д.)
        SliverToBoxAdapter(
          child: PlaceSectionsWidget(sections: place.sections),
        ),

        // События в этом месте (используем реальные данные)
        SliverToBoxAdapter(
          child: PlaceEventsSectionForPlace(place: place),
        ),

        // Режим работы
        if (place.workingHours.isNotEmpty)
          SliverToBoxAdapter(
            child: WorkingHoursWidget(place: place),
          ),

        // Как добраться / мини-карта
        SliverToBoxAdapter(
          child: PlaceMapSection(place: place),
        ),

        // Отзывы
        SliverToBoxAdapter(
          child: ReviewsWidget(place: place),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }
}
