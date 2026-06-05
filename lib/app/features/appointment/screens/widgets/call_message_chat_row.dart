import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CallMessageChatRow extends StatelessWidget {
   CallMessageChatRow({super.key});
  


  @override
  Widget build(BuildContext context) {


    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Call Button
        _buildActionButton(
          context: context,
          icon: Icons.call_outlined,
          onTap: () {
            // Handle call action
     
          },
        ),
        
        // Message Button (SMS)
        _buildActionButton(
          context: context,
          icon: Icons.video_call_outlined,
          onTap: () {
            // Handle message action
    
          },
        ),
        
        // Chat Button (In-app messaging)
        _buildActionButton(
          context: context,
          icon: Icons.chat_outlined,
          onTap: () {
            // Handle chat action
    
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(

      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 60.r,
        height: 40.r,
        padding:  EdgeInsets.symmetric(horizontal:  12.r),
        decoration: BoxDecoration(
         color: Colors.grey,
         borderRadius: BorderRadius.circular(24.r),

        ),
        child: Icon(
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface,
          icon,
          size: 24.sp,
        ),
      ),
    );
  }
}