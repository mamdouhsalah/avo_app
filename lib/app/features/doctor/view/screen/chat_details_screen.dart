import 'package:avo_app/app/core/shared/custom_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:avo_app/app/core/models/chatmodel.dart';
import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/features/chatbot/data/chat_message_model.dart';
import 'package:avo_app/app/features/chatbot/screens/widgets/chat_bubble_widget.dart';

class ChatDetailsScreen extends StatefulWidget {
  final ChatModel chat;

  const ChatDetailsScreen({super.key, required this.chat});

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final TextEditingController _messageController = TextEditingController();

  // Dummy messages for UI
  final List<ChatMessageModel> _messages = [
    ChatMessageModel(
      id: "1",
      text: "Hello Doctor, I have a question about my medication.",
      isUser: false, // Patient message
      time: "10:00 AM",
    ),
    ChatMessageModel(
      id: "2",
      text: "Sure, what's your question?",
      isUser: true, // Doctor message
      time: "10:01 AM",
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: _messageController.text,
          isUser: true,
          time: "Now",
        ),
      );
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context, theme),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.h20, vertical: AppSpacing.v20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatBubbleWidget(message: _messages[index]);
              },
            ),
          ),
          _buildInputWidget(theme),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme) {
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      leadingWidth: 50.w,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            size: 20.sp, color: theme.colorScheme.onSurface),
        onPressed: () => context.pop(),
      ),
      titleSpacing: 0,
      title: GestureDetector(
        onTap: () {
          context.go(
            '/patient-details',
            extra: widget.chat.patient,
          );
        },
        child: Row(
          children: [
            CustomAvatar(
              imageUrl: widget.chat.patientImage,
              borderColor: theme.primaryColor,
            ),
            SizedBox(width: AppSpacing.h12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat.patientName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.chat.isOnline ? "Online" : "Offline",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: widget.chat.isOnline ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        // ================= CALL BUTTON =================
        IconButton(
          icon: Icon(
            Icons.call_outlined,
            color: theme.colorScheme.primary,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  "Call ${widget.chat.patient.fullName}?",
                ),
                content: const Text(
                  "Do you want to start an audio call?",
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.call),
                    label: const Text("Call"),
                    onPressed: () {
                      context.go('/audio-call', extra: widget.chat);
                    },
                  ),
                ],
              ),
            );
          },
        ),

        // ================= MORE OPTIONS =================
        IconButton(
          icon: Icon(
            Icons.more_vert_rounded,
            color: theme.colorScheme.primary,
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20.r),
                ),
              ),
              builder: (context) {
                return SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.delete_outline),
                          title: const Text("Delete Chat"),
                          onTap: () {
                            Navigator.pop(context);

                            // delete logic
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.block_outlined),
                          title: const Text("Block Patient"),
                          onTap: () {
                            Navigator.pop(context);

                            // block logic
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.notifications_off_outlined),
                          title: const Text("Mute Notifications"),
                          onTap: () {
                            Navigator.pop(context);

                            // mute logic
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),

        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildInputWidget(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              AppSpacing.h16, AppSpacing.v12, AppSpacing.h16, AppSpacing.v12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.h12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.add_circle_outline,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                              size: 22.sp)),
                      SizedBox(width: AppSpacing.h8),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            fillColor: Colors.transparent,
                            hintText: "Type a message...",
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 12.h),
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.mic_none_rounded,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                              size: 22.sp)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.h12),
              GestureDetector(
                onTap: _sendMessage,
                child: CircleAvatar(
                  radius: 22.r,
                  backgroundColor: theme.colorScheme.primary,
                  child: Icon(Icons.send_rounded,
                      color: theme.colorScheme.onPrimary, size: 20.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
