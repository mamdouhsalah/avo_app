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
  this.balance = '\$1000000',
    this.holderName = 'User Name',
    this.isFront = true,
  });


  factory PaymentCardModel.fromMap(Map<String, dynamic> map) {
    return PaymentCardModel(
      color: map['color'] as Color,
      cardNumber: map['cardNumber'] as String,
      cardType: map['cardType'] as String,
      isFront: map['isFront'] ?? true,
      balance: map['balance'] ?? '\$12,480.50', 
      holderName: map['holderName'] ?? 'DailyFlutterUI',
    );
  }
}