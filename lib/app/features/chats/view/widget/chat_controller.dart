import 'dart:async';
import 'package:avo_app/app/core/services/remote/firestore_chats_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:avo_app/app/core/models/chatmodel.dart';

/// نفس اسم وميثودز الكلاس القديم بالظبط، عشان ChatsScreen
/// و NewChatScreen ما يحتاجوش أي تغيير في الكود بتاعهم.
class ChatController {
  final FirestoreChatService _service = FirestoreChatService();

  StreamController<List<ChatModel>>? _chatsController;
  StreamSubscription? _firestoreSub;
  List<ChatModel> _cachedChats = [];

  /// خليها true لو الشاشة دي بتتفتح من جوه حساب دكتور
  /// و false لو من حساب مريض. (Default: doctor لأن ChatsScreen
  /// اللي بعتها واضح إنها شاشة الدكتور)
  final bool isDoctorContext;

  ChatController({this.isDoctorContext = true});

  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Stream<List<ChatModel>> get chatsStream =>
      _chatsController?.stream ?? const Stream.empty();

  void initialize() {
    _chatsController = StreamController<List<ChatModel>>.broadcast();

    final source = _service.chatsStreamForUser(_currentUid);

    _firestoreSub = source.listen((chats) {
      _cachedChats = chats;
      _chatsController?.add(chats);
    });
  }

  void dispose() {
    _firestoreSub?.cancel();
    _chatsController?.close();
  }

  List<ChatModel> getAllChats() => _cachedChats;

  List<ChatModel> filterChats(List<ChatModel> chats, String query) {
    if (query.isEmpty) return chats;
    final q = query.toLowerCase();
    return chats.where((c) {
      return c.patient.fullName.toLowerCase().contains(q) ||
          c.lastMessage.toLowerCase().contains(q);
    }).toList();
  }

  List<ChatModel> sortChatsByTime(List<ChatModel> chats) {
    final sorted = [...chats];
    sorted.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return sorted;
  }

  int getTotalUnreadCount(List<ChatModel> chats) {
    return chats.fold(0, (sum, c) => sum + c.unreadCount);
  }

  Future<void> deleteChat(String chatId, String userId) =>
      _service.deleteChat(chatId, userId);

  /// بنستخدمها بدل إضافة في List محلي — هنا بتعمل/تتأكد إن الشات موجود في Firestore
  Future<void> addNewChat(ChatModel chat) async {
    await _service.getOrCreateChat(
      doctorId: chat.doctor.id,
      patientId: chat.patient.id,
    );
  }
}
