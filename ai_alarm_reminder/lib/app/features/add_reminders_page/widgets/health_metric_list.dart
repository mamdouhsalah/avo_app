import 'package:ai_alarm_reminder/app/core/utils/extensions.dart';
import 'package:ai_alarm_reminder/app/core/services/hive_service.dart';
import 'package:ai_alarm_reminder/app/core/services/service_models/models.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HealthMetricList extends StatelessWidget {
  const HealthMetricList({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveService.getHealthMetricBox().listenable(),
      builder: (context, Box<HealthMetric> box, _) {
        if (box.isEmpty) {
          return const Center(child: Text('لا توجد مقاييس صحية مضافة بعد'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: box.length,
          itemBuilder: (context, index) {
            final metric = box.getAt(index)!;
            return HealthMetricCard(metric: metric);
          },
        );
      },
    );
  }
}

class HealthMetricCard extends StatelessWidget {
  final HealthMetric metric;

  const HealthMetricCard({super.key, required this.metric});

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
                  '${metric.name}: ${metric.value} ${metric.unit}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    try {
                      await AwesomeNotifications().cancel(metric.key.hashCode);
                      await metric.delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('تم حذف المقياس الصحي بنجاح')),
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
            Text('التاريخ: ${metric.date.formatDate()}'),
            Text('تذكير: ${metric.remind ? 'مفعل' : 'غير مفعل'}'),
            const SizedBox(height: 8),
            Text('ملاحظات: ${metric.notes}'),
          ],
        ),
      ),
    );
  }
}
