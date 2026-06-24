import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/features/chatbot/data/chat_message_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avo_app/app/features/chatbot/logic/chatbot_cubit.dart';
import 'package:avo_app/app/features/chatbot/logic/chatbot_state.dart';

class ChatBubbleWidget extends StatelessWidget {
  final ChatMessageModel message;

  const ChatBubbleWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.v16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // صورة البوت (تظهر فقط لو الرسالة مش من اليوزر)
          if (!isUser) ...[
            CircleAvatar(
              radius: 16.r,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(Icons.smart_toy_rounded, size: 18.sp, color: theme.colorScheme.primary),
            ),
            SizedBox(width: AppSpacing.h8),
          ],

          // فقاعة الدردشة
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.h16, vertical: AppSpacing.v12),
              decoration: BoxDecoration(
                color: isUser ? theme.colorScheme.primary : theme.colorScheme.surface,
                // الإضافة: الـ Perimeter الأخضر لرسالة البوت
                border: !isUser
                    ? Border.all(color: theme.colorScheme.primary, width: 1.w)
                    : null,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(isUser ? 16.r : 0),
                  bottomRight: Radius.circular(isUser ? 0 : 16.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                      fontSize: 14.sp,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.time,
                        style: TextStyle(
                          color: isUser ? theme.colorScheme.onPrimary.withValues(alpha: 0.7) : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 10.sp,
                        ),
                      ),
                      if (!isUser) ...[
                        SizedBox(width: 8.w),
                        BlocBuilder<ChatbotCubit, ChatbotState>(
                          builder: (context, state) {
                            bool isPlaying = state.isSpeaking && state.currentlySpeakingMessageId == message.id;
                            return GestureDetector(
                              onTap: () => context.read<ChatbotCubit>().toggleSpeak(message.text, message.id),
                              child: Icon(
                                isPlaying ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                                size: 14.sp,
                                color: theme.colorScheme.primary,
                              ),
                            );
                          }
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // صورة اليوزر (تظهر فقط لو الرسالة من اليوزر)
          if (isUser) ...[
            SizedBox(width: AppSpacing.h8),
            CircleAvatar(
              radius: 16.r,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              // هنا ممكن تحط صورة اليوزر الحقيقية لو متاحة
              child: Icon(Icons.person, size: 18.sp, color: theme.colorScheme.primary),
            ),
          ],
        ],
      ),
    );
  }
}