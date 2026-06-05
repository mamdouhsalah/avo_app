import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/features/reminder/data/reminder_model.dart';
import 'package:avo_app/app/features/reminder/screens/widgets/add_medication_fab.dart';
import 'package:avo_app/app/features/reminder/screens/widgets/calendar_strip_widget.dart';
import 'package:avo_app/app/features/reminder/screens/widgets/medication_detail_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // داتا وهمية مطابقة للديزاين
    final List<ReminderModel> meds = [
      ReminderModel(id: '1', name: 'Amoxicillin', dosage: '500mg', pillCount: '1 pill', time: '9:00 AM', frequency: 'Twice daily', isActive: true, status: 'upcoming'),
      ReminderModel(id: '2', name: 'Vitamin D', dosage: '2000 IU', pillCount: '1 capsule', time: '7:00 AM', frequency: 'Once daily', isActive: true, status: 'taken'),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Schedule"),
        actions: [
          IconButton(
            onPressed: () {
            },
            icon: Icon(
              Icons.edit_note_rounded,
              size: 26,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. شريط التقويم
          CalendarStripWidget(
            selectedDay: _selectedDay,
            onDaySelected: (day) => setState(() => _selectedDay = day),
          ),

          SizedBox(height: AppSpacing.v16),

          // 2. قائمة الأدوية
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.h20),
              itemCount: meds.length,
              itemBuilder: (context, index) => MedicationDetailTile(reminder: meds[index]),
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