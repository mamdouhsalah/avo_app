import 'package:avo_app/app/core/constants/app_colors.dart';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/core/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class AdminCustomDrawer extends StatelessWidget {
  const AdminCustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String currentRoute = GoRouterState.of(context).uri.toString();
    final isDark = theme.brightness == Brightness.dark;

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
                _DrawerItem(
                  icon: Icons.grid_view,
                  title: 'Dashboard',
                  route: AppRouter.adminDashboard,
                  isSelected: currentRoute == AppRouter.adminDashboard,
                ),
                _DrawerItem(
                  icon: Icons.how_to_reg_rounded,
                  title: 'Approvals',
                  route: AppRouter.adminApprovals,
                  isSelected: currentRoute == AppRouter.adminApprovals,
                ),
                _DrawerItem(
                  icon: Icons.people_alt_rounded,
                  title: 'Users',
                  route: AppRouter.adminUsers,
                  isSelected: currentRoute == AppRouter.adminUsers,
                ),
                _DrawerItem(
                  icon: Icons.list_alt_rounded,
                  title: 'Logs',
                  route: AppRouter.adminLogs,
                  isSelected: currentRoute == AppRouter.adminLogs,
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.5),
          
          // Theme Toggle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: theme.colorScheme.onSurface,
                      size: 26.sp,
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      'Dark Mode',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: isDark,
                  onChanged: (value) {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                  activeColor: AppColors.lightPrimary,
                ),
              ],
            ),
          ),

          // Logout
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            leading: Icon(Icons.logout, color: Colors.red, size: 26.sp),
            title: Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  title: Text('Logout',
                      style: TextStyle(
                          fontSize: 17.sp, fontWeight: FontWeight.w700)),
                  content: Text(
                      'Are you sure you want to logout from the Admin Dashboard?',
                      style: TextStyle(fontSize: 14.sp)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                context.go(AppRouter.login);
              }
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final String route;

  const _DrawerItem({
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
        Navigator.pop(context); // Close drawer
        if (!isSelected) {
          context.push(route);
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
