import '../resources/pages/admin/admin_dashboard_page.dart';
// import 'package:flutter_app/resources/pages/home_page.dart';
import '../resources/pages/dashboard/logout/logout_page.dart';
import '../resources/pages/dashboard/history/history_page.dart';
import '../resources/pages/dashboard/bottom_navigator/base_navigation_hub.dart';
import '../resources/pages/dashboard/home/home_page.dart';
import '../resources/pages/register/register_page.dart';
import '../resources/pages/login/login_page.dart';
import '/resources/pages/home_screen_page.dart';
import '/resources/pages/not_found_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

appRouter() => nyRoutes((router) {
  router.add(NotFoundPage.path).unknownRoute();
  router.add(HomeScreenPage.path).initialRoute();
  router.add(LoginPage.path);
  router.add(RegisterPage.path);
  router.add(HomePage.path);
  router.add(BaseNavigationHub.path);
  router.add(HistoryPage.path);
  router.add(LogoutPage.path);
  router.add(AdminDashboardPage.path);

  // router.add(nyRoutes(AdminDashboardPage.path, page: (context) => AdminDashboardPage()));
});
