import 'dart:ui' as ui; // نحتاج هذا الـ Import لعمل الـ Shader
import 'package:flutter/material.dart';

class WaveHeaderPainter extends CustomPainter {
  final Color color;

  WaveHeaderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // عمل تدرج يبدأ من اللون الأساسي عند الموجة ويختفي (Opacity 0) عند قمة الشاشة
    paint.shader = ui.Gradient.linear(
      Offset(0, size.height), // البداية من أسفل (عند الموجة)
      const Offset(0, 0),      // النهاية عند القمة (Y = 0)
      [
        color.withValues(alpha: 0.5),                // اللون كامل الشفافية تحت
        color.withValues(alpha: 0.0), // شفاف تماماً فوق
      ],
      [0.0, 1.0], // توزيع اللون (من 0% لـ 100%)
    );

    paint.style = PaintingStyle.fill;

    final path = Path();

    // البداية من اليسار (نقطة الانطلاق للمنحنى)
    path.lineTo(0, size.height * 0.8);

    // الجزء الأول: المنحنى "يطلع" للأعلى (Y تقل)
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.55, // نقطة التحكم بالأعلى
      size.width * 0.5, size.height * 0.75,  // نقطة المنتصف
    );

    // الجزء الثاني: المنحنى "ينزل" للأسفل (Y تزيد)
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.95, // نقطة التحكم بالأسفل
      size.width, size.height * 0.7,         // نقطة النهاية يميناً
    );

    // إغلاق الشكل للأعلى لتعبئة المساحة المتدرجة
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}