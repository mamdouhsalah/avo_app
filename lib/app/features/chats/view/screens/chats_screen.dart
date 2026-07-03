import 'package:avo_app/app/core/constants/database_paths.dart';
import 'package:avo_app/app/core/models/chatmodel.dart';
import 'package:avo_app/app/core/shared/custom_avatar.dart';
import 'package:avo_app/app/features/chats/view/widget/chat_widget.dart';
import 'package:avo_app/app/core/services/remote/firestore_chats_services.dart';
import 'package:avo_app/app/features/admin/views/widgets/admin_custom_drawer.dart';
import 'package:avo_app/app/features/doctor/view/widget/custom_drawer.dart';
import 'package:avo_app/app/features/pharmacy/view/widget/pharmacy_custom_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ChatsScreen extends StatefulWidget {
  final bool isDoctor;
  final bool isAdmin;
  final bool isPharmacy;
  const ChatsScreen({super.key, this.isDoctor = false, this.isAdmin = false, this.isPharmacy = false});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final FirestoreChatService _chatService = FirestoreChatService();
  final TextEditingController _searchController = TextEditingController();
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  String _searchQuery = '';
  late Stream<List<ChatModel>> _chatsStream;

  @override
  void initState() {
    super.initState();
    _chatsStream = _chatService.chatsStreamForUser(_currentUid);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onChatTap(ChatModel chat) {
    context.push('/chat-details', extra: chat);
  }

  void _onChatLongPress(BuildContext context, ChatModel chat) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildChatOptionsSheet(context, chat),
    );
  }

  // ==================== Bottom Sheet ====================
  Widget _buildChatOptionsSheet(BuildContext context, ChatModel chat) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                CustomAvatar(
                  imageUrl: chat.otherUserImage(_currentUid),
                  size: 50.sp,
                  radius: 48.r,
                  borderColor: theme.colorScheme.primary,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(chat.otherUserName(_currentUid),
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      Text(
                        chat.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color:
                              chat.isOnline ? Colors.green : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildOptionTile(Icons.open_in_new, 'Open Chat', () {
            Navigator.pop(context);
            _onChatTap(chat);
          }),
          _buildOptionTile(Icons.person, 'View Profile', () {
            Navigator.pop(context);
            context.push('/user-details', extra: chat.iAmDoctor(_currentUid) ? chat.patient : chat.doctor);
          }),
          StreamBuilder<DatabaseEvent>(
            stream: FirebaseDatabase.instance
                .ref('${DatabasePaths.users}/$_currentUid/mutedChats/${chat.id}')
                .onValue,
            builder: (context, snapshot) {
              bool isMuted = false;
              if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                isMuted = snapshot.data!.snapshot.value == true;
              }
              return _buildOptionTile(
                isMuted ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
                isMuted ? 'Unmute Notifications' : 'Mute Notifications',
                () async {
                  final ref = FirebaseDatabase.instance.ref('${DatabasePaths.users}/$_currentUid/mutedChats/${chat.id}');
                  if (isMuted) {
                    await ref.remove();
                    if (context.mounted) _showSnackBar('Notifications unmuted for this chat');
                  } else {
                    await ref.set(true);
                    if (context.mounted) _showSnackBar('Notifications muted for this chat');
                  }
                  if (context.mounted) Navigator.pop(context);
                },
              );
            },
          ),
          _buildOptionTile(Icons.delete, 'Delete Chat', () {
            Navigator.pop(context);
            _showDeleteConfirmation(context, chat);
          }, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(label, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }

  void _showDeleteConfirmation(BuildContext context, ChatModel chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat?'),
        content: Text('Delete chat with ${chat.otherUserName(_currentUid)}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              _chatService.deleteChat(chat.id, _currentUid);
              Navigator.pop(context);
              _showSnackBar('Chat deleted successfully');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Chats',
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: (widget.isDoctor || widget.isAdmin || widget.isPharmacy)
            ? Builder(
                builder: (context) => IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: theme.textTheme.titleLarge?.color,
                    size: 24.sp,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : null,
      ),
      drawer: widget.isAdmin 
          ? const AdminCustomDrawer() 
          : widget.isPharmacy 
              ? const PharmacyCustomDrawer() 
              : (widget.isDoctor ? const CustomDrawer() : null),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: "Search patients or messages...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ChatModel>>(
              stream: _chatsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const _EmptyChatState(
                    message: 'Something went wrong',
                    icon: Icons.error_outline,
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _ChatLoadingState();
                }

                final allChats = snapshot.data ?? [];

                var filteredChats = allChats;
                if (_searchQuery.isNotEmpty) {
                  final query = _searchQuery.toLowerCase();
                  filteredChats = allChats.where((chat) {
                    return chat
                            .otherUserName(_currentUid)
                            .toLowerCase()
                            .contains(query) ||
                        chat.lastMessage.toLowerCase().contains(query);
                  }).toList();
                }

                filteredChats.sort(
                    (a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

                if (filteredChats.isEmpty) {
                  return _EmptyChatState(
                    message: _searchQuery.isEmpty
                        ? 'No chats yet\nStart a new conversation'
                        : 'No results found for "$_searchQuery"',
                    icon: _searchQuery.isEmpty
                        ? Icons.chat_bubble_outline
                        : Icons.search_off,
                  );
                }

                int totalUnread = 0;
                for (var chat in allChats) {
                  totalUnread += chat.unreadCount;
                }

                return Column(
                  children: [
                    _ChatListHeader(unreadCount: totalUnread),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        itemCount: filteredChats.length,
                        itemBuilder: (context, index) {
                          final chat = filteredChats[index];
                          return ChatTile(
                            chat: chat,
                            currentUid: _currentUid,
                            onTap: () => _onChatTap(chat),
                            onLongPress: (context) =>
                                _onChatLongPress(context, chat),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/new-chat'),
        backgroundColor: theme.colorScheme.surface,
        child: Icon(
          Icons.chat_outlined,
          size: 28,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

// ====================== Helper Widgets ======================

class _ChatListHeader extends StatelessWidget {
  final int unreadCount;
  const _ChatListHeader({required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Recent Chats",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
          if (unreadCount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text("$unreadCount unread",
                  style: TextStyle(color: Colors.red, fontSize: 13.sp)),
            ),
        ],
      ),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  final String message;
  final IconData icon;

  const _EmptyChatState({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _ChatLoadingState extends StatelessWidget {
  const _ChatLoadingState();

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}
