import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmergencyNumbersScreen extends StatelessWidget {
  const EmergencyNumbersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, String>> emergencyNumbers = [
      {
        'title': LocaleKeys.emergency_police.tr(),
        'number': '122',
        'icon': 'local_police',
        'color': '0xFF1976D2',
      },
      {
        'title': LocaleKeys.emergency_ambulance.tr(),
        'number': '123',
        'icon': 'medical_services',
        'color': '0xFFD32F2F',
      },
      {
        'title': LocaleKeys.emergency_fire.tr(),
        'number': '180',
        'icon': 'fire_extinguisher',
        'color': '0xFFF57C00',
      },
      {
        'title': LocaleKeys.emergency_electricity.tr(),
        'number': '121',
        'icon': 'electric_bolt',
        'color': '0xFFFBC02D',
      },
      {
        'title': LocaleKeys.emergency_gas.tr(),
        'number': '129',
        'icon': 'local_gas_station',
        'color': '0xFF388E3C',
      },
      {
        'title': LocaleKeys.emergency_water.tr(),
        'number': '125',
        'icon': 'water_drop',
        'color': '0xFF0288D1',
      },
      {
        'title': LocaleKeys.emergency_health_ministry.tr(),
        'number': '105',
        'icon': 'health_and_safety',
        'color': '0xFF00796B',
      },
    ];

    IconData _getIconData(String name) {
      switch (name) {
        case 'local_police':
          return Icons.local_police;
        case 'medical_services':
          return Icons.medical_services;
        case 'fire_extinguisher':
          return Icons.fire_extinguisher;
        case 'electric_bolt':
          return Icons.electric_bolt;
        case 'local_gas_station':
          return Icons.local_gas_station;
        case 'water_drop':
          return Icons.water_drop;
        case 'health_and_safety':
          return Icons.health_and_safety;
        default:
          return Icons.phone;
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(LocaleKeys.emergency_title.tr()),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.sp),
        itemCount: emergencyNumbers.length,
        itemBuilder: (context, index) {
          final item = emergencyNumbers[index];
          final color = Color(int.parse(item['color']!));

          return Card(
            margin: EdgeInsets.only(bottom: 12.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            elevation: 2,
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                radius: 24.r,
                child: Icon(
                  _getIconData(item['icon']!),
                  color: color,
                  size: 28.sp,
                ),
              ),
              title: Text(
                item['title']!,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                item['number']!,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
