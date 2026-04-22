import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class RatingStars extends StatelessWidget {
  final double rating;

  const RatingStars({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Padding(
            padding: EdgeInsets.only(right: 4.0.w),
            child: Icon(Icons.star, color: colorScheme.primary ,size: 45.sp,),
          );
        } else if (index < rating) {  
          return Padding(
            padding: EdgeInsets.only(right: 4.0.w),
            child: Icon(Icons.star_half, color: colorScheme.primary, size: 45.sp),
          );
        } else {
          return Padding(
            padding: EdgeInsets.only(right: 4.0.w),
            child: Icon(Icons.star_border, color: Colors.grey, size: 45.sp),
          );
        }
      }),
    );
  }
}