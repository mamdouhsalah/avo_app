import 'package:easy_localization/easy_localization.dart';
import '../../../core/Language/locale_keys.g.dart';

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

  String get formattedCard => LocaleKeys.payment_formatted_card.tr(namedArgs: {
    'cardType': cardType,
    'digits': lastFourDigits,
  });

  String get formattedDate {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}