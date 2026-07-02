import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:avo_app/app/core/services/local/hive_medical_analysis_service.dart';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:intl/intl.dart';

class SavedAnalysesListScreen extends StatefulWidget {
  const SavedAnalysesListScreen({super.key});

  @override
  State<SavedAnalysesListScreen> createState() => _SavedAnalysesListScreenState();
}

class _SavedAnalysesListScreenState extends State<SavedAnalysesListScreen> {
  final MedicalAnalysisService _medicalAnalysisService = MedicalAnalysisService();
  List<MedicalAnalysis> _analyses = [];

  @override
  void initState() {
    super.initState();
    _loadAnalyses();
  }

  void _loadAnalyses() {
    setState(() {
      _analyses = _medicalAnalysisService.getAllAnalyses();
      // Sort by latest date descending
      _analyses.sort((a, b) {
        final aDate = a.states.isNotEmpty ? a.states.last.date : DateTime.now();
        final bDate = b.states.isNotEmpty ? b.states.last.date : DateTime.now();
        return bDate.compareTo(aDate);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحاليل المحفوظة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _analyses.isEmpty
          ? const Center(
              child: Text(
                'لا توجد تحاليل محفوظة.',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _analyses.length,
              itemBuilder: (context, index) {
                final analysis = _analyses[index];
                final lastState = analysis.states.isNotEmpty ? analysis.states.last : null;
                final dateStr = lastState != null ? DateFormat('dd MMM yyyy').format(lastState.date) : '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        image: lastState?.imageUrl != null && lastState!.imageUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(lastState.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (lastState?.imageUrl == null || lastState!.imageUrl!.isEmpty)
                          ? const Icon(Icons.document_scanner, color: Color(0xFF1ABC9C), size: 30)
                          : null,
                    ),
                    title: Text(
                      analysis.analysisName,
                      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      dateStr,
                      style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      if (lastState != null) {
                        context.push(
                          AppRouter.savedAnalysis,
                          extra: {
                            'fileName': analysis.analysisName,
                            'file': lastState.imageUrl ?? '',
                            'extractedText': '',
                            'analysisResult': lastState.description,
                          },
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
