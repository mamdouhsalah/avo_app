import 'package:ai_alarm_reminder/app/core/services/hive_service.dart';
import 'package:ai_alarm_reminder/app/core/services/notification_service.dart';
import 'package:ai_alarm_reminder/app/core/services/service_models/models.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ai_alarm_reminder/app/core/services/service_models/hive_medical_analysis_service.dart';
import 'package:ai_alarm_reminder/app/core/utils/constance.dart';
import 'package:ai_alarm_reminder/app/features/add_reminders_page/add_medication_page/add_medication_page.dart';
import 'package:ai_alarm_reminder/app/features/analsys_page/view/analysis_view.dart';
import 'package:ai_alarm_reminder/app/features/chat_screen/chat_screen.dart';
import 'package:ai_alarm_reminder/app/router/route_transition.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isServiceInitialized = false;
  final MedicalAnalysisService _medicalAnalysisService =
      MedicalAnalysisService();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _medicalAnalysisService.init();
      if (mounted) {
        setState(() {
          _isServiceInitialized = true;
        });
      }
    } catch (e) {
      _showSnackBar("Failed to initialize storage: $e");
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message, style: const TextStyle(fontFamily: 'Cairo'))),
    );
  }

  Future<void> _showTodaysAnalyses() async {
    if (!_isServiceInitialized) {
      _showSnackBar("Storage is not initialized yet. Please try again.");
      return;
    }

    try {
      final today = DateTime.now();
      final analyses = _medicalAnalysisService.getAllAnalysesByDate(today);
      if (analyses.isEmpty) {
        _showSnackBar("No analyses found for today.");
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
              'Analyses for Today (${DateFormat('yyyy-MM-dd').format(today)})'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: analyses.length,
              itemBuilder: (context, index) {
                final analysis = analyses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          analysis.analysisName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...analysis.states.map(
                          (state) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              "${state.name}: ${state.value} (${state.normalLimits}, ${state.description})",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } catch (e) {
      _showSnackBar("Failed to load analyses: $e");
    }
  }

  // ✅ هذه الدالة بتحسب الـ reminders في كل مرة بتتاتى
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
            'status': status,
          });
        }
      }
    }
    reminders.sort((a, b) => a['time'].compareTo(b['time']));
    return reminders;
  }

  // ✅ دالة مساعدة بتحول الـ list لـ grouped map
  Map<String, List<Map<String, dynamic>>> _buildGroupedReminders() {
    final today = DateTime.now();
    final reminders = _getMedicationRemindersForDay(today);
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var reminder in reminders) {
      final timeKey = DateFormat('HH:mm', 'ar').format(reminder['time']);
      grouped.putIfAbsent(timeKey, () => []).add(reminder);
    }
    return grouped;
  }

  IconData _getReminderIcon(String type, String? unit) {
    if (type == 'دواء') {
      switch (unit?.toLowerCase()) {
        case 'كبسولة':
          return FontAwesomeIcons.capsules;
        case 'قرص':
          return FontAwesomeIcons.pills;
        case 'ملغ':
        case 'ml':
        case 'مل':
        case 'liquid':
          return Icons.medication_liquid;
        default:
          return FontAwesomeIcons.capsules;
      }
    } else if (type == 'تحليل') {
      return Icons.science;
    } else if (type == 'موعد') {
      return Icons.event;
    }
    return Icons.info;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Hero(
              tag: 'chat',
              child: Material(
                child: CustomPaint(
                  painter: GradientGlowPainter(),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                const CircleAvatar(
                                  backgroundColor:
                                      Color.fromARGB(158, 238, 238, 238),
                                  radius: 15,
                                ),
                                Image.asset(
                                  'assets/icons/Character.png',
                                  width: 33,
                                  height: 33,
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            const Expanded(
                              child: Text(
                                'عندك أي استفسار؟ اتكلم مع MedBot',
                                style: TextStyle(
                                  fontFamily: 'cairo',
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Spacer(),
                            const ImageIcon(
                              AssetImage('assets/icons/email.png'),
                              size: 30,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 280,
              child: GridView.custom(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(0),
                childrenDelegate: SliverChildListDelegate([
                  // ─── بطاقة فحص تحليل جديد ───
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        SideTransition(const AnalysisViewPage()),
                      );
                    },
                    child: Card(
                      color: AppColors.primaryColor,
                      elevation: 0,
                      child: Flex(
                        direction: Axis.vertical,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'فحص تحليل جديد',
                            style: TextStyle(
                              fontFamily: 'cairo',
                              color: AppColors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          CircleAvatar(
                            backgroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            radius: 30.r,
                            child: Icon(
                              CupertinoIcons.doc_text_viewfinder,
                              size: 35.sp,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'امسح تحاليلك بسهولة بالماسح الضوئي',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'cairo',
                              color: AppColors.white,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── بطاقة نظام النقاط ───
                  Container(
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 212, 212, 212)
                            .withOpacity(0.4),
                        spreadRadius: 0.5,
                        blurRadius: 5,
                        offset: const Offset(0, 0),
                      ),
                    ]),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('نظام النقاط', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
                            content: Text(
                              'كل عملية حفظ بيانات صحية تمنحك نقطة واحدة.\n\nتُستخدم هذه النقاط في تحليل النتائج الطبية بالذكاء الاصطناعي (كل تحليل يخصم نقطة واحدة).',
                              style: const TextStyle(fontFamily: 'Cairo'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('حسناً', style: TextStyle(fontFamily: 'Cairo')),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Card(
                        color: AppColors.white,
                        elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'نظام النقاط',
                                  style: TextStyle(
                                    fontFamily: 'cairo',
                                    color: AppColors.primaryColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.info_outline,
                                  color: AppColors.primaryColor,
                                  size: 16.sp,
                                ),
                              ],
                            ),
                            ValueListenableBuilder(
                              valueListenable:
                                  Hive.box('user_points').listenable(),
                              builder: (context, box, _) {
                                final points =
                                    box.get('points', defaultValue: 10) as int;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        ImageIcon(
                                          const AssetImage(
                                              'assets/icons/Star.png'),
                                          color: AppColors.primaryColor,
                                          size: 20.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          '$points نقطة',
                                          style: TextStyle(
                                            fontFamily: 'cairo',
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2.h),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: (points % 100) / 100,
                                        backgroundColor: Colors.grey.shade200,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                AppColors.primaryColor),
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                );
                                }
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ─── بطاقة إضافة تذكير ───
                  Container(
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 212, 212, 212)
                            .withOpacity(0.4),
                        spreadRadius: 0.5,
                        blurRadius: 5,
                        offset: const Offset(0, 0),
                      ),
                    ]),
                    child: GestureDetector(
                      onTap: () {
                        showBarModalBottomSheet(
                          overlayStyle: SystemUiOverlayStyle.light,
                          context: context,
                          builder: (context) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.85,
                              child: const AddMedicationPage(),
                            );
                          },
                        );
                        // ✅ حذفنا .then((_) => _loadReminders())
                        // لأن ValueListenableBuilder بيتحدث تلقائياً
                      },
                      child: Card(
                        color: AppColors.white,
                        elevation: 0,
                        child: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 20.r,
                                backgroundColor: AppColors.primaryColor,
                                child: Icon(
                                  Icons.add_alarm,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  'إضافة تذكير بالعلاج',
                                  style: TextStyle(
                                    fontFamily: 'cairo',
                                    color: AppColors.primaryColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
                gridDelegate: SliverQuiltedGridDelegate(
                  crossAxisCount: 4,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 3,
                  repeatPattern: QuiltedGridRepeatPattern.inverted,
                  pattern: [
                    const QuiltedGridTile(2, 2),
                    const QuiltedGridTile(1, 2),
                    const QuiltedGridTile(1, 2),
                  ],
                ),
              ),
            ),

            // ─── قسم تذكيرات اليوم (reactive تلقائياً) ───
            ValueListenableBuilder(
              valueListenable: HiveService.getMedicationBox().listenable(),
              builder: (context, _, __) => ValueListenableBuilder(
                valueListenable: HiveService.getMedicationLogBox().listenable(),
                builder: (context, _, __) {
                  // ✅ الحساب يحصل هنا مباشرة في كل rebuild
                  final groupedReminders = _buildGroupedReminders();

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تذكيرات اليوم',
                            style: TextStyle(
                              fontFamily: 'cairo',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          groupedReminders.isEmpty
                              ? const Text(
                                  'لا توجد تذكيرات لليوم.',
                                  style: TextStyle(
                                    fontFamily: 'cairo',
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                )
                              : ListView(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(0.0),
                                  children:
                                      groupedReminders.entries.map((entry) {
                                    final time = entry.key;
                                    final timeReminders = entry.value;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
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
                                          final status =
                                              reminder['status'] as String?;
                                          final medication =
                                              reminder['data'] as Medication;
                                          return Card(
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    blurStyle: BlurStyle.outer,
                                                    color: AppColors
                                                        .primaryColor
                                                        .withOpacity(0.1),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    tileColor: Colors.white,
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      horizontal: 16,
                                                      vertical: 12,
                                                    ),
                                                    leading: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .primaryColor
                                                            .withOpacity(0.1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        _getReminderIcon(
                                                            reminder['type'],
                                                            medication.unit),
                                                        color: AppColors
                                                            .primaryColor,
                                                        size: 28,
                                                      ),
                                                    ),
                                                    title: Text(
                                                      reminder['title'],
                                                      style: const TextStyle(
                                                        fontFamily: 'cairo',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    subtitle: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          reminder['details'],
                                                          style:
                                                              const TextStyle(
                                                            fontFamily: 'cairo',
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        if (status != null)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 4),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  status ==
                                                                          'took'
                                                                      ? Icons
                                                                          .check_circle
                                                                      : status ==
                                                                              'skipped'
                                                                          ? Icons
                                                                              .cancel
                                                                          : Icons
                                                                              .snooze,
                                                                  color: status ==
                                                                          'took'
                                                                      ? Colors
                                                                          .green
                                                                      : status ==
                                                                              'skipped'
                                                                          ? Colors
                                                                              .red
                                                                          : Colors
                                                                              .blue,
                                                                  size: 16,
                                                                ),
                                                                const SizedBox(
                                                                    width: 4),
                                                                Text(
                                                                  'الحالة: ${status == 'took' ? 'أخذته' : status == 'skipped' ? 'تم التخطي' : 'تم التأجيل'}',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'cairo',
                                                                    fontSize:
                                                                        14,
                                                                    color: status ==
                                                                            'took'
                                                                        ? Colors
                                                                            .green
                                                                        : status ==
                                                                                'skipped'
                                                                            ? Colors.red
                                                                            : Colors.blue,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 8),
                                                                TextButton(
                                                                  onPressed:
                                                                      () async {
                                                                    try {
                                                                      final logBox =
                                                                          HiveService
                                                                              .getMedicationLogBox();
                                                                      final logs = logBox.values.where((log) =>
                                                                          log.medicationKey ==
                                                                              medication
                                                                                  .key &&
                                                                          log.notificationId ==
                                                                              reminder[
                                                                                  'notificationId'] &&
                                                                          isSameDay(
                                                                              log.timestamp,
                                                                              DateTime.now()));
                                                                      if (logs
                                                                          .isNotEmpty) {
                                                                        await logs
                                                                            .last
                                                                            .delete();
                                                                        // ✅ مش محتاج _loadReminders()
                                                                        // ValueListenableBuilder هيتحدث تلقائياً
                                                                        if (mounted) {
                                                                          ScaffoldMessenger.of(context)
                                                                              .clearSnackBars();
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(
                                                                            const SnackBar(content: Text('تم التراجع عن الإجراء')),
                                                                          );
                                                                        }
                                                                      }
                                                                    } catch (e) {
                                                                      if (mounted) {
                                                                        ScaffoldMessenger.of(context)
                                                                            .clearSnackBars();
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          SnackBar(
                                                                              content: Text('خطأ أثناء التراجع: $e')),
                                                                        );
                                                                      }
                                                                    }
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'تراجع',
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'cairo',
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .blue,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    trailing:
                                                        PopupMenuButton<String>(
                                                      icon: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColors
                                                              .primaryColor
                                                              .withOpacity(0.1),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                          Icons.more_vert,
                                                          color: AppColors
                                                              .primaryColor,
                                                        ),
                                                      ),
                                                      onSelected:
                                                          (value) async {
                                                        if (value == 'edit') {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  AddMedicationPage(
                                                                medication:
                                                                    medication,
                                                              ),
                                                            ),
                                                            // ✅ حذفنا .then((_) => _loadReminders())
                                                          );
                                                        } else if (value ==
                                                            'delete') {
                                                          try {
                                                            await NotificationService
                                                                .cancelMedicationNotifications(
                                                                    medication);
                                                            await medication
                                                                .delete();
                                                            // ✅ حذفنا _loadReminders()
                                                            if (mounted) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .clearSnackBars();
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                    content: Text(
                                                                        'تم الحذف بنجاح')),
                                                              );
                                                            }
                                                          } catch (e) {
                                                            if (mounted) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .clearSnackBars();
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                    content: Text(
                                                                        'خطأ أثناء الحذف: $e')),
                                                              );
                                                            }
                                                          }
                                                        }
                                                      },
                                                      itemBuilder: (context) =>
                                                          [
                                                        PopupMenuItem(
                                                          value: 'edit',
                                                          child: Row(
                                                            children: [
                                                              const Icon(
                                                                  FontAwesomeIcons
                                                                      .pen,
                                                                  size: 16),
                                                              const SizedBox(
                                                                  width: 8),
                                                              const Text(
                                                                  'تعديل',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'cairo')),
                                                            ],
                                                          ),
                                                        ),
                                                        PopupMenuItem(
                                                          value: 'delete',
                                                          child: Row(
                                                            children: [
                                                              const Icon(
                                                                  FontAwesomeIcons
                                                                      .trash,
                                                                  size: 16),
                                                              const SizedBox(
                                                                  width: 8),
                                                              const Text('حذف',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'cairo')),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (status == null ||
                                                      status == 'snoozed')
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        IconButton(
                                                          icon: Row(
                                                            children: const [
                                                              Icon(
                                                                  Icons
                                                                      .check_circle,
                                                                  color: Colors
                                                                      .green),
                                                              SizedBox(
                                                                  width: 4),
                                                              Text(
                                                                'أخذته',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'cairo',
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          onPressed: () async {
                                                            try {
                                                              await HiveService
                                                                      .getMedicationLogBox()
                                                                  .add(
                                                                MedicationLog(
                                                                  medicationKey:
                                                                      medication
                                                                          .key,
                                                                  timestamp:
                                                                      DateTime
                                                                          .now(),
                                                                  action:
                                                                      'took',
                                                                  notificationId:
                                                                      reminder[
                                                                          'notificationId'],
                                                                ),
                                                              );
                                                              await AwesomeNotifications()
                                                                  .cancel(reminder[
                                                                      'notificationId']);
                                                              // ✅ ValueListenableBuilder هيتحدث تلقائياً
                                                              if (mounted) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .clearSnackBars();
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          'تم تسجيل أخذ الدواء')),
                                                                );
                                                              }
                                                            } catch (e) {
                                                              if (mounted) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .clearSnackBars();
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                      content: Text(
                                                                          'خطأ: $e')),
                                                                );
                                                              }
                                                            }
                                                          },
                                                          tooltip: 'أخذته',
                                                        ),
                                                        Container(
                                                          width: 1,
                                                          height: 40,
                                                          color: Colors
                                                              .grey.shade300,
                                                        ),
                                                        IconButton(
                                                          icon: Row(
                                                            children: const [
                                                              Icon(Icons.cancel,
                                                                  color: Colors
                                                                      .red),
                                                              SizedBox(
                                                                  width: 4),
                                                              Text(
                                                                'تخطي',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'cairo',
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          onPressed: () async {
                                                            try {
                                                              await HiveService
                                                                      .getMedicationLogBox()
                                                                  .add(
                                                                MedicationLog(
                                                                  medicationKey:
                                                                      medication
                                                                          .key,
                                                                  timestamp:
                                                                      DateTime
                                                                          .now(),
                                                                  action:
                                                                      'skipped',
                                                                  notificationId:
                                                                      reminder[
                                                                          'notificationId'],
                                                                ),
                                                              );
                                                              await AwesomeNotifications()
                                                                  .cancel(reminder[
                                                                      'notificationId']);
                                                              // ✅ ValueListenableBuilder هيتحدث تلقائياً
                                                              if (mounted) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .clearSnackBars();
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          'تم تسجيل تخطي الدواء')),
                                                                );
                                                              }
                                                            } catch (e) {
                                                              if (mounted) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .clearSnackBars();
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                      content: Text(
                                                                          'خطأ: $e')),
                                                                );
                                                              }
                                                            }
                                                          },
                                                          tooltip: 'تخطي',
                                                        ),
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
                                ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ─── قسم أحدث نتائج التحاليل ───
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أحدث نتائج التحاليل',
                      style: TextStyle(
                        fontFamily: 'cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: Hive.box<MedicalAnalysis>(MedicalAnalysisService.boxName).listenable(),
                      builder: (context, _, __) => FutureBuilder(
                        future:
                            _medicalAnalysisService.getLatestAnalysesByLastDay(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Text(
                            'حدث خطأ أثناء تحميل البيانات.',
                            style: TextStyle(
                              fontFamily: 'cairo',
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            (snapshot.data as List).isEmpty) {
                          return const Text(
                            'لا توجد نتائج تحليل حديثة.',
                            style: TextStyle(
                              fontFamily: 'cairo',
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          );
                        } else {
                          final analyses = snapshot.data as List<AnalysisState>;
                          return MasonryGridView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                            ),
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 4,
                            itemCount: analyses.length,
                            itemBuilder: (context, index) {
                              final analysis = analyses[index];
                              return GestureDetector(
                                onTap: _showTodaysAnalyses,
                                child: AnimatedScale(
                                  scale: 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 239, 239, 239),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            blurRadius: 1,
                                            blurStyle: BlurStyle.outer,
                                            offset: const Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              analysis.name,
                                              style: const TextStyle(
                                                fontFamily: 'cairo',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Color.fromARGB(
                                                    255, 0, 0, 0),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 0),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if (analysis.value != 0.0)
                                                    Text(
                                                      "القيمة: ${analysis.value}",
                                                      style: const TextStyle(
                                                        fontFamily: 'cairo',
                                                        fontSize: 12,
                                                        color: Color.fromARGB(
                                                            255, 0, 0, 0),
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  if (analysis.normalLimits != "N/A")
                                                    Text(
                                                      "الحدود: ${analysis.normalLimits}",
                                                      style: const TextStyle(
                                                        fontFamily: 'cairo',
                                                        fontSize: 12,
                                                        color: Color.fromARGB(
                                                            255, 100, 100, 100),
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  Text(
                                                    analysis.description.isEmpty
                                                        ? 'No description'
                                                        : analysis.description,
                                                    style: TextStyle(
                                                      fontFamily: 'cairo',
                                                      fontSize: 14,
                                                      color: AppColors
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    'تاريخ: ${DateFormat('yyyy-MM-dd').format(analysis.date)}',
                                                    style: const TextStyle(
                                                      fontFamily: 'cairo',
                                                      fontSize: 12,
                                                      color: Color.fromARGB(
                                                          255, 100, 100, 100),
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GradientGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.blue.withOpacity(0.7),
          Colors.purple.withOpacity(0.7),
          Colors.orange.withOpacity(0.7),
          Colors.blue.withOpacity(0.5),
          Colors.green.withOpacity(0.5),
          Colors.pink.withOpacity(0.5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
