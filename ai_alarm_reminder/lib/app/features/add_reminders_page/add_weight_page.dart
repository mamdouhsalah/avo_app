import 'package:ai_alarm_reminder/app/core/utils/extensions.dart';
import 'package:ai_alarm_reminder/app/core/services/hive_service.dart';
import 'package:ai_alarm_reminder/app/core/services/service_models/models.dart';
import 'package:ai_alarm_reminder/app/core/services/notification_service.dart';
import 'package:flutter/material.dart';

class AddWeightPage extends StatefulWidget {
  const AddWeightPage({super.key});

  @override
  _AddWeightPageState createState() => _AddWeightPageState();
}

class _AddWeightPageState extends State<AddWeightPage> {
  final _formKey = GlobalKey<FormState>();
  double _weight = 0.0;
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
      appBar: AppBar(title: const Text('إضافة قياس وزن')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'الوزن (كجم)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'يرجى إدخال الوزن' : null,
                onSaved: (value) => _weight = double.parse(value!),
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
                      final weight = Weight(
                        weight: _weight,
                        date: _date,
                        notes: _notes,
                        remind: _remind,
                      );
                      final box = HiveService.getWeightBox();
                      await box.add(weight);
                      if (_remind) {
                        await NotificationService.scheduleWeightNotification(
                            weight);
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('تم إضافة قياس الوزن بنجاح')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('خطأ أثناء الحفظ: $e')),
                      );
                    }
                  }
                },
                child: const Text('حفظ قياس الوزن'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
