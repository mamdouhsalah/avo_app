import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avo_app/app/features/home/logic/home_cubit.dart';
import 'package:avo_app/app/features/home/logic/home_state.dart';
import 'package:avo_app/app/features/home/view/widget/catogery_item.dart';
import 'package:avo_app/app/core/shared/loading_indicator_widget.dart';
import 'package:avo_app/app/core/shared/error_feedback_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CatogeryScreen extends StatefulWidget {
  const CatogeryScreen({super.key});

  @override
  State<CatogeryScreen> createState() => _CatogeryScreenState();
}

class _CatogeryScreenState extends State<CatogeryScreen> {
  int _selectedCategoryIndex = -1;

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
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              iconTheme: IconThemeData(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              title: Text(
                "Categories",
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: state.categories.isEmpty
                  ? const Center(child: Text("No categories available"))
                  : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 16.h,
                        crossAxisSpacing: 18.w,
                        childAspectRatio: 1,
                      ),
                      itemCount: state.categories.length,
                      itemBuilder: (_, index) {
                        return CategoryItem(
                          category: state.categories[index],
                          isSelected: _selectedCategoryIndex == index,
                          onTap: () => setState(() => _selectedCategoryIndex = index),
                          onDoubleTap: () => setState(() => _selectedCategoryIndex = -1),
                        );
                      },
                    ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
