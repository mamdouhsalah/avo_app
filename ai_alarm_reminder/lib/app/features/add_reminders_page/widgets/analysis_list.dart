import 'package:ai_alarm_reminder/app/core/utils/extensions.dart';
import 'package:ai_alarm_reminder/app/core/services/hive_service.dart';
import 'package:ai_alarm_reminder/app/core/services/service_models/models.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';


class AnalysisList extends StatelessWidget {
  const AnalysisList({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveService.getAnalysisBox().listenable(),
      builder: (context, Box<Analysis> box, _) {
        if (box.isEmpty) {
          return const Center(child: Text('لا توجد تحاليل مضافة بعد'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: box.length,
          itemBuilder: (context, index) {
            final analysis = box.getAt(index)!;
            return AnalysisCard(analysis: analysis);
          },
        );
      },
    );
  }
}

class AnalysisCard extends StatelessWidget {
  final Analysis analysis;

  const AnalysisCard({super.key, required this.analysis});

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
                  analysis.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    try {
                      await AwesomeNotifications()
                          .cancel(analysis.key.hashCode);
                      await analysis.delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم حذف التحليل بنجاح')),
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
            Text('التاريخ: ${analysis.date.formatDate()}'),
            Text('المختبر: ${analysis.labName}'),
            const SizedBox(height: 8),
            Text('ملاحظات: ${analysis.notes}'),
          ],
        ),
      ),
    );
  }
}
