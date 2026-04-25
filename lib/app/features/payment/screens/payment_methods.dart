import 'package:avo_app/app/core/shared/main_button.dart';
import 'package:avo_app/app/features/payment/data/payment_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PaymentMethods extends StatefulWidget {
  const PaymentMethods({super.key});
  
  @override
  State<PaymentMethods> createState() => _PaymentMethodsState();
}

class _PaymentMethodsState extends State<PaymentMethods> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {

     final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Methods'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title
              Text(
                'Select Method',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600 , color: colorScheme.onSurface),
              ),

              SizedBox(height: 24.h),

              // payment methods list
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: paymentMethods.length,
                  itemBuilder: (context, index) {
                  final isSelected = selectedIndex == index;
                  final method = paymentMethods[index];
              
                  return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              child: Container(
                width: 343.w,
                height: 60.h,
                margin: EdgeInsets.symmetric(vertical: 8.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary 
                        : colorScheme.onSurface, 
                    width: isSelected ? 2.w : 1.w,
                  ),
                ),
                child: Row(
                  children: [
                    
                    // Selection circle
                    Container(
                      width: 24.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(   
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                          width: 2.w,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 10.w,
                                height: 10.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorScheme.primary,
                                ),
                              ),
                            )
                          : null,
                    ),
                    
                    SizedBox(width: 12.w),
              
                    // Method name
                    Expanded(child: Text(method.name, style: TextStyle(color: colorScheme.onSurface)) ),
                     
                    SizedBox(width: 12.w),
                    // Method SVG
                    SvgPicture.asset(method.svgPath, width: 40.w, height: 40.h , color: colorScheme.onSurface,),
              
                  ],
                ),
              ),
                  );
                },
              ),
              SizedBox(height: 26.h),

              // continue button
              Center(child: MainButton(text: 'Continue', onPressed: (){},width: 343.w, height: 48.h,)),
            ],
          ),
        ),
      ),
    );
  }
}