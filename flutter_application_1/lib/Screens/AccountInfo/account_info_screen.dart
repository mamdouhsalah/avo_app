import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/AccountInfo/account_info_model.dart';

class AccountInfoScreen extends StatelessWidget {
  
  final UserProfile userData = UserProfile(
    fullName: 'Sofia Andro',
    email: 'Sofia.Andro15@gmail.com',
    phoneNumber: '+201057892010',
  );

  AccountInfoScreen({super.key});

  @override
   
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Account Info',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              label: 'Full Name',
              initialValue: 'Sofia Andro',
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Email',
              initialValue: 'Sofia.Andro15@gmail.com',
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Phone',
              initialValue: '+201057892010',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required String initialValue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF81D4C2), width: 1.5), 
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.teal, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}