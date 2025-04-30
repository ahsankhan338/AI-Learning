class AppRoute {
  final String path;
  final String name;

  const AppRoute({required this.path, required this.name});

  // Helper method to get path with parameters
  String withParams(Map<String, String> params) {
    String result = path;
    params.forEach((key, value) {
      result = result.replaceAll(':$key', value);
    });
    return result;
  }
}

class AppRoutes {
  static const splash = AppRoute(path: '/splash', name: 'splash');
  static const login = AppRoute(path: '/login', name: 'login');
  static const register = AppRoute(path: '/login/register', name: 'register');
  static const forgotPassword = AppRoute(
    path: '/login/forgot-password',
    name: 'forgotPassword',
  );

  // Main Routes
  static const home = AppRoute(path: '/home', name: 'home');
  static const eBook = AppRoute(path: '/eBook', name: 'eBook');
  static const certificate =
      AppRoute(path: '/certificate', name: 'certificate');
  static const profile = AppRoute(path: '/profile', name: 'profile');

  // Home Sub-routes
  static const courseDetail =
      AppRoute(path: '/home/course/:name', name: 'courseDetail');
  static const lectures =
      AppRoute(path: '/home/course/:name/lectures', name: 'lectures');
  static const mcq =
      AppRoute(path: '/home/course/:name/lectures/mcq', name: 'mcq');
  static const nearbyInstitute = AppRoute(
      path: '/home/course/:name/nearbyInstitute', name: 'nearbyInstitute');
  static const availableCourses = AppRoute(
      path: '/home/course/:name/availableCourses', name: 'availableCourses');

  // eBook Sub-routes
  static const eBookDetail = AppRoute(path: '/eBook/:id', name: 'eBookDetail');

  // Certificate Sub-routes
  static const certificatePreview = AppRoute(
    path: '/certificate/preview/:url',
    name: 'certificatePreview',
  );

  // Profile Sub-routes
  static const profileSettings =
      AppRoute(path: '/profile/settings', name: 'profileSettings');
}
