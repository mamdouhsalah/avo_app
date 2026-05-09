import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {"icon": Icons.map_outlined, "label": "Maps"},
      {"icon": Icons.calendar_today, "label": "Schedule"},
      {"icon": Icons.medical_services_outlined, "label": "Home"},
      {"icon": Icons.access_time_outlined, "label": "Reminder"},
      {"icon": Icons.person_outline, "label": "Profile"},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Padding(
        padding: EdgeInsets.all(10.sp),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = index == currentIndex;

            return GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 16.w : 0,
                  vertical: isSelected ? 8.h : 0,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isSelected ? 55.r : 0),
                    topRight: Radius.circular(isSelected ? 55.r : 0),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[index]["icon"] as IconData,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      items[index]["label"] as String,
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.outlineVariant,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
