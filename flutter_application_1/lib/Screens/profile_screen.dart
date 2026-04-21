import 'package:flutter/material.dart';
import 'account_info_screen.dart';
import 'language_screen.dart';
import 'medical_info_screen.dart';
import 'personal_info_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                const CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'), 
                ),
                Positioned(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 30),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          const Text("Sofia Andro", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          // القائمة
          Expanded(
            child: ListView(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  children: [
    
    _buildListTile(
      icon: Icons.lock_outline, 
      title: "Account Information",
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountInfoScreen())),
    ),

    
    _buildListTile(
      icon: Icons.person_outline, 
      title: "Personal Information",
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalInfoScreen())),
    ),

    
    _buildListTile(
      icon: Icons.medical_services_outlined, 
      title: "Medical Information",
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MedicalInfoScreen())),
    ),

    
    _buildListTile(
      icon: Icons.translate, 
      title: "Language Information",
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LanguageScreen())),
    ),

    
    ListTile(
      leading: const Icon(Icons.wb_sunny_outlined),
      title: const Text("App Theme"),
      trailing: Switch(value: true, onChanged: (v) {}, activeColor: const Color(0xFF00A98E)),
    ),
    const Divider(height: 1),

    
    ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text("Sign Out", style: TextStyle(color: Colors.red)),
      onTap: () {},
    ),
  ],
)
          ),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
        selectedItemColor: const Color(0xFF00A98E),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Chats"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: "Schedule"),
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: "Reminder"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildListTile({required IconData icon, required String title, VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}