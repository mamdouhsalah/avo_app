import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

InputDecoration buildInputDecoration({
  required BuildContext context,
  required String hint,
  String? svgPath,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return InputDecoration(
    hintText: hint,

    // spacing inside
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),

    // prefix (like VISA icon)
    prefixIcon: Padding(
      padding:  EdgeInsets.all(4.w),
      child: Align(
  widthFactor: 1,
  heightFactor: 1,
  child: Padding(
    padding: const EdgeInsets.only(left: 12, right: 8),
    child: svgPath!=null? SvgPicture.asset(
          svgPath,
          width: 28,
          height: 20,
          color: colorScheme.onSurface,
        ): null
      ),
    ),
  ),
    
    hintStyle: TextStyle(fontSize: 16.sp, color: Colors.grey),

    // default border
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: BorderSide(
        color: colorScheme.onSurface,
        width: 1.w,
      ),
    ),

    // normal state
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: BorderSide(
        color: colorScheme.onSurface,
        width: 1.w,
      ),
    ),

    // focused 
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: BorderSide(
        color: colorScheme.primary,
        width: 1.5,
      ),
    ),

    /// error
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: BorderSide(
        color: colorScheme.error,
        width: 1.5.w,
      ),
    ),
  );
}