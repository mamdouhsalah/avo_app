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

  const AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    this.status = 'pending',
    required this.date,
    required this.day,
    this.startTime = '09:00',
    this.endTime = '10:00',
    this.patientName,
    this.doctorName,
    this.notes,
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
      parsedDate = DateTime.tryParse(json['date'].toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return AppointmentModel(
      id: json['id']?.toString() ?? '',
      doctorId: json['doctorId']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      date: parsedDate,
      day: json['day']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '09:00',
      endTime: json['endTime']?.toString() ?? '10:00',
      patientName: json['patientName']?.toString(),
      doctorName: json['doctorName']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'status': status,
      'date': date.toIso8601String(),
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      if (patientName != null) 'patientName': patientName,
      if (doctorName != null) 'doctorName': doctorName,
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
}
