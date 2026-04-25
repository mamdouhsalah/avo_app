import 'package:avo_app/app/core/constants/app_svg.dart';
import 'package:avo_app/app/features/payment/data/models/payment_method.dart';

List <PaymentMethod> paymentMethods = [
  PaymentMethod(name: 'Apple Pay', svgPath: AppSvg.applePay),
  PaymentMethod(name: 'Google Pay', svgPath: AppSvg.googlePay),
  PaymentMethod(name: 'MasterCard', svgPath: AppSvg.masterCard),
  PaymentMethod(name: 'Visa', svgPath: AppSvg.visa),
  PaymentMethod(name: 'PayPal', svgPath: AppSvg.paypal),
];