// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_medical_analysis_service.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnalysisStateAdapter extends TypeAdapter<AnalysisState> {
  @override
  final int typeId = 7;

  @override
  AnalysisState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnalysisState(
      name: fields[0] as String,
      value: fields[1] as double,
      date: fields[2] as DateTime,
      normalLimits: fields[3] as String,
      description: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AnalysisState obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.normalLimits)
      ..writeByte(4)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MedicalAnalysisAdapter extends TypeAdapter<MedicalAnalysis> {
  @override
  final int typeId = 6;

  @override
  MedicalAnalysis read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicalAnalysis(
      analysisName: fields[0] as String,
      states: (fields[1] as List).cast<AnalysisState>(),
    );
  }

  @override
  void write(BinaryWriter writer, MedicalAnalysis obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.analysisName)
      ..writeByte(1)
      ..write(obj.states);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalAnalysisAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
