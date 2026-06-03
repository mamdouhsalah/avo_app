import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avo_app/app/features/home/logic/home_cubit.dart';
import 'package:avo_app/app/features/home/logic/home_state.dart';
import 'package:avo_app/app/core/shared/loading_indicator_widget.dart';
import 'package:avo_app/app/core/shared/error_feedback_widget.dart';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:avo_app/app/core/shared/appointment_card.dart';
import 'package:avo_app/app/features/home/view/widget/catogery_item.dart';
import 'package:avo_app/app/core/shared/bestdoctor_card.dart';
import 'package:avo_app/app/core/shared/medicine_card.dart';
import 'package:avo_app/app/core/shared/bestpharmacy_card.dart';
import 'package:avo_app/app/core/shared/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 2;
  bool isVisible = true;
  int selectedCategoryIndex = -1;

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
                NotificationListener<UserScrollNotification>(
                  onNotification: (notification) {
                    if (notification.direction == ScrollDirection.reverse) {
                      if (isVisible) setState(() => isVisible = false);
                    } else if (notification.direction == ScrollDirection.forward) {
                      if (!isVisible) setState(() => isVisible = true);
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
                          "Home",
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        centerTitle: true,
                        actions: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.shopping_bag_outlined,
                              color: Theme.of(context).colorScheme.onSurface,
                              size: 24.sp,
                            ),
                          )
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12.w, vertical: 1.h),
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
                                        color: Theme.of(context).colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: user.image != null && user.image!.isNotEmpty
                                          ? Image.asset(
                                              user.image.toString(),
                                              width: 55.r,
                                              height: 55.r,
                                              fit: BoxFit.cover,
                                            )
                                          : Icon(Icons.person, size: 30.r),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Welcome",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outlineVariant,
                                        ),
                                      ),
                                      Text(
                                        user.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp,
                                          color:
                                              Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.favorite_border,
                                    color:
                                        Theme.of(context).colorScheme.outlineVariant,
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
                                    color: Theme.of(context).colorScheme.surface,
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
                                          "Search",
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
                                title: 'Upcoming Appointments',
                                routePath: AppRouter.search,
                              ),
                              SizedBox(height: 16.h),

                              SizedBox(
                                height: 158.h,
                                child: state.appointments.isEmpty
                                    ? Center(
                                        child: Text(
                                          "No upcoming appointments",
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.outline,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: state.appointments.length,
                                        itemBuilder: (_, i) {
                                          return AppointmentCard(
                                            appointment: state.appointments[i],
                                          );
                                        },
                                      ),
                              ),

                              SizedBox(height: 24.h),

                              SectionHeader(
                                title: "Upcoming Medicine",
                                routePath: AppRouter.search,
                              ),
                              SizedBox(height: 16.h),

                              SizedBox(
                                height: 200.h,
                                child: state.medicines.isEmpty
                                    ? Center(
                                        child: Text(
                                          "No medicines scheduled",
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.outline,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: state.medicines.length,
                                        itemBuilder: (_, i) {
                                          return MedicineCard(
                                            medicine: state.medicines[i],
                                          );
                                        },
                                      ),
                              ),

                              SizedBox(height: 24.h),

                              SectionHeader(
                                title: 'Categories',
                                routePath: AppRouter.search,
                              ),

                              state.categories.isEmpty
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(vertical: 20.h),
                                      child: Center(
                                        child: Text("No categories available"),
                                      ),
                                    )
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
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
                                          isSelected: selectedCategoryIndex == index,
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
                                title: "Best Doctors",
                                routePath: AppRouter.search,
                              ),
                              SizedBox(height: 16.h),

                              state.bestDoctors.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 20.h),
                                        child: Text("No doctors available"),
                                      ),
                                    )
                                  : Column(
                                      children: state.bestDoctors.map((doc) {
                                        return BestDoctorCard(
                                          key: ValueKey(doc.id),
                                          doctor: doc,
                                          onFavoriteToggle: () {},
                                          onBook: () {},
                                        );
                                      }).toList(),
                                    ),

                              SizedBox(height: 16.h),

                              SectionHeader(
                                title: "Best Pharmacies",
                                routePath: AppRouter.search,
                              ),
                              SizedBox(height: 16.h),

                              state.bestPharmacies.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 20.h),
                                        child: Text("No pharmacies available"),
                                      ),
                                    )
                                  : Column(
                                      children: state.bestPharmacies.map((pharmacy) {
                                        return BestPharmacyCard(
                                          key: ValueKey(pharmacy.id),
                                          pharmacy: pharmacy,
                                          onTap: () {},
                                          onFavoriteToggle: () {},
                                        );
                                      }).toList(),
                                    ),

                              SizedBox(height: 100.h),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  bottom: 100.h,
                  right: isVisible ? 16.w : -50.w,
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
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
