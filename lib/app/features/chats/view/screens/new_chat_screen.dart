import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:avo_app/app/core/models/chatmodel.dart';
import 'package:avo_app/app/core/constants/database_paths.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer_impl.dart';
import 'package:avo_app/app/core/services/remote/firestore_chats_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  late final FirestoreChatService _chatService;
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  Future<List<PatientModel>>? _patientsFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _chatService = FirestoreChatService();
    _patientsFuture = _fetchAllUsersForTesting();
  }

  Future<List<PatientModel>> _fetchAllUsersForTesting() async {
    try {
      final allUsers = await FirebaseConsumerImpl().getList(
        'users',
        fromJson: (json) => PatientModel.fromJson(json),
      );
      final list = allUsers.where((user) => user.id != _currentUid).toList();

      if (list.isEmpty) {
        list.add(PatientModel(
          id: 'dummy_id',
          fullName: 'Debugging: Total users fetched = ${allUsers.length}',
          email: 'debug@test.com',
          phoneNumber: '0100000000',
          role: 'patient',
        ));
      }

      return list;
    } catch (e) {
      debugPrint('Error fetching all users: $e');
      throw Exception(e.toString());
    }
  }

  List<PatientModel> _getFilteredPatients(List<PatientModel> allPatients) {
    if (_searchQuery.isEmpty) return allPatients;
    final query = _searchQuery.toLowerCase();
    return allPatients.where((patient) {
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

  Future<void> _startChat(PatientModel patient) async {
    await _chatService.getOrCreateChat(
      doctorId: _currentUid,
      patientId: patient.id,
    );

    if (!mounted) return;

    // جلب بيانات الدكتور (اليوزر الحالي) عشان نبني ChatModel كامل
    DoctorModel? doctorData;
    try {
      doctorData = await FirebaseConsumerImpl().get(
        '${DatabasePaths.users}/$_currentUid',
        fromJson: (json) => DoctorModel.fromJson(json),
      );
    } catch (_) {
      doctorData = DoctorModel(
        id: _currentUid,
        email: '',
        fullName: 'Doctor',
        role: 'doctor',
        gender: '',
        dateOfBirth: '',
        phoneNumber: '',
        image: '',
        isVerified: true,
        specialty: 'Doctor',
        rating: 0.0,
        numberOfReviews: 0,
        price: 0.0,
        bio: '',
      );
    }

    if (!mounted) return;

    final chat = ChatModel(
      id: ChatModel.buildChatId(_currentUid, patient.id),
      patient: patient,
      doctor: doctorData!,
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isOnline: false,
      lastMessageSender: 'doctor',
    );

    context.push('/chat-details', extra: chat);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

          // ========== PATIENTS LIST ==========
          Expanded(
            child: FutureBuilder<List<PatientModel>>(
                future: _patientsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final allPatients = snapshot.data ?? [];
                  final patients = _getFilteredPatients(allPatients);

                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 4.h),
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
                      Expanded(
                        child: patients.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                itemCount: patients.length,
                                itemBuilder: (context, index) {
                                  return _buildPatientTile(
                                      patients[index], theme);
                                },
                              ),
                      ),
                    ],
                  );
                }),
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
                            Icons.info,
                            size: 13.sp,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              patient.role,
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
