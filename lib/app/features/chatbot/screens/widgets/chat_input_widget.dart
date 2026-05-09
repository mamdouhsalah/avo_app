import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:avo_app/app/core/constants/app_spacing.dart';

class ChatInputWidget extends StatelessWidget {
  const ChatInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // قائمة الاقتراحات الوهمية كما في ديزاين Figma
    final List<String> suggestions = [
      "I need medical advice",
      "Check symptoms",
      "Nearby hospitals",
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // شريط الاقتراحات (Suggestions Bar)
            SizedBox(
              height: 50.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.h16, vertical: 8.h),
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(right: AppSpacing.h8),
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      suggestions[index],
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),

            // حقل الإدخال الأساسي
            Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.h16, 0, AppSpacing.h16, AppSpacing.v12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.h12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline, color: theme.colorScheme.onSurface.withValues(alpha: 0.5), size: 22.sp),
                          SizedBox(width: AppSpacing.h8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Ask AI...",
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                              ),
                            ),
                          ),
                          Icon(Icons.mic_none_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.5), size: 22.sp),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.h12),
                  CircleAvatar(
                    radius: 22.r,
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(Icons.send_rounded, color: theme.colorScheme.onPrimary, size: 20.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}