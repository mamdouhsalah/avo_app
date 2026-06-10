import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final bool? isNo;

  const MainButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.isNo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isNo!? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.primary  ,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onPressed,
        child: Container(
           width: width??311.w,
            height: height??48.h,
            decoration: BoxDecoration(
              border: isNo!? Border.all(color: Theme.of(context).colorScheme.primary , width: 1.w) : null,
              borderRadius: BorderRadius.circular(8.r),
            ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isNo!? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),  
    );
  }
}