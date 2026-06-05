import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:avo_app/app/core/models/doctor_model.dart';

class ChatModel {
  final String id;
  final PatientModel patient;
  final DoctorModel? doctor;           // قد يكون الدكتور هو اللي بيتكلم أو المريض
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final String? lastMessageSender;     // "patient" or "doctor"

  ChatModel({
    required this.id,
    required this.patient,
    this.doctor,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.lastMessageSender,
  });

  String get patientName => patient.name;

  String? get patientImage => patient.image;

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(lastMessageTime);

    if (difference.inDays >= 2) {
      return "${lastMessageTime.day}/${lastMessageTime.month}";
    } else if (difference.inDays >= 1) {
      return "Yesterday";
    } else {
      return "${lastMessageTime.hour.toString().padLeft(2, '0')}:${lastMessageTime.minute.toString().padLeft(2, '0')}";
    }
  }

  bool get isLastMessageFromPatient => lastMessageSender == 'patient';
}