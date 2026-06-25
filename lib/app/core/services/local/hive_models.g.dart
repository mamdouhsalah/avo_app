// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicationAdapter extends TypeAdapter<Medication> {
  @override
  final int typeId = 0;

  @override
  Medication read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Medication(
      name: fields[0] as String,
      dose: fields[1] as double,
      unit: fields[2] as String,
      times: (fields[3] as List).cast<String>(),
      days: (fields[4] as List).cast<String>(),
      instructions: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Medication obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.dose)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.times)
      ..writeByte(4)
      ..write(obj.days)
      ..writeByte(5)
      ..write(obj.instructions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AnalysisAdapter extends TypeAdapter<Analysis> {
  @override
  final int typeId = 1;

  @override
  Analysis read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Analysis(
      name: fields[0] as String,
      date: fields[1] as DateTime,
      labName: fields[2] as String,
      notes: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Analysis obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.labName)
      ..writeByte(3)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppointmentAdapter extends TypeAdapter<Appointment> {
  @override
  final int typeId = 2;

  @override
  Appointment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Appointment(
      title: fields[0] as String,
      dateTime: fields[1] as DateTime,
      location: fields[2] as String,
      notes: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Appointment obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.dateTime)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WeightAdapter extends TypeAdapter<Weight> {
  @override
  final int typeId = 3;

  @override
  Weight read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Weight(
      weight: fields[0] as double,
      date: fields[1] as DateTime,
      notes: fields[2] as String,
      remind: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Weight obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.weight)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.remind);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HealthMetricAdapter extends TypeAdapter<HealthMetric> {
  @override
  final int typeId = 8;

  @override
  HealthMetric read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthMetric(
      type: fields[0] as String,
      value: fields[1] as double,
      date: fields[2] as DateTime,
      unit: fields[3] as String?,
      notes: fields[4] as String?,
      remind: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HealthMetric obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.unit)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.remind);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthMetricAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MedicationLogAdapter extends TypeAdapter<MedicationLog> {
  @override
  final int typeId = 5;

  @override
  MedicationLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicationLog(
      medicationKey: fields[0] as int,
      timestamp: fields[1] as DateTime,
      action: fields[2] as String,
      notificationId: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MedicationLog obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.medicationKey)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.action)
      ..writeByte(3)
      ..write(obj.notificationId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
