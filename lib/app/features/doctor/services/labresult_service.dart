import 'dart:io';
import 'package:avo_app/app/core/models/lab_result_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

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

  /// Download file from URL
  static Future<String?> downloadFile(LabResultModel result) async {
    if (result.fileUrl == null || result.fileUrl!.isEmpty) {
      throw Exception('No file URL available');
    }
    
    // If it is already a local file path
    if (!result.fileUrl!.startsWith('http')) {
      final file = File(result.fileUrl!);
      if (await file.exists()) {
        return result.fileUrl!;
      }
      throw Exception('File not found locally');
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      String ext = result.fileType.isNotEmpty ? result.fileType : 'pdf';
      final fileName = 'lab_result_${result.id}.$ext';
      final savePath = '${dir.path}/$fileName';

      // Check if already downloaded
      if (await File(savePath).exists()) {
        return savePath;
      }

      await Dio().download(result.fileUrl!, savePath);
      return savePath;
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  static Future<void> shareFile(LabResultModel result) async {
    final text = 'Lab Result: ${result.title}\nPatient: ${result.patientName ?? "Unknown"}\nDate: ${result.formattedDate}\nSummary: ${result.resultSummary ?? "N/A"}';
    
    try {
      // Try to download/get local path
      final localPath = await downloadFile(result);
      if (localPath != null) {
        await Share.shareXFiles(
          [XFile(localPath)],
          text: text,
          subject: 'Lab Result - ${result.title}',
        );
        return;
      }
    } catch (e) {
      // Ignore download errors and share text only if file fails
    }

    // Fallback to text sharing
    await Share.share(
      text,
      subject: 'Lab Result - ${result.title}',
    );
  }
}
