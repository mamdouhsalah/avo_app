import 'package:avo_app/app/core/constants/app_colors.dart';
import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:easy_localization/easy_localization.dart'; // 🔥 الترجمة
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Language/locale_keys.g.dart';


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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 170.h,
      margin: EdgeInsets.only(bottom: 12.h), // 💡 المسافة السفلية مش محتاجة Directional
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 1.2.sp,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Top Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 👨‍⚕️ Image
              Container(
                width: 55.r,
                height: 55.r,
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    doctor.imageUrl.toString(),
                    width: 55.r,
                    height: 55.r,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              /// 📌 Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      "(${doctor.specialty})",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    /// ⭐ Rating + Time
                    Row(
                      children: [
                        Text("${doctor.rating}",
                            style: TextStyle(fontSize: 12.sp)),
                        SizedBox(width: 2.w),
                        Icon(Icons.star,
                            color: AppColors.lightOrangeOutLine, size: 14.sp),
                        SizedBox(width: 8.w),
                        Icon(Icons.access_time, size: 16.sp),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            "${doctor.openTime} - ${doctor.closeTime}",
                            style: TextStyle(fontSize: 12.sp),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// ❤️ Favorite
              IconButton(
                onPressed: onFavoriteToggle,
                icon: Icon(
                  doctor.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: doctor.isFavorite
                      ? theme.colorScheme.error
                      : theme.colorScheme.outlineVariant,
                  size: 22.sp,
                ),
              ),
            ],
          ),

          const Spacer(),
          InkWell(
            onTap: onBook, // 💡 تأكدت إن الـ onBook متوصل بالزرار بدل ما كان فاضي () {}
            child: Container(
              width: double.infinity,
              height: 40.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                LocaleKeys.general_book_appointment.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}