import 'dart:async';

import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/core/models/chatmodel.dart';
import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:avo_app/app/core/models/lab_result_model.dart';
import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:avo_app/app/core/models/timerange_model.dart';
import 'package:flutter/material.dart';

class DataRepository {
  static final List<DoctorModel> doctors = [
    DoctorModel(
      id: 'd1',
      name: 'Dr. David Brown',
      specialty: 'Cardiologist',
      hospital: 'Cairo Medical Center',
      rating: 4.8,
      reviews: 342,
      hourlyRate: 85.0,
      experience: 12,
      patientsTreated: 1250,
      openTime: '08:00 AM',
      closeTime: '08:00 PM',
      isFavorite: true,
      imageUrl: 'assets/imgs/doctor/doctor1.png',
    ),
    DoctorModel(
      id: 'd2',
      name: 'Dr. Sarah Ahmed',
      specialty: 'Pediatrician',
      hospital: 'Nile Hospital',
      rating: 4.9,
      reviews: 289,
      hourlyRate: 70.0,
      experience: 8,
      patientsTreated: 980,
      openTime: '09:00 AM',
      closeTime: '07:00 PM',
      isFavorite: false,
      imageUrl: 'assets/imgs/doctor/doctor2.png',
    ),
    DoctorModel(
      id: 'd3',
      name: 'Dr. Mohamed Hassan',
      specialty: 'Orthopedic Surgeon',
      hospital: 'Al Shifa Hospital',
      rating: 4.6,
      reviews: 175,
      hourlyRate: 95.0,
      experience: 15,
      patientsTreated: 750,
      openTime: '10:00 AM',
      closeTime: '06:00 PM',
      isFavorite: true,
      imageUrl: 'assets/imgs/doctor/doctor3.png',
    ),
  ];

