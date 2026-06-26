import 'package:avo_app/app/core/models/chat_message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/core/shared/custom_avatar.dart';
import 'package:avo_app/app/features/chats/view/widget/audio_bubble.dart';
import 'package:photo_view/photo_view.dart' as photo_view;

/// Bubble مستقل لشات الدكتور/المريض — منفصل تمامًا عن ChatBubbleWidget بتاع الشات بوت.
/// بيستقبل صورة الطرف التاني عشان يعرضها صح (مش أيقونة ثابتة).
class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;

  /// صورة الطرف التاني (اللي ظاهرة جنب رسائله هو)
  final String? otherUserImage;

  /// صورة اليوزر الحالي (اللي ظاهرة جنب رسايلي أنا)
  final String? currentUserImage;

  final VoidCallback? onDelete;
  final VoidCallback? onCopy;

  const ChatBubble({
    super.key,
    required this.message,
    this.otherUserImage,
    this.currentUserImage,
    this.onDelete,
    this.onCopy,
  });

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
          // صورة الطرف التاني (تظهر فقط لو الرسالة مش من اليوزر الحالي)
          if (!isUser) ...[
            CustomAvatar(
              imageUrl: otherUserImage,
              radius: 12.r,
            ),
            SizedBox(width: AppSpacing.h8),
          ],

          // فقاعة الرسالة
          Flexible(
            child: GestureDetector(
              onLongPress: () {
                if (message.isDeleted) return;
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                  ),
                  builder: (_) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10.h),
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            message.type == MessageType.image ? "Image message" : message.text,
                            style: TextStyle(fontSize: 14.sp),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Divider(height: 1),
                        if (message.type == MessageType.text)
                          ListTile(
                            leading: Icon(Icons.copy_outlined, color: theme.colorScheme.primary),
                            title: const Text('Copy'),
                            onTap: () {
                              Navigator.pop(context);
                              if (onCopy != null) onCopy!();
                            },
                          ),
                        if (isUser)
                          ListTile(
                            leading: const Icon(Icons.delete_outline, color: Colors.red),
                            title: const Text(
                              'Delete Message',
                              style: TextStyle(color: Colors.red),
                            ),
                            subtitle: const Text('Deletes for everyone'),
                            onTap: () {
                              Navigator.pop(context);
                              if (onDelete != null) onDelete!();
                            },
                          ),
                        SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: (message.type == MessageType.image || message.type == MessageType.audio)
                      ? AppSpacing.h6
                      : AppSpacing.h16,
                  vertical: (message.type == MessageType.image || message.type == MessageType.audio)
                      ? AppSpacing.h6
                      : AppSpacing.v12,
                ),
                decoration: BoxDecoration(
                  color: message.isDeleted
                      ? theme.colorScheme.surface.withValues(alpha: 0.5)
                      : isUser
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface,
                  border: !isUser && !message.isDeleted
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
                    // محتوى الرسالة: نص أو صورة
                    if (message.type == MessageType.image && !message.isDeleted)
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Scaffold(
                              backgroundColor: Colors.black,
                              appBar: AppBar(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                iconTheme: const IconThemeData(color: Colors.white),
                              ),
                              body: photo_view.PhotoView(
                                imageProvider: NetworkImage(message.text),
                                minScale: photo_view.PhotoViewComputedScale.contained,
                                maxScale: photo_view.PhotoViewComputedScale.covered * 3,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.broken_image, color: Colors.white, size: 50),
                                ),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.network(
                            message.text,
                            width: 140.w,
                            height: 140.w,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return SizedBox(
                                width: 140.w,
                                height: 140.w,
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            },
                            errorBuilder: (context, error, stack) => SizedBox(
                              width: 140.w,
                              height: 140.w,
                              child: const Icon(Icons.broken_image, size: 40),
                            ),
                          ),
                        ),
                      )
                    else if (message.type == MessageType.audio && !message.isDeleted)
                      AudioBubble(audioUrl: message.text, isUser: isUser)
                    else
                      Padding(
                        padding: (message.type == MessageType.image || message.type == MessageType.audio)
                            ? EdgeInsets.symmetric(
                                horizontal: AppSpacing.h8, vertical: AppSpacing.v4)
                            : EdgeInsets.zero,
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: message.isDeleted
                                ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                                : isUser
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                            fontStyle: message.isDeleted
                                ? FontStyle.italic
                                : FontStyle.normal,
                            fontSize: 14.sp,
                            height: 1.4,
                          ),
                        ),
                      ),

                    SizedBox(height: 4.h),

                    // الوقت + علامة القراءة
                    Padding(
                      padding: (message.type == MessageType.image || message.type == MessageType.audio)
                          ? EdgeInsets.symmetric(horizontal: AppSpacing.h8)
                          : EdgeInsets.zero,
                      child: Row(
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
                          if (isUser) ...[
                            SizedBox(width: 4.w),
                            Icon(
                              message.status == MessageStatus.read
                                  ? Icons.done_all_rounded
                                  : Icons.done_rounded,
                              size: 12.sp,
                              color: message.status == MessageStatus.read
                                  ? Colors.blue[200]
                                  : theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // صورة اليوزر الحالي (تظهر فقط لو الرسالة مني)
          if (isUser) ...[
            SizedBox(width: AppSpacing.h8),
            CustomAvatar(
              imageUrl: currentUserImage,
              radius: 12.r,
            ),
          ],
        ],
      ),
    );
  }
}