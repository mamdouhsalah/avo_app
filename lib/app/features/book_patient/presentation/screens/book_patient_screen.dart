import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/shared/loading_indicator_widget.dart';
import 'package:avo_app/app/core/shared/main_button.dart';
import 'package:avo_app/app/features/profile/logic/profile_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../cubit/book_patient_cubit.dart';
import '../cubit/book_patient_state.dart';

class BookPatientScreen extends StatefulWidget {
  final String? doctorId;

  const BookPatientScreen({super.key, this.doctorId});

  @override
  State<BookPatientScreen> createState() => _BookPatientScreenState();
}

class _BookPatientScreenState extends State<BookPatientScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.doctorId != null) {
      context.read<BookPatientCubit>().loadDoctor(widget.doctorId!);
    }
  }

  String _getWorkingHours(BookPatientLoaded state) {
    if (state.schedules.isEmpty) {
      return "09:00 AM - 05:00 PM";
    }
    final first = state.schedules.first;
    return "${first.startTime} - ${first.endTime}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          LocaleKeys.profile_doctor_info.tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<BookPatientCubit, BookPatientState>(
        listener: (context, state) {
          if (state is BookPatientBookingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(LocaleKeys.booking_booking_success.tr()),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is BookPatientBookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BookPatientLoading || state is BookPatientInitial) {
            return const Center(child: LoadingIndicatorWidget());
          } else if (state is BookPatientError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: colorScheme.error, fontSize: 16.sp),
              ),
            );
          } else if (state is BookPatientLoaded) {
            final doctor = state.doctor;
            return Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 260.h,
                          color: colorScheme.primary.withValues(alpha: 0.08),
                          alignment: Alignment.center,
                          child: doctor.imageUrl.isNotEmpty
                              ? Image.network(
                                  doctor.imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.person, size: 80.r, color: colorScheme.outlineVariant),
                                )
                              : Icon(Icons.person, size: 80.r, color: colorScheme.outlineVariant),
                        ),
                        Transform.translate(
                          offset: Offset(0, -20.h),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24.r),
                                topRight: Radius.circular(24.r),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    width: 50.w,
                                    height: 5.h,
                                    decoration: BoxDecoration(
                                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        doctor.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24.sp,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "${doctor.rating}",
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        Icon(Icons.star, color: Colors.amber, size: 18.sp),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  doctor.location != null && doctor.location!.isNotEmpty
                                      ? "${doctor.specialty} | ${doctor.location}"
                                      : doctor.specialty,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_outlined,
                                        color: colorScheme.outlineVariant, size: 18.sp),
                                    SizedBox(width: 6.w),
                                    Text(
                                      _getWorkingHours(state),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                const Divider(),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildStatItem("${doctor.numberOfReviews}", LocaleKeys.booking_number_of_reviews.tr(), colorScheme),
                                      _buildStatItem("${doctor.patientsTreated}+", LocaleKeys.booking_treated.tr(), colorScheme),
                                      _buildStatItem("\$${doctor.price.toInt()}", LocaleKeys.booking_hourly_rate.tr(), colorScheme),
                                    ],
                                  ),
                                ),
                                const Divider(),
                                SizedBox(height: 16.h),
                                Text(
                                  LocaleKeys.booking_schedules.tr(),
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                state.schedules.isEmpty
                                    ? Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 20.h),
                                          child: Text(
                                            LocaleKeys.booking_no_available_schedules.tr(),
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      )
                                    : GridView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 12.h,
                                          crossAxisSpacing: 12.w,
                                          childAspectRatio: 2.8,
                                        ),
                                        itemCount: state.schedules.length,
                                        itemBuilder: (context, index) {
                                          final schedule = state.schedules[index];
                                          final isSelected = state.selectedSchedule?.id == schedule.id;

                                          return GestureDetector(
                                            onTap: () {
                                              context.read<BookPatientCubit>().selectSchedule(schedule);
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? colorScheme.primary
                                                    : colorScheme.surface,
                                                borderRadius: BorderRadius.circular(10.r),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? colorScheme.primary
                                                      : colorScheme.outlineVariant,
                                                  width: 1.w,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "${schedule.startTime} - ${schedule.endTime}",
                                                    style: TextStyle(
                                                      fontSize: 13.sp,
                                                      fontWeight: FontWeight.bold,
                                                      color: isSelected
                                                          ? colorScheme.onPrimary
                                                          : colorScheme.onSurface,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Text(
                                                    schedule.day,
                                                    style: TextStyle(
                                                      fontSize: 11.sp,
                                                      color: isSelected
                                                          ? colorScheme.onPrimary.withValues(alpha: 0.8)
                                                          : colorScheme.onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                SizedBox(height: 100.h),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20.h,
                  left: 20.w,
                  right: 20.w,
                  child: IgnorePointer(
                    ignoring: state.selectedSchedule == null,
                    child: Opacity(
                      opacity: state.selectedSchedule == null ? 0.5 : 1.0,
                      child: MainButton(
                        width: double.infinity,
                        height: 50.h,
                        text: LocaleKeys.general_book_appointment.tr(),
                        onPressed: () {
                          final profileCubit = context.read<ProfileCubit>();
                          final patientId = FirebaseAuth.instance.currentUser?.uid ?? '';
                          final patientName = profileCubit.userProfile?.fullName ?? 'Patient';

                          context.read<BookPatientCubit>().bookAppointment(
                                patientId: patientId,
                                patientName: patientName,
                              );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatItem(String val, String title, ColorScheme colorScheme) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
