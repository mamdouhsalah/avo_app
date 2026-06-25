import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avo_app/app/features/home/logic/home_cubit.dart';
import 'package:avo_app/app/features/home/logic/home_state.dart';
import 'package:avo_app/app/core/shared/bestdoctor_card.dart';
import 'package:avo_app/app/core/shared/bestpharmacy_card.dart';
import 'package:avo_app/app/core/shared/loading_indicator_widget.dart';
import 'package:avo_app/app/core/shared/error_feedback_widget.dart';
import 'package:easy_localization/easy_localization.dart'; // 🔥 الترجمة
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/Language/locale_keys.g.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = "";
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
          final doctors = state.bestDoctors
              .where((d) =>
          d.name.toLowerCase().contains(query.toLowerCase()) ||
              d.specialty.toLowerCase().contains(query.toLowerCase()))
              .toList();

          final pharmacies = state.bestPharmacies
              .where((p) =>
          p.name.toLowerCase().contains(query.toLowerCase()) ||
              p.type.toLowerCase().contains(query.toLowerCase()))
              .toList();

          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme: IconThemeData(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              title: Text(
                LocaleKeys.general_search.tr(), // 🔥 استخدام الكلمة المشتركة
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: Column(
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    onChanged: (value) {
                      setState(() => query = value);
                    },
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                      hintText: LocaleKeys.search_page_hint.tr(), // 🔥 ترجمة
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                        onPressed: () {
                          controller.clear();
                          setState(() => query = "");
                        },
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: query.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 70.sp,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            LocaleKeys.search_page_start_typing.tr(), // 🔥 ترجمة
                            style: TextStyle(
                              color:
                              Theme.of(context).colorScheme.outlineVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView(
                      children: [
                        if (doctors.isNotEmpty) ...[
                          Text(
                            LocaleKeys.search_page_doctors.tr(), // 🔥 ترجمة
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          ...doctors.map(
                                (doc) => BestDoctorCard(
                              doctor: doc,
                              onFavoriteToggle: () {},
                              onBook: () {},
                            ),
                          ),
                        ],
                        if (pharmacies.isNotEmpty) ...[
                          SizedBox(height: 20.h),
                          Text(
                            LocaleKeys.search_page_pharmacies.tr(), // 🔥 ترجمة
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          ...pharmacies.map(
                                (pharmacy) => BestPharmacyCard(
                              pharmacy: pharmacy,
                              onTap: () {},
                              onFavoriteToggle: () {},
                            ),
                          ),
                        ],
                        if (doctors.isEmpty && pharmacies.isEmpty)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 60.h),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 70.sp,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    LocaleKeys.search_page_no_results.tr(), // 🔥 ترجمة
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    LocaleKeys.search_page_check_spelling.tr(), // 🔥 ترجمة
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}