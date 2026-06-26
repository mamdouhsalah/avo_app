import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/features/reminder/logic/analytics_cubit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdherenceReportScreen extends StatefulWidget {
  const AdherenceReportScreen({super.key});

  @override
  State<AdherenceReportScreen> createState() => _AdherenceReportScreenState();
}

class _AdherenceReportScreenState extends State<AdherenceReportScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AnalyticsCubit>().loadWeeklyAdherence();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير الالتزام'),
        centerTitle: true,
      ),
      body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading || state is AnalyticsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AnalyticsError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: theme.colorScheme.error, fontSize: 16.sp),
              ),
            );
          }

          if (state is AnalyticsLoaded) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.h20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildOverallAdherenceCard(context, state.overallAdherence),
                  SizedBox(height: AppSpacing.v32),
                  Text(
                    'الالتزام الأسبوعي',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.v16),
                  _buildBarChart(context, state.weeklyData),
                  SizedBox(height: AppSpacing.v32),
                  _buildLegend(context),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOverallAdherenceCard(BuildContext context, double percentage) {
    final theme = Theme.of(context);
    final isGood = percentage >= 80;

    return Container(
      padding: EdgeInsets.all(AppSpacing.h24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            'نسبة الالتزام العامة',
            style: TextStyle(
              fontSize: 16.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.v12),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 48.sp,
              fontWeight: FontWeight.bold,
              color: isGood ? Colors.green : Colors.orange,
            ),
          ),
          SizedBox(height: AppSpacing.v12),
          Text(
            isGood ? 'عمل رائع! استمر على هذا المنوال' : 'حاول الالتزام بأدويتك في الوقت المحدد',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, Map<String, Map<String, int>> weeklyData) {
    final days = weeklyData.keys.toList();

    return SizedBox(
      height: 250.h,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(weeklyData),
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      days[value.toInt()],
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: weeklyData.entries.map((entry) {
            final index = days.indexOf(entry.key);
            final data = entry.value;
            final taken = data['taken']?.toDouble() ?? 0;
            final skipped = data['skipped']?.toDouble() ?? 0;
            final total = data['total']?.toDouble() ?? 1; // prevent 0 height for stacked

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: total,
                  width: 16.w,
                  borderRadius: BorderRadius.circular(4.r),
                  color: Colors.grey.shade200,
                  rodStackItems: [
                    BarChartRodStackItem(0, taken, Colors.green),
                    BarChartRodStackItem(taken, taken + skipped, Colors.orange),
                  ],
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  double _getMaxY(Map<String, Map<String, int>> weeklyData) {
    double max = 0;
    for (var data in weeklyData.values) {
      if ((data['total'] ?? 0) > max) {
        max = data['total']!.toDouble();
      }
    }
    return max == 0 ? 5 : max + 1; // Minimum scale is 5
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.green, 'تم أخذه'),
        SizedBox(width: 16.w),
        _buildLegendItem(Colors.orange, 'تم تخطيه'),
        SizedBox(width: 16.w),
        _buildLegendItem(Colors.grey.shade300, 'غير معروف/متأخر'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Text(text, style: TextStyle(fontSize: 12.sp)),
      ],
    );
  }
}
