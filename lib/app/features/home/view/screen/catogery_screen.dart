import 'package:avo_app/app/features/home/data/home_data.dart';
import 'package:avo_app/app/features/home/view/widget/catogery_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CatogeryScreen extends StatefulWidget {
  const CatogeryScreen({super.key});

  @override
  State<CatogeryScreen> createState() => _CatogeryScreenState();
}

class _CatogeryScreenState extends State<CatogeryScreen> {
  int _selectedCategoryIndex = -1;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

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
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16.h,
            crossAxisSpacing: 18.w,
            childAspectRatio: 1,
          ),
          itemCount: vm.categories.length,
          itemBuilder: (_, index) {
            return CategoryItem(
              category: vm.categories[index],
              isSelected: _selectedCategoryIndex == index,
              onTap: () => setState(() => _selectedCategoryIndex = index),
              onDoubleTap: () => setState(() => _selectedCategoryIndex = -1),
            );
          },
        ),
      ),
    );
  }
}
