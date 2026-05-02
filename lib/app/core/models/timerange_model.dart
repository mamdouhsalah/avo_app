import 'package:flutter/material.dart';

class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  const TimeRange({
    required this.start,
    required this.end,
  });

  factory TimeRange.fromJson(Map<String, dynamic> json) {
    return TimeRange(
      start: TimeOfDay(
        hour: int.tryParse(json['start']?.split(':')[0] ?? '0') ?? 0,
        minute: int.tryParse(json['start']?.split(':')[1] ?? '0') ?? 0,
      ),
      end: TimeOfDay(
        hour: int.tryParse(json['end']?.split(':')[0] ?? '0') ?? 0,
        minute: int.tryParse(json['end']?.split(':')[1] ?? '0') ?? 0,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': '${start.hour}:${start.minute}',
      'end': '${end.hour}:${end.minute}',
    };
  }
}
