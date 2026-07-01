import 'package:ai_alarm_reminder/app/core/utils/extensions.dart';
import 'package:ai_alarm_reminder/app/core/services/hive_service.dart';
import 'package:ai_alarm_reminder/app/core/services/service_models/models.dart';
import 'package:ai_alarm_reminder/app/core/services/notification_service.dart';
import 'package:flutter/material.dart';

class AddHealthMetricPage extends StatefulWidget {
  const AddHealthMetricPage({super.key});

  @override
  _AddHealthMetricPageState createState() => _AddHealthMetricPageState();
}

class _AddHealthMetricPageState extends State<AddHealthMetricPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _value = 0.0;
  String _unit = '';
  DateTime _date = DateTime.now();
  String _notes = '';
  bool _remind = false;

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('إضافة مقياس صحي')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'اسم المقياس'),
                    validator: (value) =>
                        value!.isEmpty ? 'يرجى إدخال اسم المقياس' : null,
                    onSaved: (value) => _name = value!,
                    textDirection: TextDirection.rtl,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'القيمة'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'يرجى إدخال القيمة' : null,
                    onSaved: (value) => _value = double.parse(value!),
                    textDirection: TextDirection.rtl,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'الوحدة'),
                    validator: (value) =>
                        value!.isEmpty ? 'يرجى إدخال الوحدة' : null,
                    onSaved: (value) => _unit = value!,
                    textDirection: TextDirection.rtl,
                  ),
                  ListTile(
                    title: Text('التاريخ: ${_date.formatDate()}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickDate,
                  ),
                  CheckboxListTile(
                    title: const Text('تفعيل تذكير يومي'),
                    value: _remind,
                    onChanged: (value) => setState(() => _remind = value!),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'ملاحظات'),
                    maxLines: 3,
                    onSaved: (value) => _notes = value!,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        try {
                          final metric = HealthMetric(
                            type: _name,
                            value: _value,
                            unit: _unit,
                            date: _date,
                            notes: _notes,
                            remind: _remind,
                          );
                          final box = HiveService.getHealthMetricBox();
                          await box.add(metric);
                          if (_remind) {
                            await NotificationService
                                .scheduleHealthMetricNotification(metric);
                          }
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('تم إضافة المقياس الصحي بنجاح')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('خطأ أثناء الحفظ: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('حفظ المقياس الصحي'),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
