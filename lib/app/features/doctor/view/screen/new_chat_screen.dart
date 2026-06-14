import 'package:avo_app/app/core/models/chatmodel.dart';
import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:avo_app/app/features/doctor/data/data.dart';
import 'package:avo_app/app/features/doctor/services/chatcontroller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ChatController _chatController = ChatController();
  String _searchQuery = '';

  List<PatientModel> get _allPatients => DataRepository.patients;

  List<PatientModel> get _filteredPatients {
    if (_searchQuery.isEmpty) return _allPatients;
    final query = _searchQuery.toLowerCase();
    return _allPatients.where((patient) {
      return patient.fullName.toLowerCase().contains(query) ||
          patient.email.toLowerCase().contains(query) ||
          patient.phoneNumber.toLowerCase().contains(query) ||
          (patient.diagnosis?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startChat(PatientModel patient) {
    // Check if a chat with this patient already exists
    final existingChats = _chatController.getAllChats();
    final existing = existingChats.where((c) => c.patient.id == patient.id);

    if (existing.isNotEmpty) {
      // Navigate to existing chat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chat with ${patient.fullName} already exists'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
      return;
    }

    // Create new chat
    final newChat = ChatModel(
      id: 'chat_${DateTime.now().millisecondsSinceEpoch}',
      patient: patient,
      doctor: DataRepository.doctors[0],
      lastMessage: 'New conversation started',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isOnline: false,
      lastMessageSender: 'doctor',
    );

    _chatController.addNewChat(newChat);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chat started with ${patient.fullName}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final patients = _filteredPatients;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'New Chat',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20.sp),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // ========== SEARCH BAR ==========
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search patients by name, email, phone...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14.sp,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[600],
                  size: 20.sp,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 18.sp),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surface,
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
          ),

          // ========== PATIENTS COUNT ==========
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Row(
              children: [
                Text(
                  '${patients.length} patients',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          // ========== PATIENTS LIST ==========
          Expanded(
            child: patients.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      return _buildPatientTile(patients[index], theme);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientTile(PatientModel patient, ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _startChat(patient),
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 52.w,
                      height: 52.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 26.r,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: patient.image != null
                            ? NetworkImage(patient.image!)
                            : null,
                        child: patient.image == null
                            ? Text(
                                patient.fullName[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : null,
                      ),
                    ),
                    // Verified badge
                    if (patient.isVerified)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 16.w,
                          height: 16.w,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.check,
                            size: 10.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(width: 12.w),

                // Patient info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.fullName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Icon(
                            Icons.medical_information_outlined,
                            size: 13.sp,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              patient.diagnosis ?? 'No diagnosis',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 13.sp,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            patient.phoneNumber,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chat icon
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chat_outlined,
                    color: theme.colorScheme.primary,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'No patients found for "$_searchQuery"',
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
