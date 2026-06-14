import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/core/models/catogery_model.dart';
import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:avo_app/app/core/models/medicine_model.dart';
import 'package:avo_app/app/core/models/pharmacy_model.dart';
import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:avo_app/app/core/models/timerange_model.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  final PatientModel currentUser = const PatientModel(
    id: '1',
    fullName: 'Sofia Andro',
    email: 'sofia@email.com',
    phoneNumber: '+201234567890',
    image: 'assets/imgs/profile/profile.png',
    role: 'patient',
    isVerified: true,
  );

  final List<AppointmentModel> appointments = [
    AppointmentModel(
      id: '1',
      doctor: const DoctorModel(
        id: '1',
        name: 'Jennifer Miller',
        specialty: 'Neurosurgeon',
        hospital: 'City Hospital',
        rating: 4.4,
        reviews: 98,
        hourlyRate: 50,
        experience: 10,
        patientsTreated: 500,
        openTime: '10:30 am',
        closeTime: '06:30 pm',
        isFavorite: false,
        imageUrl: 'assets/imgs/doctor/doctor1.png',
      ),
      rating: 4.5,
      isFavorite: false,
      timeRange: TimeRange(
        start: const TimeOfDay(hour: 10, minute: 30),
        end: const TimeOfDay(hour: 12, minute: 30),
      ),
      date: DateTime.now().add(const Duration(days: 1)),
    ),
    AppointmentModel(
      id: '2',
      doctor: const DoctorModel(
        id: '2',
        name: 'Laura White',
        specialty: 'Cardiologist',
        hospital: 'Heart Care Center',
        rating: 4.2,
        reviews: 76,
        hourlyRate: 60,
        experience: 8,
        patientsTreated: 350,
        openTime: '12:00 pm',
        closeTime: '08:30 pm',
        isFavorite: true,
        imageUrl: 'assets/imgs/doctor/doctor2.png',
      ),
      rating: 4.0,
      isFavorite: true,
      timeRange: TimeRange(
        start: const TimeOfDay(hour: 14, minute: 0),
        end: const TimeOfDay(hour: 15, minute: 0),
      ),
      date: DateTime.now().add(const Duration(days: 3)),
    ),
  ];

  // ── Medicines ──────────────────────────────
  final List<MedicineModel> medicines = [
    const MedicineModel(
      id: '1',
      name: 'Amoxicillin',
      dosage: 'Simvastatin + 1 pill',
      time: '10:00 AM',
      isTaken: false,
    ),
    const MedicineModel(
      id: '2',
      name: 'Panadol',
      dosage: '500mg - 1 pill',
      time: '02:00 PM',
      isTaken: true,
    ),
    const MedicineModel(
      id: '3',
      name: 'Vitamin C',
      dosage: '1000mg - 1 tablet',
      time: '08:00 AM',
      isTaken: false,
    ),
  ];

  MedicineModel? get upcomingMedicine {
    try {
      return medicines.firstWhere((m) => !m.isTaken);
    } catch (_) {
      return null;
    }
  }

  // ── Categories ─────────────────────────────
  final List<CategoryModel> categories = const [
    CategoryModel(
        id: '1', name: 'Heart', image: 'assets/imgs/categories/heart.png'),
    CategoryModel(
        id: '2', name: 'Dental', image: 'assets/imgs/categories/Dental.png'),
    CategoryModel(
        id: '3', name: 'Kidney', image: 'assets/imgs/categories/Kidney.png'),
    CategoryModel(
        id: '4', name: 'Stomach', image: 'assets/imgs/categories/Stomach.png'),
    CategoryModel(
        id: '5', name: 'Lung', image: 'assets/imgs/categories/Lung.png'),
    CategoryModel(
        id: '6', name: 'Brain', image: 'assets/imgs/categories/brain.png'),
    CategoryModel(
        id: '7',
        name: 'Pediatrics',
        image: 'assets/imgs/categories/Pediatrics.png'),
    CategoryModel(
        id: '8', name: 'Liver', image: 'assets/imgs/categories/Liver.png'),
    CategoryModel(
        id: '9', name: 'ENT', image: 'assets/imgs/categories/ENT.png'),
    CategoryModel(
        id: '10',
        name: 'Ophthalmology',
        image: 'assets/imgs/categories/Ophthalmology.png'),
    CategoryModel(
        id: '11',
        name: 'Orthopedics',
        image: 'assets/imgs/categories/Orthopedics.png'),
    CategoryModel(
        id: '12',
        name: 'Gynecology',
        image: 'assets/imgs/categories/Gynecology.png'),
    CategoryModel(
        id: '13',
        name: 'Dermatology',
        image: 'assets/imgs/categories/Dermatology.png'),
  ];

  // ── Best Doctors ───────────────────────────
  final List<DoctorModel> bestDoctors = const [
    DoctorModel(
      id: '1',
      name: 'Jennifer Miller',
      specialty: 'Neurosurgeon',
      rating: 4.4,
      reviews: 98,
      openTime: '10:30 am',
      closeTime: '06:30 pm',
      isFavorite: false,
      imageUrl: 'assets/imgs/doctor/doctor1.png',
    ),
    DoctorModel(
      id: '2',
      name: 'Laura White',
      specialty: 'Cardiologist',
      rating: 4.2,
      reviews: 76,
      openTime: '12:00 pm',
      closeTime: '08:30 pm',
      isFavorite: true,
      imageUrl: 'assets/imgs/doctor/doctor2.png',
    ),
    DoctorModel(
      id: '3',
      name: 'Robert Johnson',
      specialty: 'Orthopedic',
      rating: 4.1,
      reviews: 54,
      openTime: '08:30 am',
      closeTime: '04:30 pm',
      isFavorite: false,
      imageUrl: 'assets/imgs/doctor/doctor3.png',
    ),
  ];

  // ── Best Pharmacies ────────────────────────
  final List<PharmacyModel> bestPharmacies = const [
    PharmacyModel(
      id: '1',
      name: 'City Pharmacy',
      type: 'Pharmacy',
      rating: 4.5,
      reviews: 110,
      openTime: '10:30 am',
      closeTime: '05:30 pm',
      isFavorite: false,
      imageUrl: 'assets/imgs/doctor/doctor2.png',
    ),
    PharmacyModel(
      id: '2',
      name: 'Health Plus',
      type: 'Pharmacy | Clinic',
      rating: 4.2,
      reviews: 85,
      openTime: '10:30 am',
      closeTime: '02:30 pm',
      isFavorite: true,
      imageUrl: 'assets/imgs/doctor/doctor3.png',
    ),
  ];
}
