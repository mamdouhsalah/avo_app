import 'dart:developer';
import 'package:avo_app/app/core/services/local/hive_service.dart';
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
      final last7Days = List.generate(7, (index) => now.subtract(Duration(days: 6 - index)));
      
      final Map<String, Map<String, int>> weeklyData = {};
      final logBox = HiveService.getMedicationLogBox();
      final logs = logBox.values.toList();
      
      int totalTakenWeekly = 0;
      int totalScheduledWeekly = 0;

      final fullArabicDays = {
        1: 'الإثنين',
        2: 'الثلاثاء',
        3: 'الأربعاء',
        4: 'الخميس',
        5: 'الجمعة',
        6: 'السبت',
        7: 'الأحد',
      };

      final shortArabicDays = {
        1: 'إثن',
        2: 'ثلا',
        3: 'أرب',
        4: 'خمي',
        5: 'جمع',
        6: 'سبت',
        7: 'أحد',
      };

      for (final date in last7Days) {
        final dayStart = DateTime(date.year, date.month, date.day);
        final dayEnd = dayStart.add(const Duration(days: 1));
        
        final dayLogs = logs.where((log) => log.actionDate.isAfter(dayStart) && log.actionDate.isBefore(dayEnd)).toList();
        
        int taken = dayLogs.where((l) => l.status == 'taken' || l.action == 'took').length;
        int skipped = dayLogs.where((l) => l.status == 'skipped' || l.action == 'skipped').length;
        int overdue = dayLogs.where((l) => l.status == 'overdue').length; 
        
        int totalForDay = taken + skipped + overdue;

        // If no logs, approximate total based on current active meds for that day
        if (totalForDay == 0) {
            final medBox = HiveService.getMedicationBox();
            final dayName = fullArabicDays[date.weekday];
            
            for (final med in medBox.values) {
              if (med.days.contains(dayName)) {
                totalForDay += med.times.length;
              }
            }
        }
        
        if (taken > totalForDay) totalForDay = taken; // Safeguard

        String dayLabel = shortArabicDays[date.weekday] ?? '';
        
        weeklyData[dayLabel] = {
          'taken': taken,
          'skipped': skipped,
          'total': totalForDay,
        };
        
        totalTakenWeekly += taken;
        totalScheduledWeekly += totalForDay;
      }
      
      double adherence = totalScheduledWeekly > 0 ? (totalTakenWeekly / totalScheduledWeekly) * 100 : 0.0;
      
      emit(AnalyticsLoaded(weeklyData: weeklyData, overallAdherence: adherence));
      
    } catch (e) {
      log('AnalyticsCubit Error: $e');
      emit(AnalyticsError('حدث خطأ أثناء تحميل التقارير'));
    }
  }
}
