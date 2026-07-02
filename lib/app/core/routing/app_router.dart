import 'package:avo_app/app/core/models/appointment_action_arg.dart';
import 'package:avo_app/app/core/models/appointment_card_model.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/core/shared/app_exit_pop_scope.dart';
import 'package:avo_app/app/features/appointment/screens/appointment_patient_screen.dart';
import 'package:avo_app/app/features/doctor/view/screen/add_doctor_schedule/add_doctor_schedule_screen.dart';
import 'package:avo_app/app/features/doctor/services/add_doctor_cubit/add_doctor_cubit.dart';
import 'package:avo_app/app/features/doctor/data/doctor_repository_impl.dart';
import 'package:avo_app/app/features/doctor/view/screen/appointment_action.dart';
import 'package:avo_app/app/features/doctor/view/screen/specific_appointment_display.dart';
import 'package:avo_app/app/features/notification/view/screens/notification_screen.dart';
import 'package:avo_app/app/features/scanner/view/screens/scanner_screen.dart';
import 'package:avo_app/app/features/scanner/view/screens/saved_analysis_view_screen.dart';
import 'package:avo_app/app/features/scanner/view/screens/saved_analyses_list_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avo_app/app/features/book_patient/presentation/screens/book_patient_screen.dart';
import 'package:avo_app/app/features/book_patient/presentation/cubit/book_patient_cubit.dart';
import 'package:avo_app/app/features/book_patient/data/book_patient_repository_impl.dart';
import 'package:avo_app/app/features/reminder/logic/add_medication_cubit.dart';
import 'package:avo_app/app/features/schedule/logic/schedule_cubit.dart';
import 'package:avo_app/app/features/reminder/screens/schedule_screen.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer_impl.dart';
import 'package:avo_app/app/features/reminder/data/medication_log_repository.dart';
import 'package:avo_app/app/features/reminder/logic/analytics_cubit.dart';
import 'package:avo_app/app/features/reminder/screens/adherence_report_screen.dart';
import 'package:avo_app/app/core/layout/main_layout.dart';
import 'package:avo_app/app/core/models/chatmodel.dart';
import 'package:avo_app/app/features/admin/views/screen/admin_approvals_screen.dart';
import 'package:avo_app/app/features/admin/views/screen/admin_dashboard_screen.dart';
import 'package:avo_app/app/features/admin/views/screen/admin_logs_screen.dart';
import 'package:avo_app/app/features/admin/views/screen/admin_users_screen.dart';
import 'package:avo_app/app/features/auth/screens/create_account_type_screen.dart';
import 'package:avo_app/app/features/auth/screens/login_screen.dart';
import 'package:avo_app/app/features/auth/screens/reset_password_screen.dart';
import 'package:avo_app/app/features/auth/screens/set_password_screen.dart';
import 'package:avo_app/app/features/auth/screens/validation_code_screen.dart';
import 'package:avo_app/app/features/chatbot/screens/chatbot_screen.dart';
import 'package:avo_app/app/features/doctor/view/screen/analytics_screen.dart';
import 'package:avo_app/app/features/doctor/view/screen/appointment_screen.dart';
import 'package:avo_app/app/features/chats/view/screens/chats_screen.dart';
import 'package:avo_app/app/features/doctor/view/screen/dashboard_screen.dart';
import 'package:avo_app/app/features/chats/view/screens/user_details_screen.dart';
import 'package:avo_app/app/features/doctor/view/screen/labresult_screen.dart';
import 'package:avo_app/app/features/chats/view/screens/new_chat_screen.dart';
import 'package:avo_app/app/features/doctor/view/screen/patient_screen.dart';
import 'package:avo_app/app/features/doctor/view/screen/schedule_appointment_screen.dart';
import 'package:avo_app/app/features/chats/view/screens/chat_details_screen.dart';
import 'package:avo_app/app/features/chats/view/screens/audio_call_screen.dart';
import 'package:avo_app/app/features/home/view/screen/home_screen.dart';
import 'package:avo_app/app/features/home/view/screen/search_screen.dart';
import 'package:avo_app/app/features/payment/data/payment_card_model.dart';
import 'package:avo_app/app/features/payment/screens/add_card_screen.dart';
import 'package:avo_app/app/features/payment/screens/checkout_screen.dart';
import 'package:avo_app/app/features/profile/screens/account_info_screen.dart';
import 'package:avo_app/app/features/profile/screens/personal_info_screen.dart';
import 'package:avo_app/app/features/profile/screens/profile_screen.dart';
import 'package:avo_app/app/features/profile/screens/doctor_info_screen.dart';
import 'package:avo_app/app/features/reminder/screens/add_medication_screen.dart';
import 'package:avo_app/app/features/reminder/screens/reminder_screen.dart';
import 'package:avo_app/app/features/splash/screens/splash_screen.dart';
import 'package:avo_app/app/features/onboard/screens/onboard_screen.dart';
import 'package:avo_app/app/features/favorites/view/screens/favorites_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  // ==================== Routes Names ====================
  static const String splash = '/splash';
  static const String onboard = '/onboard';
  static const String login = '/login';
  static const String createAccountType = '/create-account-type';
  static const String createAccount = '/create-account';
  static const String validationCode = '/validation-code';
  static const String setPassword = '/set-password';
  static const String resetPassword = '/reset-password';

  // Doctor Features
  static const String dashboard = '/dashboard';
  static const String patients = '/patients';
  static const String appointments = '/appointments';
  static const String labResults = '/lab-results';
  static const String addSchedule = '/add-schedule';
  static const String schedule = '/schedule';
  static const String chats = '/chats';
  static const String doctorChats = '/doctor-chats';
  static const String newChat = '/new-chat';
  static const String analytics = '/analytics';
  static const String specificAppointmentDisplay = '/specific-appointment-display';
  // Other Features
  static const String home = '/home';
  static const String search = '/search';
  static const String reminder = '/reminder';
  static const String profile = '/profile';
  static const String profileFull = '/profile/full'; // بدون Bottom Nav
  static const String adherenceReport = '/adherence-report';

  static const String scanner = '/scanner';
  static const String savedAnalysis = '/saved-analysis';
  static const String savedAnalysisList = '/saved-analysis-list';

  static const String chatBot = '/chat-bot';
  static const String favorites = '/favorites';
  static const String checkout = '/checkout';
  static const String accountInfo = '/account-info';
  static const String personalInfo = '/personal-info';
  static const String doctorInfo = '/doctor-info';
  static const String bookPatient = '/book-patient';
  static const String addCard = '/add-card';
  static const String addMedication = '/add-medication';
  static const String detailsPatient = '/details-patient';
  static const String scheduleAppointment = '/schedule-appointment';
  static const String patientAppointment = '/patient-appointment';
  static const String appointmentAction = '/appointment-action';

  // Admin Routes
  static const String adminDashboard = '/admin-dashboard';
  static const String adminLogs = '/admin-logs';
  static const String adminApprovals = '/admin-approvals';
  static const String adminUsers = '/admin-users';
  static const String adminChats = '/admin-chats';
  static const String notifications = '/notifications';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      // ==================== Auth Routes ====================
      GoRoute(path: splash, builder: (context, state) => const SplashScreen()),
      GoRoute(
          path: onboard, builder: (context, state) => const OnboardScreen()),
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: createAccountType,
          builder: (context, state) => const CreateAccountTypeScreen()),
      GoRoute(
          path: validationCode,
          builder: (context, state) => const ValidationCodeScreen()),
      GoRoute(
          path: setPassword,
          builder: (context, state) => const SetPasswordScreen()),
      GoRoute(
          path: resetPassword,
          builder: (context, state) => const ResetPasswordScreen()),

      // ==================== Main Layout (With Bottom Navigation) ====================
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(path: scanner, builder: (context, state) => const ScannerScreen()),
          GoRoute(path: home, builder: (context, state) => AppExitPopScope(child: const HomeScreen())),
          GoRoute(
              path: reminder,
              builder: (context, state) => const ReminderScreen()),
          GoRoute(
            path: profile,
            builder: (context, state) => const ProfileScreen(
              showBottomNav: true,
              showAppBar: true,
              showDrawer: false,
            ),
          ),
          GoRoute(
            path: chats,
            builder: (context, state) => const ChatsScreen(isDoctor: false),
          ),
        ],
      ),
      GoRoute(
        path: appointmentAction,
        builder: (context, state) {
          final args = state.extra as AppointmentActionArgs;

          return AppointmentActionScreen(
            patient: args.patient,
            appointmentId: args.appointmentId,
            appointmentStatus: args.appointmentStatus,
          );
        },
      ),
      GoRoute(
        path: specificAppointmentDisplay,
        builder: (context, state) {
          final appointmentCards = state.extra as List<AppointmentCardModel>;
          return SpecificAppointmentDisplay(appointmentCards: appointmentCards);
        }
      ),
      // ==================== Full Screen Routes (بدون Bottom Navigation) ====================
      GoRoute(
          path: dashboard,
          builder: (context, state) => const DashboardScreen()),
      GoRoute(
          path: patients, builder: (context, state) => const PatientScreen()),
      GoRoute( // for doctor
          path: appointments,
          builder: (context, state) => const AppointmentScreen()),
      GoRoute(path:patientAppointment, builder: (context, state) => const AppointmentPatientScreen()),
      GoRoute(
          path: addSchedule,
          builder: (context, state) => BlocProvider(
                create: (context) => AddDoctorCubit(
                  repository: DoctorRepositoryImpl(
                    consumer: context.read<FirebaseConsumer>(),
                  ),
                )..loadSchedules(),
                child: const AddDoctorScheduleScreen(),
              )),
      GoRoute(
          path: labResults,
          builder: (context, state) => const LabresultScreen()),
      GoRoute(
          path: analytics,
          builder: (context, state) => const AnalyticsScreen()),
      GoRoute(
          path: doctorChats,
          builder: (context, state) => const ChatsScreen(isDoctor: true)),
      GoRoute(
          path: newChat, builder: (context, state) => const NewChatScreen()),
      GoRoute(
          path: scheduleAppointment,
          builder: (context, state) => const ScheduleAppointmentScreen()),

      // Profile Full Screen (بدون Bottom Nav)
      GoRoute(
        path: profileFull,
        builder: (context, state) => const ProfileScreen(
          showBottomNav: false,
          showAppBar: true,
          showDrawer: true,
        ),
      ),

      // Other Routes
      GoRoute(
        path: '/user-details',
        builder: (context, state) {
          final user = state.extra;
          return UserDetailsScreen(user: user);
        },
      ),
      GoRoute(
        path: '/chat-details',
        builder: (context, state) {
          final chat = state.extra as ChatModel;
          return ChatDetailsScreen(chat: chat);
        },
      ),
      GoRoute(
        path: '/audio-call',
        builder: (context, state) {
          final chat = state.extra as ChatModel;
          final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
          return AudioCallScreen(
            name: chat.otherUserName(currentUid),
            imageUrl: chat.otherUserImage(currentUid) ?? '',
          );
        },
      ),
      GoRoute(path: search, builder: (context, state) => const SearchScreen()),
      GoRoute(
          path: favorites,
          builder: (context, state) => const FavoritesScreen()),
      GoRoute(
        path: savedAnalysis,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return SavedAnalysisViewScreen(
            fileName: args['fileName'],
            file: args['file'],
            extractedText: args['extractedText'],
            analysisResult: args['analysisResult'],
          );
        },
      ),
      GoRoute(
          path: checkout, builder: (context, state) => const CheckoutScreen()),
      GoRoute(
          path: accountInfo, builder: (context, state) => AccountInfoScreen()),
      GoRoute(
          path: personalInfo,
          builder: (context, state) => const PersonalInfoScreen()),
      GoRoute(
          path: doctorInfo,
          builder: (context, state) {
            final docId = state.extra as String?;
            return DoctorInfoScreen(doctorId: docId);
          }),
      GoRoute(
          path: bookPatient,
          builder: (context, state) {
            final docId = state.extra as String?;
            return BlocProvider(
              create: (context) => BookPatientCubit(
                repository: BookPatientRepositoryImpl(
                  consumer: context.read<FirebaseConsumer>(),
                ),
              ),
              child: BookPatientScreen(doctorId: docId),
            );
          }),
      GoRoute(
        path: addCard,
        builder: (context, state) {
          final onCardAdded = state.extra as Function(PaymentCardModel)?;
          return AddCardScreen(
            onCardAdded: onCardAdded ?? (card) {},
          );
        },
      ),

      GoRoute(
        path: savedAnalysisList,
        builder: (context, state) => const SavedAnalysesListScreen(),
      ),

      GoRoute(
        path: addMedication,
        builder: (context, state) => BlocProvider(
          create: (_) => AddMedicationCubit(
            firebaseConsumer: FirebaseConsumerImpl(),
          ),
          child: const AddMedicationScreen(),
        ),
      ),

      // ── Schedule screen ("See All" from ReminderScreen) ──
      // Previously missing — would crash the app on navigation.
      GoRoute(
        path: schedule,
        builder: (context, state) => BlocProvider(
          create: (_) => ScheduleCubit(
            firebaseConsumer: FirebaseConsumerImpl(),
            logRepository: context.read<LogRepository>(),
          )..loadForDate(DateTime.now()),
          child: const ScheduleScreen(),
        ),
      ),
      GoRoute(
        path: adherenceReport,
        builder: (context, state) => BlocProvider(
          create: (_) => AnalyticsCubit(
            logRepository: context.read<LogRepository>(),
          ),
          child: const AdherenceReportScreen(),
        ),
      ),
      GoRoute(
          path: chatBot, builder: (context, state) => const ChatBotScreen()),
      GoRoute(
          path: notifications,
          builder: (context, state) => const NotificationScreen()),

      // ==================== Admin Routes ====================
      GoRoute(
          path: adminDashboard,
          builder: (context, state) => const AdminDashboardScreen()),
      GoRoute(
          path: adminLogs,
          builder: (context, state) => const AdminLogsScreen()),
      GoRoute(
          path: adminApprovals,
          builder: (context, state) => const AdminApprovalsScreen()),
      GoRoute(
          path: adminUsers,
          builder: (context, state) => const AdminUsersScreen()),
      GoRoute(
          path: adminChats,
          builder: (context, state) => const ChatsScreen(isAdmin: true)),
    ],
  );

  // ==================== Navigation Helpers ====================
  static void goToProfile(BuildContext context, {bool fullScreen = false}) {
    if (fullScreen) {
      context.push(profileFull);
    } else {
      context.push(profile);
    }
  }

  static void goToDashboard(BuildContext context) => context.go(dashboard);
  static void goToPatients(BuildContext context) => context.go(patients);
  static void goToAppointments(BuildContext context) =>
      context.go(appointments);
  static void goToLabResults(BuildContext context) => context.go(labResults);
  static void goToChats(BuildContext context) => context.go(chats);
  static void goToDoctorChats(BuildContext context) => context.go(doctorChats);
  static void goToAnalytics(BuildContext context) => context.go(analytics);
  static void goToNewChat(BuildContext context) => context.go(newChat);
  static void goToAdminDashboard(BuildContext context) =>
      context.go(adminDashboard);
}