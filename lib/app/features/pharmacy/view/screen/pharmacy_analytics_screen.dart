import 'package:avo_app/app/features/pharmacy/view/widget/pharmacy_custom_drawer.dart';
import 'package:avo_app/app/features/pharmacy/data/pharmacy_repository_impl.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer_impl.dart';
import 'package:avo_app/app/core/models/pharmacy_order_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';

enum ChartViewType { month, week, day }

class PharmacyAnalyticsScreen extends StatefulWidget {
  const PharmacyAnalyticsScreen({super.key});

  @override
  State<PharmacyAnalyticsScreen> createState() => _PharmacyAnalyticsScreenState();
}

class _PharmacyAnalyticsScreenState extends State<PharmacyAnalyticsScreen> {
  // ===================== TOP CHART =====================

  ChartViewType topChartView = ChartViewType.month;
  bool topShowLineChart = true;

  // ===================== BOTTOM CHART =====================

  ChartViewType bottomChartView = ChartViewType.week;
  bool bottomShowLineChart = false;

  late final PharmacyRepositoryImpl _pharmacyRepo;
  final String _pharmacyId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _pharmacyRepo = PharmacyRepositoryImpl(consumer: FirebaseConsumerImpl());
  }

  // Helper to calculate statistics
  Map<String, dynamic> _calculateStats(List<PharmacyOrderModel> orders) {
    int totalOrders = orders.length;
    int pendingOrders = orders.where((o) => o.status == 'pending').length;
    int dispensedOrders = orders.where((o) => o.status == 'dispensed').length;
    int cancelledOrders = orders.where((o) => o.status == 'cancelled').length;

    return {
      'total': totalOrders,
      'pending': pendingOrders,
      'dispensed': dispensedOrders,
      'cancelled': cancelledOrders,
    };
  }

  // Real data calculator
  List<double> _getRealChartData(
      ChartViewType type, List<PharmacyOrderModel> orders) {
    final now = DateTime.now();
    List<double> values = List.filled(7, 0.0);

    if (type == ChartViewType.day) {
      // 7 intervals today: 8-10, 10-12, 12-14, 14-16, 16-18, 18-20, 20-22
      for (var order in orders) {
        if (order.date.year == now.year &&
            order.date.month == now.month &&
            order.date.day == now.day) {
          int hour = order.date.hour;
          if (hour >= 8 && hour < 10) values[0]++;
          else if (hour >= 10 && hour < 12) values[1]++;
          else if (hour >= 12 && hour < 14) values[2]++;
          else if (hour >= 14 && hour < 16) values[3]++;
          else if (hour >= 16 && hour < 18) values[4]++;
          else if (hour >= 18 && hour < 20) values[5]++;
          else if (hour >= 20 && hour <= 24) values[6]++;
        }
      }
    } else if (type == ChartViewType.week) {
      // Current week: Sun=0, Mon=1, ..., Sat=6
      final weekStart = now.subtract(Duration(days: now.weekday % 7));
      for (var order in orders) {
        if (order.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            order.date.isBefore(weekStart.add(const Duration(days: 7)))) {
          int idx = order.date.weekday % 7; // Sun=0, Mon=1, ...
          values[idx]++;
        }
      }
    } else if (type == ChartViewType.month) {
      // Last 7 months including this month
      for (int i = 0; i < 7; i++) {
        int targetMonth = now.month - (6 - i);
        int targetYear = now.year;
        while (targetMonth <= 0) {
          targetMonth += 12;
          targetYear--;
        }

        for (var order in orders) {
          if (order.date.year == targetYear && order.date.month == targetMonth) {
            values[i]++;
          }
        }
      }
    }
    return values;
  }

  List<String> _getRealChartLabels(ChartViewType type) {
    final now = DateTime.now();
    if (type == ChartViewType.day) {
      return ['8AM', '10AM', '12PM', '2PM', '4PM', '6PM', '8PM'];
    } else if (type == ChartViewType.week) {
      return ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    } else if (type == ChartViewType.month) {
      List<String> labels = [];
      final monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      for (int i = 0; i < 7; i++) {
        int targetMonth = now.month - (6 - i);
        while (targetMonth <= 0) {
          targetMonth += 12;
        }
        labels.add(monthNames[targetMonth - 1]);
      }
      return labels;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Orders Analytics',
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
      drawer: const PharmacyCustomDrawer(),
      body: StreamBuilder<List<PharmacyOrderModel>>(
        stream: _pharmacyRepo.streamPharmacyOrders(_pharmacyId),
        builder: (context, snapshotOrders) {
          if (snapshotOrders.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshotOrders.data ?? [];
          final stats = _calculateStats(orders);

          // Prepare Chart Data
          final topData = _getRealChartData(topChartView, orders);
          final topLabels = _getRealChartLabels(topChartView);

          final bottomData = _getRealChartData(bottomChartView, orders);
          final bottomLabels = _getRealChartLabels(bottomChartView);

          return SingleChildScrollView(
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
                      "Total Orders",
                      stats['total'].toString(),
                      "All time received",
                      Colors.blue,
                      Icons.shopping_bag_rounded,
                    ),
                    _buildStatCard(
                      context,
                      "Pending",
                      stats['pending'].toString(),
                      "Awaiting fulfillment",
                      Colors.orange,
                      Icons.pending_actions_rounded,
                    ),
                    _buildStatCard(
                      context,
                      "Dispensed",
                      stats['dispensed'].toString(),
                      "Successfully delivered",
                      Colors.green,
                      Icons.check_circle_rounded,
                    ),
                    _buildStatCard(
                      context,
                      "Cancelled",
                      stats['cancelled'].toString(),
                      "Rejected or cancelled",
                      Colors.red,
                      Icons.cancel_rounded,
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // ===================== TOP CHART =====================
                _buildChartCard(
                  context,
                  title: "Orders Volume Trend",
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
                            _buildLineChartData(theme, topData, topLabels),
                          )
                        : BarChart(
                            _buildBarChartData(theme, topData, topLabels),
                          ),
                  ),
                ),

                SizedBox(height: 24.h),

                // ===================== BOTTOM CHART =====================
                _buildChartCard(
                  context,
                  title: "Activity Overview",
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
                                theme, bottomData, bottomLabels),
                          )
                        : BarChart(
                            _buildBarChartData(
                                theme, bottomData, bottomLabels),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
              fontSize: 11.sp,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
      ThemeData theme, List<double> data, List<String> labels) {
    final primary = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    double maxVal = data.isEmpty ? 5 : data.reduce(max);
    if (maxVal < 5) maxVal = 5;

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    return LineChartData(
      minY: 0,
      maxY: (maxVal * 1.2).ceilToDouble(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxVal > 10 ? (maxVal / 4).ceilToDouble() : 1,
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
              if (value % 1 != 0 && maxVal < 10) return const SizedBox();
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
              if (value.toInt() < 0 || value.toInt() >= labels.length) {
                return const SizedBox();
              }
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
          spots: spots,
          isCurved: true,
          color: primary,
          barWidth: 3.w,
          belowBarData: BarAreaData(
            show: true,
            color: primary.withValues(alpha: 0.08),
          ),
          dotData: FlDotData(show: true),
        ),
      ],
    );
  }

  // ===================== BAR CHART =====================
  BarChartData _buildBarChartData(
      ThemeData theme, List<double> data, List<String> labels) {
    final primary = theme.colorScheme.primary;

    double maxVal = data.isEmpty ? 5 : data.reduce(max);
    if (maxVal < 5) maxVal = 5;

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: (maxVal * 1.2).ceilToDouble(),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: maxVal > 10 ? (maxVal / 4).ceilToDouble() : 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: theme.dividerColor.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30.w,
            getTitlesWidget: (value, meta) {
              if (value % 1 != 0 && maxVal < 10) return const SizedBox();
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              );
            },
          ),
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
              if (value.toInt() < 0 || value.toInt() >= labels.length) {
                return const SizedBox();
              }
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
        data.length,
        (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data[index],
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
}
