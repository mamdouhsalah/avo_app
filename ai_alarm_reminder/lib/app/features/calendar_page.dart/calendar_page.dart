import 'package:ai_alarm_reminder/app/core/services/hive_service.dart';
import 'package:ai_alarm_reminder/app/core/services/notification_service.dart';
import 'package:ai_alarm_reminder/app/core/services/service_models/models.dart';
import 'package:ai_alarm_reminder/app/core/utils/constance.dart';
import 'package:ai_alarm_reminder/app/features/add_reminders_page/add_medication_page/add_medication_page.dart';
import 'package:ai_alarm_reminder/app/features/medication_report_page.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          elevation: 0,
          title: const Text('تقويم الأدوية',
              style: TextStyle(
                fontFamily: 'cairo',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
          actions: [
            IconButton(
                icon: Row(
                  children: [
                    const Text(
                      'عمل ريبورت',
                      style: TextStyle(
                        fontFamily: 'cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.assessment),
                    const SizedBox(width: 8),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MedicationReportPage()),
                  );
                })
          ],
          // bottom: TabBar(
          //   tabs: const [
          //     Tab(text: 'الأدوية'),
          //     Tab(text: 'المواعيد والتحاليل'),
          //   ],
          //   labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          //   indicatorColor: Colors.teal,
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
          // ),
        ),
        body: MedicationCalendar(),

        // const TabBarView(
        //   children: [
        //     MedicationCalendar(),
        //     AppointmentAnalysisCalendar(),
        //   ],
        // ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showBarModalBottomSheet(
                overlayStyle: SystemUiOverlayStyle.light,
                context: context,
                builder: (context) {
                  return SingleChildScrollView(
                    controller: ModalScrollController.of(context),
                    child: Container(
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16))),
                      height: 700,
                      child: const AddMedicationPage(),
                    ),
                  );
                });
          },
          tooltip: 'عرض التقارير',
          child: const ImageIcon(
            AssetImage('assets/icons/add-reminder.png'),
            //FontAwesomeIcons.remin,
            //  size: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class MedicationCalendar extends StatefulWidget {
  const MedicationCalendar({super.key});

  @override
  _MedicationCalendarState createState() => _MedicationCalendarState();
}

