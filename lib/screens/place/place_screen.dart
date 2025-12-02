// place_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/place_detail.dart';
import 'package:mobile/providers/favorite_provider.dart';
import 'package:mobile/providers/place_provider.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/screens/place/widgets/action_buttons.dart';
import 'package:mobile/screens/place/widgets/place_body.dart';
import 'package:mobile/screens/place/widgets/place_detail_error.dart';
import 'package:mobile/screens/place/widgets/place_shimmer.dart';
import 'package:mobile/utils/back_button_handler.dart';
import 'package:mobile/widgets/animated_favorite_icon.dart';
import 'package:mobile/widgets/app_bar.dart';
import 'package:mobile/widgets/swipe_back_wrapper.dart';
import 'package:provider/provider.dart';

class PlaceDetailScreen extends StatefulWidget {
  final int placeId;
  final bool isDeepLink;

  const PlaceDetailScreen({
    super.key,
    required this.placeId,
    this.isDeepLink = false,
  });

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  @override
   void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final placeProvider = context.read<PlaceProvider>();

      if (placeProvider.place == null ||
          placeProvider.place!.id != widget.placeId) {
        placeProvider.fetchPlaceDetail(
          widget.placeId,
          addToHistory: true,
          context: context,
        );
      }
    });
  }

  void _sharePlace(PlaceDetailModel place) {
    // TODO: подключить share_plus и сделать нормальный шаринг:
    // Share.share(text);
    final text = [
      place.name,
      place.address,
      if (place.website.isNotEmpty) place.website,
    ].join('\n');

    debugPrint('Share place:\n$text');
  }

  @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final userProvider = context.read<UserProvider>();

  return Consumer<PlaceProvider>(
    builder: (context, placeProvider, _) {
      final place = placeProvider.place;
      final isLoading = placeProvider.isPlaceLoading;

      // fallbackRoute
      final extra = GoRouterState.of(context).extra;
      String fallbackRoute = '/catalog';
      if (place != null) {
        fallbackRoute = '/catalog/${place.category.id}';
      }
      if (extra is Map<String, dynamic> && extra['parentPath'] != null) {
        fallbackRoute = extra['parentPath'] as String;
      }

      final isFavorite =
          place != null
              ? context.watch<FavoriteProvider>().isFavorite(place.id)
              : false;

      final hasBottomActions =
          !isLoading &&
          place != null &&
          (place.contactPhone.isNotEmpty ||
              (place.latitude != null && place.longitude != null));

      return SwipeBackWrapper(
        fallbackRoute: fallbackRoute,
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,

          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AppBarContainer(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => BackButtonHandler.handle(
                      context,
                      fallbackRoute: fallbackRoute,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      place?.name ?? 'Загрузка...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  if (place != null) ...[
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      onPressed: () => _sharePlace(place),
                    ),
                    AnimatedFavoriteIcon(
                      isFavorite: isFavorite,
                      onTap: () {
                        context.read<FavoriteProvider>().toggle(
                              place.id,
                              userProvider,
                            );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),

          body:
              isLoading || place == null
                  ? const PlaceDetailShimmer()
                  : PlaceDetailBody(place: place),

          bottomNavigationBar:
              hasBottomActions
                  ? SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: PlaceActionButtons(place: place!),
                      ),
                    )
                  : null,
        ),
      );
    },
  );
}
}
