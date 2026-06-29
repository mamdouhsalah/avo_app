import 'package:avo_app/app/core/models/lab_result_model.dart';
import 'package:share_plus/share_plus.dart';
// ignore: unused_import
import 'package:share_plus/share_plus.dart' as sp;

class LabResultService {
  static List<LabResultModel> labResults = [];
  /// Search lab results
  static List<LabResultModel> searchLabResults(
    List<LabResultModel> allResults,
    String query,
  ) {
    if (query.isEmpty) return allResults;
    final lowerQuery = query.toLowerCase();
    return allResults
        .where((result) =>
            result.title.toLowerCase().contains(lowerQuery) ||
            (result.patientName?.toLowerCase().contains(lowerQuery) ?? false) ||
            (result.resultSummary?.toLowerCase().contains(lowerQuery) ?? false))
        .toList();
  }

  /// Filter lab results by type (Manual / AI)
  static List<LabResultModel> filterByType(
    List<LabResultModel> allResults,
    String type,
  ) {
    if (type.isEmpty) return allResults;
    return allResults.where((r) => r.typeAdd == type).toList();
  }

  /// Filter lab results by date range
  static List<LabResultModel> filterByDateRange(
    List<LabResultModel> allResults,
    DateTime startDate,
    DateTime endDate,
  ) {
    return allResults
        .where((r) =>
            r.dateTime.isAfter(startDate) && r.dateTime.isBefore(endDate))
        .toList();
  }

  static List<String> getTestTypes(List<LabResultModel> allResults) {
    final types = <String>{};
    for (var r in allResults) {
      types.add(r.typeAdd);
    }
    return types.toList();
  }

  static bool deleteLabResult(LabResultModel result) {
    try {
      final before = labResults.length;
      labResults.removeWhere((item) => item.id == result.id);
      return labResults.length < before;
    } catch (e) {
      rethrow;
    }
  }

  /// Download (placeholder — hook up real file logic here)
  static Future<void> downloadFile(LabResultModel result) async {
    // TODO: implement real download
    await Future.delayed(const Duration(milliseconds: 500));
  }

  static Future<void> shareFile(LabResultModel result) async {
    await SharePlus.instance.share(
      ShareParams(
        text: 'Lab Result: ${result.title}\nPatient: ${result.patientName}\nDate: ${result.dateTime.toLocal()}\nSummary: ${result.resultSummary ?? "N/A"}',
        subject: 'Lab Result - ${result.title}',
      ),
    );
  }
}
