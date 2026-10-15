class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const announcementPattern = '/announcement/:id';
  static String announcement(String id) => '/announcement/$id';
}

String routeFromMessage(Map<String, dynamic> data) {
  final route = data['route'] as String?;
  if (route == null || route.isEmpty) return AppRoutes.home;
  return route.startsWith('/') ? route : '/$route';
}