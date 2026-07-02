// import 'dart:developer';

// import 'package:hive/hive.dart';
// import 'package:intl/intl.dart';
// import 'dart:async';

// part 'hive_medical_analysis_service.g.dart';

// // Hive model for individual analysis state
// @HiveType(typeId: 1)
// class AnalysisState extends HiveObject {
//   @HiveField(0)
//   String name;

//   @HiveField(1)
//   double value;

//   @HiveField(2)
//   DateTime date;

//   @HiveField(3)
//   String normalLimits;

//   @HiveField(4)
//   String description;

//   AnalysisState({
//     required this.name,
//     required this.value,
//     required this.date,
//     required this.normalLimits,
//     required this.description,
//   });
// }

// // Hive model for medical analysis
// @HiveType(typeId: 0)
// class MedicalAnalysis extends HiveObject {
//   @HiveField(0)
//   String analysisName;

//   @HiveField(1)
//   List<AnalysisState> states;

//   MedicalAnalysis({
//     required this.analysisName,
//     required this.states,
//   });
// }

// // Medical Analysis Service
// class MedicalAnalysisService {
//   static const String boxName = 'medicalAnalysisBox';
//   Box<MedicalAnalysis>? _box;

//   // Initialize Hive and open box
//   Future<void> init() async {
//     Hive.registerAdapter(MedicalAnalysisAdapter());
//     Hive.registerAdapter(AnalysisStateAdapter());
//     _box = await Hive.openBox<MedicalAnalysis>(boxName);
//     log('message');
//   }

//   // Add new analysis data
//   Future<void> addAnalysisData({
//     required String analysisName,
//     required String stateName,
//     required double value,
//     required String normalLimits,
//     required String description,
//     DateTime? date,
//   }) async {
//     if (_box == null) {
//       throw Exception('Hive box not initialized');
//     }

//     final analysisDate = date ?? DateTime.now();
//     final newState = AnalysisState(
//       name: stateName,
//       value: value,
//       date: analysisDate,
//       normalLimits: normalLimits,
//       description: description,
//     );

//     // Check if analysis exists
//     MedicalAnalysis? existingAnalysis;
//     for (var analysis in _box!.values) {
//       if (analysis.analysisName.toLowerCase() == analysisName.toLowerCase()) {
//         existingAnalysis = analysis;
//         break;
//       }
//     }

//     if (existingAnalysis != null) {
//       // Update existing analysis
//       existingAnalysis.states.add(newState);
//       await existingAnalysis.save();
//     } else {
//       // Create new analysis
//       final newAnalysis = MedicalAnalysis(
//         analysisName: analysisName,
//         states: [newState],
//       );
//       await _box!.add(newAnalysis);
//     }
//   }

//   // Get all analysis names
//   List<String> getAllAnalysisNames() {
//     if (_box == null) {
//       throw Exception('Hive box not initialized');
//     }
//     return _box!.values.map((analysis) => analysis.analysisName).toList();
//   }

//   // Get all states for a specific analysis
//   List<AnalysisState> getAnalysisStates(String analysisName) {
//     if (_box == null) {
//       throw Exception('Hive box not initialized');
//     }
//     final analysis = _box!.values.firstWhere(
//       (analysis) =>
//           analysis.analysisName.toLowerCase() == analysisName.toLowerCase(),
//       orElse: () => MedicalAnalysis(analysisName: analysisName, states: []),
//     );
//     return analysis.states;
//   }

//   // Get states for a specific analysis by date
//   List<AnalysisState> getAnalysisStatesByDate({
//     required String analysisName,
//     required DateTime date,
//   }) {
//     if (_box == null) {
//       throw Exception('Hive box not initialized');
//     }
//     final analysis = _box!.values.firstWhere(
//       (analysis) =>
//           analysis.analysisName.toLowerCase() == analysisName.toLowerCase(),
//       orElse: () => MedicalAnalysis(analysisName: analysisName, states: []),
//     );

//     final formattedDate = DateFormat('yyyy-MM-dd').format(date);
//     return analysis.states.where((state) {
//       final stateDate = DateFormat('yyyy-MM-dd').format(state.date);
//       return stateDate == formattedDate;
//     }).toList();
//   }

//   // Get all analyses by date
//   List<MedicalAnalysis> getAllAnalysesByDate(DateTime date) {
//     if (_box == null) {
//       throw Exception('Hive box not initialized');
//     }

//     final formattedDate = DateFormat('yyyy-MM-dd').format(date);
//     final results = <MedicalAnalysis>[];

//     for (var analysis in _box!.values) {
//       final matchingStates = analysis.states.where((state) {
//         final stateDate = DateFormat('yyyy-MM-dd').format(state.date);
//         return stateDate == formattedDate;
//       }).toList();

