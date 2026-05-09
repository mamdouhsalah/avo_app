import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddMedicationFab extends StatelessWidget {
  final VoidCallback onPressed;

  const AddMedicationFab({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: theme.colorScheme.primary,
      elevation: 4,
      shape: const CircleBorder(),
      child: Icon(
        Icons.add_rounded,
        color: Colors.white,
        size: 32.sp,
      ),
    );
  }
}