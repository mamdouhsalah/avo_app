import 'package:ai_alarm_reminder/app/core/services/hive_service.dart';
import 'package:ai_alarm_reminder/app/core/services/service_models/models.dart';
import 'package:ai_alarm_reminder/app/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';


class MedicationList extends StatelessWidget {
  const MedicationList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: HiveService.getMedicationBox().listenable(),
        builder: (context, Box<Medication> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('لا توجد أدوية مضافة بعد'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final med = box.getAt(index)!;
              return MedicationCard(medication: med);
            },
          );
        },
      ),
    );
  }
}

class MedicationCard extends StatelessWidget {
  final Medication medication;

  const MedicationCard({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  medication.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    try {
                      await NotificationService.cancelMedicationNotifications(
                          medication);
                      await medication.delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم حذف الدواء بنجاح')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('خطأ أثناء الحذف: $e')),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('الجرعة: ${medication.dose} ${medication.unit}'),
            Text('الأوقات: ${medication.times.join("، ")}'),
            Text('الأيام: ${medication.days.join("، ")}'),
            const SizedBox(height: 8),
            Text('التعليمات: ${medication.instructions}'),
          ],
        ),
      ),
    );
  }
}
