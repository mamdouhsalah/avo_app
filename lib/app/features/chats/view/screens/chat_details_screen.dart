import 'dart:io';
import 'dart:ui';
import 'package:avo_app/app/core/models/chat_message_model.dart';
import 'package:avo_app/app/core/services/remote/cloudinary_service.dart';
import 'package:avo_app/app/core/services/remote/firestore_chats_services.dart';
import 'package:avo_app/app/core/shared/custom_avatar.dart';
import 'package:avo_app/app/features/chats/view/widget/chat_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:avo_app/app/core/constants/database_paths.dart';
import 'package:avo_app/app/core/services/remote/notification_sender_service.dart';
import 'package:avo_app/app/core/models/chatmodel.dart';
import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class ChatDetailsScreen extends StatefulWidget {
  final ChatModel chat;

  const ChatDetailsScreen({super.key, required this.chat});

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirestoreChatService _service = FirestoreChatService();
  final String _currentUid = FirebaseAuth.instance.currentUser!.uid;
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingImage = false;
  bool _isMuted = false;

  late final String _chatId;
  late final String _otherUserId;
  late final bool _iAmDoctor;
  late final String _otherUserName;
  late final String? _otherUserImage;

  Timer? _typingTimer;
  bool _isTyping = false;

  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  String? _recordFilePath;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _chatId = widget.chat.id;
    _iAmDoctor = widget.chat.iAmDoctor(_currentUid);
    _otherUserId = _iAmDoctor ? widget.chat.patient.id : widget.chat.doctor.id;
    _otherUserName = widget.chat.otherUserName(_currentUid);
    _otherUserImage = widget.chat.otherUserImage(_currentUid);

    _service.markMessagesAsRead(_chatId, _currentUid);
    _checkIfMuted();
  }

  Future<void> _checkIfMuted() async {
    final snap = await FirebaseDatabase.instance
        .ref('${DatabasePaths.users}/$_currentUid/mutedChats/$_chatId')
        .get();
    if (mounted) {
      setState(() {
        _isMuted = snap.exists && snap.value == true;
      });
    }
  }

  Future<void> _toggleMute() async {
    final ref = FirebaseDatabase.instance
        .ref('${DatabasePaths.users}/$_currentUid/mutedChats/$_chatId');
    if (_isMuted) {
      await ref.remove();
      setState(() => _isMuted = false);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Notifications unmuted")));
    } else {
      await ref.set(true);
      setState(() => _isMuted = true);
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Notifications muted")));
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    if (_isTyping) {
      _service.setTyping(_chatId, _currentUid, false);
    }
    _messageController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        _recordFilePath =
            '${dir.path}/record_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(
          const RecordConfig(),
          path: _recordFilePath!,
        );
        setState(() => _isRecording = true);
      }
    } catch (e) {
      debugPrint("Error starting record: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      if (path != null) {
        _uploadAudio(File(path));
      }
    } catch (e) {
      debugPrint("Error stopping record: $e");
    }
  }

  Future<void> _uploadAudio(File file) async {
    setState(() => _isUploadingImage = true);
    try {
      final url =
          await CloudinaryService().uploadFile(file, resourceType: 'video');
      if (url.isNotEmpty) {
        await _service.sendMessage(
          chatId: _chatId,
          senderId: _currentUid,
          receiverId: _otherUserId,
          content: url,
          type: MessageType.audio,
          doctorId: widget.chat.doctor.id,
          patientId: widget.chat.patient.id,
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  void _onTextChanged(String value) {
    if (!_isTyping) {
      _isTyping = true;
      _service.setTyping(_chatId, _currentUid, true);
    }
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _isTyping = false;
        _service.setTyping(_chatId, _currentUid, false);
      }
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _onTextChanged(''); // reset typing

    await _service.sendMessage(
      chatId: _chatId,
      senderId: _currentUid,
      receiverId: _otherUserId,
      content: text,
      doctorId: widget.chat.doctor.id,
      patientId: widget.chat.patient.id,
    );

    _sendPushNotification(text);
  }

  Future<void> _sendPushNotification(String content) async {
    try {
      final muteSnap = await FirebaseDatabase.instance
          .ref('${DatabasePaths.users}/$_otherUserId/mutedChats/$_chatId')
          .get();
      if (muteSnap.exists && muteSnap.value == true) {
        return; // The other user has muted this chat
      }

      final snapshot = await FirebaseDatabase.instance
          .ref('${DatabasePaths.users}/$_otherUserId/fcmToken')
          .get();
      if (snapshot.exists && snapshot.value != null) {
        final fcmToken = snapshot.value.toString();
        final iAmDoctor = _iAmDoctor;
        final senderName =
            iAmDoctor ? widget.chat.doctor.name : widget.chat.patientName;

        await NotificationSenderService.sendNotification(
          fcmToken: fcmToken,
          title: senderName,
          body: content.contains('http') ? 'Sent an image' : content,
          chatId: _chatId,
          senderId: _currentUid,
        );
      }
    } catch (e) {
      debugPrint('Error sending push notification: $e');
    }
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final String url =
          await CloudinaryService().uploadImage(File(image.path));
      if (url.isNotEmpty && mounted) {
        await _service.sendMessage(
          chatId: _chatId,
          senderId: _currentUid,
          receiverId: _otherUserId,
          content: url,
          type: MessageType.image,
          doctorId: widget.chat.doctor.id,
          patientId: widget.chat.patient.id,
        );
        _sendPushNotification(url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _buildAppBar(context, theme),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.scaffoldBackgroundColor,
                theme.colorScheme.primary.withValues(alpha: 0.03),
                theme.colorScheme.primary.withValues(alpha: 0.08),
              ],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<ChatMessageModel>>(
                  stream: _service.messagesStream(_chatId, _currentUid),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final messages =
                        snapshot.data!; // جايين descending (الأحدث أول)

                    if (messages.isNotEmpty) {
                      final firstMsg = messages.first;
                      if (!firstMsg.isUser &&
                          firstMsg.status != MessageStatus.read) {
                        _service.markMessagesAsRead(_chatId, _currentUid);
                      }
                    }

                    return ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.h20, vertical: AppSpacing.v20),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == _currentUid;
                        final myImage = _iAmDoctor
                            ? widget.chat.doctor.imageUrl
                            : widget.chat.patientImage;
                        final otherImage = _otherUserImage;

                        final showDate = index == messages.length - 1 ||
                            !_isSameDay(
                                msg.timestamp, messages[index + 1].timestamp);

                        return Column(
                          children: [
                            if (showDate) _buildDateDivider(msg.timestamp),
                            ChatBubble(
                              message: msg,
                              otherUserImage: isMe ? null : otherImage,
                              currentUserImage: isMe ? myImage : null,
                              onCopy: () {
                                Clipboard.setData(
                                    ClipboardData(text: msg.text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Message copied')),
                                );
                              },
                              onDelete: () {
                                _service.deleteMessage(_chatId, msg.id);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              _buildInputWidget(theme),
            ],
          ),
        ));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildDateDivider(DateTime date) {
    final now = DateTime.now();
    final today = _isSameDay(date, now);
    final yesterday = _isSameDay(date, now.subtract(const Duration(days: 1)));

    String label = '';
    if (today) {
      label = 'Today';
    } else if (yesterday) {
      label = 'Yesterday';
    } else {
      label = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.v12),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.h12, vertical: AppSpacing.v4),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme) {
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.85),
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      leadingWidth: 50.w,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            size: 20.sp, color: theme.colorScheme.onSurface),
        onPressed: () => context.pop(),
      ),
      titleSpacing: 0,
      title: GestureDetector(
        onTap: () {
          final otherUser =
              _iAmDoctor ? widget.chat.patient : widget.chat.doctor;
          context.push('/user-details', extra: otherUser);
        },
        child: Row(
          children: [
            CustomAvatar(
              imageUrl: _otherUserImage,
              borderColor: theme.primaryColor,
              radius: 12.r,
            ),
            SizedBox(width: AppSpacing.h12),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                  stream: _service.chatDocumentStream(_chatId),
                  builder: (context, snapshot) {
                    bool isOtherTyping = false;
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final typingMap =
                          data['typing'] as Map<String, dynamic>? ?? {};
                      isOtherTyping = typingMap[_otherUserId] == true;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                _otherUserName,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_isMuted) ...[
                              SizedBox(width: 4.w),
                              Icon(Icons.volume_off,
                                  size: 16.sp, color: Colors.grey),
                            ],
                          ],
                        ),
                        StreamBuilder<DatabaseEvent>(
                            stream: FirebaseDatabase.instance
                                .ref('${DatabasePaths.users}/$_otherUserId')
                                .onValue,
                            builder: (context, userSnap) {
                              bool isOnline = widget.chat.isOnline;
                              String lastSeenText = "Offline";
                              if (userSnap.hasData &&
                                  userSnap.data!.snapshot.value != null) {
                                final map = userSnap.data!.snapshot.value
                                    as Map<dynamic, dynamic>;
                                isOnline = map['isOnline'] == true;
                                if (!isOnline && map['lastSeen'] != null) {
                                  final time =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          map['lastSeen'] as int);
                                  final difference =
                                      DateTime.now().difference(time);
                                  if (difference.inDays > 1) {
                                    lastSeenText =
                                        "Last seen at ${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}";
                                  } else if (difference.inHours > 0) {
                                    lastSeenText =
                                        "Last seen ${difference.inHours}h ago";
                                  } else if (difference.inMinutes > 0) {
                                    lastSeenText =
                                        "Last seen ${difference.inMinutes}m ago";
                                  } else {
                                    lastSeenText = "Last seen just now";
                                  }
                                }
                              }
                              return Text(
                                isOtherTyping
                                    ? "typing..."
                                    : (isOnline ? "Online" : lastSeenText),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: isOtherTyping
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                  color: isOtherTyping
                                      ? theme.colorScheme.primary
                                      : (isOnline ? Colors.green : Colors.grey),
                                ),
                              );
                            }),
                      ],
                    );
                  }),
            ),
          ],
        ),
      ),
      actions: [
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
                  "Call $_otherUserName?",
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
                      Navigator.pop(context); // Pop the dialog first
                      context.push('/audio-call', extra: widget.chat);
                    },
                  ),
                ],
              ),
            );
          },
        ),
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
                          onTap: () async {
                            Navigator.pop(context);
                            await _service.deleteChat(_chatId, _currentUid);
                            if (context.mounted) context.pop();
                          },
                        ),
                        ListTile(
                          leading: Icon(_isMuted
                              ? Icons.notifications_active_outlined
                              : Icons.notifications_off_outlined),
                          title: Text(_isMuted
                              ? "Unmute Notifications"
                              : "Mute Notifications"),
                          onTap: () {
                            Navigator.pop(context);
                            _toggleMute();
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
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.h12, vertical: 2.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color:
                        theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_isUploadingImage)
                      SizedBox(
                        width: 22.sp,
                        height: 22.sp,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton(
                          onPressed: _pickAndUploadImage,
                          icon: Icon(Icons.image_outlined,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                              size: 22.sp)),
                    SizedBox(width: AppSpacing.h8),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        onChanged: _onTextChanged,
                        minLines: 1,
                        maxLines: 5,
                        decoration: InputDecoration(
                          fillColor: Colors.transparent,
                          hintText: "Type a message...",
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: GestureDetector(
                        onLongPressStart: (_) => _startRecording(),
                        onLongPressEnd: (_) => _stopRecording(),
                        child: Icon(
                          _isRecording ? Icons.mic : Icons.mic_none_rounded,
                          color: _isRecording
                              ? Colors.red
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                          size: 22.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: AppSpacing.h12),
            Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: GestureDetector(
                onTap: _isRecording ? null : _sendMessage,
                child: CircleAvatar(
                  radius: 24.r,
                  backgroundColor:
                      _isRecording ? Colors.grey : theme.colorScheme.primary,
                  child: Icon(Icons.send_rounded,
                      color: theme.colorScheme.onPrimary, size: 20.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
