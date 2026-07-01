import 'package:ai_alarm_reminder/app/core/utils/constance.dart';
import 'package:ai_alarm_reminder/app/features/calendar_page.dart/calendar_page.dart';
import 'package:ai_alarm_reminder/app/features/health_metrics/view/health_metrics_page.dart';
import 'package:ai_alarm_reminder/app/features/home/view/home.dart';
import 'package:ai_alarm_reminder/app/features/notification_settings_page/notification_settings_page.dart';
import 'package:ai_alarm_reminder/app/features/tests_view_page/tests_view_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  final List<Widget> _screens = [
    const HomePage(),
    const TestsPage(),
    const HealthMetricsPage(),
    const CalendarPage(),
    const NotificationSettingsPage(),
  ];
  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  final ScrollController _scrollController3 = ScrollController();
  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        scrollToTopOnNavBarItemPress: true,
        icon: Icon(FontAwesomeIcons.houseMedical),
        
        title: ("Home"),
        activeColorPrimary: AppColors.primaryColor,
        inactiveColorPrimary: CupertinoColors.systemGrey,
        scrollController: _scrollController1,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(FontAwesomeIcons.dna),
        title: ("Analysis"),
        activeColorPrimary: AppColors.primaryColor,
        inactiveColorPrimary: CupertinoColors.systemGrey,
        scrollController: _scrollController2,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(FontAwesomeIcons.heartPulse),
        title: ("Health"),
        activeColorPrimary: AppColors.primaryColor,
        inactiveColorPrimary: CupertinoColors.systemGrey,
        scrollController: _scrollController3,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(FontAwesomeIcons.pills),
        title: ("Reminders"),
        activeColorPrimary: AppColors.primaryColor,
        inactiveColorPrimary: CupertinoColors.systemGrey,
        scrollController: _scrollController2,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.settings),
        title: ("Settings"),
        activeColorPrimary: AppColors.primaryColor,
        inactiveColorPrimary: CupertinoColors.systemGrey,
        scrollController: _scrollController2,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _screens,
      items: _navBarsItems(),
      handleAndroidBackButtonPress: true, // Default is true.

      resizeToAvoidBottomInset:
          false, // This needs to be true if you want to move up the screen on a non-scrollable screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardAppears: true,
      popBehaviorOnSelectedNavBarItemPress:
          PopBehavior.all, // Default is PopBehavior.doNotDeleteLastTab.
      padding: const EdgeInsets.only(top: 8),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      isVisible: true,
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings(
          // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          duration: Duration(milliseconds: 200),
          screenTransitionAnimationType: ScreenTransitionAnimationType.slide,
          curve: Curves.linear,
        ),
      ),
      confineToSafeArea: true,
      // navBarHeight: 60,
      // hideOnScrollSettings: HideOnScrollSettings(
      //   hideNavBarOnScroll: true,
      // ),
      navBarStyle: NavBarStyle
          .style13, // Choose the nav bar style with this void get getterName => value;
    );
  }
}
