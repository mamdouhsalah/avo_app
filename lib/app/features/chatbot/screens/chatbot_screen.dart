import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/features/chatbot/screens/widgets/chat_bubble_widget.dart';
import 'package:avo_app/app/features/chatbot/screens/widgets/chat_input_widget.dart';
import 'package:go_router/go_router.dart';

import 'package:easy_localization/easy_localization.dart';
import '../../../core/Language/locale_keys.g.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avo_app/app/features/chatbot/logic/chatbot_cubit.dart';
import 'package:avo_app/app/features/chatbot/logic/chatbot_state.dart';

class ChatBotScreen extends StatelessWidget {
  const ChatBotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => ChatbotCubit(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _buildAppBar(context, theme),
        body: Column(
          children: [
            // قائمة الرسائل
            Expanded(
              child: BlocBuilder<ChatbotCubit, ChatbotState>(
                builder: (context, state) {
                  return ListView.builder(
                    reverse: true, // Show newest messages at bottom
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.h20, vertical: AppSpacing.v20),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      // Reverse index because of reverse: true
                      return ChatBubbleWidget(message: msg);
                    },
                  );
                },
              ),
            ),
            // حقل الإدخال
            const ChatInputWidget(),
          ],
        ),
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
        icon: Transform.flip(
          flipX: context.locale.languageCode == 'ar',
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20.sp,
            color: theme.colorScheme.onSurface,
          ),
        ),
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
                LocaleKeys.chatbot_chatbot_title.tr(),
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
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
