import 'package:flutter/material.dart';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isArabic = false; // متغير مؤقت للـ UI بس
  bool isDarkTheme = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Sofia Andro",
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildListTile(
                  context,
                  icon: Icons.lock_outline,
                  title: "Account Information",
                  onTap: () => context.push(AppRouter.accountInfo),
                ),
                _buildListTile(
                  context,
                  icon: Icons.person_outline,
                  title: "Personal Information",
                  onTap: () => context.push(AppRouter.personalInfo),
                ),
                _buildListTile(
                  context,
                  icon: Icons.credit_card_outlined,
                  title: "Cards Details",
                  onTap: () => context.push(AppRouter.checkout),
                ),

                ListTile(
                  leading: Icon(Icons.translate, color: theme.iconTheme.color),
                  title: Text("Language App", style: theme.textTheme.bodyLarge),
                  trailing: GestureDetector(
                    onTap: () {
                      setState(() {
                        isArabic = !isArabic;
                      });
                      // TODO: Implement localization logic later
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isArabic ? "Ar" : "En",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Divider(height: 1, color: theme.dividerColor),

                ListTile(
                  leading: Icon(Icons.wb_sunny_outlined, color: theme.iconTheme.color),
                  title: Text("App Theme", style: theme.textTheme.bodyLarge),
                  trailing: Switch(
                    value: isDarkTheme,
                    onChanged: (v) {
                      setState(() {
                        isDarkTheme = v;
                      });
                      // TODO: Implement theme switching logic later
                    },
                    activeTrackColor: theme.colorScheme.primary,
                  ),
                ),
                Divider(height: 1, color: theme.dividerColor),

                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Sign Out", style: TextStyle(color: Colors.red)),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, {required IconData icon, required String title, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: theme.iconTheme.color),
          title: Text(title, style: theme.textTheme.bodyLarge),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.iconTheme.color),
          onTap: onTap,
        ),
        Divider(height: 1, color: theme.dividerColor),
      ],
    );
  }
}