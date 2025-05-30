import 'package:flutter/material.dart';
import 'package:flutter_app/config/colors_config.dart';
import 'package:flutter_app/resources/pages/dashboard/history/history_page.dart';
import 'package:flutter_app/resources/pages/dashboard/home/home_page.dart';
import 'package:flutter_app/resources/pages/dashboard/logout/logout_page.dart';
// import 'package:flutter_app/resources/pages/home_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

class BaseNavigationHub extends NyStatefulWidget with BottomNavPageControls {
  static RouteView path = ("/base", (_) => BaseNavigationHub());

  BaseNavigationHub()
      : super(
            child: () => _BaseNavigationHubState(),
            stateName: path.stateName());

  /// State actions
  static NavigationHubStateActions stateActions =
      NavigationHubStateActions(path.stateName());
}

class _BaseNavigationHubState extends NavigationHub<BaseNavigationHub> {
  /// Layouts:
  /// - [NavigationHubLayout.bottomNav] Bottom navigation
  /// - [NavigationHubLayout.topNav] Top navigation
  NavigationHubLayout? layout = NavigationHubLayout.bottomNav(
    backgroundColor: Colors.white,
  );

  /// Should the state be maintained
  @override
  bool get maintainState => true;

  /// Navigation pages
  _BaseNavigationHubState()
      : super(() async {
          return {
            0: NavigationTab(
              title: "Home",
              page:
                  HomePage(), // create using: 'dart run nylo_framework:main make:stateful_widget home_tab'
              icon: Icon(
                Icons.home,
                color: SetColors.Hijau60Opacity,
              ),
              activeIcon: Icon(
                Icons.home,
                color: SetColors.Hijau,
              ),
            ),
            1: NavigationTab(
              title: "History",
              page: HistoryPage(),
              icon: Icon(
                Icons.manage_history,
                color: SetColors.Hijau60Opacity,
              ),
              activeIcon: Icon(
                Icons.manage_history,
                color: SetColors.Hijau,
              ),
            ),
            2: NavigationTab(
              title: "Log Out",
              page: LogoutPage(),
              icon: Icon(
                Icons.logout_rounded,
                color: SetColors.Hijau60Opacity,
              ),
              activeIcon: Icon(
                Icons.logout,
                color: SetColors.Hijau,
              ),
            ),
          };
        });

  /// Handle the tap event
  @override
  onTap(int index) {
    super.onTap(index);
  }
}
