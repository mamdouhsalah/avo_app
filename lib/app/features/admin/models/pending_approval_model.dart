// lib/app/features/admin/models/pending_approval_model.dart

enum ApprovalStatus { pending, approved, rejected }

class PendingApprovalModel {
  final String id;
  final String userId;
  final String email;
  final String fullName;
  final String role;
  final String status; // 'pending' | 'approved' | 'rejected'
  final int timestamp;
  final String? profileImage;
  final String? specialization; // للأطباء

  PendingApprovalModel({
    required this.id,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
    required this.status,
    required this.timestamp,
    this.profileImage,
    this.specialization,
  });

  ApprovalStatus get approvalStatus {
    switch (status) {
      case 'approved':
        return ApprovalStatus.approved;
      case 'rejected':
        return ApprovalStatus.rejected;
      default:
        return ApprovalStatus.pending;
    }
  }

  factory PendingApprovalModel.fromJson(Map<String, dynamic> json) {
    return PendingApprovalModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
      profileImage: json['profileImage']?.toString(),
      specialization: json['specialization']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'fullName': fullName,
      'role': role,
      'status': status,
      'timestamp': timestamp,
      if (profileImage != null) 'profileImage': profileImage,
      if (specialization != null) 'specialization': specialization,
    };
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);
}
