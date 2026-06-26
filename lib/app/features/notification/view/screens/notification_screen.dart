import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text('Notifications',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 100.h),
            Icon(
              Icons.notifications_none_outlined,
              size: 64.sp,
              color: theme.colorScheme.outlineVariant,
            ),
            SizedBox(height: 16.h),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 16.sp,
                color: theme.colorScheme.outlineVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
