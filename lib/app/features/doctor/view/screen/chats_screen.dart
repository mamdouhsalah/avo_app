import 'package:avo_app/app/core/models/chatmodel.dart';
import 'package:avo_app/app/core/shared/custom_avatar.dart';
import 'package:avo_app/app/features/doctor/services/chatcontroller.dart';
import 'package:avo_app/app/features/doctor/view/widget/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:avo_app/app/features/doctor/view/widget/chat_widget.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final ChatController _controller = ChatController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
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
                  imageUrl: chat.patient.image,
                  size: 50.sp,
                  radius: 48.r,
                  borderColor: theme.colorScheme.primary,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(chat.patient.fullName,
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
            context.push('/patient-details', extra: chat.patient);
          }),
          _buildOptionTile(Icons.notifications_off, 'Mute Notifications', () {
            Navigator.pop(context);
            _showSnackBar('Notifications muted for this chat');
          }),
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
        content: Text('Delete chat with ${chat.patient.fullName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.deleteChat(chat.id);
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
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: theme.textTheme.titleLarge?.color,
              size: 24.sp,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const CustomDrawer(),
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
              stream: _controller.chatsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const _EmptyChatState(
                    message: 'Something went wrong',
                    icon: Icons.error_outline,
                  );
                }

                if (!snapshot.hasData) {
                  return const _ChatLoadingState();
                }

                final allChats = snapshot.data!;

                // Fixed: Using instance methods correctly
                var filteredChats =
                    _controller.filterChats(allChats, _searchQuery);
                filteredChats = _controller.sortChatsByTime(filteredChats);

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

                final totalUnread = _controller.getTotalUnreadCount(allChats);

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
