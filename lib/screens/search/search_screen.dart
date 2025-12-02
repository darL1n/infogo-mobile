import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/providers/city_provider.dart';
import 'package:mobile/providers/place_provider.dart';
import 'package:mobile/providers/search_provider.dart';
import 'package:mobile/storages/hive_storage.dart';
import 'package:mobile/utils/category_navigation.dart';
import 'package:mobile/widgets/app_bar.dart';
import 'package:mobile/widgets/base_layout.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  Timer? _debounce;
  static const _debounceDuration = Duration(milliseconds: 350);

  @override
  void initState() {
    super.initState();

    // подтягиваем последний запрос из фильтра мест (чисто UX)
    final lastQuery = context.read<PlaceProvider>().filter.query?.trim() ?? '';

    _controller = TextEditingController(text: lastQuery);
    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    final trimmed = value.trim();
    final searchProvider = context.read<SearchProvider>();

    setState(() {}); // чтобы обновить иконку очистки и контент

    _debounce?.cancel();

    if (trimmed.isEmpty) {
      searchProvider.clear();
      return;
    }

    _debounce = Timer(_debounceDuration, () {
      if (!mounted) return;
      final cityId = context.read<CityProvider>().currentCityId;
      searchProvider.loadSuggestions(trimmed, cityId: cityId);
    });
  }

  Future<void> _submitQuery(
    String raw, {
    String source =
        'manual', // manual | suggestion | popular | history | category
  }) async {
    final query = raw.trim();
    if (query.isEmpty) return;

    // 1) Локальная история (Hive)
    await HiveStorage.addSearchQuery(query);

    // 2) Лог на сервер
    final cityId = context.read<CityProvider>().currentCityId;
    await context.read<SearchProvider>().logSearch(
      query: query,
      cityId: cityId,
      source: source,
    );

    // 3) Применяем фильтр к PlaceProvider
    final placeProvider = context.read<PlaceProvider>();
    final currentFilter = placeProvider.filter;

    placeProvider.updateFilter(currentFilter.copyWith(query: query));

    if (!mounted) return;

    // 4) Переходим на экран мест
    context.push('/places');
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();

    final suggestions = searchProvider.placeSuggestions;
    final categories = searchProvider.categorySuggestions;
    final serverHistory = searchProvider.serverHistory;
    final popular = searchProvider.popularSuggestions;
    final isLoading = searchProvider.isLoading;

    // локальная история (Hive)
    final historyHive = HiveStorage.getSearchHistory();
    final query = _controller.text.trim();

    final theme = Theme.of(context);

    Widget content;

    if (query.isEmpty) {
      // === ПУСТОЙ ЗАПРОС → локальная история (Hive) ===
      content = ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          if (historyHive.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'История поиска',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await HiveStorage.clearSearchHistory();
                    setState(() {});
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Очистить'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...historyHive.map(
              (e) => ListTile(
                dense: true,
                leading: const Icon(Icons.history),
                title: Text(e),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () async {
                    await HiveStorage.removeSearchQuery(e);
                    setState(() {});
                  },
                ),
                onTap: () => _submitQuery(e, source: 'history'),
              ),
            ),
          ] else ...[
            const SizedBox(height: 32),
            Text(
              'Начните вводить название места или категории,\n'
              'чтобы найти нужное.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ],
      );
    } else {
      // === ЕСТЬ ТЕКСТ ЗАПРОСА ===
      content = ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1) История с сервера
          if (serverHistory.isNotEmpty) ...[
            Text(
              'Недавние запросы',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...serverHistory.map(
              (s) => ListTile(
                dense: true,
                leading: const Icon(Icons.history),
                title: Text(s),
                onTap: () => _submitQuery(s, source: 'server_history'),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 2) Популярное в городе
          if (popular.isNotEmpty) ...[
            Text(
              'Популярное в городе',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...popular.map(
              (s) => ListTile(
                dense: true,
                leading: const Icon(Icons.trending_up),
                title: Text(s),
                onTap: () => _submitQuery(s, source: 'popular'),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 3) Категории
          if (categories.isNotEmpty) ...[
            Text(
              'Категории',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...categories.map(
              (c) => ListTile(
                dense: true,
                leading: const Icon(Icons.folder_outlined),
                title: Text(c.name),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () => handleCategoryTap(context, c),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 4) Места
          if (suggestions.isNotEmpty) ...[
            Text(
              'Места',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...suggestions.map(
              (s) => ListTile(
                dense: true,
                leading: const Icon(Icons.search),
                title: Text(s),
                onTap: () => _submitQuery(s, source: 'suggestion'),
              ),
            ),
          ]
          // 5) Фолбек "Искать «…»"
          else if (!isLoading &&
              serverHistory.isEmpty &&
              popular.isEmpty &&
              categories.isEmpty) ...[
            Text(
              'Поиск',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.search),
              title: Text('Искать «$query»'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _submitQuery(query),
            ),
          ],

          if (isLoading) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(minHeight: 2),
          ],
        ],
      );
    }
    

    return PopScope<Object?>(
    // хотим, чтобы экран нормально закрывался (и системная "назад", и свайп)
    canPop: true,
    // новый колбэк вместо WillPopScope
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) return; // если по какой-то причине не попнулось — ничего не делаем

      // здесь ещё всё живо, можно безопасно дёрнуть провайдер
      // если используешь SearchProvider:
      // context.read<SearchProvider>().clear();

      // если пока логика в PlaceProvider:
      // context.read<PlaceProvider>().clearSuggestions();
      searchProvider.clear();
      // при желании можно ещё что-то сбросить
    },
    child: BaseLayout(
      title: '',
      currentIndex: 1,
      showBottomNavigation: false,
      showBackButton: false,
      appBar: _SearchAppBar(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onQueryChanged,
        onSubmitted: _submitQuery,
      ),
      child: content,
    ),
  );
  }
}

/// AppBar для поиска с полем ввода
class _SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  const _SearchAppBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBarContainer(
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Поиск по местам и категориям',
                isDense: true,
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.7),

                // «таблетка» без рамки
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),

                // иконка внутри поля, а не снаружи
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                ),
              ),
            ),
          ),
          // крестик убрали вообще — пользователь чистит текст руками
        ],
      ),
    );
  }
}
