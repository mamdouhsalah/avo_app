import 'package:ai_alarm_reminder/app/core/utils/extensions.dart';
import 'package:ai_alarm_reminder/app/core/services/hive_service.dart';
import 'package:ai_alarm_reminder/app/core/services/service_models/models.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';


class WeightList extends StatelessWidget {
  const WeightList({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveService.getWeightBox().listenable(),
      builder: (context, Box<Weight> box, _) {
        if (box.isEmpty) {
          return const Center(child: Text('لا توجد قياسات وزن مضافة بعد'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: box.length,
          itemBuilder: (context, index) {
            final weight = box.getAt(index)!;
            return WeightCard(weight: weight);
          },
        );
      },
    );
  }
}

class WeightCard extends StatelessWidget {
  final Weight weight;

  const WeightCard({super.key, required this.weight});

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
                  'الوزن: ${weight.weight} كجم',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    try {
                      await AwesomeNotifications().cancel(weight.key.hashCode);
                      await weight.delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('تم حذف قياس الوزن بنجاح')),
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
            Text('التاريخ: ${weight.date.formatDate()}'),
            Text('تذكير: ${weight.remind ? 'مفعل' : 'غير مفعل'}'),
            const SizedBox(height: 8),
            Text('ملاحظات: ${weight.notes}'),
          ],
        ),
      ),
    );
  }
}
