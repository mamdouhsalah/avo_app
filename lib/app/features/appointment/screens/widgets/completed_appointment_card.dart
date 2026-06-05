import 'package:avo_app/app/core/shared/main_button.dart';
import 'package:avo_app/app/core/utils/date_utils.dart';
import 'package:avo_app/app/core/utils/is_today.dart';
import 'package:avo_app/app/features/appointment/data/models/appointment.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/stars_rating.dart';
import 'package:flutter/material.dart';
import 'package:avo_app/app/core/constants/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompletedAppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const CompletedAppointmentCard({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;


    return  Padding(
      padding: EdgeInsets.only(left: 24.w, top: 16.h ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // date on day for the oppointment
            Text(
              isToday(date : appointment.date) ? "Today" : "${appointment.date.day} ${ getMonthNameFromDate(date :appointment.date)}",
              style: TextStyle(
                color: colorScheme.onSurface, 
                fontSize: 14.sp,
                fontWeight: FontWeight.bold
              ),
            ),
      
        SizedBox(height: 16.h),
      
        SizedBox(
              height: 225.h,
              child:
            Container(
              width: 343.w,
              margin: EdgeInsets.only(right: 33.w),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ================= TOP =================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Image
                      Container(
                        width: 55.r,
                        height: 55.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            appointment.doctorPictureUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
            
                      SizedBox(width: 16.w),
            
                      /// Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.doctorName,
                              style: TextStyle(
                                color: colorScheme.onSurface, 
                                fontWeight: FontWeight.w500,
                                fontSize: 16.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
            
                            Text(
                              "(${appointment.specialty} | ${appointment.clinic})",
                              style: TextStyle(
                                color: Colors.grey, 
                                fontWeight: FontWeight.w400,
                                fontSize: 12.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // rate and star
                         Row(
                          children: [
                            Text(
                              "${appointment.rating}",
                              style: TextStyle(
                                color: colorScheme.onSurface, 
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400
                              ),
                            ),
                            
                            SizedBox(width: 10.w),
                        
                            Icon(
                              Icons.star,
                              color: AppColors.lightOrangeOutLine,
                              size: 18.sp,
                            ),
                          ],
                        ),
                    ],
                  ),
               // stars based on rating
               SizedBox(height: 16.h),

                RatingStars(rating: appointment.rating),

                SizedBox(height: 8.h),
                
                // review your experience with the doctor
                Center(
                  child: Text(
                    "Review your experience",
                    style: TextStyle(
                      color: Colors.grey, 
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                ),

                 SizedBox(height: 16.h),
               
                /// button
                MainButton(
                  text: appointment.status == AppointmentStatus.upcoming
                    ? "Cancel Appointment": "Reschedule",
                  onPressed: () {}
                )
                ],
              ),
            ),
            ),
          ],
      ),
    );
  }
}