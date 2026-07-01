
int getWeekdayNumber(String dayName) {
  switch (dayName.trim().toLowerCase()) {
    case 'monday': return DateTime.monday;
    case 'tuesday': return DateTime.tuesday;
    case 'wednesday': return DateTime.wednesday;
    case 'thursday': return DateTime.thursday;
    case 'friday': return DateTime.friday;
    case 'saturday': return DateTime.saturday;
    case 'sunday': return DateTime.sunday;
    default: return DateTime.monday;
  }
}

DateTime calculateNextDateForWeekday(String dayName) {
  final today = DateTime.now();
  final todayWeekday = today.weekday;
  final targetWeekday = getWeekdayNumber(dayName);
  
  int daysToAdd = targetWeekday - todayWeekday;
  if (daysToAdd < 0) {
    daysToAdd += 7;
  }
  
  return today.add(Duration(days: daysToAdd));
}

String formatCalculationDate(DateTime date) {
  final dayStr = date.day.toString().padLeft(2, '0');
  final monthStr = date.month.toString().padLeft(2, '0');
  final yearStr = date.year.toString();
  return '$dayStr/$monthStr/$yearStr';
}
