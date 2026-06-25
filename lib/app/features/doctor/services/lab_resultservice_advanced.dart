import 'dart:developer';
import 'dart:io';
import 'package:avo_app/app/core/models/lab_result_model.dart';
import 'package:avo_app/app/features/doctor/data/data.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class LabResultServiceAdvanced {
  static final Dio _dio = Dio();

  /// Download file with progress tracking
  static Future<bool> downloadFileWithProgress(
    LabResultModel result, {
    required Function(double) onProgress,
  }) async {
    try {
      // Check and request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied');
      }

      // Get download directory
      final dir = await getDownloadsDirectory();
      if (dir == null) throw Exception('Downloads directory not found');

      final filePath =
          '${dir.path}/${result.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Download with progress
      await _dio.download(
        result.fileUrl ?? '', // TODO: أضف fileUrl للـ model
        filePath,
        onReceiveProgress: (received, total) {
          final progress = received / total;
          onProgress(progress);
        },
      );

      log('✓ Downloaded to: $filePath');
      return true;
    } catch (e) {
      log('✗ Download error: $e');
      rethrow;
    }
  }

  /// Simple download without progress
  static Future<bool> downloadFile(LabResultModel result) async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied');
      }

      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${result.title}.pdf';

      await _dio.download(
        result.fileUrl ?? '',
        filePath,
      );

      log('✓ File downloaded: $filePath');
      return true;
    } catch (e) {
      log('✗ Error: $e');
      rethrow;
    }
  }

  /// Share file with options
  static Future<void> shareFile(
    LabResultModel result, {
    String? subject,
  }) async {
    try {
      // إذا كان لديك ملف فعلي:
      if (result.fileUrl != null && result.fileUrl!.isNotEmpty) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(result.fileUrl!)],
            text: subject ?? 'Lab Result: ${result.title}',
            subject: subject ?? result.title,
          ),
        );
      } else {
        // مشاركة نصية فقط إذا لم يكن هناك ملف
        await SharePlus.instance.share(
          ShareParams(
            text: _buildShareText(result),
            subject: subject ?? 'Lab Result - ${result.title}',
          ),
        );
      }

      log('✓ Shared: ${result.title}');
    } catch (e) {
      log('✗ Share error: $e');
      rethrow;
    }
  }

  /// Delete lab result
  static bool deleteLabResult(LabResultModel result) {
    try {
      final initialLength = DataRepository.labResults.length;

      DataRepository.labResults.removeWhere((item) => item.id == result.id);

      final wasDeleted = DataRepository.labResults.length < initialLength;

      if (wasDeleted) {
        log('✓ Deleted: ${result.id}');
      }

      return wasDeleted;
    } catch (e) {
      log('✗ Delete error: $e');
      rethrow;
    }
  }

  /// Search with highlights support
  static List<LabResultModel> searchLabResults(
    List<LabResultModel> allResults,
    String query,
  ) {
    if (query.isEmpty) return allResults;

    final lowerQuery = query.toLowerCase();

    return allResults.where((result) {
      return result.title.toLowerCase().contains(lowerQuery) ||
          result.patientName.toLowerCase().contains(lowerQuery) ||
          (result.resultSummary?.toLowerCase().contains(lowerQuery) ?? false) ||
          result.typeAdd.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Advanced search with multiple filters
  static List<LabResultModel> advancedSearch(
    List<LabResultModel> allResults, {
    String? keyword,
    String? testType,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    var results = allResults;

    // Filter by keyword
    if (keyword != null && keyword.isNotEmpty) {
      final lower = keyword.toLowerCase();
      results = results
          .where((r) =>
              r.title.toLowerCase().contains(lower) ||
              r.patientName.toLowerCase().contains(lower) ||
              (r.resultSummary?.toLowerCase().contains(lower) ?? false))
          .toList();
    }

    // Filter by test type
    if (testType != null && testType.isNotEmpty) {
      results = results.where((r) => r.typeAdd == testType).toList();
    }

    // Filter by date range
    if (fromDate != null && toDate != null) {
      results = results
          .where((r) =>
              r.dateTime.isAfter(fromDate) && r.dateTime.isBefore(toDate.add(
                    Duration(days: 1), // شامل ليوم الانتهاء
                  )))
          .toList();
    } else if (fromDate != null) {
      results = results.where((r) => r.dateTime.isAfter(fromDate)).toList();
    } else if (toDate != null) {
      results = results.where((r) => r.dateTime.isBefore(toDate)).toList();
    }

    return results;
  }

  /// Get unique test types
  static List<String> getTestTypes(List<LabResultModel> allResults) {
    final types = <String>{};
    for (var result in allResults) {
      types.add(result.typeAdd);
    }
    return types.toList()..sort();
  }

  /// Get statistics
  static Map<String, dynamic> getStatistics(
    List<LabResultModel> allResults,
  ) {
    return {
      'totalCount': allResults.length,
      'testTypes': getTestTypes(allResults),
      'latestResult': allResults.isNotEmpty
          ? allResults.reduce(
              (a, b) => a.dateTime.isAfter(b.dateTime) ? a : b,
            )
          : null,
      'oldestResult': allResults.isNotEmpty
          ? allResults.reduce(
              (a, b) => a.dateTime.isBefore(b.dateTime) ? a : b,
            )
          : null,
      'groupedByType': _groupByType(allResults),
      'groupedByMonth': _groupByMonth(allResults),
    };
  }

  /// Filter by date range
  static List<LabResultModel> filterByDateRange(
    List<LabResultModel> allResults,
    DateTime startDate,
    DateTime endDate,
  ) {
    return allResults
        .where((result) =>
            result.dateTime.isAfter(startDate) && result.dateTime.isBefore(endDate))
        .toList();
  }

  /// Filter by test type
  static List<LabResultModel> filterByType(
    List<LabResultModel> allResults,
    String type,
  ) {
    if (type.isEmpty) return allResults;
    return allResults.where((result) => result.typeAdd == type).toList();
  }

  /// Export results as CSV
  static Future<String> exportAsCSV(List<LabResultModel> results) async {
    try {
      final buffer = StringBuffer();

      // Header
      buffer.writeln('Title,Patient,Date,Type,Summary');

      // Data
      for (var result in results) {
        buffer.writeln(
          '"${result.title}","${result.patientName}","${result.formattedDate}","${result.typeAdd}","${result.resultSummary ?? 'N/A'}"',
        );
      }

      // Save to file
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/lab_results_${DateTime.now().millisecondsSinceEpoch}.csv',
      );
      await file.writeAsString(buffer.toString());

      log('✓ Exported to: ${file.path}');
      return file.path;
    } catch (e) {
      log('✗ Export error: $e');
      rethrow;
    }
  }

  /// Delete multiple results
  static int deleteMultiple(
    List<LabResultModel> resultsToDelete,
  ) {
    int deletedCount = 0;
    for (var result in resultsToDelete) {
      if (deleteLabResult(result)) {
        deletedCount++;
      }
    }
    return deletedCount;
  }

  // ============== Helper Methods ==============

  static String _buildShareText(LabResultModel result) {
    return '''
Lab Result Report
═══════════════════════════════════════════════
Title: ${result.title}
Patient: ${result.patientName}
Date: ${result.formattedDate}
Type: ${result.typeAdd}

Summary:
${result.resultSummary ?? 'No summary available'}

═══════════════════════════════════════════════
Generated on: ${DateTime.now().toString().split('.')[0]}
''';
  }

  static Map<String, int> _groupByType(List<LabResultModel> results) {
    final grouped = <String, int>{};
    for (var result in results) {
      grouped[result.typeAdd] = (grouped[result.typeAdd] ?? 0) + 1;
    }
    return grouped;
  }

  static Map<String, int> _groupByMonth(List<LabResultModel> results) {
    final grouped = <String, int>{};
    for (var result in results) {
      final monthKey =
          '${result.dateTime.year}-${result.dateTime.month.toString().padLeft(2, '0')}';
      grouped[monthKey] = (grouped[monthKey] ?? 0) + 1;
    }
    return grouped;
  }
}

// ============== Helper Classes ==============

/// Download progress model
class DownloadProgress {
  final int received;
  final int total;

  DownloadProgress(this.received, this.total);

  double get progress => total > 0 ? received / total : 0;
  int get percentProgress => (progress * 100).toInt();

  @override
  String toString() => '$percentProgress%';
}

/// Search result model with highlight
class SearchResult {
  final LabResultModel result;
  final List<String> matchedFields;

  SearchResult({
    required this.result,
    required this.matchedFields,
  });
}