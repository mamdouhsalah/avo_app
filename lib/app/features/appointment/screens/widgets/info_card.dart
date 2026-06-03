import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class InfoCard extends StatelessWidget{
  
  final String title;
  final String value;

  const InfoCard({super.key, required this.title, required this.value});
  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: colorScheme.onSurface
          ),
        ),

        SizedBox(height: 8.5.h,),
        
        // container for the value
        Container(
          width: 161.w,
          height: 48.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: colorScheme.primary, width: 2),
          ),
          child: Text(value, style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurface),),
        )
      ],
    );
  }
}