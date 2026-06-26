import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:avo_app/app/core/services/local/crypto_services.dart'; // عدّل الاسم/المسار لو مختلف عندك
import 'package:cloud_firestore/cloud_firestore.dart';

/// نفس شكل الموديل القديم تماماً (نفس الحقول اللي الـ UI شايفها)
/// لكن دلوقتي جايين من Firestore بدل الداتا الوهمية.
class ChatModel {
  final String id;
  final PatientModel patient;
  final DoctorModel doctor;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount; // عدد الرسايل غير المقروءة لليوزر الحالي بس
  final bool isOnline; // أونلاين status بتاع الطرف التاني (حسب الدور)
  final String lastMessageSender; // 'doctor' أو 'patient'

  ChatModel({
    required this.id,
    required this.patient,
    required this.doctor,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
    required this.lastMessageSender,
  });

  /// بيتبني من مستند chats/{chatId} + بيانات الـ patient و doctor اللي هنجيبها مع بعض
  factory ChatModel.fromFirestore({
    required String chatId,
    required Map<String, dynamic> chatData,
    required PatientModel patient,
    required DoctorModel doctor,
    required String currentUid,
    required bool otherUserOnline,
  }) {
    final rawLastMessage = chatData['lastMessage'] ?? '';
    final decrypted =
        rawLastMessage.isNotEmpty ? CryptoService.decryptAES(rawLastMessage) : '';

    final unreadMap = Map<String, dynamic>.from(chatData['unreadCount'] ?? {});
    final myUnread = (unreadMap[currentUid] ?? 0) as int;

    final lastSenderId = chatData['lastMessageSenderId'] ?? '';
    final senderRole = lastSenderId == doctor.id ? 'doctor' : 'patient';

    return ChatModel(
      id: chatId,
      patient: patient,
      doctor: doctor,
      lastMessage: decrypted,
      lastMessageTime: _parseTime(chatData['lastMessageTime']),
      unreadCount: myUnread,
      isOnline: otherUserOnline,
      lastMessageSender: senderRole,
    );
  }

  // Getters للتوافق مع الكود القديم اللي شايف chat.patientName / chat.patientImage
  String get patientName => patient.fullName;
  String? get patientImage => patient.image;

  // ============ Helper methods لتحديد الطرف التاني ============
  /// هل اليوزر الحالي هو الدكتور؟
  bool iAmDoctor(String currentUid) => currentUid == doctor.id;

  /// اسم الطرف التاني (لو أنا دكتور يبقى اسم المريض، والعكس)
  String otherUserName(String currentUid) =>
      iAmDoctor(currentUid) ? patient.fullName : doctor.name;

  /// صورة الطرف التاني
  String? otherUserImage(String currentUid) =>
      iAmDoctor(currentUid) ? patient.image : doctor.imageUrl;

  static DateTime _parseTime(dynamic timeData) {
    if (timeData == null) return DateTime.now();
    if (timeData is Timestamp) return timeData.toDate();
    if (timeData is int) return DateTime.fromMillisecondsSinceEpoch(timeData);
    return DateTime.now();
  }

  /// يولّد chatId ثابت من الـ doctorId و patientId (نفس الفكرة بتاعة getChatId)
  static String buildChatId(String doctorId, String patientId) {
    final ids = [doctorId, patientId]..sort();
    return ids.join('_');
  }
}