import 'package:easy_localization/easy_localization.dart';

import '../Language/locale_keys.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Day Localizer
// ─────────────────────────────────────────────────────────────────────────────
//
// ARCHITECTURE RULE:
//   ✅  The DATABASE (Hive / Firebase) always stores the ENGLISH day name.
//       e.g.  'Saturday', 'Sunday', 'Monday', …
//
//   ✅  The UI calls [translateDay] / [translateDayShort] to display a
//       locale-aware string.  Never pass the translated string back to the DB.
//
//   ✅  Cubits use [weekdayToEnglish] to convert DateTime.weekday → the
//       canonical English key used for DB queries.
//
// ─────────────────────────────────────────────────────────────────────────────

/// Maps [DateTime.weekday] (1 = Monday … 7 = Sunday) to the canonical
/// English day name stored in Hive / Firebase.
///
/// Use this in Cubits/repositories — never the Arabic equivalent.
String weekdayToEnglish(int weekday) {
  const map = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };
  return map[weekday] ?? 'Monday';
}

/// Returns all 7 English day names in calendar order (Saturday-first,
/// matching [StartingDayOfWeek.sunday] / the Middle-East calendar convention).
const List<String> kAllEnglishDays = [
  'Saturday',
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
];

/// Translates an English day key (from the DB) into the current locale's
/// full day name for display in the UI.
///
/// Example (AR):  translateDay('Saturday') → 'السبت'
/// Example (EN):  translateDay('Saturday') → 'Saturday'
String translateDay(String englishDayKey) {
  switch (englishDayKey) {
    case 'Monday':
      return LocaleKeys.days_monday.tr();
    case 'Tuesday':
      return LocaleKeys.days_tuesday.tr();
    case 'Wednesday':
      return LocaleKeys.days_wednesday.tr();
    case 'Thursday':
      return LocaleKeys.days_thursday.tr();
    case 'Friday':
      return LocaleKeys.days_friday.tr();
    case 'Saturday':
      return LocaleKeys.days_saturday.tr();
    case 'Sunday':
      return LocaleKeys.days_sunday.tr();
    default:
      return englishDayKey; // Fallback: return as-is
  }
}

/// Helper function to convert legacy Arabic day names back to English keys
/// for backward compatibility during Firebase Sync.
String mapDayToEnglish(String day) {
  switch (day.trim()) {
    case 'السبت':
      return 'Saturday';
    case 'الأحد':
      return 'Sunday';
    case 'الاثنين':
    case 'الإثنين':
      return 'Monday';
    case 'الثلاثاء':
      return 'Tuesday';
    case 'الأربعاء':
      return 'Wednesday';
    case 'الخميس':
      return 'Thursday';
    case 'الجمعة':
      return 'Friday';
    default:
      return day; // Already English or unknown
  }
}

/// Translates an English day key into the current locale's *abbreviated*
/// day name — used in bar-chart labels and compact calendar headers.
///
/// Example (AR):  translateDayShort('Saturday') → 'سبت'
/// Example (EN):  translateDayShort('Saturday') → 'Sat'
String translateDayShort(String englishDayKey) {
  switch (englishDayKey) {
    case 'Monday':
      return LocaleKeys.days_monday_short.tr();
    case 'Tuesday':
      return LocaleKeys.days_tuesday_short.tr();
    case 'Wednesday':
      return LocaleKeys.days_wednesday_short.tr();
    case 'Thursday':
      return LocaleKeys.days_thursday_short.tr();
    case 'Friday':
      return LocaleKeys.days_friday_short.tr();
    case 'Saturday':
      return LocaleKeys.days_saturday_short.tr();
    case 'Sunday':
      return LocaleKeys.days_sunday_short.tr();
    default:
      return englishDayKey.length > 3
          ? englishDayKey.substring(0, 3)
          : englishDayKey;
  }
}

/// Translates a month number (1–12) into the current locale's full month name.
///
/// Example (AR):  translateMonth(6) → 'يونيو'
/// Example (EN):  translateMonth(6) → 'June'
String translateMonth(int month) {
  switch (month) {
    case 1:
      return LocaleKeys.months_january.tr();
    case 2:
      return LocaleKeys.months_february.tr();
    case 3:
      return LocaleKeys.months_march.tr();
    case 4:
      return LocaleKeys.months_april.tr();
    case 5:
      return LocaleKeys.months_may.tr();
    case 6:
      return LocaleKeys.months_june.tr();
    case 7:
      return LocaleKeys.months_july.tr();
    case 8:
      return LocaleKeys.months_august.tr();
    case 9:
      return LocaleKeys.months_september.tr();
    case 10:
      return LocaleKeys.months_october.tr();
    case 11:
      return LocaleKeys.months_november.tr();
    case 12:
      return LocaleKeys.months_december.tr();
    default:
      return '$month';
  }
}
