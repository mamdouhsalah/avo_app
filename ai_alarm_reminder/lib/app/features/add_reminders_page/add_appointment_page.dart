import 'package:ai_alarm_reminder/app/core/services/hive_service.dart';
import 'package:ai_alarm_reminder/app/core/services/notification_service.dart';
import 'package:ai_alarm_reminder/app/core/services/service_models/models.dart';
import 'package:ai_alarm_reminder/app/core/utils/extensions.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';


class AddAppointmentPage extends StatefulWidget {
  final Appointment? appointment;

  const AddAppointmentPage({super.key, this.appointment});

  @override
  _AddAppointmentPageState createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends State<AddAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  DateTime _dateTime = DateTime.now();
  String _location = '';
  String _notes = '';

  @override
  void initState() {
    super.initState();
    if (widget.appointment != null) {
      _title = widget.appointment!.title;
      _dateTime = widget.appointment!.dateTime;
      _location = widget.appointment!.location;
      _notes = widget.appointment!.notes;
    }
  }

  void _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dateTime),
      );
      if (time != null) {
        setState(() {
          _dateTime =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(widget.appointment == null ? 'إضافة موعد' : 'تعديل موعد')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'عنوان الموعد'),
                validator: (value) =>
                    value!.isEmpty ? 'يرجى إدخال عنوان الموعد' : null,
                onSaved: (value) => _title = value!,
                textDirection: TextDirection.rtl,
              ),
              ListTile(
                title: Text('التاريخ والوقت: ${_dateTime.formatDateTime()}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDateTime,
              ),
              TextFormField(
                initialValue: _location,
                decoration: const InputDecoration(labelText: 'الموقع'),
                validator: (value) =>
                    value!.isEmpty ? 'يرجى إدخال الموقع' : null,
                onSaved: (value) => _location = value!,
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
                      final appointment = Appointment(
                        title: _title,
                        dateTime: _dateTime,
                        location: _location,
                        notes: _notes,
                      );
                      final box = HiveService.getAppointmentBox();
                      if (widget.appointment != null) {
                        await AwesomeNotifications()
                            .cancel(widget.appointment!.key.hashCode);
                        await widget.appointment!.delete();
                      }
                      await box.add(appointment);
                      await NotificationService.scheduleAppointmentNotification(
                          appointment);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(widget.appointment == null
                                ? 'تم إضافة الموعد بنجاح'
                                : 'تم تعديل الموعد بنجاح')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('خطأ أثناء الحفظ: $e')),
                      );
                    }
                  }
                },
                child: Text(
                    widget.appointment == null ? 'حفظ الموعد' : 'تعديل الموعد'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
