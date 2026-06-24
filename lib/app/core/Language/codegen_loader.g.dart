// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes, avoid_renaming_method_parameters, constant_identifier_names

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> _ar = {
  "chatbot": {
    "chatbot_title": "مساعد أفو",
    "chatbot_online": "متصل",
    "bot_welcome_msg": "أهلاً! أنا مساعد أفو. إزاي أقدر أساعدك في صحتك النهاردة؟"
  },
  "shared": {
    "save": "حفظ",
    "cancel": "إلغاء",
    "done": "تم"
  },
  "auth": {
    "create_account": "إنشاء حساب",
    "choose_role": "اختر دورك لإنشاء حسابك.",
    "create_desc": "أنشئ حسابك لتجربة رعاية صحية سلسة",
    "doctor": "طبيب",
    "patient": "مريض",
    "radiology_specialist": "أخصائي أشعة",
    "pharmacy_specialist": "أخصائي صيدلة",
    "laboratory_specialist": "أخصائي مختبر",
    "continue": "استمرار",
    "sign_up": "تسجيل",
    "full_name": "الاسم الكامل",
    "email": "البريد الإلكتروني",
    "phone": "الهاتف",
    "gender": "الجنس",
    "male": "ذكر",
    "female": "أنثى",
    "height": "الطول (سم)",
    "weight": "الوزن (كجم)",
    "dob": "تاريخ الميلاد",
    "password": "كلمة المرور",
    "confirm_password": "تأكيد كلمة المرور",
    "full_name_hint": "أدخل اسمك الكامل",
    "email_hint": "أدخل بريدك الإلكتروني",
    "phone_hint": "أدخل رقم هاتفك",
    "height_hint": "الطول",
    "weight_hint": "الوزن",
    "dob_hint": "يوم / شهر / سنة",
    "password_hint": "أدخل كلمة المرور",
    "confirm_password_hint": "أكد كلمة المرور الخاصة بك",
    "welcome_back": "مرحباً بك مجدداً",
    "sign_in_desc": "سجل دخولك للمتابعة",
    "forgot_password": "هل نسيت كلمة المرور؟",
    "login": "تسجيل الدخول",
    "or_continue_with": "أو المتابعة باستخدام",
    "new_to_avo": "جديد في أفو؟ ",
    "create_an_account": "أنشئ حساباً",
    "error_invalid_credentials": "البريد الإلكتروني أو كلمة المرور غير صحيحة",
    "error_select_role": "يرجى تحديد دور",
    "error_invalid_name": "يرجى إدخال اسم صحيح",
    "error_invalid_email": "يرجى إدخال بريد إلكتروني صحيح",
    "error_invalid_phone": "يرجى إدخال رقم هاتف صحيح",
    "error_select_gender": "يرجى اختيار الجنس",
    "error_invalid_height": "يرجى إدخال طول صحيح",
    "error_invalid_weight": "يرجى إدخال وزن صحيح",
    "error_select_dob": "يرجى تحديد تاريخ ميلادك",
    "error_invalid_password": "يجب أن تكون كلمة المرور 6 أحرف على الأقل",
    "error_password_mismatch": "كلمتا المرور غير متطابقتين",
    "error_need_verification": "حسابك غير مفعل، يرجى التحقق من بريدك الإلكتروني أولاً",
    "reset_email_sent": "تم إرسال بريد إعادة تعيين كلمة المرور بنجاح، يرجى التحقق من بريدك الإلكتروني",
    "forgot_password_appbar": "نسيت كلمة المرور",
    "forgot_password_title": "هل نسيت كلمة مرورك؟",
    "forgot_password_subtitle": "أدخل البريد الإلكتروني المرتبط بحسابك وسنرسل لك رابطاً لإعادة تعيين كلمة المرور.",
    "send_code": "إرسال الرابط"
  }
};
static const Map<String,dynamic> _en = {
  "chatbot": {
    "chatbot_title": "AVO Assistant",
    "chatbot_online": "Online",
    "bot_welcome_msg": "Hello! I am AVO Bot. How can I assist you with your health today?"
  },
  "shared": {
    "save": "Save",
    "cancel": "Cancel",
    "done": "Done"
  },
  "auth": {
    "create_account": "Create Account",
    "choose_role": "Choose your role to create your account.",
    "create_desc": "Create your account for a seamless healthcare experience",
    "doctor": "Doctor",
    "patient": "Patient",
    "radiology_specialist": "Radiology Specialist",
    "pharmacy_specialist": "Pharmacy Specialist",
    "laboratory_specialist": "Laboratory Specialist",
    "continue": "Continue",
    "sign_up": "Sign Up",
    "full_name": "Full name",
    "email": "Email",
    "phone": "Phone",
    "gender": "Gender",
    "male": "Male",
    "female": "Female",
    "height": "Height (CM)",
    "weight": "Weight (KG)",
    "dob": "Date of Birth",
    "password": "Password",
    "confirm_password": "Confirm Password",
    "full_name_hint": "Enter your full name",
    "email_hint": "Enter your email",
    "phone_hint": "Enter your Phone Number",
    "height_hint": "Height",
    "weight_hint": "Weight",
    "dob_hint": "DD / MM / YY",
    "password_hint": "Enter your password",
    "confirm_password_hint": "Confirm Your Password",
    "welcome_back": "Welcome Back",
    "sign_in_desc": "Sign in to continue",
    "forgot_password": "Forgot Password?",
    "login": "Login",
    "or_continue_with": "Or continue with",
    "new_to_avo": "New to AVO? ",
    "create_an_account": "Create an account",
    "error_invalid_credentials": "Invalid email or password",
    "error_select_role": "Please select a role",
    "error_invalid_name": "Please enter a valid name",
    "error_invalid_email": "Please enter a valid email address",
    "error_invalid_phone": "Please enter a valid phone number",
    "error_select_gender": "Please select a gender",
    "error_invalid_height": "Please enter a valid height",
    "error_invalid_weight": "Please enter a valid weight",
    "error_select_dob": "Please select your date of birth",
    "error_invalid_password": "Password must be at least 6 characters",
    "error_password_mismatch": "Passwords do not match",
    "error_need_verification": "Your account is not verified. check your email to verify.",
    "reset_email_sent": "Reset Password Email Sent Successfully, check your email to reset your password",
    "forgot_password_appbar": "Forgot Password",
    "forgot_password_title": "Forgot your password?",
    "forgot_password_subtitle": "Enter the email address associated with your account and we will send you a verification code.",
    "send_code": "Send Code"
  }
};
static const Map<String, Map<String,dynamic>> mapLocales = {"ar": _ar, "en": _en};
}
