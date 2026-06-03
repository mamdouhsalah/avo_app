import 'package:avo_app/app/core/models/chatmodel.dart';
import 'package:avo_app/app/features/doctor/data/data.dart';

class ChatController {
  final ChatRepository _repository = ChatRepository();

  Stream<List<ChatModel>> get chatsStream => _repository.chatsStream;
  Stream<String> get errorStream => _repository.errorStream;

  Future<void> initialize() async {
    _repository.init();
  }

  List<ChatModel> getAllChats() => _repository.getAllChats();

  ChatModel? getChatById(String chatId) =>
      _repository.getChatById(chatId);

  int getTotalChatCount() => _repository.getChatCount();

  // ================= Filtering =================

  List<ChatModel> filterChats(
      List<ChatModel> chats,
      String query,
      ) {
    if (query.isEmpty) return chats;

    final lowerQuery = query.toLowerCase();

    return chats.where((chat) {
      return chat.patient.name
              .toLowerCase()
              .contains(lowerQuery) ||
          chat.lastMessage
              .toLowerCase()
              .contains(lowerQuery) ||
          chat.patient.phone
              .toLowerCase()
              .contains(lowerQuery);
    }).toList();
  }

  List<ChatModel> sortChatsByTime(
      List<ChatModel> chats,
      ) {
    final sorted = List<ChatModel>.from(chats);

    sorted.sort(
      (a, b) =>
          b.lastMessageTime.compareTo(a.lastMessageTime),
    );

    return sorted;
  }

  int getTotalUnreadCount(List<ChatModel> chats) {
    return chats.fold(
      0,
      (total, chat) => total + chat.unreadCount,
    );
  }

  // ================= Actions =================

  Future<void> addNewChat(ChatModel chat) async {
    await _repository.addNewChat(chat);
  }

  Future<void> updateLastMessage({
    required String chatId,
    required String message,
    required String sender,
  }) async {
    await _repository.updateLastMessage(
      chatId: chatId,
      message: message,
      sender: sender,
    );
  }

  Future<void> markChatAsRead(String chatId) async {
    await _repository.markChatAsRead(chatId);
  }

  Future<void> deleteChat(String chatId) async {
    await _repository.deleteChat(chatId);
  }

  Future<void> updateOnlineStatus(
      String chatId,
      bool isOnline,
      ) async {
    await _repository.updateOnlineStatus(
      chatId,
      isOnline,
    );
  }

  void dispose() {
    // Do not dispose the singleton repository
  }
}