import 'package:aieducator/components/bottom_navigation_bar.dart';
import 'package:aieducator/provider/auth_provider.dart';
import 'package:aieducator/screens/auth/login_screen.dart';
import 'package:aieducator/screens/certificates/certificate_screen.dart';
import 'package:aieducator/screens/courses/course_screen.dart';
import 'package:aieducator/screens/error_screen.dart';
import 'package:aieducator/screens/home/courseName/availaible_courses.dart';
import 'package:aieducator/screens/home/courseName/nearby_institute.dart';
import 'package:aieducator/screens/home/course_name.dart';
import 'package:aieducator/screens/home/home_screen.dart';
import 'package:aieducator/screens/home/courseName/lecture_screen.dart';
import 'package:aieducator/screens/profile/profile_screen.dart';
import 'package:aieducator/screens/splash_screen.dart';
import 'package:aieducator/utility/go_router_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final router = GoRouter(
    refreshListenable: authProvider,
    initialLocation: AppRoutes.splash.path,
    routes: [
      _splashRoute,
      _loginRoute,
      _shellRoute,
    ],
    redirect: _handleRedirect,
    errorBuilder: (_, __) => const ErrorScreen(),
  );

  // Auth Routes
  GoRoute get _splashRoute => GoRoute(
        path: AppRoutes.splash.path,
        name: AppRoutes.splash.name,
        builder: (_, __) => const SplashScreen(),
      );

  GoRoute get _loginRoute => GoRoute(
        path: AppRoutes.login.path,
        name: AppRoutes.login.name,
        builder: (_, __) => const LoginScreen(),
      );

  // Main Shell Route
  StatefulShellRoute get _shellRoute => StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => BottomNavigationBarScreen(
          navigationShell: shell,
        ),
        branches: [
          _homeBranch,
          _eBookBranch,
          _certificateBranch,
          _profileBranch,
        ],
      );

  // Shell Branches
  StatefulShellBranch get _homeBranch => StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.home.path,
            name: AppRoutes.home.name,
            builder: (_, __) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'course/:name',
                name: 'courseDetail',
                builder: (_, state) => CourseName(
                  name: state.pathParameters['name'] ?? '',
                ),
                routes: [
                  GoRoute(
                    path: 'lectures',
                    name: 'lectures',
                    builder: (_, state) => LectureScreen(
                      courseName: state.pathParameters['name'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: 'nearbyInstitute',
                    name: 'nearbyInstitute',
                    builder: (_, state) => NearbyInstituteScreen(
                      courseName: state.pathParameters['name'] ?? 'Unknown',
                    ),
                  ),
                  GoRoute(
                    path: 'availableCourses',
                    name: 'availableCourses',
                    builder: (_, state) => AvailaibleCoursesScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

  StatefulShellBranch get _eBookBranch => StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.eBook.path,
            name: AppRoutes.eBook.name,
            builder: (_, __) => const CourseScreen(),
          ),
        ],
      );

  StatefulShellBranch get _certificateBranch => StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.certificate.path,
            name: AppRoutes.certificate.name,
            builder: (_, __) => const CertificateScreen(),
          ),
        ],
      );

  StatefulShellBranch get _profileBranch => StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.profile.path,
            name: AppRoutes.profile.name,
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      );

  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final isSplashComplete = authProvider.splashComplete;
    final isLoggedIn = authProvider.isAuthenticated;
    final location = state.uri.toString();

    // Allow course detail navigation
    if (state.uri.path.startsWith('/home/')) return null;

    // Handle splash screen
    if (!isSplashComplete && location != AppRoutes.splash.path) {
      return AppRoutes.splash.path;
    }

    // Handle authentication
    if (isSplashComplete) {
      if (!isLoggedIn && !location.startsWith(AppRoutes.login.path)) {
        return AppRoutes.login.path;
      }
      if (isLoggedIn &&
          (location == AppRoutes.login.path ||
              location == AppRoutes.splash.path)) {
        return AppRoutes.home.path;
      }
    }

    return null;
  }
}
