import 'dart:developer';

import 'package:avo_app/app/core/services/local/hive_service.dart';
import 'package:avo_app/app/core/services/local/hive_models.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer_impl.dart';
import 'package:avo_app/app/core/utils/day_localizer.dart';
import 'package:avo_app/app/features/reminder/data/medication_log_repository.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static Future<void> init() async {
    final settingsBox = await Hive.openBox('settings');
    final soundEnabled =
        settingsBox.get('notificationSound', defaultValue: true);
    final vibrationEnabled =
        settingsBox.get('notificationVibration', defaultValue: true);
    await AwesomeNotifications().initialize(
      null, // Reference to your icon, null uses default app icon
      [
        NotificationChannel(
          channelKey: 'med_channel',
          channelName: 'تذكيرات الأدوية',
          channelDescription: 'إشعارات لتذكير الأدوية',
          importance: NotificationImportance.Max,
          locked: true, // Non-dismissible
          channelShowBadge: true,
          ledColor: Colors.white,
          defaultColor: Color(0xFF9D50DD),
          playSound: soundEnabled,
          enableVibration: vibrationEnabled,
          defaultPrivacy: NotificationPrivacy.Public,
          defaultRingtoneType: DefaultRingtoneType.Ringtone,
          vibrationPattern: Int64List.fromList([0, 2000, 500, 2000]),
        ),
        NotificationChannel(
          channelKey: 'analysis_channel',
          channelName: 'تذكيرات التحاليل',
          channelDescription: 'إشعارات لتذكير التحاليل الطبية',
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: soundEnabled,
          enableVibration: vibrationEnabled,
          defaultRingtoneType: DefaultRingtoneType.Ringtone,
          vibrationPattern: Int64List.fromList([0, 2000, 500, 2000]),
        ),
        NotificationChannel(
          channelKey: 'appointment_channel',
          channelName: 'تذكيرات المواعيد',
          channelDescription: 'إشعارات لتذكير المواعيد الطبية',
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: soundEnabled,
          enableVibration: vibrationEnabled,
          defaultRingtoneType: DefaultRingtoneType.Ringtone,
          vibrationPattern: Int64List.fromList([0, 2000, 500, 2000]),
        ),
        NotificationChannel(
          channelKey: 'weight_channel',
          channelName: 'تذكيرات الوزن',
          channelDescription: 'إشعارات لتذكير قياس الوزن',
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: soundEnabled,
          enableVibration: vibrationEnabled,
          defaultRingtoneType: DefaultRingtoneType.Ringtone,
          vibrationPattern: Int64List.fromList([0, 2000, 500, 2000]),
        ),
        NotificationChannel(
          channelKey: 'health_metric_channel',
          channelName: 'تذكيرات المقاييس الصحية',
          channelDescription: 'إشعارات لتذكير المقاييس الصحية',
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: soundEnabled,
          enableVibration: vibrationEnabled,
          defaultRingtoneType: DefaultRingtoneType.Ringtone,
          vibrationPattern: Int64List.fromList([0, 2000, 500, 2000]),
        ),
      ],
    );

    // Request notification permissions
    if (kIsWeb) {
      await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
        if (!isAllowed) {
          AwesomeNotifications().requestPermissionToSendNotifications(
            channelKey: 'med_channel',
            permissions: [
              NotificationPermission.Alert,
              NotificationPermission.Sound,
              NotificationPermission.Vibration,
              NotificationPermission
                  .FullScreenIntent, // Request full-screen permission
            ],
          );
        }
      });
    } else {
      await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
        if (!isAllowed) {
          AwesomeNotifications().requestPermissionToSendNotifications(
            channelKey: 'med_channel',
            permissions: [
              NotificationPermission.Alert,
              NotificationPermission.Sound,
              NotificationPermission.Vibration,
              NotificationPermission
                  .FullScreenIntent, // Request full-screen permission
            ],
          );
        }
      });
    }

    // Listen for notification actions
    AwesomeNotifications().setListeners(onActionReceivedMethod: (action) async {
      if (action.channelKey == 'med_channel') {
        final payload = action.payload;
        final medicationKey = int.parse(payload!['medicationKey']!);
        final notificationId = int.parse(payload['notificationId']!);
        final time = payload['time']!;
        final logBox = HiveService.getMedicationLogBox();

        if (action.buttonKeyPressed == 'TOOK') {
          await logBox.add(MedicationLog(
            medicationKey: medicationKey,
            timestamp: DateTime.now(),
            action: 'took',
            notificationId: notificationId,
            logId: '',
            medicationId: '',
            medicationName: '',
            actionDate: DateTime.now(),
            scheduledTime: '',
            status: '',
          ));
          await AwesomeNotifications().cancel(notificationId);
        } else if (action.buttonKeyPressed == 'SKIPPED') {
          await logBox.add(MedicationLog(
            medicationKey: medicationKey,
            timestamp: DateTime.now(),
            action: 'skipped',
            notificationId: notificationId,
            logId: '',
            medicationId: '',
            medicationName: '',
            actionDate: DateTime.now(),
            scheduledTime: '',
            status: '',
          ));
          await AwesomeNotifications().cancel(notificationId);
        } else if (action.buttonKeyPressed == 'SNOOZE') {
          await logBox.add(MedicationLog(
            medicationKey: medicationKey,
            timestamp: DateTime.now(),
            action: 'snoozed',
            notificationId: notificationId,
            logId: '',
            medicationId: '',
            medicationName: '',
            actionDate: DateTime.now(),
            scheduledTime: '',
            status: '',
          ));
          // Reschedule notification for 15 minutes later
          final med = HiveService.getMedicationBox()
              .values
              .firstWhere((m) => m.key == medicationKey);
          final now = DateTime.now();
          final snoozeTime = now.add(Duration(minutes: 15));
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              fullScreenIntent: true,
              locked: true,
              id: notificationId,
              channelKey: 'med_channel',
              title: 'تذكير بالدواء: ${med.name}',
              body: 'حان وقت أخذ ${med.dose} ${med.unit} من ${med.name}',
              payload: {
                'medicationKey': medicationKey.toString(),
                'notificationId': notificationId.toString(),
                'time': time,
              },
            ),
            actionButtons: [
              NotificationActionButton(
                key: 'TOOK',
                label: 'أخذته',
                color: Colors.green,
                autoDismissible: true,
              ),
              NotificationActionButton(
                key: 'SKIPPED',
                label: 'تخطي',
                color: Colors.red,
                autoDismissible: true,
              ),
              NotificationActionButton(
                key: 'SNOOZE',
                label: 'تأجيل',
                color: Colors.blue,
                autoDismissible: false,
              ),
            ],
            schedule: NotificationCalendar(
              year: snoozeTime.year,
              month: snoozeTime.month,
              day: snoozeTime.day,
              hour: snoozeTime.hour,
              minute: snoozeTime.minute,
              second: 0,
              millisecond: 0,
              allowWhileIdle: true,
            ),
          );
        }
      }
    });
    await AwesomeNotifications().requestPermissionToSendNotifications(
      channelKey: 'med_channel',
      permissions: [
        NotificationPermission.Alert,
        NotificationPermission.Sound,
        NotificationPermission.Vibration,
        NotificationPermission
            .FullScreenIntent, // Request full-screen permission
      ],
    );

    // Check for initial notification action (app launched from notification)
    final initialAction =
        await AwesomeNotifications().getInitialNotificationAction();
    if (initialAction != null && initialAction.channelKey == 'med_channel') {
      await handleNotificationAction(initialAction);
    }

    // Listen for notification actions
    // AwesomeNotifications().setListeners(
    //   onActionReceivedMethod: (ReceivedAction action) async {
    //     if (action.channelKey == 'med_channel') {
    //       await _handleNotificationAction(action);
    //     }
    //   },
    // );
    requestBatteryOptimization();
  }

  // Static method for handling actions in background/terminated state
  @pragma('vm:entry-point')
  static Future<void> onActionReceived(ReceivedAction action) async {
    // Initialize Hive in background
    try {
      await HiveService.init();
      await handleNotificationAction(action);
    } catch (e) {
      // Log error (e.g., to native logs or file)
      log('Error in background action handler: $e');
    }
  }
