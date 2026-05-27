import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AudioCallScreen extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String duration;

  const AudioCallScreen({
    super.key,
    required this.name,
    required this.imageUrl,
    this.duration = "22:55 min",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffD2EFEB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text("Audio Call"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 85.r,
              backgroundImage: NetworkImage(imageUrl),
            ),
            SizedBox(height: 20.h),
            Text(
              name,
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            Text(
              duration,
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
            ),
            SizedBox(height: 80.h),

            // Call Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCallButton(Icons.volume_up, "Speaker"),
                SizedBox(width: 30.w),
                _buildCallButton(Icons.videocam, "Video"),
                SizedBox(width: 30.w),
                _buildCallButton(Icons.mic, "Mute"),
              ],
            ),

            SizedBox(height: 60.h),

            // End Call Button
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 70.w,
                height: 70.w,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.call_end, color: Colors.white, size: 36),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Icon(icon, size: 28.sp),
        ),
        SizedBox(height: 8.h),
        Text(label, style: TextStyle(fontSize: 13.sp)),
      ],
    );
  }
}
