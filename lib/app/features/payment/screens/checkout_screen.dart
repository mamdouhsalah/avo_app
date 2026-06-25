import 'dart:math';
import 'dart:ui' as ui;
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/features/payment/data/payment_card_model.dart';
import 'package:avo_app/app/features/payment/screens/payment_success_sheet.dart';
import 'package:easy_localization/easy_localization.dart'; // 🔥 الترجمة
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/Language/locale_keys.g.dart'; // 🔥 الـ LocaleKeys

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedMethod = "PayPal";
  final PageController _pageController = PageController(viewportFraction: 0.85);

  // لستة الكروت الافتراضية
  List<PaymentCardModel> cards = [
    PaymentCardModel(
      color: const Color(0xFF21468B),
      cardNumber: "4242 5678 9012 3456",
      cardType: "VISA",
    ),
    PaymentCardModel(
      color: const Color(0xFF5E2D91),
      cardNumber: "5555 4444 3333 2222",
      cardType: "Mastercard",
    ),
    PaymentCardModel(
      color: const Color(0xFF00707B),
      cardNumber: "3782 8224 6310 005",
      cardType: "AMEX",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Transform.flip(
            flipX: context.locale.languageCode == 'ar',
            child: Icon(
              Icons.arrow_back_ios,
              color: theme.iconTheme.color,
              size: 20,
            ),
          ),
        ),
        title: Text(
          LocaleKeys.payment_checkout.tr(), // 🔥 ترجمة
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LocaleKeys.payment_your_cards.tr(), // 🔥 ترجمة
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      context.push(
                        AppRouter.addCard,
                        extra: (newCard) {
                          setState(() {
                            cards.add(newCard as PaymentCardModel);
                          });
                        },
                      );
                    },
                    icon: Icon(Icons.add, size: 18, color: theme.colorScheme.primary),
                    label: Text(
                      LocaleKeys.payment_add_card.tr(), // 🔥 ترجمة
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        cards[index].isFront = !cards[index].isFront;
                      });
                    },
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(
                        begin: 0,
                        end: cards[index].isFront ? 0 : pi,
                      ),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, double value, child) {
                        return Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(value),
                          alignment: Alignment.center,
                          child: value < pi / 2
                              ? Stack(
                            children: [
                              buildCreditCard(
                                color: cards[index].color,
                                cardNumber: cards[index].cardNumber,
                                cardType: cards[index].cardType,
                                balance: cards[index].balance,
                                holderName: cards[index].holderName,
                              ),
                              Positioned(
                                top: 20,
                                right: 20,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      cards.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          )
                              : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(pi),
                            child: buildCreditCardBack(color: cards[index].color),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                LocaleKeys.payment_other_methods.tr(), // 🔥 ترجمة
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            buildPaymentOption(context, LocaleKeys.payment_paypal.tr(), "dailyflutterui@example.com", Icons.paypal, Colors.blue), // 🔥 ترجمة
            buildPaymentOption(context, LocaleKeys.payment_apple_pay.tr(), LocaleKeys.payment_connected.tr(), Icons.apple, theme.iconTheme.color!), // 🔥 ترجمة
            buildPaymentOption(context, LocaleKeys.payment_bank_transfer.tr(), "085 - **** - 222", Icons.account_balance, theme.iconTheme.color!), // 🔥 ترجمة
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: buildBottomPaySection(context),
    );
  }

  Widget buildCreditCard({
    required Color color,
    required String cardNumber,
    required String cardType,
    required String balance,
    required String holderName,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(LocaleKeys.payment_balance.tr(), style: const TextStyle(color: Colors.white70, fontSize: 12)), // 🔥 ترجمة
              Text(
                balance,
                // 🔥 تأكيد اتجاه الأرقام من الشمال لليمين حتى في العربي
                textDirection: ui.TextDirection.ltr,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
              cardNumber,
              textDirection: ui.TextDirection.ltr,
              style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2)
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(holderName, style: const TextStyle(color: Colors.white70)),
              Text(
                cardType,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCreditCardBack({required Color color}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(height: 45, color: Colors.black87),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 35,
              color: Colors.white70,
              alignment: Alignment.centerRight, // 💡 خليناها يمين عشان الـ CVV دايماً يمين
              child: const Text("CVV 123 ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), textDirection: ui.TextDirection.ltr),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPaymentOption(BuildContext context, String title, String subtitle, IconData icon, Color iconColor) {
    final theme = Theme.of(context);
    bool isSelected = selectedMethod == title;
    return GestureDetector(
      onTap: () => setState(() => selectedMethod = title),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.05) : theme.cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor), textDirection: ui.TextDirection.ltr), // 🔥
                ],
              ),
            ),
            Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomPaySection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(LocaleKeys.payment_total_price.tr(), style: TextStyle(color: theme.hintColor)), // 🔥 ترجمة
              Text(
                "\$249.00",
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textDirection: ui.TextDirection.ltr, // 🔥
              ),
            ],
          ),

          const SizedBox(width: 20),

          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _showConfirmationDialog(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 50),
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                LocaleKeys.payment_pay_now.tr(), // 🔥 ترجمة زر الدفع وسهمه
                style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(LocaleKeys.payment_confirm_payment.tr(), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), // 🔥
          content: Text(
              LocaleKeys.payment_confirm_msg.tr(namedArgs: {'amount': '\$249.00'}), // 🔥 ترجمة مع تمرير المبلغ
              style: theme.textTheme.bodyMedium
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text(LocaleKeys.general_cancel.tr(), style: TextStyle(color: theme.hintColor)), // 🔥 المشترك
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                context.pop();
                _showSuccessSheet(context);
              },
              child: Text(LocaleKeys.payment_confirm.tr(), style: TextStyle(color: theme.colorScheme.onPrimary)), // 🔥 ترجمة
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PaymentSuccessSheet(),
    );
  }
}