
// Sample data

import 'package:avo_app/app/core/constants/app_imgs.dart';
import 'package:avo_app/app/features/appointment/data/models/appointment.dart';

final List<Appointment> upcomingAppointments = [
    Appointment(
      id: 1,
      doctorName: 'Dr. Jason Smith',
      doctorPictureUrl: AppImgs.doctor,
      specialty: 'Dentist',
      clinic: 'Cedar Dental Care',
      rating: 4.8,
      date: DateTime.now(),
      timeStart: '10:30 AM',
      timeEnd: '11:30 AM',
      status: AppointmentStatus.upcoming,
      isFavorite: true,
      
    ),
    Appointment(
      id: 2,
      doctorName: 'Dr. Melisa Josef',
      doctorPictureUrl: AppImgs.doctor,
      specialty: 'Pediatrician',
      clinic: 'Mercy Hospital',
      rating: 4.2,
      date: DateTime.now().add(Duration(days: 1)),
      timeStart: '2:00 PM',
      timeEnd: '3:00 PM',
      status: AppointmentStatus.upcoming,
      isFavorite: false,
    ),
    Appointment(
      id: 3,
      doctorName: 'Dr. Johnson Robert',
      doctorPictureUrl: AppImgs.doctor, 
      specialty: 'Radiology Specialist',
      clinic: 'ABC Hospital',
      rating: 4.9,
      date: DateTime.now().add(Duration(days: 2)),
      timeStart: '9:30 AM',
      timeEnd: '10:30 AM',
      status: AppointmentStatus.upcoming,
      isFavorite: true,
    ),
    Appointment(
      id: 4,
      doctorName: 'Dr. Sarah Williams',
      doctorPictureUrl: AppImgs.doctor,
      specialty: 'Cardiologist',
      clinic: 'Heart Center Medical',
      rating: 4.7,
      date: DateTime.now().add(Duration(days: 3)),
      timeStart: '11:00 AM',
      timeEnd: '12:00 PM',
      status: AppointmentStatus.upcoming,
      isFavorite: false,
    ),
  ];

  final List<Appointment> completedAppointments = [
    Appointment(
      id: 5,
      doctorName: 'Dr. Emily Parker',
      doctorPictureUrl: AppImgs.doctor,
      specialty: 'Dermatologist',
      clinic: 'Skin Health Center',
      rating: 4.8,
      date: DateTime.now().add(Duration(days: 4)),
      timeStart: '10:00 AM',
      timeEnd: '10:45 AM',
      status: AppointmentStatus.completed,
      isFavorite: false,
    ),
    Appointment(
      id: 6,
      doctorName: 'Dr. David Miller',
      doctorPictureUrl: AppImgs.doctor,
      specialty: 'Orthopedic',
      clinic: 'Bone & Joint Clinic',
      rating: 4.6,
      date: DateTime.now().add(Duration(days: 5)),
      timeStart: '2:30 PM',
      timeEnd: '3:30 PM',
      status: AppointmentStatus.completed,
      isFavorite: true,
    ),
  ];

  final List<Appointment> canceledAppointments = [
    Appointment(
      id: 7,
      doctorName: 'Dr. Lisa Anderson',
      doctorPictureUrl: AppImgs.doctor,
      specialty: 'Gynecologist',
      clinic: "Women's Health Center",
      rating: 4.5,
      date: DateTime.now().add(Duration(days: 6)),
      timeStart: '9:00 AM',
      timeEnd: '10:00 AM',
      status: AppointmentStatus.canceled,
      isFavorite: false,
    ),
    Appointment(
      id: 8,
      doctorName: 'Dr. Robert Taylor',
      doctorPictureUrl: AppImgs.doctor,
      specialty: 'ENT Specialist',
      clinic: 'Hear & ENT Clinic',
      rating: 4.7,
      date: DateTime.now().add(Duration(days: 7)),
      timeStart: '1:00 PM',
      timeEnd: '1:45 PM',
      status: AppointmentStatus.canceled,
      isFavorite: true,
    ),
  ];
