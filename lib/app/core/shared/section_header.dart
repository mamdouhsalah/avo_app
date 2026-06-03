import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? routePath;

  const SectionHeader({
    super.key,
    required this.title,
    this.routePath,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 16.sp,
          ),
        ),
        const Spacer(),

        if (routePath != null)
          InkWell(
            onTap: () {
              context.push(routePath!);
            },
            child: Text(
              "view all",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14.sp,
              ),
            ),
          ),
      ],
    );
  }
}
