import 'package:avo_app/app/core/shared/main_button.dart';
import 'package:easy_localization/easy_localization.dart'; // 🔥 الترجمة
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Language/locale_keys.g.dart';


class ErrorFeedbackWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;
  final double? height;

  const ErrorFeedbackWidget({
    super.key,
    required this.errorMessage,
    this.onRetry,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 200.h,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Theme.of(context).colorScheme.error,
                size: 24.sp,
              ),
              SizedBox(height: 12.h),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (onRetry != null) ...[
                SizedBox(height: 16.h),
                MainButton(
                  text: LocaleKeys.general_retry.tr(),
                  onPressed: onRetry!,
                  width: 150.w,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}