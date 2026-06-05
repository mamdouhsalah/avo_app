import 'package:avo_app/app/features/payment/data/payment_summary_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentSuccessSheet extends StatelessWidget {
  const PaymentSuccessSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // الداتا اللي هتتعرض في الشيت
    final summary = PaymentSummary(
      amount: 249.00,
      cardType: "VISA",
      lastFourDigits: "3456",
      date: DateTime.now(),
    );

    return Container(
      // 🔥 1. شيلنا الـ height الثابت من هنا عشان الشيت ياخد راحته
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      // 🔥 2. ضفنا SingleChildScrollView عشان لو الشاشة صغيرة اليوزر يقدر يعمل سكرول
      child: SingleChildScrollView(
        child: SafeArea( // بيحمي المحتوى من النوتش أو الزراير السفلية
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20), // مسافة أمان من تحت
            child: Column(
              mainAxisSize: MainAxisSize.min, // 🔥 3. بتخلي الكولوم ياخد المساحة المطلوبة بس
              children: [
                const SizedBox(height: 15),
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.green.shade500,
                  child: const Icon(Icons.check, color: Colors.white, size: 50),
                ),
                const SizedBox(height: 25),
                Text(
                  "Payment Successful",
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Your payment has been processed",
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                ),
                const SizedBox(height: 40),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      _buildRow(context, "Amount", "\$${summary.amount.toStringAsFixed(2)}"),
                      const SizedBox(height: 15),
                      _buildRow(context, "Card", summary.formattedCard),
                      const SizedBox(height: 15),
                      _buildRow(context, "Date", summary.formattedDate),
                    ],
                  ),
                ),

                // 🔥 4. شيلنا الـ Spacer وحطينا مسافة ثابتة عشان تتوافق مع السكرول
                const SizedBox(height: 40),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () => context.pop(),
                      child: Text(
                        "Done",
                        style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
        Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}