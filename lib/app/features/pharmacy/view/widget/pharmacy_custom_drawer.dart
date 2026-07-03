import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:easy_localization/easy_localization.dart';

class PharmacyCustomDrawer extends StatelessWidget {
  const PharmacyCustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String currentRoute = GoRouterState.of(context).uri.toString();

    return Drawer(
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu_open_outlined),
                  color: theme.colorScheme.outlineVariant,
                  iconSize: 24.sp,
                  onPressed: () => Navigator.pop(context),
                ),
                SvgPicture.asset(
                  'assets/svg/logo/logo.svg',
                  width: 150.w,
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerItem(
                  icon: Icons.grid_view,
                  title: LocaleKeys.drawer_dashboard.tr(),
                  route: AppRouter.pharmacyDashboard,
                  isSelected:
                      currentRoute.contains(AppRouter.pharmacyDashboard),
                ),
                DrawerItem(
                  icon: Icons.list_alt,
                  title: LocaleKeys.medical_records_pharmacy_orders.tr(),
                  route: AppRouter.pharmacyOrders,
                  isSelected: currentRoute.contains(AppRouter.pharmacyOrders),
                ),
                DrawerItem(
                  icon: Icons.chat_outlined,
                  title: LocaleKeys.drawer_chats.tr(),
                  route: AppRouter.pharmacyChats,
                  isSelected: currentRoute.contains(AppRouter.pharmacyChats),
                ),
                DrawerItem(
                  icon: Icons.analytics_outlined,
                  title: LocaleKeys.drawer_analytics.tr(),
                  route: AppRouter.pharmacyAnalytics,
                  isSelected: currentRoute.contains(AppRouter.pharmacyAnalytics),
                ),
                DrawerItem(
                  icon: Icons.document_scanner_outlined,
                  title: LocaleKeys.scanner_medical_analysis.tr(),
                  route: AppRouter.scannerFull,
                  isSelected: currentRoute.contains(AppRouter.scannerFull),
                ),
                DrawerItem(
                  icon: Icons.person,
                  title: LocaleKeys.bottom_nav_profile.tr(),
                  route: AppRouter.profileFull,
                  isSelected: currentRoute.contains(AppRouter.profileFull),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.5),
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: const Icon(Icons.logout, color: Colors.red, size: 26),
            title: Text(
              LocaleKeys.drawer_logout.tr(),
              style: const TextStyle(
                color: Colors.red,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              context.go('/login');
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final String route;

  const DrawerItem({
    super.key,
    required this.icon,
    required this.title,
    required this.route,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color textIconColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // إغلاق الدراور
        if (!isSelected) {
          context.go(route);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        color: Colors.transparent,
        child: Row(
          children: [
            Icon(
              icon,
              size: isSelected ? 26.sp : 24.sp,
              color: textIconColor,
            ),
            SizedBox(width: 16.w),
            Text(
              title,
              style: TextStyle(
                fontSize: isSelected ? 17.sp : 15.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: textIconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
