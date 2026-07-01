import 'package:ai_alarm_reminder/app/core/services/health_metrics_service.dart';
import 'package:ai_alarm_reminder/app/core/services/points_service.dart';
import 'package:ai_alarm_reminder/app/core/services/service_models/models.dart';
import 'package:ai_alarm_reminder/app/core/utils/constance.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class HealthMetricsPage extends StatefulWidget {
  const HealthMetricsPage({super.key});

  @override
  State<HealthMetricsPage> createState() => _HealthMetricsPageState();
}

class _HealthMetricsPageState extends State<HealthMetricsPage> {
  DateTime _selectedDateTime = DateTime.now();
  String _selectedType = 'sugar';

  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _value2Controller = TextEditingController();

  final Map<String, String> _typeNames = {
    'sugar': 'سكر الدم',
    'pressure': 'ضغط الدم',
    'weight': 'الوزن',
    'sleep': 'ساعات النوم',
  };

  @override
  void dispose() {
    _valueController.dispose();
    _value2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('متابعة الصحة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18.sp)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeSelector(),
            SizedBox(height: 15.h),
            _buildChartSection(),
            SizedBox(height: 15.h),
            _buildInputSection(),
            SizedBox(height: 15.h),
            _buildRecentLogs(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _typeNames.entries.map((e) {
          bool isSelected = _selectedType == e.key;
          return Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: ChoiceChip(
              label: Text(e.value, style: TextStyle(fontFamily: 'Cairo', color: isSelected ? Colors.white : Colors.black, fontSize: 12.sp)),
              selected: isSelected,
              selectedColor: AppColors.primaryColor,
              onSelected: (val) => setState(() => _selectedType = e.key),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartSection() {
    List<HealthMetric> metrics = HealthMetricsService.getMetricsByType(_selectedType);
    if (_selectedType == 'pressure') {
      metrics = HealthMetricsService.getMetricsByType('pressure_systolic');
    }

    // Get diastolic data for pressure overlay
    List<HealthMetric> diastolicMetrics = [];
    if (_selectedType == 'pressure') {
      diastolicMetrics = HealthMetricsService.getMetricsByType('pressure_diastolic');
    }

    return Container(
      height: 220.h,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)],
      ),
      child: metrics.isEmpty 
        ? Center(child: Text('لا توجد بيانات كافية للرسم البياني', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)))
        : LineChart(
            LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (val) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35, getTitlesWidget: (val, meta) => Text(val.toInt().toString(), style: TextStyle(fontSize: 10.sp)))),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, getTitlesWidget: (val, meta) {
                  if (val.toInt() >= 0 && val.toInt() < metrics.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(DateFormat('MM/dd').format(metrics[val.toInt()].date), style: TextStyle(fontSize: 8.sp)),
                    );
                  }
                  return const SizedBox();
                })),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final idx = spot.x.toInt();
                      String label = '${spot.y}';
                      if (_selectedType == 'pressure' && spot.barIndex == 0 && idx < metrics.length) {
                        label = 'انقباضي: ${spot.y}';
                      } else if (_selectedType == 'pressure' && spot.barIndex == 1) {
                        label = 'انبساطي: ${spot.y}';
                      }
                      return LineTooltipItem(label, const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 12));
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: metrics.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
                  isCurved: true,
                  color: AppColors.primaryColor,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: AppColors.primaryColor.withOpacity(0.1)),
                ),
                if (_selectedType == 'pressure' && diastolicMetrics.isNotEmpty)
                  LineChartBarData(
                    spots: diastolicMetrics.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
                    isCurved: true,
                    color: Colors.orange,
                    barWidth: 2,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: Colors.orange.withOpacity(0.05)),
                  ),
              ],
            ),
          ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('تسجيل قراءة جديدة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14.sp)),
          SizedBox(height: 10.h),
          if (_selectedType == 'pressure') ...[
            Row(
              children: [
                Expanded(child: _buildTextField(_valueController, 'الانقباضي')),
                SizedBox(width: 10.w),
                Expanded(child: _buildTextField(_value2Controller, 'الانبساطي')),
              ],
            ),
          ] else
            _buildTextField(_valueController, 'القيمة (${_getUnit()})'),
          SizedBox(height: 10.h),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(context: context, initialDate: _selectedDateTime, firstDate: DateTime(2000), lastDate: DateTime.now());
              if (date != null && mounted) {
                final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_selectedDateTime));
                if (time != null) {
                  setState(() => _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                }
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8.r)),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16.sp, color: AppColors.primaryColor),
                  SizedBox(width: 8.w),
                  Text(DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime), style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp)),
                ],
              ),
            ),
          ),
          SizedBox(height: 15.h),
          ElevatedButton(
            onPressed: _saveMetric,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              minimumSize: Size(double.infinity, 45.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text('حفظ القراءة', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }

  String _getUnit() {
    switch (_selectedType) {
      case 'sugar': return 'mg/dL';
      case 'weight': return 'kg';
      case 'sleep': return 'ساعة';
      default: return '';
    }
  }

  void _saveMetric() async {
    if (_valueController.text.isEmpty) {
      _showSnack('يرجى إدخال القيمة');
      return;
    }
    double? val = double.tryParse(_valueController.text);
    if (val == null) {
      _showSnack('يرجى إدخال رقم صحيح');
      return;
    }

    if (_selectedType == 'pressure') {
      if (_value2Controller.text.isEmpty) {
        _showSnack('يرجى إدخال قيمة الضغط الانبساطي');
        return;
      }
      double? val2 = double.tryParse(_value2Controller.text);
      if (val2 == null) {
        _showSnack('يرجى إدخال رقم صحيح للضغط الانبساطي');
        return;
      }
      await HealthMetricsService.addMetric(HealthMetric(type: 'pressure_systolic', value: val, date: _selectedDateTime));
      await HealthMetricsService.addMetric(HealthMetric(type: 'pressure_diastolic', value: val2, date: _selectedDateTime));
      _checkAlert('pressure', val, val2);
    } else {
      await HealthMetricsService.addMetric(HealthMetric(type: _selectedType, value: val, date: _selectedDateTime));
      _checkAlert(_selectedType, val);
    }

    await PointsService.addPoints(5);
    _valueController.clear();
    _value2Controller.clear();
    setState(() => _selectedDateTime = DateTime.now());
    
    _showSnack('تم حفظ البيانات وحصلت على 5 نقاط!', color: Colors.green);
  }

  void _showSnack(String message, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
      backgroundColor: color ?? Colors.grey.shade800,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _checkAlert(String type, double val, [double? val2]) {
    String? alert;
    Color alertColor = Colors.orange;

    // Sugar alerts
    if (type == 'sugar' && val > 200) {
      alert = 'تحذير: مستوى السكر مرتفع جدًا (${val.toStringAsFixed(0)} mg/dL). يرجى مراجعة الطبيب.';
      alertColor = Colors.red;
    }
    if (type == 'sugar' && val < 70) {
      alert = 'تحذير: مستوى السكر منخفض جدًا (${val.toStringAsFixed(0)} mg/dL). يرجى تناول شيء سكري فوراً.';
      alertColor = Colors.red;
    }
    if (type == 'sugar' && val >= 70 && val <= 200) {
      alert = 'مستوى السكر طبيعي (${val.toStringAsFixed(0)} mg/dL) 👍';
      alertColor = Colors.green;
    }

    // Pressure alerts
    if (type == 'pressure') {
      if (val > 140 || (val2 ?? 0) > 90) {
        alert = 'تحذير: ضغط الدم مرتفع (${val.toStringAsFixed(0)}/${val2?.toStringAsFixed(0)}). يرجى الراحة ومتابعة القياس.';
        alertColor = Colors.red;
      } else if (val < 90 || (val2 ?? 80) < 60) {
        alert = 'تحذير: ضغط الدم منخفض (${val.toStringAsFixed(0)}/${val2?.toStringAsFixed(0)}). يرجى شرب سوائل ومتابعة القياس.';
        alertColor = Colors.orange;
      } else {
        alert = 'ضغط الدم طبيعي (${val.toStringAsFixed(0)}/${val2?.toStringAsFixed(0)}) 👍';
        alertColor = Colors.green;
      }
    }

    // Sleep alerts
    if (type == 'sleep') {
      if (val < 5) {
        alert = 'تحذير: ساعات النوم قليلة جدًا (${val.toStringAsFixed(1)} ساعة). حاول تنام على الأقل 7 ساعات.';
        alertColor = Colors.red;
      } else if (val > 10) {
        alert = 'تنبيه: ساعات النوم كثيرة (${val.toStringAsFixed(1)} ساعة). النوم الزائد قد يسبب خمول.';
        alertColor = Colors.orange;
      } else {
        alert = 'ساعات النوم مناسبة (${val.toStringAsFixed(1)} ساعة) 👍';
        alertColor = Colors.green;
      }
    }

    // Weight alerts (informational only)
    if (type == 'weight') {
      alert = 'تم تسجيل الوزن: ${val.toStringAsFixed(1)} كجم';
      alertColor = Colors.blue;
    }
    
    if (alert != null) {
      final isWarning = alertColor == Colors.red || alertColor == Colors.orange;
      if (isWarning) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
            title: Row(children: [
              Icon(Icons.warning_amber_rounded, color: alertColor, size: 28.sp),
              SizedBox(width: 8.w),
              Text('تنبيه ذكي', style: TextStyle(fontFamily: 'Cairo'))
            ]),
            content: Text(alert!, style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp)),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('فهمت', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)))],
          ),
        );
      } else {
        _showSnack(alert, color: alertColor);
      }
    }
  }

  Widget _buildRecentLogs() {
    List<HealthMetric> metrics = HealthMetricsService.getAllMetrics();
    metrics.sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('السجلات الأخيرة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14.sp)),
        SizedBox(height: 8.h),
        metrics.isEmpty 
          ? Center(child: Padding(padding: EdgeInsets.all(20.w), child: Text('لا توجد سجلات بعد', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey))))
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: metrics.length > 10 ? 10 : metrics.length,
              itemBuilder: (context, index) {
                final m = metrics[index];
                final isPressure = m.type.contains('pressure');
                final displayType = isPressure ? 'pressure' : m.type;
                final displayValue = m.type == 'pressure_diastolic' 
                    ? '${m.value.toStringAsFixed(0)} (انبساطي)' 
                    : m.type == 'pressure_systolic'
                      ? '${m.value.toStringAsFixed(0)} (انقباضي)'
                      : m.value.toStringAsFixed(m.type == 'sleep' ? 1 : 0);
                return Card(
                  elevation: 0,
                  margin: EdgeInsets.only(bottom: 8.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r), side: BorderSide(color: Colors.grey.shade100)),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: AppColors.primaryColor.withOpacity(0.1), child: Icon(_getIcon(m.type), color: AppColors.primaryColor, size: 18.sp)),
                    title: Text('${_typeNames[displayType] ?? m.type} : $displayValue', style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, fontWeight: FontWeight.w600)),
                    subtitle: Text(DateFormat('yyyy/MM/dd - HH:mm').format(m.date), style: TextStyle(fontSize: 10.sp)),
                    trailing: Icon(Icons.arrow_forward_ios, size: 12.sp, color: Colors.grey),
                  ),
                );
              },
            ),
      ],
    );
  }

  IconData _getIcon(String type) {
    if (type.contains('sugar')) return FontAwesomeIcons.droplet;
    if (type.contains('pressure')) return FontAwesomeIcons.heartPulse;
    if (type.contains('weight')) return FontAwesomeIcons.weightScale;
    if (type.contains('sleep')) return FontAwesomeIcons.bed;
    return Icons.health_and_safety;
  }
}
