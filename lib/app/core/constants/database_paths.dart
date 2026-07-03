class DatabasePaths {
  static const String users = 'users';
  static const String doctors = 'doctors';
  static const String patients = 'patients';
  static const String appointments = 'appointments';
  static const String medicines = 'medicines';
  static String patientMedicines(String patientId) => 'medicines/$patientId';
  static const String categories = 'categories';
  static const String pharmacies = 'pharmacies';
  static const String notifications = 'notifications';
  static const String reviews = 'reviews';
  static const String reports = 'reports';
  static const String messages = 'messages';
  static const String chatrooms = 'chatrooms';
  static const String schedules = 'schedules';
  static const String pharmacyOrders = 'pharmacy_orders';

  // doctor Schedule
  static String doctorSchedule(String doctorId) => 'schedules/$doctorId';

  // Admin
  static const String logs = 'logs';
  static const String pendingApprovals = 'pending_approvals';
}