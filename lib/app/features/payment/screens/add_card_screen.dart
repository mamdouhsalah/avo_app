import 'package:avo_app/app/features/payment/data/payment_card_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/Language/locale_keys.g.dart';

class AddCardScreen extends StatefulWidget {
  final Function(PaymentCardModel) onCardAdded;

  const AddCardScreen({super.key, required this.onCardAdded});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  Color selectedColor = Colors.black;

  final List<Color> availableColors = [
    Colors.black,
    Colors.deepPurple,
    Colors.blue.shade900,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Transform.flip(
            // لو اللغة عربي (ar) اقلب الأيقونة، لو إنجليزي سيبها زي ما هي
            flipX: context.locale.languageCode == 'ar',
            child: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          ),
        ),
        title: Text(
          LocaleKeys.payment_add_card_title.tr(), // 🔥 ترجمة
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(LocaleKeys.payment_name_on_card.tr(), style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)), // 🔥 ترجمة
            const SizedBox(height: 8),
            _buildTextField(context, controller: nameController, hint: LocaleKeys.payment_name_hint.tr()), // 🔥 ترجمة

            const SizedBox(height: 20),
            Text(LocaleKeys.payment_number_on_card.tr(), style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)), // 🔥 ترجمة
            const SizedBox(height: 8),
            _buildTextField(
              context,
              controller: numberController,
              hint: "0000 0000 0000 0000",
              isNumber: true,
              prefixIcon: Icons.credit_card,
            ),

            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(LocaleKeys.payment_expiry.tr(), style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)), // 🔥 ترجمة
                      const SizedBox(height: 8),
                      _buildTextField(context, controller: expiryController, hint: "MM / YY"),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(LocaleKeys.payment_cvv.tr(), style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)), // 🔥 ترجمة
                      const SizedBox(height: 8),
                      _buildTextField(context, controller: cvvController, hint: "000", isNumber: true, isObscure: true),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),
            Text(LocaleKeys.payment_select_color.tr(), style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)), // 🔥 ترجمة
            const SizedBox(height: 12),
            Row(
              children: availableColors.map((color) {
                bool isSelected = selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => selectedColor = color),
                  child: Container(
                    // 🔥 التعديل السحري لضبط المسافات في الـ RTL
                    margin: const EdgeInsetsDirectional.only(end: 15),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(backgroundColor: color, radius: 18),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (numberController.text.isNotEmpty && nameController.text.isNotEmpty) {
                    final newCard = PaymentCardModel(
                      color: selectedColor,
                      cardNumber: numberController.text,
                      cardType: "VISA",
                      holderName: nameController.text,
                      isFront: true,
                    );
                    widget.onCardAdded(newCard);
                    context.pop();
                  }
                },
                child: Text(
                  LocaleKeys.payment_add_card_title.tr(), // 🔥 ترجمة
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, {
    required TextEditingController controller,
    required String hint,
    bool isNumber = false,
    bool isObscure = false,
    IconData? prefixIcon,
  }) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      obscureText: isObscure,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: theme.hintColor),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: theme.colorScheme.primary) : null,
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    numberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    super.dispose();
  }
}