import 'package:flutter/material.dart';
import 'package:mobile/providers/history_provider.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/screens/history_view/widgets/history_view_card.dart';
import 'package:mobile/widgets/base_layout.dart';
import 'package:mobile/widgets/swipe_back_wrapper.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userProvider = context.read<UserProvider>();
      context.read<HistoryProvider>().load(userProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();
    final history = provider.history;

    return SwipeBackWrapper(
      child: BaseLayout(
        title: 'История просмотров',
        currentIndex: 2,
        child:
            provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : history.isEmpty
                ? const Center(
                  child: Text(
                    'История пуста',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
                : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return HistoryPlaceCard(
                      history: item,
                    ); // или HistoryCard позже
                  },
                ),
      ),
    );
  }
}
