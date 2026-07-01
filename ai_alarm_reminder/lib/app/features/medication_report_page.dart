import 'package:ai_alarm_reminder/app/core/services/hive_service.dart';
import 'package:ai_alarm_reminder/app/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';


class MedicationReportPage extends StatefulWidget {
  const MedicationReportPage({super.key});

  @override
  _MedicationReportPageState createState() => _MedicationReportPageState();
}

class _MedicationReportPageState extends State<MedicationReportPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String? _selectedMedication;

  void _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير الأدوية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _pickDateRange,
            tooltip: 'اختيار نطاق التاريخ',
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: HiveService.getMedicationBox().listenable(),
        builder: (context, _, __) => ValueListenableBuilder(
          valueListenable: HiveService.getMedicationLogBox().listenable(),
          builder: (context, _, __) {
            final medications = HiveService.getMedicationBox().values.toList();
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButton<String>(
                    hint: const Text('اختر الدواء'),
                    value: _selectedMedication,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('جميع الأدوية'),
                      ),
                      ...medications.map((med) => DropdownMenuItem<String>(
                            value: med.key.toString(),
                            child: Text(med.name),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedMedication = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'النطاق الزمني: ${_startDate.formatDate()} إلى ${_endDate.formatDate()}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildReport(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReport(BuildContext context) {
    final logs = HiveService.getMedicationLogBox().values.where((log) {
      final inDateRange =
          log.timestamp.isAfter(_startDate.subtract(const Duration(days: 1))) &&
              log.timestamp.isBefore(_endDate.add(const Duration(days: 1)));
      final matchesMedication = _selectedMedication == null ||
          log.medicationKey.toString() == _selectedMedication;
      return inDateRange && matchesMedication;
    }).toList();

    if (logs.isEmpty) {
      return const Center(child: Text('لا توجد سجلات لهذا النطاق'));
    }

    final medicationBox = HiveService.getMedicationBox();
    final tookCount = logs.where((log) => log.action == 'took').length;
    final skippedCount = logs.where((log) => log.action == 'skipped').length;
    final totalCount = tookCount + skippedCount;
    final adherenceRate = totalCount > 0
        ? (tookCount / totalCount * 100).toStringAsFixed(1)
        : '0.0';

    return ListView(
      children: [
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'إحصائيات الالتزام',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('الجرعات المأخوذة: $tookCount'),
                Text('الجرعات المتخطاة: $skippedCount'),
                Text('نسبة الالتزام: $adherenceRate%'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'سجل الجرعات',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ...logs.map((log) {
          final med = medicationBox.get(log.medicationKey);
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(med?.name ?? 'دواء غير معروف'),
              subtitle: Text(
                '${log.timestamp.formatDateTime()} - ${log.action == 'took' ? 'أخذته' : log.action == 'skipped' ? 'تم التخطي' : 'تم التأجيل'}',
              ),
              leading: Icon(
                log.action == 'took'
                    ? Icons.check_circle
                    : log.action == 'skipped'
                        ? Icons.cancel
                        : Icons.access_time,
                color: log.action == 'took'
                    ? Colors.green
                    : log.action == 'skipped'
                        ? Colors.red
                        : Colors.blue,
              ),
            ),
          );
        }),
      ],
    );
  }
}
