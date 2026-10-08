import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'routes.dart';

GoRouter buildRouter(ProviderContainer container) => GoRouter(
      redirect: (context, state) {
        final loggedIn = container.read(authStateProvider).value ?? false;
        final goingLogin = state.matchedLocation == AppRoutes.login;
        if (!loggedIn && !goingLogin) return AppRoutes.login;
        if (loggedIn && goingLogin) return AppRoutes.home;
        return null;
      },
      routes: [
        GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginPage()),
        GoRoute(path: AppRoutes.home, builder: (_, __) => const HomePage()),
        GoRoute(
          path: AppRoutes.announcementPattern,
          builder: (_, s) =>
              AnnouncementPage(id: s.pathParameters['id'] ?? ''),
        ),
      ],
    );