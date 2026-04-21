import 'package:flutter/material.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Personal Information", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Full name"),
            _buildTextField("Enter your Name"),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Height (CM)"),
                      _buildTextField("Height"),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Weight (KG)"),
                      _buildTextField("Weight"),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildLabel("Date of Birth"),
            _buildTextField("DD / MM / YY", suffixIcon: Icons.keyboard_arrow_down),
            const Spacer(),
            _buildSaveButton("Save"),
          ],
        ),
      ),
    );
  }

  
  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  Widget _buildTextField(String hint, {IconData? suffixIcon}) => TextField(
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

  Widget _buildSaveButton(String text) => SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00A98E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(text, style: const TextStyle(color: Color.fromARGB(255, 182, 182, 182), fontSize: 18)),
        ),
      );
}