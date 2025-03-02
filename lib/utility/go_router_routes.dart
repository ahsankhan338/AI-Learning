enum AppRoutes {
  // Auth Routes
  splash('/splash'),
  login('/login'),

  // Main Routes
  home('/home'),
  eBook('/eBook'),
  certificate('/certificate'),
  profile('/profile'),

  // Home Sub-routes
  courseDetail('/home/course/:name'),
  lectures('/home/course/:name/lectures'),
  nearbyInstitute('/home/course/:name/nearbyInstitute'),
  availableCourses('/home/course/:name/availableCourses'),

  // eBook Sub-routes
  eBookDetail('/eBook/:id'),

  // Certificate Sub-routes
  certificateDetail('/certificate/:id'),

  // Profile Sub-routes
  profileSettings('/profile/settings');

  final String path;
  const AppRoutes(this.path);

  // Helper method to get path with parameters
  String withParams(Map<String, String> params) {
    String result = path;
    params.forEach((key, value) {
      result = result.replaceAll(':$key', value);
    });
    return result;
  }
}
