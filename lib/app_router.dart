import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/news.dart';
import 'package:mobile/screens/auth/email_login.dart';
import 'package:mobile/screens/auth/email_verification_screen.dart';
import 'package:mobile/screens/auth/login_screen.dart';

import 'package:mobile/screens/auth/phone_login.dart';
import 'package:mobile/screens/auth/phone_verification_screen.dart';
import 'package:mobile/screens/catalog/catalog_screen.dart';
import 'package:mobile/screens/events/events_screen.dart';
import 'package:mobile/screens/favorites/favorites_screen.dart';
import 'package:mobile/screens/history_view/history_screen.dart';
import 'package:mobile/screens/home/home_screen.dart';
import 'package:mobile/screens/info/privacy_policy_screen.dart';
import 'package:mobile/screens/locations/cities_screen.dart';
import 'package:mobile/screens/map/map_screen_with_layout.dart';
import 'package:mobile/screens/news/news_detail_screen.dart';
import 'package:mobile/screens/news/news_screen.dart';
import 'package:mobile/screens/onboarding/language_setup_screen.dart';
import 'package:mobile/screens/place/place_screen.dart';
import 'package:mobile/screens/profile/profile_screen.dart';
import 'package:mobile/screens/search/search_results.dart';
import 'package:mobile/screens/search/search_screen.dart';
import 'package:mobile/screens/splash_screen.dart';
import 'package:mobile/widgets/custom_transition_page.dart';
import 'package:mobile/screens/onboarding/location_setup_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // 👇 экран первичной настройки города/гео
        GoRoute(
          path: '/onboarding/location',
          builder: (context, state) => const LocationSetupScreen(),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) {
            return buildSlideTransitionPage(
              child: const LoginScreen(),
              withFadeBackground: true,
              key: state.pageKey,
            );
          },
        ),
        GoRoute(
          path: '/login/phone',
          pageBuilder: (context, state) {
            return buildSlideTransitionPage(
              child: PhoneLoginScreen(
                onLoginSuccess:
                    (phone) => context.go('/verification-phone/$phone'),
              ),
              withFadeBackground: true,
              key: state.pageKey,
            );
          },
        ),
        // 🔹 Email-флоу
        GoRoute(
          path: '/login/email',
          pageBuilder: (context, state) {
            return buildSlideTransitionPage(
              child: EmailLoginScreen(
                onLoginSuccess:
                    (email) => context.go(
                      '/verification-email/${Uri.encodeComponent(email)}',
                    ),
              ),
              withFadeBackground: true,
              key: state.pageKey,
            );
          },
        ),
        GoRoute(
          path: '/verification-phone/:phone',
          builder: (context, state) {
            final phone = state.pathParameters['phone']!;
            return VerificationScreen(phone: phone);
          },
        ),

        GoRoute(
          path: '/verification-email/:email',
          builder: (context, state) {
            final email = Uri.decodeComponent(state.pathParameters['email']!);
            return EmailVerificationScreen(email: email);
          },
        ),
        GoRoute(
          name: 'placeDetail',
          path: '/place/:placeId',
          // parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (context, state) {
            final placeId = int.tryParse(state.pathParameters['placeId']!);
            return placeId != null
                ? buildSlideTransitionPage(
                  key: state.pageKey,
                  withFadeBackground: true,
                  child: PlaceDetailScreen(placeId: placeId, isDeepLink: true),
                )
                : const MaterialPage<void>(
                  child: Scaffold(body: Center(child: Text("Неверное место"))),
                );
          },
        ),
        GoRoute(
          path: '/map',
          builder: (context, state) => const MapScreenWithLayout(),
        ),
        GoRoute(
          path: '/events',
          builder: (context, state) => const EventsScreen(),
        ),
        GoRoute(path: '/news', builder: (context, state) => const NewsScreen()),
        GoRoute(
          path: '/news/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            final preview =
                state.extra is NewsModel ? state.extra as NewsModel : null;
            return NewsDetailScreen(newsId: id, preview: preview);
          },
        ),
        GoRoute(
          path: '/onboarding/language',
          builder: (context, state) => const LanguageSetupScreen(),
        ),
        GoRoute(
          path: '/home',
          pageBuilder:
              (context, state) => buildInstantPage(
                key: state.pageKey,
                child: const HomeScreen(),
              ),
        ),
        GoRoute(
          path: '/catalog',
          pageBuilder:
              (context, state) => buildInstantPage(
                key: state.pageKey,
                child: const CatalogScreen(),
              ),
          routes: [
            // подкатегории по-прежнему со слайдом
            GoRoute(
              path: ':categoryId',
              pageBuilder: (context, state) {
                final id = int.tryParse(state.pathParameters['categoryId']!);
                return buildSlideTransitionPage(
                  key: state.pageKey,
                  withFadeBackground: true,
                  child: CatalogScreen(categoryId: id),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/places',
          pageBuilder: (context, state) {
            return buildSlideTransitionPage(
              key: state.pageKey,
              withFadeBackground: true,
              child: SearchResultsScreen(),
            );
          },
        ),

        GoRoute(
          path: '/cities',
          name: 'cities',
          builder: (context, state) => const CitiesScreen(),
        ),
        GoRoute(
          path: '/search',
          pageBuilder:
              (context, state) => buildSlideTransitionPage(
                key: state.pageKey,
                withFadeBackground: false,
                child: const SearchScreen(),
              ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder:
              (context, state) => buildInstantPage(
                key: state.pageKey,
                child: const ProfileScreen(),
              ),
        ),

        GoRoute(
          path: '/favorites',
          pageBuilder: (context, state) {
            return buildSlideTransitionPage(
              child: const FavoritesScreen(),
              key: state.pageKey,
              withFadeBackground: true,
            );
          },
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) {
            return buildSlideTransitionPage(
              child: const HistoryScreen(),
              key: state.pageKey,
              withFadeBackground: true,
            );
          },
        ),

        GoRoute(
          path: '/privacy',
          builder: (context, state) => const PrivacyPolicyScreen(),
        ),
      ],
    );
  }
}
