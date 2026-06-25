// lib/app/features/admin/views/screen/admin_users_screen.dart
import 'package:avo_app/app/core/constants/app_colors.dart';
import 'package:avo_app/app/core/constants/database_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _db = FirebaseDatabase.instance;
  Stream<List<Map<String, dynamic>>>? _usersStream;
  String _filterRole = 'all';

  final _filters = ['all', 'patient', 'doctor', 'admin', 'verified', 'pending'];
  final _labels = ['All', 'Patient', 'Doctor', 'Admin', 'Verified', 'Pending'];

  @override
  void initState() {
    super.initState();
    _usersStream = _db
        .ref(DatabasePaths.users)
        .onValue
        .map((event) {
      final snap = event.snapshot;
      if (!snap.exists || snap.value == null) return [];
      final List<Map<String, dynamic>> users = [];
      final raw = snap.value;
      if (raw is Map) {
        raw.forEach((key, value) {
          if (value is Map) {
            final data = Map<String, dynamic>.from(value);
            data['id'] = key.toString();
            users.add(data);
          }
        });
      }
      return users;
    });
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'doctor':
        return 'Doctor';
      case 'patient':
        return 'Patient';
      case 'admin':
        return 'Admin';
      case 'radiology_specialist':
        return 'Radiologist';
      case 'pharmacy_specialist':
        return 'Pharmacist';
      default:
        return role;
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'doctor':
        return const Color(0xFF0095FF);
      case 'patient':
        return AppColors.lightPrimary;
      case 'admin':
        return const Color(0xFF735BF2);
      case 'verified':
        return const Color(0xFF00A991); // Green
      case 'pending':
        return const Color(0xFFFBC02D); // Yellow
      default:
        return AppColors.lightSecondaryText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter
          SizedBox(
            height: 50.h,
            child: ListView.separated(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, i) {
                final isSelected = _filterRole == _filters[i];
                final color = _roleColor(_filters[i]);
                return GestureDetector(
                  onTap: () => setState(() => _filterRole = _filters[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color
                          : color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected
                            ? color
                            : color.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _labels[i],
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : color,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Users List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _usersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.lightPrimary),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  );
                }
                var users = snapshot.data ?? [];
                if (_filterRole != 'all') {
                  if (_filterRole == 'verified') {
                    users = users.where((u) => u['isVerified'] == true || u['is_verified'] == true).toList();
                  } else if (_filterRole == 'pending') {
                    users = users.where((u) => u['isVerified'] != true && u['is_verified'] != true).toList();
                  } else {
                    users = users.where((u) => u['role'] == _filterRole).toList();
                  }
                }

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          size: 64.sp,
                          color: AppColors.lightPrimary.withValues(alpha: 0.3),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'No users found',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 8.h),
                  itemCount: users.length,
                  itemBuilder: (context, i) {
                    final user = users[i];
                    final role = user['role']?.toString() ?? '';
                    final roleColor = _roleColor(role);
                    final isVerified = user['isVerified'] == true || user['is_verified'] == true;
                    final email =
                        user['email']?.toString() ?? 'No Email';
                    final name =
                        user['full_name']?.toString() ?? user['fullName']?.toString() ?? 'No Name';
                    final imageUrl = user['image']?.toString();
                    final createdAt = user['createdAt'] != null
                        ? DateFormat('dd MMM yyyy').format(
                            DateTime.fromMillisecondsSinceEpoch(
                              (user['createdAt'] as num).toInt(),
                            ),
                          )
                        : null;

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 5.h),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 6.h),
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              radius: 24.r,
                              backgroundColor:
                                  roleColor.withValues(alpha: 0.12),
                              backgroundImage: imageUrl != null &&
                                      imageUrl.isNotEmpty
                                  ? NetworkImage(imageUrl)
                                  : null,
                              child: imageUrl == null || imageUrl.isEmpty
                                  ? Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: roleColor,
                                      ),
                                    )
                                  : null,
                            ),
                            if (isVerified)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: EdgeInsets.all(2.r),
                                  decoration: const BoxDecoration(
                                    color: AppColors.lightPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 9.sp,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              email,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (createdAt != null)
                              Text(
                                'Registered: $createdAt',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                          ],
                        ),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                                color: roleColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            _roleLabel(role),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: roleColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
