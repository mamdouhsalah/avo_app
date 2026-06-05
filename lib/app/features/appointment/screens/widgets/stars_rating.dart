import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class RatingStars extends StatelessWidget {
  final double rating;

  const RatingStars({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        IconData icon;
        Color color;

        if (index < rating.floor()) {
          icon = Icons.star;
          color = colorScheme.primary;
        } else if (index < rating) {
          icon = Icons.star_half;
          color = colorScheme.primary;
        } else {
          icon = Icons.star_border;
          color = Colors.grey;
        }

        return Padding(
          padding: EdgeInsets.only(right: 4.w),
          child: Icon(
            icon,
            color: color,
            size: 45.sp,
          ),
        );
      }),
    );
  }
}