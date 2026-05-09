import 'package:avo_app/app/features/home/data/home_data.dart';
import 'package:avo_app/app/features/home/view/screen/catogery_screen.dart';
import 'package:avo_app/app/features/home/view/screen/search_Screen.dart';
import 'package:avo_app/app/core/shared/appointment_card.dart';
import 'package:avo_app/app/features/home/view/widget/catogery_item.dart';
import 'package:avo_app/app/core/shared/custom_navigationbar.dart';
import 'package:avo_app/app/core/shared/bestdoctor_card.dart';
import 'package:avo_app/app/core/shared/medicine_card.dart';
import 'package:avo_app/app/core/shared/bestpharmacy_card.dart';
import 'package:avo_app/app/features/home/view/widget/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

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
    final vm = context.watch<HomeViewModel>();
    final user = vm.currentUser;

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
                                child: Image.asset(
                                  user.image.toString(),
                                  width: 55.r,
                                  height: 55.r,
                                  fit: BoxFit.cover,
                                ),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SearchScreen(),
                              ),
                            );
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
                              color: Theme.of(context).colorScheme.background,
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
                          onSeeAll: () => const SearchScreen(),
                        ),
                        SizedBox(height: 16.h),

                        SizedBox(
                          height: 158.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: vm.appointments.length,
                            itemBuilder: (_, i) {
                              return AppointmentCard(
                                appointment: vm.appointments[i],
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 24.h),

                        SectionHeader(
                          title: "Upcoming Medicine",
                          onSeeAll: () => const SearchScreen(),
                        ),
                        SizedBox(height: 16.h),

                        SizedBox(
                          height: 200.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: vm.medicines.length,
                            itemBuilder: (_, i) {
                              return MedicineCard(
                                medicine: vm.medicines[i],
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 24.h),

                        SectionHeader(
                          title: 'Categories',
                          onSeeAll: () => const CatogeryScreen(),
                        ),

                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.only(top: 16.h),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 16.h,
                            crossAxisSpacing: 19.w,
                          ),
                          itemCount: 8,
                          itemBuilder: (_, index) {
                            return CategoryItem(
                              category: vm.categories[index],
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
                          onSeeAll: () => const SearchScreen(),
                        ),
                        SizedBox(height: 16.h),

                        Column(
                          children: vm.bestDoctors.map((doc) {
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
                          onSeeAll: () => const SearchScreen(),
                        ),
                        SizedBox(height: 16.h),

                        Column(
                          children: vm.bestPharmacies.map((pharmacy) {
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
                onTap: () {},
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
                          .background
                          .withOpacity(0.8),
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
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            bottom: isVisible ? 0 : -100.h,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isVisible ? 1 : 0,
              child: CustomBottomNav(
                currentIndex: currentIndex,
                onTap: (index) {
                  setState(() => currentIndex = index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
