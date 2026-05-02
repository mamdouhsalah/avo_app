import 'package:avo_app/app/core/constants/app_colors.dart';
import 'package:avo_app/app/core/models/medicine_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MedicineCard extends StatelessWidget {
  final MedicineModel medicine;

  const MedicineCard({
    super.key,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 16.w),
      height: 197.h,
      width: 325.w,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.lightPrimary,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                medicine.time,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w400,
                  fontSize: 18.37.sp,
                ),
              ),
              const Spacer(),
              Container(
                height: 21.43.h,
                width: 63.67.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text(
                    "In ${medicine.time[medicine.time.length - 1]} min ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 10.72.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 15.h),

          Row(
            children: [
              Container(
                height: 49.h,
                width: 49.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.medication_liquid,
                    color: Theme.of(context).colorScheme.primary),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w400,
                        fontSize: 16.sp,
                      ),
                    ),
                    Text(
                      medicine.dosage,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Spacer(),
          // Mark as Taken Button
          SizedBox(
            height: 40.h,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.lightPrimary,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: () {},
              child: Text(
                "Mark as Taken",
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
