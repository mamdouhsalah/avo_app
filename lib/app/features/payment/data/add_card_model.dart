import 'package:flutter/material.dart';

class CardModel {
  final String cardNumber;
  final String cardType;
  final String cardHolderName;
  final String expiryDate;
  final double balance;
  final Color cardColor;

  CardModel({
    required this.cardNumber,
    required this.cardType,
    required this.cardHolderName,
    required this.expiryDate,
    required this.balance,
    required this.cardColor,
  });
}

class PaymentMethod {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  PaymentMethod({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });
}