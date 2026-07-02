class AppointmentStatus {
  static const String pending = "pending";
  static const String confirmed = "confirmed";
  static const String completed = "completed";
  static const String canceled = "canceled";
}

class AppointmentModel {
  final String id;
  final String doctorId;
  final String patientId;
  final String status; // confirmed, pending, cancelled, completed
  final DateTime date; // DateTime
  final String day; // "Sunday", "Monday", etc.
  final String startTime; // "09:00"
  final String endTime; // "10:00"
  final String? patientName;
  final String? doctorName;
  final String? notes;
  final bool? isRated;
  final double? patientRating;

  const AppointmentModel(
      {required this.id,
      required this.doctorId,
      required this.patientId,
      this.status = AppointmentStatus.pending,
      required this.date,
      this.startTime = '09:00',
      this.endTime = '10:00',
      this.patientName,
      this.doctorName,
      this.notes,
      this.isRated,
      this.patientRating
      });

  factory AppointmentModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AppointmentModel(
        id: '',
        doctorId: '',
        patientId: '',
        date: DateTime.now(),
        day: '',
      );
    }
    
    DateTime parsedDate;
    if (json['date'] != null) {
      final dateStr = json['date'].toString();
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2]);
        if (d != null && m != null && y != null) {
          parsedDate = DateTime(y, m, d);
        } else {
          parsedDate = DateTime.tryParse(dateStr) ?? DateTime.now();
        }
      } else {
        parsedDate = DateTime.tryParse(dateStr) ?? DateTime.now();
      }
    } else {
      parsedDate = DateTime.now();
    }

    return AppointmentModel(
      id: json['id']?.toString() ?? '',
      doctorId: json['doctorId']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      status: json['status']?.toString() ?? AppointmentStatus.pending,
      date: parsedDate,
      day: json['day']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '09:00',
      endTime: json['endTime']?.toString() ?? '10:00',
      patientName: json['patientName']?.toString(),
      doctorName: json['doctorName']?.toString(),
      notes: json['notes']?.toString(),
      isRated: json['isRated'] as bool? ?? false,
      patientRating: (json['patientRating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final dayStr = date.day.toString().padLeft(2, '0');
    final monthStr = date.month.toString().padLeft(2, '0');
    final yearStr = date.year.toString();
    final formattedDate = '$dayStr/$monthStr/$yearStr';
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'status': status,
      'date': formattedDate,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'isRated': isRated ?? false,
      if (patientRating != null) 'patientRating': patientRating,
      if (notes != null) 'notes': notes,
    };
  }

  /// Parse the date string into DateTime
  DateTime get dateTime => date;

  /// Format date for display
  String get formattedDate {
    final dt = dateTime;
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  }

  /// Format time range for display
  String get timeRangeText => '$startTime - $endTime';

  /// Check if appointment is upcoming
  bool get isUpcoming => dateTime.isAfter(DateTime.now());

  /// Check if appointment is today
  bool get isToday {
    final now = DateTime.now();
    final dt = dateTime;
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  /// Get start hour for scheduling
  int get startHour {
    final parts = startTime.split(':');
    return int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0;
  }

  /// Get start minute
  int get startMinute {
    final parts = startTime.split(':');
    return int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
  }

  AppointmentModel copyWith({
    String? id,
    String? doctorId,
    String? patientId,
    String? status,
    DateTime? date,
    String? day,
    String? startTime,
    String? endTime,
    String? patientName,
    String? doctorName,
    String? notes,
    bool? isRated,
    double? patientRating,
  }) {
    return AppointmentModel(
        id: id ?? this.id,
        doctorId: doctorId ?? this.doctorId,
        patientId: patientId ?? this.patientId,
        status: status ?? this.status,
        date: date ?? this.date,
        day: day ?? this.day,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        patientName: patientName ?? this.patientName,
        doctorName: doctorName ?? this.doctorName,
        notes: notes ?? this.notes,
        isRated: isRated ?? this.isRated,
        patientRating: patientRating ?? this.patientRating);
  }
}