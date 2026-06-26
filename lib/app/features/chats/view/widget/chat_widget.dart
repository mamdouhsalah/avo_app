import 'package:avo_app/app/core/constants/database_paths.dart';
import 'package:avo_app/app/core/shared/custom_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:avo_app/app/core/models/chatmodel.dart';
import 'package:firebase_database/firebase_database.dart';

/// Chat Search Bar Widget
class ChatSearchBar extends StatelessWidget {
  final Function(String) onChanged;
  final TextEditingController? controller;

  const ChatSearchBar({
    super.key,
    required this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search patients or messages...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[600],
            size: 20.sp,
          ),
          filled: true,
          fillColor: Colors.grey.withValues(alpha: 0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: BorderSide(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1,
            ),
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        ),
      ),
    );
  }
}

/// Chat Tile Widget
class ChatTile extends StatelessWidget {
  final ChatModel chat;
  final String currentUid;
  final VoidCallback onTap;
  final Function(BuildContext)? onLongPress;

  const ChatTile({
    super.key,
    required this.chat,
    required this.currentUid,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: () => onLongPress?.call(context),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                // ========== AVATAR ==========
                _buildAvatar(theme),
                SizedBox(width: 12.w),

                // ========== CHAT INFO ==========
                Expanded(
                  child: _buildChatInfo(theme),
                ),

                // ========== TIME & BADGE ==========
                // لازم نمرر context هنا عشان .format(context) شغالة جواه
                _buildTimeAndBadge(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========== AVATAR WITH ONLINE STATUS ==========
  Widget _buildAvatar(ThemeData theme) {
    return Stack(
      children: [
        Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: CustomAvatar(
              imageUrl: chat.otherUserImage(currentUid),
              radius: 22.r,
            )),
        // Online indicator
        if (chat.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ========== CHAT INFORMATION ==========
  Widget _buildChatInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Other user's name + Mute Icon
        Row(
          children: [
            Flexible(
              child: Text(
                chat.otherUserName(currentUid),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            StreamBuilder(
              stream: FirebaseDatabase.instance
                  .ref(
                      '${DatabasePaths.users}/$currentUid/mutedChats/${chat.id}')
                  .onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.snapshot.value == true) {
                  return Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child:
                        Icon(Icons.volume_off, size: 14.sp, color: Colors.grey),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        SizedBox(height: 4.h),

        // Last message
        Text(
          chat.lastMessage,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12.sp,
            fontWeight:
                chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ========== TIME & UNREAD BADGE ==========
  // ✅ التصحيح: بقت تستقبل context كباراميتر عشان TimeOfDay.format(context) يشتغل
  Widget _buildTimeAndBadge(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Time
        Text(
          TimeOfDay.fromDateTime(chat.lastMessageTime).format(context),
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 6.h),

        // Unread badge
        if (chat.unreadCount > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              chat.unreadCount > 99 ? '99+' : chat.unreadCount.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

/// Empty Chat State Widget
class EmptyChatState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyChatState({
    super.key,
    required this.message,
    this.icon = Icons.chat_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Loading State Widget
class ChatLoadingState extends StatelessWidget {
  const ChatLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading chats...',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chat List Header Widget
class ChatListHeader extends StatelessWidget {
  final int unreadCount;

  const ChatListHeader({
    super.key,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Messages',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '$unreadCount unread',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
