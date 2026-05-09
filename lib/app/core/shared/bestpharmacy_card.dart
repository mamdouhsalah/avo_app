import 'package:avo_app/app/core/constants/app_colors.dart';
import 'package:avo_app/app/core/models/pharmacy_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BestPharmacyCard extends StatelessWidget {
  final PharmacyModel pharmacy;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const BestPharmacyCard({
    super.key,
    required this.pharmacy,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity.w,
      height: 170.h,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5.sp,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🏥 Image
              ClipOval(
                clipBehavior: Clip.antiAlias,
                key: ValueKey(pharmacy.id),
                child: Image.asset(
                  pharmacy.imageUrl.toString(),
                  width: 55.r,
                  height: 55.r,
                  fit: BoxFit.fill,
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Name
                    Text(
                      pharmacy.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    /// Type
                    Text(
                      pharmacy.type.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Row(
                      children: [
                        Text(
                          "${pharmacy.rating}",
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        SizedBox(width: 2.w),
                        Icon(Icons.star,
                            color: AppColors.lightOrangeOutLine, size: 14.sp),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.access_time,
                          size: 16.sp,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            "${pharmacy.openTime} - ${pharmacy.closeTime}",
                            style: TextStyle(fontSize: 12.sp),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: onFavoriteToggle,
                icon: Icon(
                  pharmacy.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: pharmacy.isFavorite
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.outlineVariant,
                  size: 22.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Spacer(),
          InkWell(
            onTap: () {},
            child: Container(
              width: double.infinity,
              height: 40.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                "Buy Medicine",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
