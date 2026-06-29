import 'package:avo_app/app/core/services/local/crypto_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum MessageType { text, image, audio }

enum MessageStatus { sent, delivered, read }

class ChatMessageModel {
  final String id;
  final String text;
  final bool isUser; // true = الرسالة من اليوزر الحالي (نفس الاسم بتاع الـ UI القديم)
  final String time; // نص جاهز للعرض زي "10:01 AM"
  final String senderId;
  final MessageType type;
  final MessageStatus status;
  final bool isDeleted;
  final DateTime timestamp;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.time,
    this.senderId = '',
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.isDeleted = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessageModel.fromFirestore(
    DocumentSnapshot doc,
    String currentUid,
  ) {
    final data = doc.data() as Map<String, dynamic>;

    final rawContent = data['content'] ?? '';
    final isDeleted = data['isDeleted'] ?? false;
    final typeStr = data['type'] as String?;
    
    final msgType = typeStr == 'image'
        ? MessageType.image
        : typeStr == 'audio'
            ? MessageType.audio
            : MessageType.text;

    // We only decrypt if it's text. URLs for image/audio might not be encrypted in this setup, 
    // but if they are, we can decrypt them. Assuming CryptoService handles it.
    final decryptedContent =
        (!isDeleted && rawContent.isNotEmpty) ? CryptoService.decryptAES(rawContent) : rawContent;

    final ts = data['timestamp'] is Timestamp
        ? (data['timestamp'] as Timestamp).toDate()
        : DateTime.fromMillisecondsSinceEpoch(data['timestamp'] ?? 0);

    return ChatMessageModel(
      id: doc.id,
      text: isDeleted ? 'This message was deleted' : decryptedContent,
      isUser: data['senderId'] == currentUid,
      time: DateFormat.jm().format(ts),
      senderId: data['senderId'] ?? '',
      type: msgType,
      status: data['status'] == 'read'
          ? MessageStatus.read
          : data['status'] == 'delivered'
              ? MessageStatus.delivered
              : MessageStatus.sent,
      isDeleted: isDeleted,
      timestamp: ts,
    );
  }

  Map<String, dynamic> toMap({required String senderId, required String content}) {
    return {
      'senderId': senderId,
      'content': CryptoService.encryptAES(content),
      'type': type.name, // 'text', 'image', or 'audio'
      'status': 'sent',
      'isDeleted': false,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
}