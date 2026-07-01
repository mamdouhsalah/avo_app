import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ai_alarm_reminder/app/core/utils/constance.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _isNotificationEnabled = false;
  bool _isBatteryOptimizationDisabled = false;
  bool _isSoundEnabled = true;
  bool _isVibrationEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadPreferences();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isLoading = true;
    });

    // Check notification permission
    final notificationStatus =
        await AwesomeNotifications().isNotificationAllowed();
    final batteryStatus = await Permission.ignoreBatteryOptimizations.isGranted;

    setState(() {
      _isNotificationEnabled = notificationStatus;
      _isBatteryOptimizationDisabled = batteryStatus;
      _isLoading = false;
    });
  }

  Future<void> _loadPreferences() async {
    final box = await Hive.openBox('settings');
    setState(() {
      _isSoundEnabled = box.get('notificationSound', defaultValue: true);
      _isVibrationEnabled =
          box.get('notificationVibration', defaultValue: true);
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final box = await Hive.openBox('settings');
    await box.put(key, value);
  }

  Future<void> _requestNotificationPermission() async {
    await AwesomeNotifications().requestPermissionToSendNotifications();
    await _checkPermissions();
  }

  Future<void> _requestBatteryOptimizationPermission() async {
    await Permission.ignoreBatteryOptimizations.request();
    await _checkPermissions();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message, style: const TextStyle(fontFamily: 'cairo'))),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required bool isEnabled,
    required IconData icon,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 28),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'cairo',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontFamily: 'cairo', fontSize: 14),
          ),
          trailing: trailing ??
              Icon(
                isEnabled ? Icons.check_circle : Icons.warning,
                color: isEnabled ? Colors.green : Colors.red,
              ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required String title,
    required bool value,
    required IconData icon,
    required Function(bool) onChanged,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 28),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'cairo',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          trailing: Switch(
            value: value,
            onChanged: (newValue) {
              setState(() {
                onChanged(newValue);
              });
            },
            activeThumbColor: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'إعدادات الإشعارات',
          style: TextStyle(
            fontFamily: 'cairo',
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _checkPermissions,
              color: AppColors.primaryColor,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حالة الأذونات',
                      style: TextStyle(
                        fontFamily: 'cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingCard(
                      title: 'السماح بالإشعارات',
                      subtitle: _isNotificationEnabled
                          ? 'الإشعارات مفعلة'
                          : 'الرجاء تفعيل الإشعارات لتلقي تذكيرات الأدوية',
                      isEnabled: _isNotificationEnabled,
                      icon: Icons.notifications,
                      onTap: _isNotificationEnabled
                          ? null
                          : () async {
                              await _requestNotificationPermission();
                              _showSnackBar(_isNotificationEnabled
                                  ? 'الإشعارات مفعلة بالفعل'
                                  : 'تم طلب تفعيل الإشعارات');
                            },
                    ),
                    _buildSettingCard(
                      title: 'تعطيل تحسين البطارية',
                      subtitle: _isBatteryOptimizationDisabled
                          ? 'تحسين البطارية معطل'
                          : 'الرجاء تعطيل تحسين البطارية لضمان عمل الإشعارات',
                      isEnabled: _isBatteryOptimizationDisabled,
                      icon: Icons.battery_charging_full,
                      onTap: _isBatteryOptimizationDisabled
                          ? null
                          : () async {
                              await _requestBatteryOptimizationPermission();
                              _showSnackBar(_isBatteryOptimizationDisabled
                                  ? 'تحسين البطارية معطل بالفعل'
                                  : 'تم طلب تعطيل تحسين البطارية');
                            },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'تفضيلات الإشعارات',
                      style: TextStyle(
                        fontFamily: 'cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildToggleCard(
                      title: 'صوت الإشعار',
                      value: _isSoundEnabled,
                      icon: Icons.volume_up,
                      onChanged: (value) {
                        setState(() {
                          _isSoundEnabled = value;
                          _savePreference('notificationSound', value);
                        });
                        _showSnackBar('تم تحديث إعداد صوت الإشعار');
                      },
                    ),
                    _buildToggleCard(
                      title: 'اهتزاز الإشعار',
                      value: _isVibrationEnabled,
                      icon: Icons.vibration,
                      onChanged: (value) {
                        setState(() {
                          _isVibrationEnabled = value;
                          _savePreference('notificationVibration', value);
                        });
                        _showSnackBar('تم تحديث إعداد الاهتزاز');
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
