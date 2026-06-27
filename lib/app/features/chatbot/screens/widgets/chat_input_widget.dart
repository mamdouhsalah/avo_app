import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:avo_app/app/features/chatbot/logic/chatbot_cubit.dart';
import 'package:avo_app/app/features/chatbot/logic/chatbot_state.dart';

class ChatInputWidget extends StatefulWidget {
  const ChatInputWidget({super.key});

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  void _sendMessage([String? text]) {
    final messageText = text ?? _controller.text.trim();
    if (messageText.isNotEmpty) {
      context.read<ChatbotCubit>().sendMessage(messageText);
      _controller.clear();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 80);
      if (image != null) {
        final bytes = await image.readAsBytes();
        if (mounted) {
          context.read<ChatbotCubit>().sendMessage(_controller.text, imageBytes: bytes);
          _controller.clear();
        }
      }
    } catch (e) {
      // Ignore picker errors or handle them gracefully
    }
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt_rounded, color: Theme.of(context).colorScheme.primary),
                title: Text('الكاميرا (Camera)', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_rounded, color: Theme.of(context).colorScheme.primary),
                title: Text('الاستوديو (Gallery)', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Check current locale to provide language-specific suggestions
    final bool isArabic = context.locale.languageCode == 'ar';
    
    final List<String> suggestions = isArabic 
      ? [
          "ما هو تطبيق AVO؟",
          "أحتاج استشارة طبية",
          "كيف أراجع الأعراض؟",
        ]
      : [
          "What is AVO app?",
          "I need medical advice",
          "How to check symptoms?",
        ];

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // شريط الاقتراحات (Suggestions Bar)
            SizedBox(
              height: 50.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.h16, vertical: 8.h),
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _sendMessage(suggestions[index]),
                    child: Container(
                      margin: EdgeInsets.only(right: AppSpacing.h8),
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        suggestions[index],
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // حقل الإدخال الأساسي
            Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.h16, 0, AppSpacing.h16, AppSpacing.v12),
              child: BlocBuilder<ChatbotCubit, ChatbotState>(
                builder: (context, state) {
                  return Row(
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
                              GestureDetector(
                                onTap: () {
                                  _showImagePickerOptions(context);
                                },
                                child: Icon(Icons.add_circle_outline, color: theme.colorScheme.onSurface.withValues(alpha: 0.5), size: 22.sp),
                              ),
                              SizedBox(width: AppSpacing.h8),
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  onSubmitted: (_) => _sendMessage(),
                                  decoration: InputDecoration(
                                    hintText: state.isListening ? "Listening..." : "Ask AI...",
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTapDown: (_) {
                                  context.read<ChatbotCubit>().startListening((words) {
                                    _controller.text = words;
                                  });
                                },
                                onTapUp: (_) async {
                                  await context.read<ChatbotCubit>().stopListening();
                                  // Wait briefly to allow the final recognized words to populate
                                  Future.delayed(const Duration(milliseconds: 500), () {
                                    if (_controller.text.isNotEmpty) {
                                      _sendMessage();
                                    }
                                  });
                                },
                                onTapCancel: () async {
                                  await context.read<ChatbotCubit>().stopListening();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4.sp),
                                  color: Colors.transparent,
                                  child: Icon(
                                    state.isListening ? Icons.mic : Icons.mic_none_rounded, 
                                    color: state.isListening ? theme.colorScheme.error : theme.colorScheme.onSurface.withValues(alpha: 0.5), 
                                    size: 22.sp
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.h12),
                      GestureDetector(
                        onTap: () => _sendMessage(),
                        child: CircleAvatar(
                          radius: 22.r,
                          backgroundColor: theme.colorScheme.primary,
                          child: state.isGenerating 
                              ? SizedBox(width: 20.sp, height: 20.sp, child: CircularProgressIndicator(color: theme.colorScheme.onPrimary, strokeWidth: 2))
                              : Icon(Icons.send_rounded, color: theme.colorScheme.onPrimary, size: 20.sp),
                        ),
                      ),
                    ],
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}