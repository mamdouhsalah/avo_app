// lib/app/features/admin/views/widgets/log_tile.dart
import 'package:avo_app/app/features/admin/models/app_log_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class LogTile extends StatelessWidget {
  final AppLogModel log;

  const LogTile({super.key, required this.log});

  Color _getLevelColor(BuildContext context) {
    switch (log.level) {
      case 'error':
        return const Color(0xFFD32F2F);
      case 'warning':
        return const Color(0xFFFBC02D);
      case 'success':
        return const Color(0xFF00A991);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _getLevelIcon() {
    switch (log.level) {
      case 'error':
        return Icons.error_outline_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'success':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _getTypeLabel() {
    switch (log.type) {
      case 'user_login':
        return 'Login';
      case 'user_registration':
        return 'Registration';
      case 'login_error':
        return 'Login Error';
      case 'register_error':
        return 'Registration Error';
      default:
        return log.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getLevelColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedTime =
        DateFormat('dd MMM, hh:mm a').format(log.dateTime);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E1E)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border(
          left: BorderSide(color: color, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        leading: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(_getLevelIcon(), color: color, size: 18.sp),
        ),
        title: Row(
          children: [
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                _getTypeLabel(),
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                log.email,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text(
            log.message,
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.55),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Text(
          formattedTime,
          style: TextStyle(
            fontSize: 10.sp,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
