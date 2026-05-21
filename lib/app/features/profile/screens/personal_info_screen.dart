import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  bool isEditMode = false;

  final TextEditingController _heightController = TextEditingController(text: '179.50');
  final TextEditingController _weightController = TextEditingController(text: '120.50');
  final TextEditingController _dobController = TextEditingController(text: '11 / 05 / 2006');
  final TextEditingController _bloodTypeController = TextEditingController(text: 'O+');
  final TextEditingController _chronicController = TextEditingController(text: 'Chronic Diseases');

  String selectedGender = 'Male';

  // الألوان الخاصة بالجنس سبناها زي ما هي عشان تميز الـ UI
  static const Color maleBlue = Color(0xFF00A3FF);
  static const Color femalePink = Color(0xFFFD778D);

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _dobController.dispose();
    _bloodTypeController.dispose();
    _chronicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Personal Information',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gender', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildGenderCard(context, 'Male', Icons.person, maleBlue, selectedGender == 'Male'),
                const SizedBox(width: 20),
                _buildGenderCard(context, 'Female', Icons.person_3, femalePink, selectedGender == 'Female'),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(child: _buildEditableField(context, 'Height (CM)', _heightController, isNumeric: true, showEditIcon: false)),
                const SizedBox(width: 15),
                Expanded(child: _buildEditableField(context, 'Weight (KG)', _weightController, isNumeric: true, showEditIcon: false)),
              ],
            ),
            const SizedBox(height: 20),
            _buildEditableField(context, 'Date of Birth', _dobController, isDropdown: true),
            const SizedBox(height: 20),
            _buildEditableField(context, 'Blood Type', _bloodTypeController, isDropdown: true),
            const SizedBox(height: 25),
            Text('Chronic Diseases', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildEditableField(context, '', _chronicController, isDropdown: true, isHint: true),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Surgical History', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.add, color: isEditMode ? theme.iconTheme.color : theme.disabledColor),
                  onPressed: isEditMode ? () {} : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildSurgicalHistoryItem(context, 'Bidding process', '08/10/2026'),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: theme.scaffoldBackgroundColor,
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                isEditMode = !isEditMode;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isEditMode ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              isEditMode ? 'Save' : 'Edit',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isEditMode ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderCard(BuildContext context, String title, IconData icon, Color color, bool isSelected) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: isEditMode ? () => setState(() => selectedGender = title) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(color: isSelected ? color : theme.dividerColor, width: 1.5),
            borderRadius: BorderRadius.circular(15),
            color: isEditMode || isSelected ? theme.cardColor : theme.scaffoldBackgroundColor,
          ),
          child: Column(
            children: [
              Icon(icon, size: 55, color: isSelected ? color : theme.disabledColor),
              const SizedBox(height: 12),
              Text(title, style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : theme.textTheme.bodyMedium?.color,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(BuildContext context, String label, TextEditingController controller, {bool isNumeric = false, bool isDropdown = false, bool isHint = false, bool showEditIcon = true}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        if (label.isNotEmpty) const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: isEditMode,
          style: theme.textTheme.bodyMedium,
          keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          readOnly: isDropdown,
          decoration: InputDecoration(
            suffixIcon: isEditMode && showEditIcon ? Icon(isDropdown ? Icons.keyboard_arrow_down : Icons.edit_outlined, size: 20, color: theme.iconTheme.color) : null,
            filled: true,
            // لو مش في وضع التعديل، بيدي خلفية رمادية خفيفة من الثيم، لو في وضع التعديل بتبقى بلون الكارد
            fillColor: isEditMode ? theme.cardColor : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: isDropdown && isHint ? theme.dividerColor : theme.colorScheme.primary.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSurgicalHistoryItem(BuildContext context, String title, String date) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(10),
        color: isEditMode ? theme.cardColor : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          Text(date, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
        ],
      ),
    );
  }
}