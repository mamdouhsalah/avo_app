import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:flutter/material.dart';

class LabResultModel {
  final String id;
  final String title;
  final PatientModel patient;
  final DoctorModel doctor;
  final String description;
  final DateTime dateTime;
  final String fileType;
  final String typeAdd;
  final String? resultSummary;
  final String? notes;
  final String? fileUrl;

  LabResultModel({
    required this.id,
    required this.title,
    required this.patient,
    required this.doctor,
    required this.description,
    required this.dateTime,
    required this.fileType,
    required this.typeAdd,
    this.resultSummary,
    this.notes,
    this.fileUrl,
  });

  String get formattedDate =>
      "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";

  String get formattedTime =>
      "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

  String get patientName => patient.fullName;

  String get doctorName => doctor.name;
}