//       if (matchingStates.isNotEmpty) {
//         results.add(MedicalAnalysis(
//           analysisName: analysis.analysisName,
//           states: matchingStates,
//         ));
//       }
//     }

//     return results;
//   }

//   // Clear all data
//   Future<void> clearAllData() async {
//     if (_box == null) {
//       throw Exception('Hive box not initialized');
//     }
//     await _box!.clear();
//   }

//   // Close Hive box
//   Future<void> close() async {
//     await _box?.close();
//   }
// }

import 'dart:developer';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'dart:async';

part 'hive_medical_analysis_service.g.dart';

// Hive model for individual analysis state
@HiveType(typeId: 7)
class AnalysisState extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double value;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String normalLimits;

  @HiveField(4)
  String description;

  @HiveField(5)
  String? imageUrl;

  AnalysisState({
    required this.name,
    required this.value,
    required this.date,
    required this.normalLimits,
    required this.description,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
        'date': date.toIso8601String(),
        'normalLimits': normalLimits,
        'description': description,
        'imageUrl': imageUrl,
      };

  factory AnalysisState.fromJson(Map<String, dynamic> json) => AnalysisState(
        name: json['name'] as String? ?? 'غير محدد',
        value: (json['value'] as num?)?.toDouble() ?? 0.0,
        date: json['date'] != null
            ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
            : DateTime.now(),
        normalLimits: json['normalLimits'] as String? ?? '',
        description: json['description'] as String? ?? '',
        imageUrl: json['imageUrl'] as String?,
      );
}

// Hive model for medical analysis
@HiveType(typeId: 6)
class MedicalAnalysis extends HiveObject {
  @HiveField(0)
  String analysisName;

  @HiveField(1)
  List<AnalysisState> states;

  MedicalAnalysis({
    required this.analysisName,
    required this.states,
  });

  Map<String, dynamic> toJson() => {
        'analysisName': analysisName,
        'states': states.map((s) => s.toJson()).toList(),
      };

