import 'package:aieducator/components/bottom_navigation_bar.dart';
import 'package:aieducator/provider/auth_provider.dart';
import 'package:aieducator/screens/auth/login_screen.dart';
import 'package:aieducator/screens/certificates/certificate_screen.dart';
import 'package:aieducator/screens/courses/course_screen.dart';
import 'package:aieducator/screens/error_screen.dart';
import 'package:aieducator/screens/home/home_screen.dart';
import 'package:aieducator/screens/profile/profile_screen.dart';
import 'package:aieducator/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum AppRoutes {
  splash('/splash'),
  root('/'),
  login('/login'),
  home('/home'),
  course('/course'),
  certificate('/certificate'),
  profile('/profile');

  final String path;
  const AppRoutes(this.path);
}

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final router = GoRouter(
    refreshListenable: authProvider,
    initialLocation: AppRoutes.splash.path,
    routes: [
      GoRoute(
        path: AppRoutes.splash.path,
        name: AppRoutes.splash.name,
        pageBuilder: (context, state) => const MaterialPage(
          child: SplashScreen(),
          fullscreenDialog: true,
        ),
      ),
      GoRoute(
        path: AppRoutes.login.path,
        name: AppRoutes.login.name,
        pageBuilder: (context, state) => MaterialPage(
          child: LoginScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            BottomNavigationBarScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.home.path,
              name: AppRoutes.home.name,
              pageBuilder: (context, state) => const MaterialPage(
                child: HomeScreen(),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.course.path,
              name: AppRoutes.course.name,
              pageBuilder: (context, state) => const MaterialPage(
                child: CourseScreen(),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.certificate.path,
              name: AppRoutes.certificate.name,
              pageBuilder: (context, state) => const MaterialPage(
                child: CertificateScreen(),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile.path,
              name: AppRoutes.profile.name,
              pageBuilder: (context, state) => const MaterialPage(
                child: ProfileScreen(),
              ),
            ),
          ]),
        ],
      ),
    ],
    redirect: (context, state) {
      final isSplashComplete = authProvider.splashComplete;
      final isLoggedIn = authProvider.isAuthenticated;
      final currentLocation = state.uri.toString();

      // Splash redirection
      if (!isSplashComplete && currentLocation != AppRoutes.splash.path) {
        return AppRoutes.splash.path;
      }

      // Auth redirection
      if (isSplashComplete) {
        print("SplashScreen Completed");
        if (!isLoggedIn && !currentLocation.startsWith(AppRoutes.login.path)) {
          print("SplashScreen Completed & path is Login");
          return AppRoutes.login.path;
        }
        if (isLoggedIn &&
            (currentLocation == AppRoutes.login.path ||
                currentLocation == AppRoutes.splash.path)) {
          return AppRoutes.home.path;
        }
      }

      return null;
    },
    errorBuilder: (context, state) => const ErrorScreen(),
  );
}
