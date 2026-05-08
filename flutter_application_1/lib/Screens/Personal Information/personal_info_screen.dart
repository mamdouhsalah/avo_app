import 'package:flutter/material.dart';

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

  static const Color primaryGreen = Color(0xFF00AA8D);
  static const Color secondaryAqua = Color(0xFF7CD9C9);
  static const Color maleBlue = Color(0xFF00A3FF);
  static const Color femalePink = Color(0xFFFD778D);
  static const Color inactiveBorder = Color(0xFFE8E8E8);

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
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, 
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Personal Information',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildGenderCard('Male', Icons.person, maleBlue, selectedGender == 'Male'),
                const SizedBox(width: 20),
                _buildGenderCard('Female', Icons.person_3, femalePink, selectedGender == 'Female'),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(child: _buildEditableField('Height (CM)', _heightController, isNumeric: true, showEditIcon: false)),
                const SizedBox(width: 15),
                Expanded(child: _buildEditableField('Weight (KG)', _weightController, isNumeric: true, showEditIcon: false)),
              ],
            ),
            const SizedBox(height: 20),
            _buildEditableField('Date of Birth', _dobController, isDropdown: true),
            const SizedBox(height: 20),
            _buildEditableField('Blood Type', _bloodTypeController, isDropdown: true),
            const SizedBox(height: 25),
            const Text('Chronic Diseases', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _buildEditableField('', _chronicController, isDropdown: true, isHint: true),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Surgical History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black),
                  onPressed: isEditMode ? () {} : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildSurgicalHistoryItem('Bidding process', '08/10/2026'),
            const SizedBox(height: 100), 
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
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
              backgroundColor: isEditMode ? primaryGreen : Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              isEditMode ? 'Save' : 'Edit',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderCard(String title, IconData icon, Color color, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: isEditMode ? () => setState(() => selectedGender = title) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(color: isSelected ? color : inactiveBorder, width: 1.5),
            borderRadius: BorderRadius.circular(15),
            color: isEditMode || isSelected ? Colors.white : Colors.grey.shade50,
          ),
          child: Column(
            children: [
              Icon(icon, size: 55, color: isSelected ? color : Colors.grey),
              const SizedBox(height: 12),
              Text(title, style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.black54,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, {bool isNumeric = false, bool isDropdown = false, bool isHint = false, bool showEditIcon = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        if (label.isNotEmpty) const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: isEditMode,
          keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          readOnly: isDropdown,
          decoration: InputDecoration(
            suffixIcon: isEditMode && showEditIcon ? Icon(isDropdown ? Icons.keyboard_arrow_down : Icons.edit_outlined, size: 20) : null,
            filled: !isEditMode,
            fillColor: isEditMode ? Colors.white : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: inactiveBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: isDropdown && isHint ? inactiveBorder : secondaryAqua),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primaryGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSurgicalHistoryItem(String title, String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
      decoration: BoxDecoration(
        border: Border.all(color: secondaryAqua),
        borderRadius: BorderRadius.circular(10),
        color: isEditMode ? Colors.white : Colors.grey.shade50,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          Text(date, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ],
      ),
    );
  }
}