// static Future<void> initializeBackgroundHandler() async {
//     AwesomeNotifications().setListeners(
//       onActionReceivedMethod: (ReceivedAction action) async {
//         await HiveService.init(); // Reinitialize Hive in background
//         await _handleNotificationAction(action);
//       },
//     );
//   }

  static Future<void> handleNotificationAction(ReceivedAction action) async {
    final payload = action.payload;
    if (payload == null) return;

    final medicationKey = int.parse(payload['medicationKey']!);
    final medicationId = payload['medicationId']!;
    final medicationName = payload['medicationName']!;
    final notificationId = int.parse(payload['notificationId']!);
    final time = payload['time']!;

    // Create a temporary FirebaseConsumer for background usage
    final firebaseConsumer = FirebaseConsumerImpl();
    try {
      await firebaseConsumer.init();
    } catch (e) {
      log('Background Firebase init error (might already be initialized): $e');
    }
    
    final logRepository = LogRepository(firebaseConsumer: firebaseConsumer);

    Future<void> recordLog(String status) async {
      final logEntry = MedicationLog(
        logId: '', // Will be generated in repository
        medicationKey: medicationKey,
        medicationId: medicationId,
        medicationName: medicationName,
        actionDate: DateTime.now(),
        scheduledTime: time,
        status: status,
        action: status,
        timestamp: DateTime.now(),
        notificationId: notificationId,
      );
      await logRepository.saveLog(logEntry);
    }

    if (action.buttonKeyPressed == 'TAKE_ACTION') {
      await recordLog('taken');
      await AwesomeNotifications().cancel(notificationId);
    } else if (action.buttonKeyPressed == 'SKIP_ACTION') {
      await recordLog('skipped');
      await AwesomeNotifications().cancel(notificationId);
    } else if (action.buttonKeyPressed == 'SNOOZE') {
      await recordLog('snoozed');

      // Reschedule notification for 15 minutes later
      final med = HiveService.getMedicationBox()
          .values
          .firstWhere((m) => m.key == medicationKey);
      final now = DateTime.now();
      final snoozeTime = now.add(Duration(minutes: 15));
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'med_channel',
          title: 'تذكير بالدواء: ${med.name}',
          body: 'حان وقت أخذ ${med.dose} ${med.unit} من ${med.name}',
          payload: payload,
          fullScreenIntent: true,
          locked: true,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'TAKE_ACTION',
            label: 'أخذته',
            color: Colors.green,
            autoDismissible: true,
          ),
          NotificationActionButton(
            key: 'SKIP_ACTION',
            label: 'تخطي',
            color: Colors.red,
            autoDismissible: true,
          ),
          NotificationActionButton(
            key: 'SNOOZE',
            label: 'تأجيل',
            color: Colors.blue,
            autoDismissible: false,
          ),
        ],
        schedule: NotificationCalendar(
          year: snoozeTime.year,
          month: snoozeTime.month,
          day: snoozeTime.day,
          hour: snoozeTime.hour,
          minute: snoozeTime.minute,
          second: 0,
          millisecond: 0,
          allowWhileIdle: true,
        ),
      );
    } else if (action.buttonKeyPressed == 'DISMISS') {
      await AwesomeNotifications().cancel(notificationId);
    }
  }

  static Future<void> scheduleMedicationNotification(
      Medication medication, String time, int index) async {
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Lookup Firebase Key
    final settingsBox = Hive.box('settings');
    final firebaseKey = settingsBox.get('firebase_key_${medication.key}') as String? ?? '';

    for (var day in medication.days) {
      final weekday = englishDayToWeekday(day);
      log('weekday: $weekday');

      // Generate a unique notification ID by including the weekday
      final notificationId = '${medication.key}$index$weekday'.hashCode;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          fullScreenIntent: true, // Enable full-screen display
          wakeUpScreen: true, // Wake up the screen
          criticalAlert: true, // High-priority alert
          category: NotificationCategory.Alarm, // Suitable for alarms or calls
          autoDismissible: false, // Prevent auto-dismissal
          id: notificationId,
          channelKey: 'med_channel',
          title: 'تذكير بالدواء: ${medication.name}',
          body:
              'حان وقت أخذ ${medication.dose} ${medication.unit} من ${medication.name}',
          payload: {
            'medicationKey': medication.key.toString(),
            'medicationId': firebaseKey,
            'medicationName': medication.name,
            'notificationId': notificationId.toString(),
            'time': time,
          },
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'TAKE_ACTION',
            label: 'أخذته',
            color: Colors.green,
            autoDismissible: true,
          ),
          NotificationActionButton(
            key: 'SKIP_ACTION',
            label: 'تخطي',
            color: Colors.red,
            autoDismissible: true,
          ),
          NotificationActionButton(
            key: 'SNOOZE',
            label: 'تأجيل',
            color: Colors.blue,
            autoDismissible: false,
          ),
        ],
        schedule: NotificationCalendar(
          weekday: weekday,
          hour: hour,
          minute: minute,
          second: 0,
          millisecond: 0,
          repeats: true,
          allowWhileIdle: true,
        ),
      );
    }
  }

  static Future<void> cancelMedicationNotifications(Medication med) async {
    for (int i = 0; i < med.times.length; i++) {
      for (String day in med.days) {
        final weekday = englishDayToWeekday(day);
          await AwesomeNotifications()
              .cancel(med.key.hashCode + i + weekday * 100);
      }
    }
  }

  static Future<void> scheduleAnalysisNotification(Analysis analysis) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: analysis.key.hashCode,
        channelKey: 'analysis_channel',
        title: 'تذكير بالتحليل: ${analysis.name}',
        body: 'موعد التحليل في ${analysis.labName} اليوم',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        year: analysis.date.year,
        month: analysis.date.month,
        day: analysis.date.day,
        hour: 8,
        minute: 0,
        second: 0,
      ),
    );
  }

  static Future<void> scheduleAppointmentNotification(
      Appointment appointment) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: appointment.key.hashCode,
        channelKey: 'appointment_channel',
        title: 'تذكير بالموعد: ${appointment.title}',
        body:
            'الموعد في ${appointment.location} الساعة ${DateFormat('HH:mm').format(appointment.dateTime)}',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        year: appointment.dateTime.year,
        month: appointment.dateTime.month,
        day: appointment.dateTime.day,
        hour: appointment.dateTime.hour,
        minute: appointment.dateTime.minute,
        second: 0,
      ),
    );
  }

  static Future<void> scheduleWeightNotification(Weight weight) async {
    if (!weight.remind) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: weight.key.hashCode,
        channelKey: 'weight_channel',
        title: 'تذكير بقياس الوزن',
        body: 'حان وقت قياس وزنك اليوم',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        year: weight.date.year,
        month: weight.date.month,
        day: weight.date.day,
        hour: 9,
        minute: 0,
        second: 0,
      ),
    );
  }

  static Future<void> scheduleHealthMetricNotification(
      HealthMetric metric) async {
    if (!metric.remind) return;

    final String displayName = {
          'sugar': 'سكر الدم',
          'pressure': 'ضغط الدم',
          'pressure_systolic': 'ضغط الدم',
          'pressure_diastolic': 'ضغط الدم',
          'weight': 'الوزن',
          'sleep': 'ساعات النوم',
        }[metric.type] ??
        metric.type;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: metric.key.hashCode,
        channelKey: 'health_metric_channel',
        title: 'تذكير بقياس: $displayName',
        body: 'حان وقت قياس $displayName اليوم',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        year: metric.date.year,
        month: metric.date.month,
        day: metric.date.day,
        hour: 9,
        minute: 0,
        second: 0,
      ),
    );
  }
}

Future<void> requestBatteryOptimization() async {
  if (await Permission.ignoreBatteryOptimizations.isDenied) {
    await Permission.ignoreBatteryOptimizations.request();
  }
}
