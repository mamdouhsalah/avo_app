import 'package:avo_app/app/features/appointment/logic/appointment_cubit.dart';
import 'package:avo_app/app/features/appointment/logic/appointment_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avo_app/app/features/home/logic/home_cubit.dart';
import 'package:avo_app/app/features/home/logic/home_state.dart';
import 'package:avo_app/app/features/reminder/logic/reminder_cubit.dart';
import 'package:avo_app/app/features/reminder/data/reminder_model.dart';
import 'package:avo_app/app/core/models/medicine_model.dart';
import 'package:avo_app/app/core/shared/loading_indicator_widget.dart';
import 'package:avo_app/app/core/shared/error_feedback_widget.dart';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:avo_app/app/core/shared/appointment_card.dart';
import 'package:avo_app/app/features/home/view/widget/catogery_item.dart';
import 'package:avo_app/app/core/shared/bestdoctor_card.dart';
import 'package:avo_app/app/core/shared/medicine_card.dart';
import 'package:avo_app/app/core/shared/bestpharmacy_card.dart';
import 'package:avo_app/app/features/notification/logic/app_notification_cubit.dart';
import 'package:avo_app/app/features/notification/logic/app_notification_state.dart';
import 'package:avo_app/app/core/shared/section_header.dart';
import 'package:avo_app/app/features/favorite/logic/favorite_cubit.dart';
import 'package:avo_app/app/features/favorite/logic/favorite_sate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/Language/locale_keys.g.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 2;
  bool isVisible = true;
  int selectedCategoryIndex = -1;
  bool isAtTop = true;

  String _calculateMinsUntil(String timeStr) {
    try {
      final timeStrTrimmed = timeStr.trim().toUpperCase();
      final isPM = timeStrTrimmed.contains('PM');
      final isAM = timeStrTrimmed.contains('AM');
      final cleanTime =
          timeStrTrimmed.replaceAll('AM', '').replaceAll('PM', '').trim();
      final parts = cleanTime.split(':');
      if (parts.length < 2) return '--';

      int hour = int.parse(parts[0]);
      final min = int.parse(parts[1]);

      if (isPM && hour != 12) hour += 12;
      if (isAM && hour == 12) hour = 0;

      final medMinutes = hour * 60 + min;
      final now = TimeOfDay.now();
      final currentMinutes = now.hour * 60 + now.minute;

      final diff = medMinutes - currentMinutes;
      if (diff < 0) return '0';
      return diff.toString();
    } catch (_) {
      return '--';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return const Scaffold(
            body: Center(
              child: LoadingIndicatorWidget(),
            ),
          );
        } else if (state is HomeError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: ErrorFeedbackWidget(
                  errorMessage: state.message,
                  onRetry: () {
                    context.read<HomeCubit>().loadDashboard('1');
                  },
                ),
              ),
            ),
          );
        } else if (state is HomeLoaded) {
          final user = state.currentUser;
          return Scaffold(
            body: Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollUpdateNotification) {
                      final atTop = notification.metrics.pixels <= 10;
                      if (atTop != isAtTop) {
                        setState(() => isAtTop = atTop);
                      }
                    }
                    if (notification is UserScrollNotification) {
                      if (notification.direction == ScrollDirection.reverse) {
                        if (isVisible) setState(() => isVisible = false);
                      } else if (notification.direction ==
                          ScrollDirection.forward) {
                        if (!isVisible) setState(() => isVisible = true);
                      }
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        scrolledUnderElevation: 0,
                        floating: true,
                        elevation: 0,
                        title: Text(
                          LocaleKeys.home_title.tr(),
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        centerTitle: true,
                        actions: [
                          BlocBuilder<AppNotificationCubit,
                              AppNotificationState>(
                            builder: (context, notifState) {
                              int unreadCount = 0;
                              if (notifState is AppNotificationLoaded) {
                                unreadCount = notifState.unreadCount;
                              }
                              return IconButton(
                                onPressed: () =>
                                    context.push(AppRouter.notifications),
                                icon: Badge(
                                  isLabelVisible: unreadCount > 0,
                                  label: Text(unreadCount.toString()),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                  child: Icon(
                                    Icons.notifications_none_outlined,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 28.sp,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 1.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 55.r,
                                    height: 55.r,
                                    padding: const EdgeInsets.all(0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: user.image != null &&
                                              user.image!.isNotEmpty
                                          ? (user.image!.startsWith('http')
                                              ? Image.network(
                                                  user.image!,
                                                  width: 55.r,
                                                  height: 55.r,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Icon(Icons.person,
                                                          size: 30.r),
                                                )
                                              : Image.asset(
                                                  user.image!,
                                                  width: 55.r,
                                                  height: 55.r,
                                                  fit: BoxFit.cover,
                                                ))
                                          : Icon(Icons.person, size: 30.r),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        LocaleKeys.home_welcome.tr(),
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outlineVariant,
                                        ),
                                      ),
                                      Text(
                                        user.fullName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      context.push(AppRouter.favoriteDoctors);
                                    },
                                    icon: Icon(
                                      Icons.favorite_border_outlined,
                                      size: 28.sp,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24.h),
                              InkWell(
                                borderRadius: BorderRadius.circular(12.r),
                                onTap: () {
                                  context.push(AppRouter.search);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 12.h),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 2,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant,
                                    ),
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.search,
                                          size: 24.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outlineVariant),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Text(
                                          LocaleKeys.general_search.tr(),
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outlineVariant,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                      Icon(Icons.filter_alt_outlined,
                                          size: 24.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outlineVariant),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 25.h),
                              SectionHeader(
                                title:
                                    LocaleKeys.home_upcoming_appointments.tr(),
                                routePath: AppRouter.patientAppointment,
                                onTap: () {
                                  context.push(AppRouter.patientAppointment);
                                },
                              ),
                              SizedBox(height: 16.h),
                              SizedBox(
                                height: 158.h,
                                child: BlocBuilder<AppointmentCubit,
                                    AppointmentState>(
                                  builder: (context, appointmentState) {
                                    if (appointmentState
                                        is AppointmentLoading) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }

                                    if (appointmentState is AppointmentError) {
                                      return Center(
                                        child: Text(
                                          appointmentState.message,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      );
                                    }

                                    final cubit =
                                        context.read<AppointmentCubit>();
                                    final upcoming = cubit.upcomingAppointments;

                                    if (upcoming.isEmpty) {
                                      return Center(
                                        child: Text(
                                          LocaleKeys
                                              .home_no_upcoming_appointments
                                              .tr(),
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      );
                                    }

                                    return ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: upcoming.length,
                                      itemBuilder: (_, i) {
                                        return AppointmentCard(
                                          appointmentCard: upcoming[i],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 24.h),
                              SectionHeader(
                                title: LocaleKeys.home_upcoming_medicine.tr(),
                                onTap: () {
                                  context.go(AppRouter.reminder);
                                },
                              ),
                              SizedBox(height: 16.h),
                              BlocBuilder<ReminderCubit, ReminderState>(
                                builder: (context, reminderState) {
                                  List<MedicineModel> upcomingMedicines = [];
                                  List<ReminderModel> upcomingReminders = [];

                                  if (reminderState is ReminderLoaded) {
                                    upcomingReminders = reminderState
                                        .todaysSchedule
                                        .where((r) =>
                                            r.status == 'upcoming' ||
                                            r.status == 'next' ||
                                            r.status == 'overdue')
                                        .toList();

                                    upcomingMedicines = upcomingReminders
                                        .map((r) => MedicineModel(
                                              id: r.id,
                                              name: r.name,
                                              dosage: r.dosage,
                                              time: r.time,
                                              isTaken: false,
                                            ))
                                        .toList();
                                  }

                                  return SizedBox(
                                    height: 200.h,
                                    child: (reminderState is ReminderLoading)
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : upcomingMedicines.isEmpty
                                            ? Center(
                                                child: Text(
                                                  LocaleKeys
                                                      .home_no_medicines_scheduled
                                                      .tr(),
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .outline,
                                                    fontSize: 13.sp,
                                                  ),
                                                ),
                                              )
                                            : ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    upcomingMedicines.length,
                                                itemBuilder: (_, i) {
                                                  final reminder =
                                                      upcomingReminders[i];
                                                  return MedicineCard(
                                                    medicine:
                                                        upcomingMedicines[i],
                                                    minsUntil:
                                                        _calculateMinsUntil(
                                                            reminder.time),
                                                    onMarkAsTaken: () {
                                                      context
                                                          .read<ReminderCubit>()
                                                          .markAsTaken(
                                                              reminder);
                                                    },
                                                  );
                                                },
                                              ),
                                  );
                                },
                              ),
                              SizedBox(height: 24.h),
                              SectionHeader(
                                title: LocaleKeys.home_categories.tr(),
                                routePath: AppRouter.categories,
                              ),
                              state.categories.isEmpty
                                  ? Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20.h),
                                      child: Center(
                                        child: Text(
                                            LocaleKeys.home_no_categories.tr()),
                                      ),
                                    )
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.only(top: 16.h),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        mainAxisSpacing: 16.h,
                                        crossAxisSpacing: 19.w,
                                      ),
                                      itemCount: state.categories.length > 8
                                          ? 8
                                          : state.categories.length,
                                      itemBuilder: (_, index) {
                                        return CategoryItem(
                                          category: state.categories[index],
                                          isSelected:
                                              selectedCategoryIndex == index,
                                          onTap: () {
                                            setState(() {
                                              selectedCategoryIndex = index;
                                            });
                                          },
                                          onDoubleTap: () {
                                            setState(() {
                                              selectedCategoryIndex = -1;
                                            });
                                          },
                                        );
                                      },
                                    ),
                              SizedBox(height: 24.h),
                              SectionHeader(
                                title: LocaleKeys.home_best_doctors.tr(),
                                routePath: AppRouter.allDoctors,
                              ),
                              SizedBox(height: 16.h),
                              state.bestDoctors.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 20.h),
                                        child: Text(
                                            LocaleKeys.home_no_doctors.tr()),
                                      ),
                                    )
                                  : BlocBuilder<FavoriteCubit, FavoriteState>(
                                      builder: (context, favState) {
                                        final patientId = FirebaseAuth
                                                .instance.currentUser?.uid ??
                                            '';
                                        return Column(
                                          children:
                                              state.bestDoctors.map((doc) {
                                            final isFav = context
                                                .read<FavoriteCubit>()
                                                .isFavorite(doc.id);
                                            final updatedDoc =
                                                doc.copyWith(isFavorite: isFav);
                                            return BestDoctorCard(
                                              key: ValueKey(doc.id),
                                              doctor: updatedDoc,
                                              onFavoriteToggle: () {
                                                context
                                                    .read<FavoriteCubit>()
                                                    .toggleFavorite(
                                                        patientId, doc.id);
                                              },
                                              onBook: () => context.push(
                                                  AppRouter.bookPatient,
                                                  extra: doc.id),
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),
                              SizedBox(height: 16.h),
                              SectionHeader(
                                title: LocaleKeys.home_best_pharmacies.tr(),
                                routePath: AppRouter.allPharmacies,
                              ),
                              SizedBox(height: 16.h),
                              state.bestPharmacies.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 20.h),
                                        child: Text(
                                            LocaleKeys.home_no_pharmacies.tr()),
                                      ),
                                    )
                                  : BlocBuilder<FavoriteCubit, FavoriteState>(
                                      builder: (context, favState) {
                                        final patientId = FirebaseAuth
                                                .instance.currentUser?.uid ??
                                            '';
                                        return Column(
                                          children: state.bestPharmacies
                                              .map((pharmacy) {
                                            final isFav = context
                                                .read<FavoriteCubit>()
                                                .isFavoritePharmacy(
                                                    pharmacy.id);
                                            final updatedPharmacy = pharmacy
                                                .copyWith(isFavorite: isFav);
                                            return BestPharmacyCard(
                                              key: ValueKey(pharmacy.id),
                                              pharmacy: updatedPharmacy,
                                              onTap: () {
                                                context.push(
                                                    AppRouter.sendPrescription,
                                                    extra: pharmacy.id);
                                              },
                                              onFavoriteToggle: () {
                                                context
                                                    .read<FavoriteCubit>()
                                                    .toggleFavoritePharmacy(
                                                        patientId, pharmacy.id);
                                              },
                                            );
                                          }).toList(),
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
                AnimatedPositionedDirectional(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  bottom: 100.h,
                  end: isVisible ? 16.w : -50.w,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: isVisible ? 1 : 0.8,
                    child: GestureDetector(
                      onTap: () {
                        context.push(AppRouter.chatBot);
                      },
                      child: Container(
                        width: 86.w,
                        height: 86.h,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2.w,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          width: 86.w,
                          height: 86.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context)
                                .colorScheme
                                .surface
                                .withValues(alpha: 0.8),
                          ),
                          child: Image.asset('assets/imgs/chatbut/chatbut.png',
                              color: Theme.of(context).colorScheme.primary,
                              colorBlendMode: BlendMode.srcIn,
                              height: 70.h,
                              width: 70.w),
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  bottom: isAtTop ? -40.h : -150.h,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isAtTop ? 1.0 : 0.0,
                    child: Center(
                      child: Lottie.asset(
                        'assets/animations/Scroll.json',
                        width: 150.w,
                        height: 150.h,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
