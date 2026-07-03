class LabResultModel {
  final String id;
  final String title;
  final String patientId;
  final String doctorId;
  final String description;
  final DateTime dateTime;
  final String fileType;
  final String typeAdd;
  final String? resultSummary;
  final String? notes;
  final String? fileUrl;
  final String? patientName; // For display
  final String? doctorName; // For display

  LabResultModel({
    required this.id,
    required this.title,
    required this.patientId,
    required this.doctorId,
    required this.description,
    required this.dateTime,
    required this.fileType,
    required this.typeAdd,
    this.resultSummary,
    this.notes,
    this.fileUrl,
    this.patientName,
    this.doctorName,
  });

  factory LabResultModel.fromJson(Map<String, dynamic> json) {
    return LabResultModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      doctorId: json['doctorId']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      dateTime: json['date_time'] != null ? DateTime.parse(json['date_time']) : DateTime.now(),
      fileType: json['file_type']?.toString() ?? '',
      typeAdd: json['type_add']?.toString() ?? '',
      resultSummary: json['result_summary']?.toString(),
      notes: json['notes']?.toString(),
      fileUrl: json['file_url']?.toString(),
      patientName: json['patientName']?.toString(),
      doctorName: json['doctorName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'patientId': patientId,
      'doctorId': doctorId,
      'description': description,
      'date_time': dateTime.toIso8601String(),
      'file_type': fileType,
      'type_add': typeAdd,
      if (resultSummary != null) 'result_summary': resultSummary,
      if (notes != null) 'notes': notes,
      if (fileUrl != null) 'file_url': fileUrl,
      if (patientName != null) 'patientName': patientName,
      if (doctorName != null) 'doctorName': doctorName,
    };
  }

  String get formattedDate =>
      "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";

  String get formattedTime =>
      "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
}
