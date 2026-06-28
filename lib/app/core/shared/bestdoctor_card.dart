import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/shared/main_button.dart';

class BestDoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onBook;

  const BestDoctorCard({
    super.key,
    required this.doctor,
    required this.onFavoriteToggle,
    required this.onBook,
  });

  String _getWorkingHours() {
    if (doctor.schedules == null || doctor.schedules!.isEmpty) {
      return "09:00 AM - 05:00 PM";
    }
    final first = doctor.schedules!.first;
    return "${first.startTime} - ${first.endTime}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1.2.sp,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60.r,
                height: 60.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary,
                    width: 2.r,
                  ),
                ),
                child: ClipOval(
                  child: doctor.imageUrl.isNotEmpty
                      ? Image.network(
                          doctor.imageUrl,
                          width: 60.r,
                          height: 60.r,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.person, size: 30.r, color: colorScheme.onSurfaceVariant),
                        )
                      : Icon(Icons.person, size: 30.r, color: colorScheme.onSurfaceVariant),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            doctor.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: onFavoriteToggle,
                          child: Icon(
                            doctor.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: doctor.isFavorite ? Colors.red : colorScheme.outlineVariant,
                            size: 24.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      doctor.location != null && doctor.location!.isNotEmpty
                          ? "${doctor.specialty} | ${doctor.location}"
                          : doctor.specialty,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text(
                          "${doctor.rating}",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(Icons.star, color: Colors.amber, size: 14.sp),
                        SizedBox(width: 12.w),
                        Icon(Icons.access_time, color: colorScheme.outlineVariant, size: 14.sp),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            _getWorkingHours(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          MainButton(
            width: double.infinity,
            height: 44.h,
            text: LocaleKeys.general_book_appointment.tr(),
            onPressed: onBook,
          ),
        ],
      ),
    );
  }
}