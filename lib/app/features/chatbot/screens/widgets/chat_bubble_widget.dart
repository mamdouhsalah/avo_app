import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/features/chatbot/data/chatbot_message_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avo_app/app/features/chatbot/logic/chatbot_cubit.dart';
import 'package:avo_app/app/features/chatbot/logic/chatbot_state.dart';
import 'package:avo_app/app/core/services/local/gemini_service.dart';

/// Returns the dominant text direction based on Arabic character ratio.
TextDirection _resolveDirection(String text) {
  if (text.isEmpty) return TextDirection.rtl;
  final arabic = RegExp(r'[\u0600-\u06FF]').allMatches(text).length;
  return arabic / text.length > 0.2 ? TextDirection.rtl : TextDirection.ltr;
}

class ChatBubbleWidget extends StatelessWidget {
  final ChatbotMessageModel message;

  const ChatBubbleWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.v16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Bot avatar
          if (!isUser) ...[
            CircleAvatar(
              radius: 16.r,
              backgroundColor:
                  theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(Icons.smart_toy_rounded,
                  size: 18.sp, color: theme.colorScheme.primary),
            ),
            SizedBox(width: AppSpacing.h8),
          ],

          // Bubble
          Flexible(
            child: message.isLoading
                ? _LoadingBubble(theme: theme)
                : _TextBubble(message: message, theme: theme, isUser: isUser),
          ),

          // User avatar
          if (isUser) ...[
            SizedBox(width: AppSpacing.h8),
            CircleAvatar(
              radius: 16.r,
              backgroundColor:
                  theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(Icons.person,
                  size: 18.sp, color: theme.colorScheme.primary),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Loading Bubble (three animated dots) ────────────────────────────────────
class _LoadingBubble extends StatefulWidget {
  final ThemeData theme;
  const _LoadingBubble({required this.theme});

  @override
  State<_LoadingBubble> createState() => _LoadingBubbleState();
}

class _LoadingBubbleState extends State<_LoadingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.theme.colorScheme.primary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface,
        border: Border.all(
            color: widget.theme.colorScheme.primary.withValues(alpha: 0.35),
            width: 1.w),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              // Each dot offset by 0.33
              final offset = ((_controller.value * 3 - i) % 3) / 3;
              final bounce = sin(offset * pi).clamp(0.0, 1.0);
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: 8.w,
                height: 8.w,
                transform: Matrix4.translationValues(0, -6 * bounce, 0),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.4 + 0.6 * bounce),
                  shape: BoxShape.circle,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// ─── Text Bubble ─────────────────────────────────────────────────────────────
class _TextBubble extends StatelessWidget {
  final ChatbotMessageModel message;
  final ThemeData theme;
  final bool isUser;

  const _TextBubble({
    required this.message,
    required this.theme,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatbotCubit, ChatbotState>(
      builder: (context, state) {
        final isTypingThis =
            state.isTyping && state.typingMessageId == message.id;
        final displayText =
            isTypingThis ? state.displayedText : message.text;

        final textColor = isUser
            ? theme.colorScheme.onPrimary
            : message.isError
                ? theme.colorScheme.error
                : theme.colorScheme.onSurface;

        return Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.h16, vertical: AppSpacing.v12),
          decoration: BoxDecoration(
            color: isUser
                ? theme.colorScheme.primary
                : message.isError
                    ? theme.colorScheme.error.withValues(alpha: 0.1) // Light red background
                    : theme.colorScheme.surface,
            border: !isUser
                ? Border.all(
                    color: message.isError
                        ? theme.colorScheme.error.withValues(alpha: 0.5)
                        : theme.colorScheme.primary.withValues(alpha: 0.35),
                    width: 1.w)
                : null,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
              bottomLeft: Radius.circular(isUser ? 16.r : 0),
              bottomRight: Radius.circular(isUser ? 0 : 16.r),
            ),
          ),
          child: Directionality(
            textDirection: _resolveDirection(displayText),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // If there's an image attached, show it
                if (message.imageBytes != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.memory(
                      message.imageBytes!,
                      width: 200.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (displayText.isNotEmpty) SizedBox(height: AppSpacing.v8),
                ],

                // Message text
                if (displayText.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.isError) ...[
                        Icon(Icons.error_outline_rounded, color: theme.colorScheme.error, size: 20.sp),
                        SizedBox(width: 8.w),
                      ],
                      Expanded(
                        child: Text(
                          displayText,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14.sp,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                // Cursor blink while typing
                if (isTypingThis)
                  _BlinkingCursor(color: theme.colorScheme.primary),

                SizedBox(height: 4.h),

                // Footer: time + speak button
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.time,
                      style: TextStyle(
                        color: isUser
                            ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 10.sp,
                      ),
                    ),
                    if (!isUser && !message.isError) ...[
                      SizedBox(width: 8.w),
                      _SpeakButton(message: message),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


// ─── Blinking cursor ─────────────────────────────────────────────────────────
class _BlinkingCursor extends StatefulWidget {
  final Color color;
  const _BlinkingCursor({required this.color});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 2.w,
        height: 16.h,
        margin: EdgeInsets.only(top: 2.h),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

// ─── Speak Button ─────────────────────────────────────────────────────────────
class _SpeakButton extends StatelessWidget {
  final ChatbotMessageModel message;
  const _SpeakButton({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ChatbotCubit, ChatbotState>(
      buildWhen: (prev, cur) =>
          prev.isSpeaking != cur.isSpeaking ||
          prev.currentlySpeakingMessageId != cur.currentlySpeakingMessageId,
      builder: (context, state) {
        final isPlaying = state.isSpeaking &&
            state.currentlySpeakingMessageId == message.id;
        return GestureDetector(
          onTap: () => context
              .read<ChatbotCubit>()
              .toggleSpeak(
                GeminiService.cleanResponse(message.text),
                message.id,
              ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Icon(
              isPlaying
                  ? Icons.stop_circle_rounded
                  : Icons.volume_up_rounded,
              key: ValueKey(isPlaying),
              size: 16.sp,
              color: isPlaying
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
        );
      },
    );
  }
}