class _MedicationCalendarState extends State<MedicationCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Map<String, dynamic>> _getMedicationRemindersForDay(DateTime day) {
    final reminders = <Map<String, dynamic>>[];
    final medicationBox = HiveService.getMedicationBox();
    final logBox = HiveService.getMedicationLogBox();
    for (var med in medicationBox.values) {
      if (med.days.contains(availableDays[day.weekday - 1])) {
        for (var time in med.times) {
          final timeParts = time.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          final reminderTime =
              DateTime(day.year, day.month, day.day, hour, minute);
          final notificationId =
              '${med.key}${med.times.indexOf(time)}'.hashCode;

          // Check if there's a log for this reminder on this day
          String? status;
          final logs = logBox.values.where((log) =>
              log.medicationKey == med.key &&
              log.notificationId == notificationId &&
              isSameDay(log.timestamp, day));
          if (logs.isNotEmpty) {
            status = logs.last.action;
          }

          reminders.add({
            'type': 'دواء',
            'title': med.name,
            'details': 'الجرعة: ${med.dose} ${med.unit}',
            'time': reminderTime,
            'data': med,
            'notificationId': notificationId,
            'status': status, // null, 'took', 'skipped', or 'snoozed'
          });
        }
      }
    }
    reminders.sort((a, b) => a['time'].compareTo(b['time']));
    return reminders;
  }

  Map<DateTime, List<Map<String, dynamic>>> _getMedicationEvents() {
    final events = <DateTime, List<Map<String, dynamic>>>{};
    final medicationBox = HiveService.getMedicationBox();
    for (var med in medicationBox.values) {
      for (var day in med.days) {
        final weekday = arabicDayToWeekday[day];
        if (weekday == null) continue;
        for (int i = 0; i < 30; i++) {
          final date = DateTime.now().add(Duration(days: i));
          if (date.weekday == weekday) {
            final eventDate = DateTime(date.year, date.month, date.day);
            events[eventDate] = events[eventDate] ?? [];
            for (var time in med.times) {
              final timeParts = time.split(':');
              final hour = int.parse(timeParts[0]);
              final minute = int.parse(timeParts[1]);
              final notificationId =
                  '${med.key}${med.times.indexOf(time)}'.hashCode;
              events[eventDate]!.add({
                'type': 'دواء',
                'title': med.name,
                'details': 'الجرعة: ${med.dose} ${med.unit}',
                'time': DateTime(date.year, date.month, date.day, hour, minute),
                'data': med,
                'notificationId': notificationId,
              });
            }
          }
        }
      }
    }
    return events;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveService.getMedicationBox().listenable(),
      builder: (context, _, __) => ValueListenableBuilder(
        valueListenable: HiveService.getMedicationLogBox().listenable(),
        builder: (context, _, __) {
          final events = _getMedicationEvents();
          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: EasyDateTimeLine(
                  initialDate: _selectedDay ?? DateTime.now(),
                  onDateChange: (newDate) {
                    setState(() {
                      _selectedDay = newDate;
                      _focusedDay = newDate;
                    });
                  },
                  activeColor: AppColors.primaryColor,
                  headerProps: const EasyHeaderProps(
                    selectedDateStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'cairo',
                        fontSize: 18),
                  ),
                  dayProps: const EasyDayProps(
                    todayHighlightStyle: TodayHighlightStyle.withBorder,
                    activeDayStyle: DayStyle(
                      borderRadius: 10,
                      // borderColor: Colors.teal,
                      dayNumStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'cairo',
                          fontSize: 18),
                    ),
                  ),
                  locale: 'ar',
                ),
              ),
              Expanded(
                child: _selectedDay != null
                    ? _buildRemindersList(context, _selectedDay!)
                    : const Center(child: Text('اختر يومًا لعرض التذكيرات')),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRemindersList(BuildContext context, DateTime day) {
    final reminders = _getMedicationRemindersForDay(day);
    if (reminders.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد تذكيرات لهذا اليوم',
          style: TextStyle(fontFamily: 'cairo', fontSize: 16),
        ),
      );
    }

    final groupedReminders = <String, List<Map<String, dynamic>>>{};
    for (var reminder in reminders) {
      final timeKey = DateFormat('HH:mm', 'ar').format(reminder['time']);
      groupedReminders.putIfAbsent(timeKey, () => []).add(reminder);
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      children: groupedReminders.entries.map((entry) {
        final time = entry.key;
        final timeReminders = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'الوقت: $time',
                style: TextStyle(
                  height: 1.5,
                  fontFamily: 'cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            ...timeReminders.map((reminder) {
              final status = reminder['status'] as String?;
              final medication = reminder['data'] as Medication;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        blurStyle: BlurStyle.outer,
                        color: AppColors.primaryColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        tileColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getReminderIcon(reminder['type'], medication.unit),
                            color: AppColors.primaryColor,
                            size: 28,
                          ),
                        ),
                        title: Text(
                          reminder['title'],
                          style: const TextStyle(
                            fontFamily: 'cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              reminder['details'],
                              style: const TextStyle(
                                  fontFamily: 'cairo', fontSize: 14),
                            ),
                            if (status != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      status == 'took'
                                          ? Icons.check_circle
                                          : status == 'skipped'
                                              ? Icons.cancel
                                              : Icons.snooze,
                                      color: status == 'took'
                                          ? Colors.green
                                          : status == 'skipped'
                                              ? Colors.red
                                              : Colors.blue,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'الحالة: ${status == 'took' ? 'أخذته' : status == 'skipped' ? 'تم التخطي' : 'تم التأجيل'}',
                                      style: TextStyle(
                                        fontFamily: 'cairo',
                                        fontSize: 14,
                                        color: status == 'took'
                                            ? Colors.green
                                            : status == 'skipped'
                                                ? Colors.red
                                                : Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 0),
                                    TextButton(
                                      onPressed: () async {
                                        try {
                                          final logBox =
                                              HiveService.getMedicationLogBox();
                                          final logs = logBox.values.where(
                                              (log) =>
                                                  log.medicationKey ==
                                                      medication.key &&
                                                  log.notificationId ==
                                                      reminder[
                                                          'notificationId'] &&
                                                  isSameDay(
                                                      log.timestamp, day));
                                          if (logs.isNotEmpty) {
                                            await logs.last.delete();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'تم التراجع عن الإجراء')),
                                            );
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'خطأ أثناء التراجع: $e')),
                                          );
                                        }
                                      },
                                      child: const Text(
                                        'تراجع',
                                        style: TextStyle(
                                          fontFamily: 'cairo',
                                          fontSize: 14,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.more_vert,
                                color: AppColors.primaryColor,
                              )),
                          onSelected: (value) async {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddMedicationPage(
                                    medication: medication,
                                  ),
                                ),
                              );
                            } else if (value == 'delete') {
                              try {
                                await NotificationService
                                    .cancelMedicationNotifications(medication);
                                await medication.delete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('تم الحذف بنجاح')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('خطأ أثناء الحذف: $e')),
                                );
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(FontAwesomeIcons.pen, size: 16),
                                  const SizedBox(width: 8),
                                  const Text('تعديل'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(FontAwesomeIcons.trash, size: 16),
                                  const SizedBox(width: 8),
                                  const Text('حذف'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (status == null || status == 'snoozed')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (status == null || status == 'snoozed') ...[
                              IconButton(
                                icon: Row(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        color: Colors.green),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'أخذته',
                                      style: TextStyle(
                                        fontFamily: 'cairo',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: () async {
                                  try {
                                    await HiveService.getMedicationLogBox().add(
                                      MedicationLog(
                                        medicationKey: medication.key,
                                        timestamp: DateTime.now(),
                                        action: 'took',
                                        notificationId:
                                            reminder['notificationId'],
                                      ),
                                    );
                                    await AwesomeNotifications()
                                        .cancel(reminder['notificationId']);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('تم تسجيل أخذ الدواء')),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('خطأ: $e')),
                                    );
                                  }
                                },
                                tooltip: 'أخذته',
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey.shade300,
                              ),
                              IconButton(
                                icon: Row(
                                  children: [
                                    const Icon(Icons.cancel, color: Colors.red),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'تخطي',
                                      style: TextStyle(
                                        fontFamily: 'cairo',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: () async {
                                  try {
                                    await HiveService.getMedicationLogBox().add(
                                      MedicationLog(
                                        medicationKey: medication.key,
                                        timestamp: DateTime.now(),
                                        action: 'skipped',
                                        notificationId:
                                            reminder['notificationId'],
                                      ),
                                    );
                                    await AwesomeNotifications()
                                        .cancel(reminder['notificationId']);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('تم تسجيل تخطي الدواء')),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('خطأ: $e')),
                                    );
                                  }
                                },
                                tooltip: 'تخطي',
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  IconData _getReminderIcon(String type, String unit) {
    if (type == 'دواء') {
      // Map medication unit to specific icons
      switch (unit.toLowerCase()) {
        case 'كبسولة':
          return FontAwesomeIcons.capsules; // Icon for pills or tablets

        case 'قرص':
          return FontAwesomeIcons.pills; // Icon for pills or tablets
        case 'ملغ':
        case 'ml':
        case 'مل':
        case 'liquid':
          return Icons.medication_liquid; // Icon for capsules
        default:
          return FontAwesomeIcons.capsules; // Icon for pills or tablets
      }
    } else if (type == 'تحليل') {
      return Icons.science;
    } else if (type == 'موعد') {
      return Icons.event;
    }
    return Icons.info;
  }
}

// class AppointmentAnalysisCalendar extends StatefulWidget {
//   const AppointmentAnalysisCalendar({Key? key}) : super(key: key);

//   @override
//   _AppointmentAnalysisCalendarState createState() =>
//       _AppointmentAnalysisCalendarState();
// }

// class _AppointmentAnalysisCalendarState
//     extends State<AppointmentAnalysisCalendar> {
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;

//   @override
//   void initState() {
//     super.initState();
//     _selectedDay = _focusedDay;
//   }

//   List<Map<String, dynamic>> _getAppointmentAnalysisRemindersForDay(
//       DateTime day) {
//     final reminders = <Map<String, dynamic>>[];
//     final analysisBox = HiveService.getAnalysisBox();
//     for (var analysis in analysisBox.values) {
//       if (isSameDay(analysis.date, day)) {
//         reminders.add({
//           'type': 'تحليل',
//           'title': analysis.name,
//           'details': 'المختبر: ${analysis.labName}',
//           'time': DateTime(day.year, day.month, day.day, 8, 0),
//           'data': analysis,
//         });
//       }
//     }
//     final appointmentBox = HiveService.getAppointmentBox();
//     for (var appointment in appointmentBox.values) {
//       if (isSameDay(appointment.dateTime, day)) {
//         reminders.add({
//           'type': 'موعد',
//           'title': appointment.title,
//           'details': 'الموقع: ${appointment.location}',
//           'time': appointment.dateTime,
//           'data': appointment,
//         });
//       }
//     }
//     reminders.sort((a, b) => a['time'].compareTo(b['time']));
//     return reminders;
//   }

//   Map<DateTime, List<Map<String, dynamic>>> _getAppointmentAnalysisEvents() {
//     final events = <DateTime, List<Map<String, dynamic>>>{};
//     final analysisBox = HiveService.getAnalysisBox();
//     for (var analysis in analysisBox.values) {
//       final eventDate =
//           DateTime(analysis.date.year, analysis.date.month, analysis.date.day);
//       events[eventDate] = events[eventDate] ?? [];
//       events[eventDate]!.add({
//         'type': 'تحليل',
//         'title': analysis.name,
//         'details': 'المختبر: ${analysis.labName}',
//         'time': DateTime(eventDate.year, eventDate.month, eventDate.day, 8, 0),
//         'data': analysis,
//       });
//     }
//     final appointmentBox = HiveService.getAppointmentBox();
//     for (var appointment in appointmentBox.values) {
//       final eventDate = DateTime(appointment.dateTime.year,
//           appointment.dateTime.month, appointment.dateTime.day);
//       events[eventDate] = events[eventDate] ?? [];
//       events[eventDate]!.add({
//         'type': 'موعد',
//         'title': appointment.title,
//         'details': 'الموقع: ${appointment.location}',
//         'time': appointment.dateTime,
//         'data': appointment,
//       });
//     }
//     return events;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder(
//       valueListenable: HiveService.getAnalysisBox().listenable(),
//       builder: (context, _, __) => ValueListenableBuilder(
//         valueListenable: HiveService.getAppointmentBox().listenable(),
//         builder: (context, _, __) {
//           final events = _getAppointmentAnalysisEvents();
//           return Column(
//             children: [
//               Card(
//                 margin: const EdgeInsets.all(16.0),
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//                 child: TableCalendar(
//                   firstDay: DateTime.utc(2020, 1, 1),
//                   lastDay: DateTime.utc(2030, 12, 31),
//                   focusedDay: _focusedDay,
//                   selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//                   calendarFormat: CalendarFormat.month,
//                   locale: 'ar_SA',
//                   headerStyle: const HeaderStyle(
//                     formatButtonVisible: false,
//                     titleCentered: true,
//                     titleTextStyle:
//                         TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   calendarStyle: const CalendarStyle(
//                     todayDecoration: BoxDecoration(
//                       color: Colors.teal,
//                       shape: BoxShape.circle,
//                     ),
//                     selectedDecoration: BoxDecoration(
//                       color: Colors.tealAccent,
//                       shape: BoxShape.circle,
//                     ),
//                     markerDecoration: BoxDecoration(
//                       color: Colors.red,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   eventLoader: (day) =>
//                       events[DateTime(day.year, day.month, day.day)] ?? [],
//                   onDaySelected: (selectedDay, focusedDay) {
//                     setState(() {
//                       _selectedDay = selectedDay;
//                       _focusedDay = focusedDay;
//                     });
//                   },
//                 ),
//               ),
//               Expanded(
//                 child: _selectedDay != null
//                     ? _buildRemindersList(context, _selectedDay!)
//                     : const Center(child: Text('اختر يومًا لعرض التذكيرات')),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildRemindersList(BuildContext context, DateTime day) {
//     final reminders = _getAppointmentAnalysisRemindersForDay(day);
//     if (reminders.isEmpty) {
//       return const Center(child: Text('لا توجد تذكيرات لهذا اليوم'));
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16.0),
//       itemCount: reminders.length,
//       itemBuilder: (context, index) {
//         final reminder = reminders[index];
//         return Card(
//           elevation: 2,
//           margin: const EdgeInsets.only(bottom: 16),
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: ListTile(
//             leading: Icon(
//               _getReminderIcon(reminder['type']),
//               color: Colors.teal,
//             ),
//             title: Text(
//               reminder['title'],
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(reminder['details']),
//                 Text('الوقت: ${reminder['time'].formatTime()}'),
//               ],
//             ),
//             trailing: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.edit, color: Colors.blue),
//                   onPressed: () {
//                     if (reminder['type'] == 'تحليل') {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => AddAnalysisPage(
//                             analysis: reminder['data'] as Analysis,
//                           ),
//                         ),
//                       );
//                     } else if (reminder['type'] == 'موعد') {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => AddAppointmentPage(
//                             appointment: reminder['data'] as Appointment,
//                           ),
//                         ),
//                       );
//                     }
//                   },
//                   tooltip: 'تعديل',
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete, color: Colors.red),
//                   onPressed: () async {
//                     try {
//                       if (reminder['type'] == 'تحليل') {
//                         final analysis = reminder['data'] as Analysis;
//                         await AwesomeNotifications()
//                             .cancel(analysis.key.hashCode);
//                         await analysis.delete();
//                       } else if (reminder['type'] == 'موعد') {
//                         final appointment = reminder['data'] as Appointment;
//                         await AwesomeNotifications()
//                             .cancel(appointment.key.hashCode);
//                         await appointment.delete();
//                       }
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('تم الحذف بنجاح')),
//                       );
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('خطأ أثناء الحذف: $e')),
//                       );
//                     }
//                   },
//                   tooltip: 'حذف',
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   IconData _getReminderIcon(String type) {
//     switch (type) {
//       case 'دواء':
//         return Icons.medical_services;
//       case 'تحليل':
//         return Icons.science;
//       case 'موعد':
//         return Icons.event;
//       default:
//         return Icons.info;
//     }
//   }
// }
