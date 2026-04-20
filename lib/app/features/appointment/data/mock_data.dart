
// Sample data

  import 'package:avo_app/app/features/appointment/data/models/appointment.dart';

final List<Appointment> upcomingAppointments = [
    Appointment(
      id: '1',
      doctorName: 'Dr. Jason Smith',
      specialty: 'Dentist',
      clinic: 'Cedar Dental Care',
      rating: 4.8,
      date: 'Today',
      timeStart: '10:30 AM',
      timeEnd: '11:30 AM',
      status: AppointmentStatus.upcoming,
    ),
    Appointment(
      id: '2',
      doctorName: 'Dr. Melisa Josef',
      specialty: 'Pediatrician',
      clinic: 'Mercy Hospital',
      rating: 4.2,
      date: 'Tomorrow',
      timeStart: '2:00 PM',
      timeEnd: '3:00 PM',
      status: AppointmentStatus.upcoming,
    ),
    Appointment(
      id: '3',
      doctorName: 'Dr. Johnson Robert',
      specialty: 'Radiology Specialist',
      clinic: 'ABC Hospital',
      rating: 4.9,
      date: 'Apr 20, 2026',
      timeStart: '9:30 AM',
      timeEnd: '10:30 AM',
      status: AppointmentStatus.upcoming,
    ),
    Appointment(
      id: '4',
      doctorName: 'Dr. Sarah Williams',
      specialty: 'Cardiologist',
      clinic: 'Heart Center Medical',
      rating: 4.7,
      date: 'Apr 22, 2026',
      timeStart: '11:00 AM',
      timeEnd: '12:00 PM',
      status: AppointmentStatus.upcoming,
    ),
  ];

  final List<Appointment> completedAppointments = [
    Appointment(
      id: '5',
      doctorName: 'Dr. Emily Parker',
      specialty: 'Dermatologist',
      clinic: 'Skin Health Center',
      rating: 4.8,
      date: 'Apr 10, 2026',
      timeStart: '10:00 AM',
      timeEnd: '10:45 AM',
      status: AppointmentStatus.completed,
    ),
    Appointment(
      id: '6',
      doctorName: 'Dr. David Miller',
      specialty: 'Orthopedic',
      clinic: 'Bone & Joint Clinic',
      rating: 4.6,
      date: 'Apr 5, 2026',
      timeStart: '2:30 PM',
      timeEnd: '3:30 PM',
      status: AppointmentStatus.completed,
    ),
  ];

  final List<Appointment> canceledAppointments = [
    Appointment(
      id: '7',
      doctorName: 'Dr. Lisa Anderson',
      specialty: 'Gynecologist',
      clinic: "Women's Health Center",
      rating: 4.5,
      date: 'Apr 8, 2026',
      timeStart: '9:00 AM',
      timeEnd: '10:00 AM',
      status: AppointmentStatus.canceled,
    ),
    Appointment(
      id: '8',
      doctorName: 'Dr. Robert Taylor',
      specialty: 'ENT Specialist',
      clinic: 'Hear & ENT Clinic',
      rating: 4.7,
      date: 'Apr 12, 2026',
      timeStart: '1:00 PM',
      timeEnd: '1:45 PM',
      status: AppointmentStatus.canceled,
    ),
  ];
