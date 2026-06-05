import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/features/chatbot/data/chat_message_model.dart';
import 'package:avo_app/app/features/chatbot/screens/widgets/chat_bubble_widget.dart';
import 'package:avo_app/app/features/chatbot/screens/widgets/chat_input_widget.dart';
import 'package:go_router/go_router.dart';

import 'package:easy_localization/easy_localization.dart';
import '../../../core/Language/locale_keys.g.dart';

class ChatBotScreen extends StatelessWidget {
  const ChatBotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<ChatMessageModel> dummyMessages = [
      ChatMessageModel(
        text: LocaleKeys.chatbot_bot_welcome_msg.tr(),
        isUser: false,
        time: "10:00 AM",
      ),
      ChatMessageModel(
        text: "I need to set a reminder for my Amoxicillin.",
        isUser: true,
        time: "10:01 AM",
      ),
      ChatMessageModel(
        text:
            "Sure! What is the dosage and when would you like to be reminded?",
        isUser: false,
        time: "10:01 AM",
      ),
      ChatMessageModel(
        text: "500mg, every day at 9:00 AM.",
        isUser: true,
        time: "10:02 AM",
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context, theme),
      body: Column(
        children: [
          // قائمة الرسائل
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.h20, vertical: AppSpacing.v20),
              itemCount: dummyMessages.length,
              itemBuilder: (context, index) {
                return ChatBubbleWidget(message: dummyMessages[index]);
              },
            ),
          ),
          // حقل الإدخال
          const ChatInputWidget(),
        ],
      ),
    );
  }

  // فصل الـ AppBar لترتيب الكود
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
      title: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(Icons.smart_toy_rounded,
                color: theme.colorScheme.primary, size: 20.sp),
          ),
          SizedBox(width: AppSpacing.h12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // "AVO Assistant",
                LocaleKeys.chatbot_chatbot_title.tr(), // 👈 ترجمة اسم البوت
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                LocaleKeys.chatbot_chatbot_online.tr(), 
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors
                      .green, 
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
