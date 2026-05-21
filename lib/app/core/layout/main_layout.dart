import 'package:avo_app/app/core/shared/custom_navigationbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child; // الشاشة اللي هتتعرض جوه الـ Scaffold

  const MainLayout({super.key, required this.child});

  // دالة بتحدد إحنا في أي شاشة عشان تنور الأيقونة الصح
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/maps')) return 0;
    if (location.startsWith('/schedule')) return 1;
    if (location.startsWith('/home')) return 2;
    if (location.startsWith('/reminder')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 2; // Home by default
  }

  // دالة التنقل لما اليوزر يدوس على أيقونة تحت
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/maps');
        break;
      case 1:
        context.go('/schedule');
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
      body: child, // هنا بتتعرض الشاشة (Home, Profile, etc..)
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }
}
