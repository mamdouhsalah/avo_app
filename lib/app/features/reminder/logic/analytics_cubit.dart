import 'dart:developer';
import 'package:avo_app/app/core/services/local/hive_service.dart';
import 'package:avo_app/app/core/utils/day_localizer.dart';
import 'package:avo_app/app/features/reminder/data/medication_log_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AnalyticsState {}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final Map<String, Map<String, int>> weeklyData; // Day Name -> {'taken': x, 'skipped': y, 'total': z}
  final double overallAdherence; // Percentage 0.0 - 100.0

  AnalyticsLoaded({required this.weeklyData, required this.overallAdherence});
}

class AnalyticsError extends AnalyticsState {
  final String message;
  AnalyticsError(this.message);
}

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final LogRepository logRepository;

  AnalyticsCubit({required this.logRepository}) : super(AnalyticsInitial());

  void loadWeeklyAdherence() {
    emit(AnalyticsLoading());
    try {
      final now = DateTime.now();
      final last7Days =
          List.generate(7, (index) => now.subtract(Duration(days: 6 - index)));

      final Map<String, Map<String, int>> weeklyData = {};
      final logBox = HiveService.getMedicationLogBox();
      // ✅ Issue 13 fix: Hoist medBox reference outside the loop
      final medBox = HiveService.getMedicationBox();
      final logs = logBox.values.toList();

      int totalTakenWeekly = 0;
      int totalScheduledWeekly = 0;

      for (final date in last7Days) {
        final dayStart = DateTime(date.year, date.month, date.day);
        final dayEnd = dayStart.add(const Duration(days: 1));

        final dayLogs = logs
            .where((log) =>
                log.actionDate.isAfter(dayStart) &&
                log.actionDate.isBefore(dayEnd))
            .toList();

        int taken =
            dayLogs.where((l) => l.status == 'taken' || l.action == 'took').length;
        int skipped = dayLogs
            .where((l) => l.status == 'skipped' || l.action == 'skipped')
            .length;
        int overdue = dayLogs.where((l) => l.status == 'overdue').length;

        int totalForDay = taken + skipped + overdue;

        // If no logs, approximate from currently active meds for that day
        if (totalForDay == 0) {
          // ✅ English day name for DB lookup
          final englishDayName = weekdayToEnglish(date.weekday);
          for (final med in medBox.values) {
            if (med.days.contains(englishDayName)) {
              totalForDay += med.times.length;
            }
          }
        }

        if (taken > totalForDay) totalForDay = taken; // Safeguard

        // ✅ Localized short label for chart x-axis
        final dayLabel = translateDayShort(weekdayToEnglish(date.weekday));

        weeklyData[dayLabel] = {
          'taken': taken,
          'skipped': skipped,
          'total': totalForDay,
        };

        totalTakenWeekly += taken;
        totalScheduledWeekly += totalForDay;
      }

      final adherence = totalScheduledWeekly > 0
          ? (totalTakenWeekly / totalScheduledWeekly) * 100
          : 0.0;

      emit(AnalyticsLoaded(
          weeklyData: weeklyData, overallAdherence: adherence));
    } catch (e) {
      log('AnalyticsCubit Error: $e');
      // Pass locale key string; screen calls .tr() on it
      emit(AnalyticsError('reminder.error_loading_reports'));
    }
  }
}
