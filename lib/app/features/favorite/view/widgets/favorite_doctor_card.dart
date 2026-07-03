import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/core/services/auth_service.dart';
import 'package:avo_app/app/features/favorite/logic/favorite_cubit.dart';
import 'package:avo_app/app/features/favorite/logic/favorite_sate.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';


class DoctorCard extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorCard({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthService>().currentUid;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool hasClinic = doctor.clinic != null && doctor.clinic!.trim().isNotEmpty;
    final bool hasBio = doctor.bio.trim().isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: () {
        context.push(AppRouter.bookPatient, extra: doctor.id);
      },
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: 24.w, top: 16.h),
        child: SizedBox(
          width: 343.w,
          height: 255.h,
          child: Stack(
            children: [
              Container(
                width: 343.w,
                margin: EdgeInsetsDirectional.only(end: 33.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: colorScheme.primary,
                    width: 1.w,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// ================= IMAGE (top middle, bigger) =================
                    Container(
                      width: 90.r,
                      height: 90.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: doctor.imageUrl.isNotEmpty
                            ? Image.network(
                                doctor.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/imgs/doctor/doctor1.png',
                                    fit: BoxFit.cover,
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/imgs/doctor/doctor1.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    /// ================= NAME =================
                    Text(
                      doctor.name,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 4.h),

                    /// ================= SPECIALTY / CLINIC =================
                    Text(
                      hasClinic
                          ? "${doctor.specialty} (${doctor.clinic})"
                          : doctor.specialty,
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 12.h),

                    /// ================= RATING =================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          doctor.rating.toStringAsFixed(2),
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.star,
                          color: Colors.orange,
                          size: 18.sp,
                        ),
                        SizedBox(width: 15.w),
                        Text(
                          "${doctor.numberOfReviews}  ${LocaleKeys.booking_number_of_reviews.tr()}",
                          
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),

                    /// ================= BIO =================
                    if (hasBio) ...[
                      SizedBox(height: 12.h),
                      Text(
                        doctor.bio,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),

              /// ================= FAVORITE ICON =================
              PositionedDirectional(
                top: 8.h,
                end: 41.w,
                child: BlocBuilder<FavoriteCubit, FavoriteState>(
                  builder: (context, favoriteState) {
                    final isFav = context.read<FavoriteCubit>().isFavorite(doctor.id);

                    return IconButton(
                      onPressed: () {
                        context.read<FavoriteCubit>().toggleFavorite(
                              uid!,
                              doctor.id,
                            );
                      },
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                        size: 24.sp,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}