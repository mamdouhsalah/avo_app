import 'package:avo_app/app/features/payment/data/payment_card_model.dart';
import 'package:avo_app/app/features/auth/screens/create_account_screen.dart';
import 'package:avo_app/app/features/auth/screens/validation_code_screen.dart';
import 'package:avo_app/app/features/auth/screens/set_password_screen.dart';
import 'package:avo_app/app/features/payment/screens/add_card_screen.dart';
import 'package:avo_app/app/features/reminder/screens/add_medication_screen.dart';
import 'package:avo_app/app/core/layout/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// استدعاء الشاشات بتاعتك
import 'package:avo_app/app/features/splash/screens/splash_screen.dart';
import 'package:avo_app/app/features/onboard/screens/onboard_screen.dart';
import 'package:avo_app/app/features/auth/screens/login_screen.dart';
import 'package:avo_app/app/features/auth/screens/create_account_type_screen.dart';
import 'package:avo_app/app/features/auth/screens/reset_password_screen.dart';
import 'package:avo_app/app/features/home/view/screen/home_screen.dart';
import 'package:avo_app/app/features/home/view/screen/search_screen.dart';
import 'package:avo_app/app/features/reminder/screens/reminder_screen.dart';
import 'package:avo_app/app/features/reminder/screens/schedule_screen.dart';
import 'package:avo_app/app/features/chatbot/screens/chat_screen.dart';
import 'package:avo_app/app/features/profile/screens/profile_screen.dart';
import 'package:avo_app/app/features/profile/screens/account_info_screen.dart';
import 'package:avo_app/app/features/profile/screens/personal_info_screen.dart';
import 'package:avo_app/app/features/payment/screens/checkout_screen.dart';

class AppRouter {
  // 1. تعريف أسماء المسارات
  static const String splash = '/splash';
  static const String onboard = '/onboard';
  static const String login = '/login';
  static const String createAccountType = '/create-account-type';
  static const String resetPassword = '/reset-password';
  static const String createAccount = '/create-account';
  static const String validationCode = '/validation-code';
  static const String setPassword = '/set-password';

  static const String maps = '/maps';
  static const String schedule = '/schedule';
  static const String home = '/home';
  static const String reminder = '/reminder';
  static const String profile = '/profile';

  static const String search = '/search';
  static const String chat = '/chat';
  static const String checkout = '/checkout';
  static const String accountInfo = '/account-info';
  static const String personalInfo = '/personal-info';
  static const String addCard = '/add-card';
  static const String addMedication = '/add-medication';

  // 2. إعداد الـ Router
  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: onboard,
        builder: (context, state) => const OnboardScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: createAccountType,
        builder: (context, state) => const CreateAccountTypeScreen(),
      ),
      GoRoute(
        path: resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: createAccount,
        builder: (context, state) => const CreateAccountScreen(),
      ),
      GoRoute(
        path: validationCode,
        builder: (context, state) => const ValidationCodeScreen(),
      ),
      GoRoute(
        path: setPassword,
        builder: (context, state) => const SetPasswordScreen(),
      ),

      // ====== شاشات الـ Bottom Navigation Bar (ShellRoute) ======
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: maps,
            builder: (context, state) => const Center(child: Text("Maps Screen")),
          ),
          GoRoute(
            path: schedule,
            builder: (context, state) => const ScheduleScreen(),
          ),
          GoRoute(
            path: home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: reminder,
            builder: (context, state) => const ReminderScreen(),
          ),
          GoRoute(
            path: profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // ====== الشاشات الفرعية (Standalone Routes) ======
      GoRoute(
        path: search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: chat,
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: accountInfo,
        builder: (context, state) => AccountInfoScreen(),
      ),
      GoRoute(
        path: personalInfo,
        builder: (context, state) => const PersonalInfoScreen(),
      ),
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
        path: addMedication,
        builder: (context, state) => const AddMedicationScreen(),
      ),
    ],
  );

  // 3. دوال مساعدة للتنقل السريع (Navigation Helpers)
  static void goToCheckout(BuildContext context) => context.push(checkout);
  static void goToAccountInfo(BuildContext context) => context.push(accountInfo);
  static void goToPersonalInfo(BuildContext context) => context.push(personalInfo);
}