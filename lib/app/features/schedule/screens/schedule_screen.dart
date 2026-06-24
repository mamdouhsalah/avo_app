import 'package:avo_app/app/features/schedule/widgets/calender_section.dart';
import 'package:avo_app/app/features/schedule/widgets/scheduale_header.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/Language/locale_keys.g.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.schedule_title.tr()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// WHITE CONTAINER
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: const [
                    ScheduleHeader(),
                    SizedBox(height: 16),
                    CalendarSection(),
                  ],
                ),
              ),
            ),

            /// GREEN BOTTOM PART
            // const SelectedDateBar(),
            // const Expanded(
            //   child: AppointmentList(),
            // ),
          ],
        ),
      ),
    );
  }
}