  factory MedicalAnalysis.fromJson(Map<String, dynamic> json) {
    return MedicalAnalysis(
      analysisName: json['analysisName'] as String? ?? 'تحليل طبي',
      states: (json['states'] as List<dynamic>?)
              ?.map((e) => AnalysisState.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// Medical Analysis Service
class MedicalAnalysisService {
  static const String boxName = 'medicalAnalysisBox';
  static final MedicalAnalysisService _instance = MedicalAnalysisService._internal();

  factory MedicalAnalysisService() {
    return _instance;
  }

  MedicalAnalysisService._internal();

  Box<MedicalAnalysis>? _box;

  // Initialize by accessing or opening the box
  Future<void> init() async {
    if (_box == null) {
      if (Hive.isBoxOpen(boxName)) {
        _box = Hive.box<MedicalAnalysis>(boxName);
      } else {
        _box = await Hive.openBox<MedicalAnalysis>(boxName);
      }
      log('MedicalAnalysisService: Hive box initialized for $boxName');
    } else {
      log('MedicalAnalysisService: Hive box already initialized');
    }
  }

  // Add new analysis data
  Future<void> addAnalysisData({
    required String analysisName,
    required String stateName,
    required double value,
    required String normalLimits,
    required String description,
    String? imageUrl,
    DateTime? date,
  }) async {
    if (_box == null) {
      throw Exception('Hive box not initialized');
    }

    final analysisDate = date ?? DateTime.now();
    final newState = AnalysisState(
      name: stateName,
      value: value,
      date: analysisDate,
      normalLimits: normalLimits,
      description: description,
      imageUrl: imageUrl,
    );

    MedicalAnalysis? existingAnalysis;
    for (var analysis in _box!.values) {
      if (analysis.analysisName.toLowerCase() == analysisName.toLowerCase()) {
        existingAnalysis = analysis;
        break;
      }
    }

    if (existingAnalysis != null) {
      existingAnalysis.states.add(newState);
      await existingAnalysis.save();
      log('MedicalAnalysisService: Added state to existing analysis: $analysisName');
    } else {
      final newAnalysis = MedicalAnalysis(
        analysisName: analysisName,
        states: [newState],
      );
      await _box!.add(newAnalysis);
      log('MedicalAnalysisService: Created new analysis: $analysisName');
    }
  }

  // Get all full analyses
  List<MedicalAnalysis> getAllAnalyses() {
    if (_box == null) throw Exception('Hive box not initialized');
    return _box!.values.toList();
  }

  // Add or update full analysis
  Future<void> addOrUpdateAnalysis(MedicalAnalysis analysis) async {
    if (_box == null) throw Exception('Hive box not initialized');

    MedicalAnalysis? existingAnalysis;
    dynamic existingKey;
    
    for (var k in _box!.keys) {
      final a = _box!.get(k);
      if (a != null && a.analysisName.toLowerCase() == analysis.analysisName.toLowerCase()) {
        existingAnalysis = a;
        existingKey = k;
        break;
      }
    }

    if (existingAnalysis != null && existingKey != null) {
      await _box!.put(existingKey, analysis);
    } else {
      await _box!.add(analysis);
    }
  }

  // Get all analysis names
  List<String> getAllAnalysisNames() {
    if (_box == null) {
      throw Exception('Hive box not initialized');
    }
    final names =
        _box!.values.map((analysis) => analysis.analysisName).toList();
    log('MedicalAnalysisService: Retrieved analysis names: $names');
    return names;
  }

  // Get all states for a specific analysis
  List<AnalysisState> getAnalysisStates(String analysisName) {
    if (_box == null) {
      throw Exception('Hive box not initialized');
    }
    final analysis = _box!.values.firstWhere(
      (analysis) =>
          analysis.analysisName.toLowerCase() == analysisName.toLowerCase(),
      orElse: () => MedicalAnalysis(analysisName: analysisName, states: []),
    );
    log('MedicalAnalysisService: Retrieved states for $analysisName: ${analysis.states.length} states');
    return analysis.states;
  }

  // Get states for a specific analysis by date
  List<AnalysisState> getAnalysisStatesByDate({
    required String analysisName,
    required DateTime date,
  }) {
    if (_box == null) {
      throw Exception('Hive box not initialized');
    }
    final analysis = _box!.values.firstWhere(
      (analysis) =>
          analysis.analysisName.toLowerCase() == analysisName.toLowerCase(),
      orElse: () => MedicalAnalysis(analysisName: analysisName, states: []),
    );

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final states = analysis.states.where((state) {
      final stateDate = DateFormat('yyyy-MM-dd').format(state.date);
      return stateDate == formattedDate;
    }).toList();
    log('MedicalAnalysisService: Retrieved states for $analysisName on $formattedDate: ${states.length} states');
    return states;
  }

  // Get the latest analysis states for all analyses by the last stored day
  Future<List<AnalysisState>> getLatestAnalysesByLastDay() async {
    if (_box == null) {
      throw Exception('Hive box not initialized');
    }

    if (_box!.isEmpty) {
      log('MedicalAnalysisService: No analyses found in the box');
      return [];
    }

    // Find the latest date across all states
    DateTime? latestDate;
    for (var analysis in _box!.values) {
      for (var state in analysis.states) {
        if (latestDate == null || state.date.isAfter(latestDate)) {
          latestDate = state.date;
        }
      }
    }

    if (latestDate == null) {
      log('MedicalAnalysisService: No states found in any analysis');
      return [];
    }

    final formattedLatestDate = DateFormat('yyyy-MM-dd').format(latestDate);

    // Collect all states matching the latest date
    final latestStates = <AnalysisState>[];
    for (var analysis in _box!.values) {
      latestStates.addAll(analysis.states.where((state) {
        final stateDate = DateFormat('yyyy-MM-dd').format(state.date);
        return stateDate == formattedLatestDate;
      }));
    }

    log('MedicalAnalysisService: Retrieved ${latestStates.length} states for the latest date: $formattedLatestDate from analyses');
    return latestStates;
  }

  // Get all analyses by date
  List<MedicalAnalysis> getAllAnalysesByDate(DateTime date) {
    if (_box == null) {
      throw Exception('Hive box not initialized');
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final results = <MedicalAnalysis>[];

    for (var analysis in _box!.values) {
      final matchingStates = analysis.states.where((state) {
        final stateDate = DateFormat('yyyy-MM-dd').format(state.date);
        return stateDate == formattedDate;
      }).toList();

      if (matchingStates.isNotEmpty) {
        results.add(MedicalAnalysis(
          analysisName: analysis.analysisName,
          states: matchingStates,
        ));
      }
    }
    log('MedicalAnalysisService: System.Text.RegularExpressions.RegexOptions.None'
        'Retrieved analyses for $formattedDate: ${results.length} analyses');
    return results;
  }

  // Clear all data
  Future<void> clearAllData() async {
    if (_box == null) {
      throw Exception('Hive box not initialized');
    }
    await _box!.clear();
    log('MedicalAnalysisService: Cleared all data');
  }

  // Close Hive box
  // Future<void> close() async {
  //   if (_box != null && _box!.isOpen) {
  //     await _box!.close();
  //     _box = null;
  //     log('MedicalAnalysisService: Closed Hive box');
  //   }
  // }
}
