import 'package:ai_alarm_reminder/app/core/utils/constance.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: Text(
          'عن التطبيق',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.black,
            )),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'التطبيق هو مساعد شخصي لتحليل المستندات الطبية وإدارة الصحة. إليك أهم ميزاته ووظائفه:',
                style: TextStyle(fontSize: 16, fontFamily: 'Cairo'),
              ),
              const SizedBox(height: 16),
              Text(
                'ميزات التطبيق:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: AppColors.primaryColor),
              ),
              const SizedBox(height: 12),
              _buildFeatureText('1. فحص المستندات (الماسح الضوئي):', [
                'يتيح للمستخدمين فحص المستندات والتحاليل باستخدام الكاميرا أو اختيارها من المعرض.',
              ]),
              _buildFeatureText('2. التعرف على النصوص:', [
                'يستخرج النصوص من الصور الممسوحة ضوئياً بدقة عالية.',
                'يدعم استخراج النصوص باللغتين العربية والإنجليزية.',
              ]),
              _buildFeatureText('3. التحليل الطبي بالذكاء الاصطناعي:', [
                'يقوم بتحليل النصوص المستخرجة باستخدام الذكاء الاصطناعي لتقديم شرح مبسط.',
                'توليد ردود باللغة العربية العامية، مع استبعاد التفاصيل الشخصية أو المعقدة، مع التركيز على تقديم تفسيرات واضحة ونصائح صحية مفيدة.',
              ]),
              _buildFeatureText('4. نظام النقاط:', [
                'نظام تفاعلي يمنحك نقطة لكل عملية إدخال لبياناتك الصحية.',
                'تُستخدم النقاط في الاستفادة من ميزة الذكاء الاصطناعي (كل تحليل يخصم نقطة).',
              ]),
              _buildFeatureText('5. تخزين البيانات محلياً:', [
                'يحفظ التحاليل والنتائج والمقاييس الصحية في جهازك محلياً لضمان الخصوصية والوصول السريع بدون إنترنت.',
              ]),
              _buildFeatureText('6. تذكير بمواعيد الأدوية:', [
                'جدولة إشعارات ذكية لتذكيرك بمواعيد الأدوية.',
              ]),
              const SizedBox(height: 16),
              Text(
                'حالات الاستخدام:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: AppColors.primaryColor),
              ),
              const SizedBox(height: 8),
              const Text(
                'هذا التطبيق مثالي للمرضى والمهتمين بمتابعة صحتهم حيث يساعد في:',
                style: TextStyle(fontSize: 16, fontFamily: 'Cairo'),
              ),
              const SizedBox(height: 8),
              _buildUseCaseList([
                'حفظ السجلات الطبية وتحليلها بصورة مبسطة.',
                'الحصول على اقتراحات أو تفسيرات لنتائج المختبر بشكل سريع.',
                'الحفاظ على سجل شخصي للمقاييس الصحية مع رسوم بيانية توضيحية.',
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureText(String title, List<String> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        ),
        ...details.map((detail) => Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 4.0),
              child: Text(
                '• $detail',
                style: const TextStyle(fontSize: 15, fontFamily: 'Cairo', color: Colors.black87),
              ),
            )),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildUseCaseList(List<String> useCases) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...useCases.map((useCase) => Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 6.0),
              child: Text(
                '• $useCase',
                style: const TextStyle(fontSize: 15, fontFamily: 'Cairo', color: Colors.black87),
              ),
            )),
        const SizedBox(height: 16),
      ],
    );
  }
}
