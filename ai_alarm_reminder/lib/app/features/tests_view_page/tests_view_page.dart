import 'dart:developer';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:ai_alarm_reminder/app/core/services/service_models/hive_medical_analysis_service.dart';
import 'package:ai_alarm_reminder/app/core/utils/constance.dart';
import 'package:ai_alarm_reminder/app/features/about_page/about_app_page.dart';
import 'package:ai_alarm_reminder/app/features/analsys_page/view/analysis_view.dart';
import 'package:ai_alarm_reminder/app/router/route_transition.dart';

class TestsPage extends StatefulWidget {
  const TestsPage({super.key});

  @override
  State<TestsPage> createState() => _TestsPageState();
}

class _TestsPageState extends State<TestsPage> {
  List<Map<String, dynamic>> savedEntries = [];
  bool _isServiceInitialized = false;
  final MedicalAnalysisService _medicalAnalysisService =
      MedicalAnalysisService();
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now(); // Track selected date

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message, style: const TextStyle(fontFamily: 'Cairo'))),
    );
  }

  Future<void> _initializeServices() async {
    try {
      await _medicalAnalysisService.init();
      setState(() {
        _isServiceInitialized = true;
      });
      await _fetchAnalyses();
    } catch (e) {
      _showSnackBar("Failed to initialize storage: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAnalyses() async {
    if (!_isServiceInitialized) return;
    try {
      final analyses = _medicalAnalysisService.getAllAnalysesByDate(
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day));
      setState(() {
        savedEntries = analyses
            .map((analysis) => {
                  'analysisName': analysis.analysisName,
                  'states': analysis.states
                      .map((state) => {
                            'name': state.name,
                            'value': state.value,
                            'normalLimits': state.normalLimits,
                            'description': state.description,
                            'date': state.date,
                          })
                      .toList(),
                })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      log('Error fetching analyses: $e');
      _showSnackBar("Failed to load analyses: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show date picker and update selected date
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _isLoading = true; // Show loading while fetching new data
      });
      await _fetchAnalyses();
    }
  }

  // Fetch history for a specific test, grouped by date
  Future<Map<String, List<Map<String, dynamic>>>> _fetchTestHistory(
      String analysisName) async {
    try {
      final states = _medicalAnalysisService.getAnalysisStates(analysisName);
      // Group states by date (formatted as yyyy-MM-dd)
      final groupedByDate = <String, List<Map<String, dynamic>>>{};
      for (var state in states) {
        final dateKey = DateFormat('yyyy-MM-dd').format(state.date);
        if (!groupedByDate.containsKey(dateKey)) {
          groupedByDate[dateKey] = [];
        }
        groupedByDate[dateKey]!.add({
          'name': state.name,
          'value': state.value,
          'normalLimits': state.normalLimits,
          'description': state.description,
          'date': state.date,
        });
      }
      // Sort dates in descending order (newest first)
      final sortedGroupedByDate = Map.fromEntries(
        groupedByDate.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
      );
      return sortedGroupedByDate;
    } catch (e) {
      log('Error fetching test history: $e');
      _showSnackBar("Failed to load test history: $e");
      return {};
    }
  }

  // Show test history in a dialog
  void _showTestHistoryDialog(String analysisName) async {
    final history = await _fetchTestHistory(analysisName);
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'تاريخ $analysisName',
            style: const TextStyle(
              fontFamily: 'cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: history.isEmpty
                ? const Text(
                    'لا يوجد تاريخ متاح لهذا التحليل',
                    style: TextStyle(fontFamily: 'cairo'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: history.keys.length,
                    itemBuilder: (context, index) {
                      final dateKey = history.keys.elementAt(index);
                      final states = history[dateKey]!;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'التاريخ: $dateKey',
                                style: const TextStyle(
                                  fontFamily: 'cairo',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...states.map((state) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "الاسم: ${state['name']}",
                                          style: const TextStyle(
                                            fontFamily: 'cairo',
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (state['value'] != 0.0)
                                          Text(
                                            "القيمة: ${state['value']}",
                                            style: const TextStyle(
                                              fontFamily: 'cairo',
                                              fontSize: 14,
                                            ),
                                          ),
                                        if (state['normalLimits'] != "N/A")
                                          Text(
                                            "الحدود الطبيعية: ${state['normalLimits']}",
                                            style: const TextStyle(
                                              fontFamily: 'cairo',
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        Text(
                                          "الوصف: ${state['description'] ?? 'لا يوجد وصف'}",
                                          style: TextStyle(
                                            fontFamily: 'cairo',
                                            fontSize: 14,
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Divider(),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'إغلاق',
                style: TextStyle(fontFamily: 'cairo'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text(
          'التحاليل الطبية',
          style: TextStyle(
            fontFamily: 'cairo',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FontAwesomeIcons.coins,
                        size: 14, color: AppColors.primaryColor),
                    const SizedBox(width: 4),
                    ValueListenableBuilder(
                        valueListenable: Hive.box('user_points').listenable(),
                        builder: (context, box, _) {
                          return Text(
                            (box.get('points', defaultValue: 10) as int)
                                .toString(),
                            style: TextStyle(
                              fontFamily: 'cairo',
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          );
                        }),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: InkWell(
              onTap: () =>
                  Navigator.push(context, SideTransition(const AboutPage())),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  CupertinoIcons.info_circle,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    SideTransition(const AnalysisViewPage()),
                  ).whenComplete(() {
                    _fetchAnalyses();
                  });
                },
                child: Card(
                  color: AppColors.primaryColor,
                  elevation: 0,
                  child: Flex(
                    direction: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 16),
                      CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 255, 255, 255),
                        radius: 40,
                        child: Icon(
                          CupertinoIcons.doc_text_viewfinder,
                          size: 50,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Flex(
                        direction: Axis.vertical,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'فحص تحليل جديد',
                            style: TextStyle(
                              fontFamily: 'cairo',
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'امسح تحاليلك بسهولة بالماسح الضوئي',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'cairo',
                              color: AppColors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ValueListenableBuilder(
                              valueListenable:
                                  Hive.box('user_points').listenable(),
                              builder: (context, box, _) {
                                return Text(
                                  'سيكلفك هذا نقطة واحدة (رصيدك: ${box.get('points', defaultValue: 10)})',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'cairo',
                                    color: const Color.fromARGB(
                                        177, 255, 255, 255),
                                    fontSize: 14,
                                  ),
                                );
                              }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'التاريخ: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                    style: const TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _selectDate,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'اختيار التاريخ',
                      style: TextStyle(fontFamily: 'cairo'),
                    ),
                  ),
                ],
              ),
            ),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : savedEntries.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد تحاليل متاحة لهذا التاريخ',
                          style: TextStyle(
                            fontFamily: 'cairo',
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Expanded(child: buildModernGridView(savedEntries))
          ],
        ),
      ),
    );
  }

  Widget buildModernGridView(List<Map<String, dynamic>> savedEntries) {
    return MasonryGridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 tiles per row
      ),
      mainAxisSpacing: 8,
      crossAxisSpacing: 4,
      itemCount: savedEntries.length,
      itemBuilder: (context, index) {
        final analysis = savedEntries[index];
        return GestureDetector(
          onTap: () => _showTestHistoryDialog(analysis['analysisName']),
          child: AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 200),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 239, 239, 239),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 1,
                      blurStyle: BlurStyle.outer,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Fit content
                    children: [
                      Text(
                        analysis['analysisName'] ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: (analysis['states'] as List)
                            .asMap()
                            .entries
                            .map((entry) {
                          final state = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (state['value'] != 0.0)
                                    Text(
                                      "القيمة: ${state['value']}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        fontFamily: 'cairo',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  if (state['normalLimits'] != "N/A")
                                    Text(
                                      "${state['normalLimits']}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(255, 100, 100, 100),
                                        fontFamily: 'cairo',
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  Text(
                                    "${state['description'] ?? 'لا يوجد تفاصيل'}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
