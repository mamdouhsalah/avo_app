import 'package:flutter/material.dart';

class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  const TimeRange({
    required this.start,
    required this.end,
  });

  factory TimeRange.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TimeRange(
        start: TimeOfDay(hour: 0, minute: 0),
        end: TimeOfDay(hour: 0, minute: 0),
      );
    }
    final startStr = json['start']?.toString() ?? '0:0';
    final endStr = json['end']?.toString() ?? '0:0';
    
    final startParts = startStr.split(':');
    final endParts = endStr.split(':');

    return TimeRange(
      start: TimeOfDay(
        hour: int.tryParse(startParts.isNotEmpty ? startParts[0] : '0') ?? 0,
        minute: int.tryParse(startParts.length > 1 ? startParts[1] : '0') ?? 0,
      ),
      end: TimeOfDay(
        hour: int.tryParse(endParts.isNotEmpty ? endParts[0] : '0') ?? 0,
        minute: int.tryParse(endParts.length > 1 ? endParts[1] : '0') ?? 0,
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
