import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/core/models/catogery_model.dart';
import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:avo_app/app/core/models/medicine_model.dart';
import 'package:avo_app/app/core/models/pharmacy_model.dart';
import 'package:avo_app/app/core/models/user_model.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  // ── Static User ─────────────────────────────
  final List<UserModel> user = [
    const UserModel(
      id: '1',
      name: 'Sofia Andro',
      email: 'sofia@email.com',
      phone: '+201234567890',
      image: 'assets/imgs/profile/profile.png',
      role: 'patient',
      isVerified: true,
    )
  ];

  // ── Data ───────────────────────────────────
  final List<AppointmentModel> appointments = [
    const AppointmentModel(
        id: '1',
        doctorName: 'Jason Smith',
        specialty: 'Neurosurgeon',
        rating: 4.8,
        reviews: 120,
        date: '2 Oct',
        time: '10:00am',
        imageUrl: 'assets/imgs/doctor/doctor1.png'),
    const AppointmentModel(
      id: '2',
      doctorName: 'Melisa Josef',
      specialty: 'Pediatrician | Mercy Hospital',
      rating: 3.9,
      reviews: 85,
      date: '5 Oct',
      time: '10:30 am - 05:30 pm',
      imageUrl: 'assets/imgs/doctor/doctor2.png',
    ),
    const AppointmentModel(
        id: '3',
        doctorName: 'Sarah Connor',
        specialty: 'Cardiologist',
        rating: 4.9,
        reviews: 210,
        date: '10 Oct',
        time: '02:00pm',
        imageUrl: 'assets/imgs/doctor/doctor3.png'),
  ];

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

  final List<CategoryModel> categories = [
    const CategoryModel(
        id: '1', name: 'Heart', image: 'assets/imgs/categories/heart.png'),
    const CategoryModel(
        id: '2', name: 'Dental', image: 'assets/imgs/categories/Dental.png'),
    const CategoryModel(
        id: '3', name: 'Kidney', image: 'assets/imgs/categories/Kidney.png'),
    const CategoryModel(
        id: '4', name: 'Stomach', image: 'assets/imgs/categories/Stomach.png'),
    const CategoryModel(
        id: '5', name: 'Lung', image: 'assets/imgs/categories/Lung.png'),
    const CategoryModel(
        id: '6', name: 'Brain', image: 'assets/imgs/categories/brain.png'),
    const CategoryModel(
        id: '7',
        name: 'Pediatrics',
        image: 'assets/imgs/categories/Pediatrics.png'),
    const CategoryModel(
        id: '8', name: 'Liver', image: 'assets/imgs/categories/Liver.png'),
    const CategoryModel(
        id: '9', name: 'ENT', image: 'assets/imgs/categories/ENT.png'),
    const CategoryModel(
        id: '10',
        name: 'Ophthalmology',
        image: 'assets/imgs/categories/Ophthalmology.png'),
    const CategoryModel(
        id: '11',
        name: 'Orthopedics',
        image: 'assets/imgs/categories/Orthopedics.png'),
    const CategoryModel(
        id: '12',
        name: 'Gynecology',
        image: 'assets/imgs/categories/Gynecology.png'),
    const CategoryModel(
        id: '13',
        name: 'Dermatology',
        image: 'assets/imgs/categories/Dermatology.png'),
  ];

  final List<DoctorModel> bestDoctors = [
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
    DoctorModel(
      id: '4',
      name: 'Emily Davis',
      specialty: 'Pediatrician',
      rating: 4.7,
      reviews: 120,
      openTime: '09:00 am',
      closeTime: '05:00 pm',
      isFavorite: true,
      imageUrl: 'assets/imgs/doctor/doctor4.png',
    ),
    DoctorModel(
      id: '5',
      name: 'Michael Brown',
      specialty: 'Dermatologist',
      rating: 4.6,
      reviews: 145,
      openTime: '11:00 am',
      closeTime: '07:00 pm',
      isFavorite: false,
      imageUrl: 'assets/imgs/doctor/doctor5.png',
    ),
  ];

  final List<PharmacyModel> bestPharmacies = [
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
    PharmacyModel(
      id: '3',
      name: 'Care Pharmacy',
      type: 'Pharmacy | ABC Clinic',
      rating: 4.4,
      reviews: 92,
      openTime: '10:30 am',
      closeTime: '08:30 pm',
      isFavorite: false,
      imageUrl: 'assets/imgs/doctor/doctor4.png',
    ),
  ];
}
