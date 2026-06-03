// ====================== ANALYTICS SCREEN ======================

import 'package:avo_app/app/features/doctor/data/data.dart';
import 'package:avo_app/app/features/doctor/view/widget/custom_drawer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ChartViewType { month, week, day }

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // ===================== TOP CHART =====================

  ChartViewType topChartView = ChartViewType.month;
  bool topShowLineChart = true;

  // ===================== BOTTOM CHART =====================

  ChartViewType bottomChartView = ChartViewType.week;
  bool bottomShowLineChart = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalPatients = DataRepository.patients.length * 200;
    final completedAppointments = DataRepository.appointments.length * 400;
    final avgWaitTime = 18;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: colorScheme.onSurface,
              size: 28.sp,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===================== STATS =====================

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.45,
              children: [
                _buildStatCard(
                  context,
                  "Total Patients",
                  totalPatients.toString(),
                  "+12% from last month",
                  Colors.blue,
                  Icons.people,
                ),
                _buildStatCard(
                  context,
                  "Appointments",
                  completedAppointments.toString(),
                  "+8% from last month",
                  Colors.green,
                  Icons.check_circle,
                ),
                _buildStatCard(
                  context,
                  "Wait Time",
                  "$avgWaitTime min",
                  "-2 min improved",
                  Colors.orange,
                  Icons.timer,
                ),
                _buildStatCard(
                  context,
                  "Satisfaction",
                  "98%",
                  "+0.2% growth",
                  Colors.purple,
                  Icons.star,
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // ===================== TOP CHART =====================

            _buildChartCard(
              context,
              title: "Patient Visits Over Time",
              selectedType: topChartView,
              showLineChart: topShowLineChart,
              onTypeChanged: (value) {
                setState(() {
                  topChartView = value;
                });
              },
              onChartToggle: () {
                setState(() {
                  topShowLineChart = !topShowLineChart;
                });
              },
              child: SizedBox(
                height: 220.h,
                child: topShowLineChart
                    ? LineChart(
                        _buildLineChartData(
                          theme,
                          topChartView,
                        ),
                      )
                    : BarChart(
                        _buildBarChartData(
                          theme,
                          topChartView,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 24.h),

            // ===================== BOTTOM CHART =====================

            _buildChartCard(
              context,
              title: "Patient Statistics",
              selectedType: bottomChartView,
              showLineChart: bottomShowLineChart,
              onTypeChanged: (value) {
                setState(() {
                  bottomChartView = value;
                });
              },
              onChartToggle: () {
                setState(() {
                  bottomShowLineChart = !bottomShowLineChart;
                });
              },
              child: SizedBox(
                height: 220.h,
                child: bottomShowLineChart
                    ? LineChart(
                        _buildLineChartData(
                          theme,
                          bottomChartView,
                        ),
                      )
                    : BarChart(
                        _buildBarChartData(
                          theme,
                          bottomChartView,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== STAT CARD =====================

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    String change,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22.sp,
                ),
              ),
            ],
          ),
          Text(
            change,
            style: TextStyle(
              fontSize: 12.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== CHART CARD =====================

  Widget _buildChartCard(
    BuildContext context, {
    required String title,
    required Widget child,
    required ChartViewType selectedType,
    required ValueChanged<ChartViewType> onTypeChanged,
    required bool showLineChart,
    required VoidCallback onChartToggle,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ================= HEADER =================

          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),

              // ================= FILTERS =================

              _buildFilterButton(
                context,
                "M",
                ChartViewType.month,
                selectedType,
                onTypeChanged,
              ),

              SizedBox(width: 8.w),

              _buildFilterButton(
                context,
                "W",
                ChartViewType.week,
                selectedType,
                onTypeChanged,
              ),

              SizedBox(width: 8.w),

              _buildFilterButton(
                context,
                "D",
                ChartViewType.day,
                selectedType,
                onTypeChanged,
              ),

              SizedBox(width: 14.w),

              // ================= TOGGLE ICON =================

              GestureDetector(
                onTap: onChartToggle,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    showLineChart
                        ? Icons.bar_chart_rounded
                        : Icons.show_chart_rounded,
                    color: primary,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          child,
        ],
      ),
    );
  }

  // ===================== FILTER BUTTON =====================

  Widget _buildFilterButton(
    BuildContext context,
    String text,
    ChartViewType type,
    ChartViewType selectedType,
    ValueChanged<ChartViewType> onChanged,
  ) {
    final isSelected = selectedType == type;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        onChanged(type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 6.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? Colors.white
                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  // ===================== LINE CHART =====================

  LineChartData _buildLineChartData(
    ThemeData theme,
    ChartViewType viewType,
  ) {
    final primary = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return LineChartData(
      minY: 0,
      maxY: 120,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 25,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: theme.dividerColor.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30.w,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: textColor,
                ),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final labels = _getBottomLabels(viewType);

              return Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  labels[value.toInt()],
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: textColor,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: _getLineSpots(viewType),
          isCurved: true,
          color: primary,
          barWidth: 3.w,
          belowBarData: BarAreaData(
            show: true,
            color: primary.withValues(alpha: 0.08),
          ),
          dotData: FlDotData(show: false),
        ),
      ],
    );
  }

  // ===================== BAR CHART =====================

  BarChartData _buildBarChartData(
    ThemeData theme,
    ChartViewType viewType,
  ) {
    final primary = theme.colorScheme.primary;

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 120,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: 20,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: theme.dividerColor.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final labels = _getBottomLabels(viewType);

              return Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  labels[value.toInt()],
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      barGroups: List.generate(
        _getBarValues(viewType).length,
        (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: _getBarValues(viewType)[index],
                width: 16.w,
                borderRadius: BorderRadius.circular(8.r),
                color: primary,
              ),
            ],
          );
        },
      ),
    );
  }

  // ===================== DYNAMIC LABELS =====================

  List<String> _getBottomLabels(ChartViewType viewType) {
    switch (viewType) {
      case ChartViewType.day:
        return ['1', '4', '8', '12', '16', '20', '24'];

      case ChartViewType.week:
        return ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

      case ChartViewType.month:
        return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
    }
  }

  // ===================== LINE SPOTS =====================

  List<FlSpot> _getLineSpots(ChartViewType viewType) {
    switch (viewType) {
      case ChartViewType.day:
        return const [
          FlSpot(0, 15),
          FlSpot(1, 35),
          FlSpot(2, 55),
          FlSpot(3, 45),
          FlSpot(4, 80),
          FlSpot(5, 60),
          FlSpot(6, 95),
        ];

      case ChartViewType.week:
        return const [
          FlSpot(0, 5),
          FlSpot(1, 50),
          FlSpot(2, 15),
          FlSpot(3, 60),
          FlSpot(4, 30),
          FlSpot(5, 105),
          FlSpot(6, 70),
        ];

      case ChartViewType.month:
        return const [
          FlSpot(0, 20),
          FlSpot(1, 40),
          FlSpot(2, 65),
          FlSpot(3, 45),
          FlSpot(4, 85),
          FlSpot(5, 100),
          FlSpot(6, 90),
        ];
    }
  }

  // ===================== BAR VALUES =====================

  List<double> _getBarValues(ChartViewType viewType) {
    switch (viewType) {
      case ChartViewType.day:
        return [20, 40, 60, 50, 90, 70, 100];

      case ChartViewType.week:
        return [30, 50, 45, 70, 90, 80, 110];

      case ChartViewType.month:
        return [40, 70, 55, 85, 100, 95, 120];
    }
  }
}
