import 'package:avo_app/app/core/models/medicine_model.dart';

class PharmacyOrderModel {
  final String id;
  final String patientId;
  final String pharmacyId;
  final String patientName;
  final String patientPhone;
  final String patientAddress;
  final String status; // 'pending', 'dispensed', 'cancelled'
  final DateTime date;
  final List<MedicineModel> medicines;
  final String? note; // Note from pharmacy or patient
  final String? pharmacyName;

  PharmacyOrderModel({
    required this.id,
    required this.patientId,
    required this.pharmacyId,
    required this.patientName,
    required this.patientPhone,
    required this.patientAddress,
    required this.status,
    required this.date,
    required this.medicines,
    this.note,
    this.pharmacyName,
  });

  factory PharmacyOrderModel.fromJson(Map<dynamic, dynamic>? json) {
    if (json == null) {
      return PharmacyOrderModel(
        id: '',
        patientId: '',
        pharmacyId: '',
        patientName: '',
        patientPhone: '',
        patientAddress: '',
        status: 'pending',
        date: DateTime.now(),
        medicines: [],
      );
    }
    
    List<MedicineModel> meds = [];
    if (json['medicines'] != null) {
      final medsList = json['medicines'] as List<dynamic>;
      meds = medsList.map((m) => MedicineModel.fromJson(Map<String, dynamic>.from(m as Map))).toList();
    }

    return PharmacyOrderModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      pharmacyId: json['pharmacyId']?.toString() ?? '',
      patientName: json['patientName']?.toString() ?? '',
      patientPhone: json['patientPhone']?.toString() ?? '',
      patientAddress: json['patientAddress']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      date: json['date'] != null ? DateTime.parse(json['date'].toString()) : DateTime.now(),
      medicines: meds,
      note: json['note']?.toString(),
      pharmacyName: json['pharmacyName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'pharmacyId': pharmacyId,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'patientAddress': patientAddress,
      'status': status,
      'date': date.toIso8601String(),
      'medicines': medicines.map((m) => m.toJson()).toList(),
      if (note != null) 'note': note,
      if (pharmacyName != null) 'pharmacyName': pharmacyName,
    };
  }
}
