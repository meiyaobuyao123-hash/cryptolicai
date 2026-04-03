import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/data_tab/data_page.dart';
import 'features/platform_detail/platform_detail_page.dart';
import 'features/platform_compare/platform_compare_page.dart';
import 'features/market_tab/market_page.dart';
import 'features/market_tab/platform_products_page.dart';
import 'features/placeholder/placeholder_page.dart';
import 'features/profile/profile_page.dart';
import 'features/settings/language_page.dart';
import 'features/settings/about_page.dart';
import 'features/settings/coming_soon_page.dart';
import 'shared/widgets/frosted_tab_bar.dart';

final router = GoRouter(
  initialLocation: '/data',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) {
        return Scaffold(
          body: shell,
          bottomNavigationBar: FrostedTabBar(
            currentIndex: shell.currentIndex,
            onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
          ),
        );
      },
      branches: [
        // Tab 0: 数据
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/data',
            builder: (context, state) => const DataPage(),
            routes: [
              GoRoute(path: 'compare', builder: (_, __) => const PlatformComparePage()),
              GoRoute(
                path: 'platform/:slug',
                builder: (context, state) {
                  final slug = state.pathParameters['slug']!;
                  final name = state.uri.queryParameters['name'] ?? slug;
                  return PlatformDetailPage(slug: slug, name: name);
                },
              ),
            ],
          ),
        ]),
        // Tab 1: 市场
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/discover',
            builder: (_, __) => const MarketPage(),
            routes: [
              GoRoute(
                path: 'platform/:slug',
                builder: (context, state) {
                  final slug = state.pathParameters['slug']!;
                  final name = state.uri.queryParameters['name'] ?? slug;
                  return PlatformProductsPage(slug: slug, name: name);
                },
              ),
            ],
          ),
        ]),
        // Tab 2: 交易
        StatefulShellBranch(routes: [
          GoRoute(path: '/finance', builder: (_, __) => const PlaceholderPage(title: '交易')),
        ]),
        // Tab 3: 我的
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfilePage(),
            routes: [
              GoRoute(path: 'language', builder: (_, __) => const LanguagePage()),
              GoRoute(path: 'about', builder: (_, __) => const AboutPage()),
              GoRoute(path: 'notifications', builder: (_, __) => const ComingSoonPage(title: '通知设置')),
              GoRoute(path: 'security', builder: (_, __) => const ComingSoonPage(title: '安全中心')),
              GoRoute(path: 'help', builder: (_, __) => const ComingSoonPage(title: '帮助与反馈')),
            ],
          ),
        ]),
      ],
    ),
  ],
);
