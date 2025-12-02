import 'package:flutter/material.dart';
import 'package:mobile/screens/map/map_screen.dart';
import 'package:mobile/widgets/base_layout.dart';

class MapScreenWithLayout extends StatelessWidget {
  const MapScreenWithLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'Карта мест',
      currentIndex: -1,
      showBackButton: true,
      showBottomNavigation: false, // если требуется нижняя навигация
      child: MapScreen(),
    );
  }
}
