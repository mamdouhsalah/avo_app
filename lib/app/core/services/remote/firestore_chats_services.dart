import 'package:avo_app/app/core/models/chat_message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avo_app/app/core/models/chatmodel.dart';
import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:flutter/foundation.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer_impl.dart';
import 'package:avo_app/app/core/constants/database_paths.dart';

class FCollections {
  static const patients = 'patients';
  static const doctors = 'doctors';
  static const chats = 'chats';
  static const messages = 'messages';
}

class FirestoreChatService {
  final _db = FirebaseFirestore.instance;
  final _rtdb = FirebaseConsumerImpl();

  String getChatId(String doctorId, String patientId) =>
      ChatModel.buildChatId(doctorId, patientId);

  Future<void> getOrCreateChat({
    required String doctorId,
    required String patientId,
  }) async {
    final chatId = getChatId(doctorId, patientId);
    final ref = _db.collection(FCollections.chats).doc(chatId);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'doctorId': doctorId,
        'patientId': patientId,
        'participants': [doctorId, patientId],
        'lastMessage': '',
        'lastMessageSenderId': '',
        'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
        'unreadCount': {doctorId: 0, patientId: 0},
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Stream<DocumentSnapshot> chatDocumentStream(String chatId) {
    return _db.collection(FCollections.chats).doc(chatId).snapshots();
  }

  // ============ Unified Chats Stream ============
  Stream<List<ChatModel>> chatsStreamForUser(String uid) {
    return _db
        .collection(FCollections.chats)
        .where(Filter.or(
          Filter('doctorId', isEqualTo: uid),
          Filter('patientId', isEqualTo: uid),
        ))
        .snapshots()
        .asyncMap((snap) async {
      final List<ChatModel> result = [];
      for (final doc in snap.docs) {
        final data = doc.data();
        final doctorId = data['doctorId'];
        final patientId = data['patientId'];

        PatientModel? patient;
        DoctorModel? doctor;

        try {
          doctor = await _rtdb.get(
            '${DatabasePaths.users}/$doctorId',
            fromJson: (json) => DoctorModel.fromJson(json),
          );
        } catch (e) {
          doctor = DoctorModel(id: doctorId, name: 'Unknown Doctor', specialty: '', rating: 0, reviews: 0, openTime: '', closeTime: '');
        }

        try {
          patient = await _rtdb.get(
            '${DatabasePaths.users}/$patientId',
            fromJson: (json) => PatientModel.fromJson(json),
          );
        } catch (e) {
          patient = PatientModel(id: patientId, fullName: 'Unknown Patient', email: '', phoneNumber: '', role: 'patient');
        }

        if (doctor == null || patient == null) continue;

        final lastMessage = data['lastMessage'] as String?;
        if (lastMessage == null || lastMessage.trim().isEmpty) continue;

        final deletedBy = List<String>.from(data['deletedBy'] ?? []);
        if (deletedBy.contains(uid)) continue;

        result.add(ChatModel.fromFirestore(
          chatId: doc.id,
          chatData: data,
          patient: patient,
          doctor: doctor,
          currentUid: uid,
          otherUserOnline: false,
        ));
      }
      return result;
    });
  }

  // ============ Messages stream ============
  Stream<List<ChatMessageModel>> messagesStream(String chatId, String currentUid) {
    return _db
        .collection(FCollections.chats)
        .doc(chatId)
        .collection(FCollections.messages)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ChatMessageModel.fromFirestore(d, currentUid)).toList());
  }

  // ============ Send Message ============
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
    String? doctorId,
    String? patientId,
  }) async {
    final chatRef = _db.collection(FCollections.chats).doc(chatId);
    final msgRef = chatRef.collection(FCollections.messages).doc();

    final model = ChatMessageModel(id: msgRef.id, text: content, isUser: true, time: '', type: type);

    final batch = _db.batch();
    batch.set(msgRef, model.toMap(senderId: senderId, content: content));
    
    final Map<String, dynamic> chatData = {
      'lastMessage': model.toMap(senderId: senderId, content: content)['content'],
      'lastMessageSenderId': senderId,
      'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
      'unreadCount': {
        receiverId: FieldValue.increment(1),
      },
      'deletedBy': [], // Clear deletedBy when new message is sent
    };
    
    if (doctorId != null) chatData['doctorId'] = doctorId;
    if (patientId != null) chatData['patientId'] = patientId;

    batch.set(chatRef, chatData, SetOptions(merge: true));

    await batch.commit();
  }

  // ============ Mark as read ============
  Future<void> markMessagesAsRead(String chatId, String currentUid) async {
    await _db.collection(FCollections.chats).doc(chatId).update({
      'unreadCount.$currentUid': 0,
    }).catchError((e) {
      // If document doesn't exist yet, we can set it
      _db.collection(FCollections.chats).doc(chatId).set({
        'unreadCount': {currentUid: 0},
      }, SetOptions(merge: true));
    });

    try {
      final unread = await _db
          .collection(FCollections.chats)
          .doc(chatId)
          .collection(FCollections.messages)
          .where('status', isNotEqualTo: 'read')
          .get();

      final batch = _db.batch();
      for (final doc in unread.docs) {
        if (doc.data()['senderId'] != currentUid) {
          batch.update(doc.reference, {'status': 'read'});
        }
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error in markMessagesAsRead: $e');
    }
  }

  // ============ Delete Chat ============
  Future<void> deleteChat(String chatId, String userId) async {
    await _db.collection(FCollections.chats).doc(chatId).update({
      'deletedBy': FieldValue.arrayUnion([userId]),
    });
  }

  // ============ Delete single message (soft delete) ============
  Future<void> deleteMessage(String chatId, String messageId) async {
    await _db
        .collection(FCollections.chats)
        .doc(chatId)
        .collection(FCollections.messages)
        .doc(messageId)
        .update({'isDeleted': true, 'content': ''});
  }

  // ============ Typing ============
  Future<void> setTyping(String chatId, String uid, bool isTyping) async {
    await _db.collection(FCollections.chats).doc(chatId).update({
      'typing.$uid': isTyping,
    });
  }
}