import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

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
                  route: AppRouter.dashboard,
                  isSelected: currentRoute.contains(AppRouter.dashboard),
                ),
                DrawerItem(
                  icon: Icons.person,
                  title: LocaleKeys.drawer_patients.tr(),
                  route: AppRouter.patients,
                  isSelected: currentRoute.contains(AppRouter.patients),
                ),
                DrawerItem(
                  icon: Icons.add_home_outlined,
                  title: LocaleKeys.drawer_appointments.tr(),
                  route: AppRouter.appointments,
                  isSelected: currentRoute.contains(AppRouter.appointments),
                ),
                DrawerItem(
                  icon: Icons.schedule,
                  title: LocaleKeys.drawer_add_schedule.tr(),
                  route: AppRouter.addSchedule,
                  isSelected: currentRoute.contains(AppRouter.addSchedule),
                ),
                DrawerItem(
                  icon: Icons.science_outlined,
                  title: LocaleKeys.drawer_lab_results.tr(),
                  route: AppRouter.labResults,
                  isSelected: currentRoute.contains(AppRouter.labResults),
                ),
                DrawerItem(
                  icon: Icons.calendar_month,
                  title: LocaleKeys.drawer_schedule.tr(),
                  route: AppRouter.scheduleAppointment,
                  isSelected:
                      currentRoute.contains(AppRouter.scheduleAppointment),
                ),
                DrawerItem(
                  icon: Icons.chat_outlined,
                  title: LocaleKeys.drawer_chats.tr(),
                  route: AppRouter.doctorChats,
                  isSelected: currentRoute.contains(AppRouter.doctorChats),
                ),
                DrawerItem(
                  icon: Icons.analytics_outlined,
                  title: LocaleKeys.drawer_analytics.tr(),
                  route: AppRouter.analytics,
                  isSelected: currentRoute.contains(AppRouter.analytics),
                ),
                DrawerItem(
                  icon: Icons.settings,
                  title: LocaleKeys.drawer_settings.tr(),
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
              context.go(
                '/login',
              );
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
