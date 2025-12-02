import 'package:flutter/material.dart';
import 'package:mobile/providers/favorite_provider.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/widgets/base_layout.dart';
import 'package:mobile/widgets/favorite_place_card.dart';
import 'package:mobile/widgets/swipe_back_wrapper.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = context.watch<FavoriteProvider>();
    final favorites = favoriteProvider.favorites;

    return SwipeBackWrapper(
      child: BaseLayout(
        title: 'Избранное',
        currentIndex: 2,
        child:
            favorites.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: favorites.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final fav = favorites[index];

                    return Dismissible(
                      key: ValueKey(fav.place.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        final favoriteProvider =
                            context.read<FavoriteProvider>();
                        final userProvider = context.read<UserProvider>();
                        favoriteProvider.remove(fav.place.id, userProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Удалено из избранного'),
                          ),
                        );
                      },
                      child: FavoritePlaceCard(favorite: fav),
                    );
                  },
                ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'У вас пока нет избранных мест',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