  // ==================== Appointments Data ====================
  static final List<AppointmentModel> appointments = [
    // Upcoming
    AppointmentModel(
      id: 'app1',
      doctor: doctors[0],
      patient: DataRepository.patients[0],
      rating: 4.8,
      isFavorite: true,
      timeRange: TimeRange(
          start: const TimeOfDay(hour: 8, minute: 30),
          end: const TimeOfDay(hour: 9, minute: 0)),
      date: DateTime.now(),
    ),
    AppointmentModel(
      id: 'app2',
      doctor: doctors[1],
      patient: DataRepository.patients[1],
      rating: 4.9,
      isFavorite: false,
      timeRange: TimeRange(
          start: const TimeOfDay(hour: 11, minute: 0),
          end: const TimeOfDay(hour: 12, minute: 0)),
      date: DateTime.now(),
    ),
    AppointmentModel(
      id: 'app3',
      doctor: doctors[2],
      patient: DataRepository.patients[2],
      rating: 4.6,
      isFavorite: true,
      timeRange: TimeRange(
          start: const TimeOfDay(hour: 14, minute: 30),
          end: const TimeOfDay(hour: 15, minute: 30)),
      date: DateTime.now().add(const Duration(days: 1)),
    ),
    // Past
    AppointmentModel(
      id: 'app4',
      doctor: doctors[0],
      patient: DataRepository.patients[3],
      rating: 4.8,
      isFavorite: false,
      timeRange: TimeRange(
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 11, minute: 0)),
      date: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    AppointmentModel(
      id: 'app5',
      doctor: doctors[1],
      patient: DataRepository.patients[3],
      rating: 4.7,
      isFavorite: true,
      timeRange: TimeRange(
          start: const TimeOfDay(hour: 9, minute: 0),
          end: const TimeOfDay(hour: 10, minute: 0)),
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AppointmentModel(
      id: 'app6',
      doctor: doctors[2],
      patient: DataRepository.patients[4],
      rating: 4.5,
      isFavorite: false,
      timeRange: TimeRange(
          start: const TimeOfDay(hour: 15, minute: 0),
          end: const TimeOfDay(hour: 16, minute: 0)),
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  // ==================== Patients Data ====================
  static final List<PatientModel> patients = [
    PatientModel(
      id: 'p1',
      name: 'Ahmed Mohamed Ali',
      email: 'ahmed.mohamed@gmail.com',
      phone: '+20 112 345 6789',
      image: 'https://i.pravatar.cc/150?img=64',
      role: 'patient',
      isVerified: true,
      diagnosis: 'Heart Disease',
    ),
    PatientModel(
      id: 'p2',
      name: 'Sara Ahmed Hassan',
      email: 'sara.hassan@gmail.com',
      phone: '+20 100 987 6543',
      image: 'https://i.pravatar.cc/150?img=65',
      role: 'patient',
      isVerified: true,
      diagnosis: 'Back Pain',
    ),
    PatientModel(
      id: 'p3',
      name: 'Mohamed Khaled Ibrahim',
      email: 'mohamed.khaled@gmail.com',
      phone: '+20 155 667 8899',
      image: 'https://i.pravatar.cc/150?img=33',
      role: 'patient',
      isVerified: false,
      diagnosis: 'Tension Headache',
    ),
    PatientModel(
      id: 'p4',
      name: 'Nour El-Din Hassan',
      email: 'nour.hassan@gmail.com',
      phone: '+20 122 334 4556',
      image: 'https://i.pravatar.cc/150?img=44',
      role: 'patient',
      isVerified: true,
      diagnosis: 'Cataract',
    ),
    PatientModel(
      id: 'p5',
      name: 'Fatma Ali Mahmoud',
      email: 'fatma.ali@gmail.com',
      phone: '+20 109 876 5432',
      image: 'https://i.pravatar.cc/150?img=48',
      role: 'patient',
      isVerified: true,
      diagnosis: 'Gastritis',
    ),
    PatientModel(
      id: 'p6',
      name: 'Omar Youssef Reda',
      email: 'omar.youssef@gmail.com',
      phone: '+20 114 567 8901',
      image: 'https://i.pravatar.cc/150?img=55',
      role: 'patient',
      isVerified: false,
      diagnosis: 'Skin Allergy',
    ),
    PatientModel(
      id: 'p7',
      name: 'Laila Mostafa Kamal',
      email: 'laila.mostafa@gmail.com',
      phone: '+20 101 234 5678',
      image: 'https://i.pravatar.cc/150?img=66',
      role: 'patient',
      isVerified: true,
      diagnosis: 'Routine Checkup',
    ),
  ];

  static List<LabResultModel> labResults = [
    LabResultModel(
      id: "lr_001",
      title: "Prescription for Stomach Inflammation",
      patient: PatientModel(
        id: "p1",
        name: "Bedroo Mommes",
        email: "bedroo@example.com",
        phone: "+20123456789",
        role: "patient",
        diagnosis: "Stomach inflammation",
      ),
      doctor: DoctorModel(
        id: "d1",
        name: "Dr. Ahmed Hassan",
        specialty: "General Medicine",
        rating: 4.8,
        reviews: 124,
        openTime: "09:00",
        closeTime: "21:00",
      ),
      description: "Medical Prescription",
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      fileType: "pdf",
      typeAdd: "Manual",
      resultSummary: "Antibiotics + Pain relief medication",
      notes: "Take after meals",
    ),
    LabResultModel(
      id: "lr_002",
      title: "full body scan",
      patient: PatientModel(
        id: "p2",
        name: "Marvien Smoth",
        email: "marvien@example.com",
        phone: "+20109876543",
        role: "patient",
      ),
      doctor: DoctorModel(
        id: "d2",
        name: "Dr. Sara Khalid",
        specialty: "Radiology",
        rating: 4.9,
        reviews: 89,
        openTime: "10:00",
        closeTime: "18:00",
      ),
      description: "Full Body Scan",
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      fileType: "pdf",
      typeAdd: "AI",
      resultSummary: "No major abnormalities detected",
    ),
    LabResultModel(
      id: "lr_003",
      title: "Urine Analysis",
      patient: PatientModel(
        id: "p3",
        name: "Farhat Tegahr",
        email: "farhat@example.com",
        phone: "+20111223344",
        role: "patient",
      ),
      doctor: DoctorModel(
        id: "d3",
        name: "Dr. Mohamed Ali",
        specialty: "Urology",
        rating: 4.6,
        reviews: 67,
        openTime: "08:00",
        closeTime: "20:00",
      ),
      description: "Urine Analysis",
      dateTime: DateTime.now().subtract(const Duration(days: 4)),
      fileType: "pdf",
      typeAdd: "Manual",
    ),
    LabResultModel(
      id: "lr_004",
      title: "collagen percentage",
      patient: PatientModel(
        id: "p4",
        name: "Eproo Areif",
        email: "eproo@example.com",
        phone: "+20155667788",
        role: "patient",
        diagnosis: "Skin analysis",
      ),
      doctor: DoctorModel(
        id: "d4",
        name: "Dr. Lina Mostafa",
        specialty: "Dermatology",
        rating: 4.7,
        reviews: 156,
        openTime: "09:30",
        closeTime: "19:00",
      ),
      description: "Blood Test - Collagen Level",
      dateTime: DateTime.now().subtract(const Duration(days: 7)),
      fileType: "pdf",
      typeAdd: "AI",
      resultSummary: "Collagen level: 65% (Normal)",
    ),
    LabResultModel(
      id: "lr_005",
      title: "X-Ray Report",
      patient: PatientModel(
        id: "p5",
        name: "Jan Louse",
        email: "jan@example.com",
        phone: "+20199887766",
        role: "patient",
      ),
      doctor: DoctorModel(
        id: "d5",
        name: "Dr. Sara Khalid",
        specialty: "Radiology",
        rating: 4.9,
        reviews: 89,
        openTime: "10:00",
        closeTime: "18:00",
      ),
      description: "Chest & Shoulder X-Ray",
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      fileType: "xray",
      typeAdd: "Manual",
      resultSummary: "No fracture detected",
    ),
  ];

  static void addLabResult(LabResultModel newResult) {
    labResults.insert(0, newResult); // تضاف في الأول
  }

  static List<LabResultModel> searchResults(String query) {
    if (query.isEmpty) return labResults;
    return labResults.where((result) {
      return result.title.toLowerCase().contains(query.toLowerCase()) ||
          result.patientName.toLowerCase().contains(query.toLowerCase()) ||
          result.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}

class ChatRepository {
  static final ChatRepository _instance = ChatRepository._internal();
  factory ChatRepository() => _instance;
  ChatRepository._internal();

  final StreamController<List<ChatModel>> _chatsController =
      StreamController.broadcast();

  final StreamController<String> _errorController =
      StreamController.broadcast();

  // Cache the last emitted value so new listeners get it immediately
  List<ChatModel>? _lastEmittedChats;

  Stream<List<ChatModel>> get chatsStream async* {
    // Replay the last emitted value for new listeners
    if (_lastEmittedChats != null) {
      yield _lastEmittedChats!;
    }
    yield* _chatsController.stream;
  }

  Stream<String> get errorStream => _errorController.stream;

  List<ChatModel> _chats = [];

  void _emit() {
    _lastEmittedChats = List.from(_chats);
    _chatsController.add(_lastEmittedChats!);
  }

  void init() {
    _chats = [
      ChatModel(
        id: "chat_001",
        patient: DataRepository.patients[0],
        doctor: DataRepository.doctors[0],
        lastMessage: "Ok, see you later",
        lastMessageTime: DateTime.now(),
        unreadCount: 2,
        isOnline: true,
        lastMessageSender: "patient",
      ),
      ChatModel(
        id: "chat_002",
        patient: DataRepository.patients[1],
        doctor: DataRepository.doctors[1],
        lastMessage: "i don't remember anything 😊",
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 45)),
        lastMessageSender: "patient",
      ),
      ChatModel(
        id: "chat_003",
        patient: DataRepository.patients[2],
        doctor: DataRepository.doctors[2],
        lastMessage: "Table for four, 5PM. Be there.",
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
        lastMessageSender: "patient",
      ),
      ChatModel(
        id: "chat_004",
        patient: DataRepository.patients[3],
        doctor: DataRepository.doctors[2],
        lastMessage: "Tell mom i will be home for tea 💜",
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        lastMessageSender: "patient",
      ),
    ];

    _emit();
  }

  List<ChatModel> getAllChats() => List.from(_chats);

  ChatModel? getChatById(String chatId) {
    return _chats.cast<ChatModel?>().firstWhere(
          (chat) => chat?.id == chatId,
          orElse: () => null,
        );
  }

  int getChatCount() => _chats.length;

  Future<void> addNewChat(ChatModel chat) async {
    _chats.insert(0, chat);
    _emit();
  }

  Future<void> updateLastMessage({
    required String chatId,
    required String message,
    required String sender,
  }) async {
    final index = _chats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      _chats[index] = ChatModel(
        id: _chats[index].id,
        patient: _chats[index].patient,
        doctor: _chats[index].doctor,
        lastMessage: message,
        lastMessageTime: DateTime.now(),
        unreadCount: _chats[index].unreadCount + (sender == "patient" ? 1 : 0),
        isOnline: _chats[index].isOnline,
        lastMessageSender: sender,
      );
      _emit();
    }
  }

  Future<void> markChatAsRead(String chatId) async {
    final index = _chats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      _chats[index] = ChatModel(
        id: _chats[index].id,
        patient: _chats[index].patient,
        doctor: _chats[index].doctor,
        lastMessage: _chats[index].lastMessage,
        lastMessageTime: _chats[index].lastMessageTime,
        unreadCount: 0,
        isOnline: _chats[index].isOnline,
        lastMessageSender: _chats[index].lastMessageSender,
      );
      _emit();
    }
  }

  Future<void> deleteChat(String chatId) async {
    _chats.removeWhere((chat) => chat.id == chatId);
    _emit();
  }

  Future<void> updateOnlineStatus(String chatId, bool isOnline) async {
    final index = _chats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      _chats[index] = ChatModel(
        id: _chats[index].id,
        patient: _chats[index].patient,
        doctor: _chats[index].doctor,
        lastMessage: _chats[index].lastMessage,
        lastMessageTime: _chats[index].lastMessageTime,
        unreadCount: _chats[index].unreadCount,
        isOnline: isOnline,
        lastMessageSender: _chats[index].lastMessageSender,
      );
      _emit();
    }
  }

  void dispose() {
    _chatsController.close();
    _errorController.close();
  }
}