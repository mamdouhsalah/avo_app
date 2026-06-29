import 'package:avo_app/app/core/shared/custom_navigationbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final bool showBottomNav;

  const MainLayout({
    super.key,
    required this.child,
    this.showBottomNav = true,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool isVisible = true;

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/scanner')) return 0;
    if (location.startsWith('/chats')) return 1;
    if (location.startsWith('/home')) return 2;
    if (location.startsWith('/reminder')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 2;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/scanner');
        break;
      case 1:
        context.go('/chats');
        break;
      case 2:
        context.go('/home');
        break;
      case 3:
        context.go('/reminder');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse) {
            if (isVisible) setState(() => isVisible = false);
          } else if (notification.direction == ScrollDirection.forward) {
            if (!isVisible) setState(() => isVisible = true);
          }
          return false;
        },
        child: widget.child,
      ),
      bottomNavigationBar: widget.showBottomNav
          ? AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isVisible ? 1.0 : 0.0,
                child: isVisible
                    ? CustomBottomNav(
                        currentIndex: _calculateSelectedIndex(context),
                        onTap: (index) => _onItemTapped(index, context),
                      )
                    : const SizedBox.shrink(),
              ),
            )
          : null,
    );
  }
}
