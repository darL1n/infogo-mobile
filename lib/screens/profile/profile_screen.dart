// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mobile/providers/city_provider.dart';
import 'package:mobile/providers/locale_provider.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/screens/profile/views/profile_view_model.dart';
import 'package:mobile/widgets/base_layout.dart';
import 'package:mobile/widgets/custom_pull_to_refresh.dart'; // 👈 вот это

// наши виджеты
import 'widgets/profile_header.dart';
import 'widgets/profile_quick_actions.dart';
import 'widgets/profile_settings_section.dart';
import 'widgets/profile_support_section.dart';
import 'widgets/profile_logout_block.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => ProfileViewModel(
            context.read<UserProvider>(),
            context.read<CityProvider>(),
            context.read<LocaleProvider>(),
          ),
      child: Consumer<ProfileViewModel>(
        builder: (context, vm, _) {
          final theme = Theme.of(context);

          final content = CustomPullToRefresh(
            onRefresh: vm.refresh, // 👈 дёргаем VM
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              SliverToBoxAdapter(child: ProfileHeader(vm: vm)),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              SliverToBoxAdapter(
                child: ProfileQuickActions(isAuth: vm.isAuthenticated),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              SliverToBoxAdapter(child: ProfileSettingsSection(vm: vm)),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              const SliverToBoxAdapter(child: ProfileSupportSection()),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child:
                      vm.isAuthenticated
                          ? ProfileLogoutBlock(vm: vm)
                          : const SizedBox.shrink(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );

          return BaseLayout(
            title: 'Профиль',
            currentIndex: 2,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              // Просто регистрируем горизонтальный жест, но ничего не делаем.
              // Это достаточно, чтобы VerticalDrag внутри ScrollView
              // не «выиграл» жест и не начал вертикальный скролл.
              onHorizontalDragStart: (_) {},
              onHorizontalDragUpdate: (_) {},
              onHorizontalDragEnd: (_) {},
              child: content,
            ),
          );
        },
      ),
    );
  }
}
