class PaymentSummary {
  final double amount;
  final String cardType;
  final String lastFourDigits;
  final DateTime date;

  PaymentSummary({
    required this.amount,
    required this.cardType,
    required this.lastFourDigits,
    required this.date,
  });

  String get formattedCard => "$cardType **** $lastFourDigits";

  String get formattedDate {
    return "${_getMonthName(date.month)} ${date.day.toString().padLeft(2, '0')}, ${date.year}";
  }

  String _getMonthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }
}