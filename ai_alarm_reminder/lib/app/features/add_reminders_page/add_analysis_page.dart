import 'package:ai_alarm_reminder/app/core/services/hive_service.dart';
import 'package:ai_alarm_reminder/app/core/services/notification_service.dart';
import 'package:ai_alarm_reminder/app/core/services/service_models/models.dart';
import 'package:ai_alarm_reminder/app/core/utils/extensions.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class AddAnalysisPage extends StatefulWidget {
  final Analysis? analysis;

  const AddAnalysisPage({super.key, this.analysis});

  @override
  _AddAnalysisPageState createState() => _AddAnalysisPageState();
}

class _AddAnalysisPageState extends State<AddAnalysisPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  DateTime _date = DateTime.now();
  String _labName = '';
  String _notes = '';

  @override
  void initState() {
    super.initState();
    if (widget.analysis != null) {
      _name = widget.analysis!.name;
      _date = widget.analysis!.date;
      _labName = widget.analysis!.labName;
      _notes = widget.analysis!.notes;
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.analysis == null ? 'إضافة تحليل' : 'تعديل تحليل')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'اسم التحليل'),
                validator: (value) =>
                    value!.isEmpty ? 'يرجى إدخال اسم التحليل' : null,
                onSaved: (value) => _name = value!,
                textDirection: TextDirection.rtl,
              ),
              ListTile(
                title: Text('التاريخ: ${_date.formatDate()}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              TextFormField(
                initialValue: _labName,
                decoration: const InputDecoration(labelText: 'اسم المختبر'),
                validator: (value) =>
                    value!.isEmpty ? 'يرجى إدخال اسم المختبر' : null,
                onSaved: (value) => _labName = value!,
                textDirection: TextDirection.rtl,
              ),
              TextFormField(
                initialValue: _notes,
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
                      final analysis = Analysis(
                        name: _name,
                        date: _date,
                        labName: _labName,
                        notes: _notes,
                      );
                      final box = HiveService.getAnalysisBox();
                      if (widget.analysis != null) {
                        await AwesomeNotifications()
                            .cancel(widget.analysis!.key.hashCode);
                        await widget.analysis!.delete();
                      }
                      await box.add(analysis);
                      await NotificationService.scheduleAnalysisNotification(
                          analysis);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(widget.analysis == null
                                ? 'تم إضافة التحليل بنجاح'
                                : 'تم تعديل التحليل بنجاح')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('خطأ أثناء الحفظ: $e')),
                      );
                    }
                  }
                },
                child: Text(
                    widget.analysis == null ? 'حفظ التحليل' : 'تعديل التحليل'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
