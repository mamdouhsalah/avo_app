class ScheduleModel {
  final String id;
  final String day;
  final String date;
  final String startTime;
  final String endTime;
  final int maxVisits;
  final int currentVisits;

  ScheduleModel({
    required this.id,
    required this.day,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.maxVisits,
    required this.currentVisits,
  });

  bool get isFull => currentVisits >= maxVisits;

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] ?? '',
      day: json['day'] ?? '',
      date: json['date'] ??'',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      maxVisits: json['maxVisits'] ?? 0,
      currentVisits: json['currentVisits'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'maxVisits': maxVisits,
      'currentVisits': currentVisits,
    };
  }
}