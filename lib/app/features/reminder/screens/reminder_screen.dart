import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/features/reminder/data/reminder_model.dart';
import 'package:avo_app/app/features/reminder/screens/widgets/add_medication_fab.dart';
import 'package:avo_app/app/features/reminder/screens/widgets/next_dose_card.dart';
import 'package:avo_app/app/features/reminder/screens/widgets/schedule_tile.dart';
import 'package:avo_app/app/features/reminder/screens/widgets/wave_header_painter.dart';
import 'package:easy_localization/easy_localization.dart'; // 🔥 الترجمة
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/Language/locale_keys.g.dart'; // 🔥 الـ LocaleKeys

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dummy Data بعد التحديث
    final List<ReminderModel> schedule = [
      ReminderModel(
        id: '1',
        name: 'Amoxicillin',
        dosage: '500mg',
        pillCount: '1 pill',
        time: '9:00 AM',
        status: 'next',
        frequency: 'Twice daily',
        isActive: true,
      ),
      ReminderModel(
        id: '2',
        name: 'Vitamin D',
        dosage: '2000 IU',
        pillCount: '1 capsule',
        time: '7:00 AM',
        status: 'taken',
        frequency: 'Once daily',
        isActive: true,
      ),
      ReminderModel(
        id: '3',
        name: 'Paracetamol',
        dosage: '500mg',
        pillCount: '1 tablet',
        time: '7:00 AM',
        status: 'taken',
        frequency: 'As needed',
        isActive: false,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // 1. الخلفية المتموجة
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(double.infinity, 300.h),
              painter: WaveHeaderPainter(color: theme.colorScheme.primary),
            ),
          ),

          // 2. المحتوى فوق الخلفية
          SafeArea(
            child: Column(
              children: [
                // AppBar مخصص شفاف
                Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.v16, horizontal: AppSpacing.h20),
                  child: Center(
                    child: Text(
                      LocaleKeys.reminder_title.tr(), // 🔥 ترجمة العنوان
                      style: TextStyle(
                        inherit: false,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.h20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: AppSpacing.v12),
                        // كارت الجرعة القادمة متداخل مع الخلفية
                        const NextDoseCard(),

                        SizedBox(height: AppSpacing.v32),

                        // عنوان جدول اليوم
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              LocaleKeys.reminder_todays_schedule.tr(), // 🔥 ترجمة جدول النهاردة
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.push(AppRouter.schedule);
                              },
                              child: Text(
                                LocaleKeys.reminder_see_all.tr(), // 🔥 ترجمة عرض الكل
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.v16),

                        // قائمة الأدوية
                        ...schedule.map((item) => ScheduleTile(reminder: item)),

                        SizedBox(height: 100.h), // مساحة أسفل القائمة عشان الـ Scroll
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: AddMedicationFab(
        onPressed: () {
          context.push(AppRouter.addMedication);
        },
      ),
    );
  }
}