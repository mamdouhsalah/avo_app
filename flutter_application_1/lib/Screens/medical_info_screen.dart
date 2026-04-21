import 'package:flutter/material.dart';



class MedicalInfoScreen extends StatefulWidget {
  const MedicalInfoScreen({super.key});

  @override
  State<MedicalInfoScreen> createState() => _MedicalInfoScreenState();
}

class _MedicalInfoScreenState extends State<MedicalInfoScreen> {
  
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Medical Information", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Blood Type"),
            _buildDropdownField("O+"),
            const SizedBox(height: 20),
            
            _buildLabel("Chronic Diseases"),
            
            Wrap(
              spacing: 8,
              children: [
                _buildChip("Diabetes"),
                _buildChip("Pressure"),
              ],
            ),
            const SizedBox(height: 10),
            
            if (isEditing) _buildTextField("Chosen Chronic Diseases"),
            
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Surgical History", style: TextStyle(fontWeight: FontWeight.bold)),
                if (isEditing) const Icon(Icons.add, color: Colors.black),
              ],
            ),
            const SizedBox(height: 10),
            _buildHistoryItem("Bidding process", "08/10/2026"),

            const Spacer(),
            
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isEditing = !isEditing; 
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A98E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  isEditing ? "Save" : "Edit", 
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget _buildDropdownField(String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(value, style: TextStyle(color: isEditing ? Colors.black : Colors.grey)),
        const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      ],
    ),
  );

  Widget _buildTextField(String hint) => TextField(
    enabled: isEditing,
    decoration: InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  Widget _buildChip(String label) => Chip(
    label: Text(label, style: const TextStyle(color: Color(0xFF00A98E), fontSize: 12)),
    backgroundColor: Colors.white,
    side: const BorderSide(color: Color(0xFF00A98E)),
    onDeleted: isEditing ? () {} : null, 
    deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFF00A98E)),
  );

  Widget _buildHistoryItem(String title, String date) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFF00A98E)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    ),
  );
}