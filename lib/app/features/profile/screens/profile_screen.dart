import 'dart:io';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/core/shared/CustomAvatar.dart';
import 'package:avo_app/app/features/doctor/view/widget/custom_drawer.dart';
import 'package:avo_app/app/features/profile/logic/profile_cubit.dart';
import 'package:avo_app/app/features/profile/logic/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final bool showBottomNav;
  final bool showAppBar;
  final bool showDrawer;

  const ProfileScreen({
    super.key,
    this.showBottomNav = true,
    this.showAppBar = true,
    this.showDrawer = true,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isArabic = false;
  bool isDarkTheme = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      context.read<ProfileCubit>().uploadAvatar(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // AppBar
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              leading: widget.showDrawer
                  ? Builder(
                      builder: (context) => IconButton(
                        icon: Icon(Icons.menu,
                            color: theme.textTheme.titleLarge?.color,
                            size: 24.sp),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    )
                  : null,
            )
          : null,

      // Drawer
      drawer: widget.showDrawer ? const CustomDrawer() : null,

      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          } else if (state is ProfileLogout) {
            context.go(AppRouter.login);
          }
        },
        builder: (context, state) {
          final cubit = context.read<ProfileCubit>();
          final profileName = cubit.userProfile?.fullName ?? 'No Name';
          final avatarUrl = cubit.imageUrl;

          return Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomAvatar(
                            size: 150.r,
                            borderColor: theme.colorScheme.primary,
                            imageUrl: avatarUrl.isNotEmpty
                                ? avatarUrl
                                : "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8c29maWFuJTIwYW5kcm98ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=500&q=60",
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(Icons.camera_alt_outlined,
                                  color: Colors.white, size: 30.sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profileName,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      children: [
                        _buildListTile(
                            context,
                            Icons.lock_outline,
                            "Account Information",
                            () => context.push(AppRouter.accountInfo)),
                        _buildListTile(
                            context,
                            Icons.person_outline,
                            "Personal Information",
                            () => context.push(AppRouter.personalInfo)),
                        _buildListTile(context, Icons.credit_card_outlined,
                            "Cards Details", () => context.push(AppRouter.checkout)),
                        ListTile(
                          leading:
                              Icon(Icons.translate, color: theme.colorScheme.onSurface),
                          title: Text("Language App", style: theme.textTheme.bodyLarge),
                          trailing: IconButton(
                            onPressed: _showLanguageBottomSheet,
                            icon: Icon(Icons.language,
                                color: theme.colorScheme.onSurface),
                          ),
                        ),
                        Divider(
                          height: 1,
                        ),
                        ListTile(
                          leading: Icon(Icons.wb_sunny_outlined,
                              color: theme.colorScheme.onSurface),
                          title: Text(
                            "App Theme",
                            style: theme.textTheme.bodyLarge,
                          ),
                          trailing: Switch(
                            value: isDarkTheme,
                            onChanged: (v) => setState(() => isDarkTheme = v),
                            activeTrackColor: theme.colorScheme.primary,
                            inactiveThumbColor: theme.colorScheme.onSurface,
                            trackOutlineColor: MaterialStateProperty.all(
                                theme.colorScheme.outlineVariant),
                          ),
                        ),
                        Divider(
                          height: 1,
                        ),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text("Sign Out",
                              style: TextStyle(color: Colors.red)),
                          onTap: () {
                            cubit.logout();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (state is ProfileLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        },
      ),
    );
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Select Language",
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text("English"),
                trailing: isArabic
                    ? null
                    : const Icon(Icons.check, color: Colors.green),
                onTap: () => _changeLanguage(false),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text("Arabic"),
                trailing: isArabic
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () => _changeLanguage(true),
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeLanguage(bool arabic) {
    setState(() => isArabic = arabic);
    Navigator.pop(context);
  }

  Widget _buildListTile(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: theme.colorScheme.onSurface),
          title: Text(title, style: theme.textTheme.bodyLarge),
          trailing: Icon(Icons.arrow_forward_ios,
              size: 16, color: theme.colorScheme.onSurface),
          onTap: onTap,
        ),
        Divider(
          height: 1,
        ),
      ],
    );
  }
}
