import 'package:flutter/material.dart';

class PaymentCardModel {
  final Color color;
  final String cardNumber;
  final String cardType;
  final String balance;
  final String holderName;
  bool isFront;

  PaymentCardModel({
    required this.color,
    required this.cardNumber,
    required this.cardType,
    this.balance = '\$12,480.50',
    this.holderName = 'Sofia Andro', // وحدنا الاسم هنا
    this.isFront = true,
  });
}