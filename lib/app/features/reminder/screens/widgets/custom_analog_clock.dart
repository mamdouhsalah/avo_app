import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InteractiveAnalogClock extends StatelessWidget {
  final TimeOfDay time;
  final bool isSelectingHour;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const InteractiveAnalogClock({
    super.key,
    required this.time,
    required this.isSelectingHour,
    required this.onTimeChanged,
  });

  // دالة تحويل اللمسة على الشاشة إلى وقت (ساعة أو دقيقة)
  void _handleGesture(Offset localPosition, double size) {
    final center = Offset(size / 2, size / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;

    // حساب الزاوية
    double angle = math.atan2(dy, dx);
    double degrees = angle * 180 / math.pi + 90;
    if (degrees < 0) degrees += 360;

    if (isSelectingHour) {
      int h = (degrees / 30).round();
      if (h == 0) h = 12;

      // الحفاظ على حالة الـ AM/PM الحالية
      bool isPM = time.period == DayPeriod.pm;
      int finalHour = h;
      if (isPM && h < 12) finalHour = h + 12;
      if (!isPM && h == 12) finalHour = 0;
      if (isPM && h == 12) finalHour = 12;

      onTimeChanged(TimeOfDay(hour: finalHour, minute: time.minute));
    } else {
      int m = (degrees / 6).round();
      if (m == 60) m = 0;
      onTimeChanged(TimeOfDay(hour: time.hour, minute: m));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double clockSize = 240.r;

    return GestureDetector(
      onTapDown: (details) => _handleGesture(details.localPosition, clockSize),
      onPanUpdate: (details) => _handleGesture(details.localPosition, clockSize),
      child: SizedBox(
        width: clockSize,
        height: clockSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // الخلفية الخضراء
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),

            // رسم الأرقام (ساعات أو دقائق بناءً على الحالة)
            ...List.generate(12, (index) {
              final number = isSelectingHour
                  ? (index == 0 ? 12 : index)
                  : (index * 5); // للدقائق: 0, 5, 10...

              final angle = (index * 30 - 90) * (math.pi / 180);
              final radius = clockSize / 2 - 24.r;

              // تحديد الرقم المختار حالياً لتلوينه
              bool isSelected = false;
              if (isSelectingHour) {
                int currentHour = time.hourOfPeriod;
                if (currentHour == 0) currentHour = 12;
                isSelected = currentHour == number;
              } else {
                isSelected = time.minute == number;
              }

              return Transform.translate(
                offset: Offset(radius * math.cos(angle), radius * math.sin(angle)),
                child: Container(
                  padding: EdgeInsets.all(isSelected ? 6.r : 0),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    isSelectingHour ? number.toString() : number.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: isSelected ? 16.sp : 14.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? theme.colorScheme.primary : Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              );
            }),

            // رسم العقرب المتصل باللمس
            CustomPaint(
              size: Size(clockSize, clockSize),
              painter: SingleHandPainter(
                time: time,
                isSelectingHour: isSelectingHour,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// رسام عقرب واحد ديناميكي
class SingleHandPainter extends CustomPainter {
  final TimeOfDay time;
  final bool isSelectingHour;

  SingleHandPainter({required this.time, required this.isSelectingHour});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final handPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.w
      ..strokeCap = StrokeCap.round;

    final centerDotPaint = Paint()..color = Colors.white;

    double angle;
    double handLength;

    if (isSelectingHour) {
      int h = time.hourOfPeriod;
      if (h == 0) h = 12;
      angle = (h * 30 - 90) * (math.pi / 180);
      handLength = size.width * 0.28;
    } else {
      angle = (time.minute * 6 - 90) * (math.pi / 180);
      handLength = size.width * 0.35;
    }

    canvas.drawLine(
      center,
      Offset(center.dx + handLength * math.cos(angle), center.dy + handLength * math.sin(angle)),
      handPaint,
    );
    canvas.drawCircle(center, 6.r, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}