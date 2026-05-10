import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notification/core/controllers/settings_controller.dart';
import 'package:notification/features/auth/presentation/controllers/auth_controller.dart';
import 'package:notification/features/notifications/presentation/controllers/notification_settings_controller.dart';

class SettingsView extends GetView<NotificationSettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final bgColor = isDark ? const Color(0xFF131313) : const Color(0xFFF7F8FA);
    final textColor = isDark ? Colors.white : const Color(0xFF1D1F24);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'settings'.tr,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: textColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _buildThemeSection(context, isDark, primaryColor, textColor),
          const SizedBox(height: 32),
          _buildLanguageSection(context, isDark, primaryColor, textColor),
          const SizedBox(height: 32),
          _buildNotificationSection(context, isDark, primaryColor, textColor),
          const SizedBox(height: 48),
          _buildLogoutSection(context, isDark, textColor),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildThemeSection(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'display_mode'.tr,
          textColor,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'PREMIUM',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final currentMode = SettingsController.to.themeMode;
          final activeIsDark =
              currentMode == ThemeMode.dark ||
              (currentMode == ThemeMode.system && isDark);

          return Row(
            children: [
              Expanded(
                child: _ThemeCard(
                  icon: Icons.wb_sunny_outlined,
                  label: 'light'.tr,
                  isActive: !activeIsDark,
                  primaryColor: primaryColor,
                  isDark: isDark,
                  onTap: () =>
                      SettingsController.to.setThemeMode(ThemeMode.light),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ThemeCard(
                  icon: Icons.nightlight_outlined,
                  label: 'dark'.tr,
                  isActive: activeIsDark,
                  primaryColor: primaryColor,
                  isDark: isDark,
                  onTap: () =>
                      SettingsController.to.setThemeMode(ThemeMode.dark),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildLanguageSection(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('language'.tr, textColor),
        const SizedBox(height: 16),
        Obx(() {
          final currentLang = SettingsController.to.locale.languageCode;
          return Column(
            children: [
              _LanguageCard(
                label: 'vietnamese'.tr,
                subtitle: currentLang == 'vi' ? 'current_language'.tr : null,
                icon: Icons.language,
                isActive: currentLang == 'vi',
                primaryColor: primaryColor,
                isDark: isDark,
                onTap: () => SettingsController.to.setLanguage('vi'),
              ),
              const SizedBox(height: 12),
              _LanguageCard(
                label: 'english'.tr,
                subtitle: currentLang == 'en' ? 'current_language'.tr : null,
                icon: Icons.translate,
                isActive: currentLang == 'en',
                primaryColor: primaryColor,
                isDark: isDark,
                onTap: () => SettingsController.to.setLanguage('en'),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildNotificationSection(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('notifications'.tr, textColor),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoading.value) {
            return _buildNotificationSkeleton(isDark);
          }
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF222222) : const Color(0xFFF1F3F5),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Obx(
                  () => _NotificationToggleItem(
                    label: 'email'.tr,
                    icon: Icons.email_outlined,
                    isEnabled: controller.emailEnabled.value,
                    isLoading: controller.isChannelLoading('email'),
                    primaryColor: primaryColor,
                    isDark: isDark,
                    onChanged: (val) => controller.toggleSetting('email', val),
                  ),
                ),
                Obx(
                  () => _NotificationToggleItem(
                    label: 'push_notification'.tr,
                    icon: Icons.notifications_active_outlined,
                    isEnabled: controller.pushEnabled.value,
                    isLoading: controller.isChannelLoading('push'),
                    primaryColor: primaryColor,
                    isDark: isDark,
                    onChanged: (val) => controller.toggleSetting('push', val),
                  ),
                ),
                Obx(
                  () => _NotificationToggleItem(
                    label: 'sms'.tr,
                    icon: Icons.sms_outlined,
                    isEnabled: controller.smsEnabled.value,
                    isLoading: controller.isChannelLoading('sms'),
                    primaryColor: primaryColor,
                    isDark: isDark,
                    onChanged: (val) => controller.toggleSetting('sms', val),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNotificationSkeleton(bool isDark) {
    final baseColor = isDark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFE5E7EB);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222222) : const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: baseColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 48,
                  height: 28,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutSection(
    BuildContext context,
    bool isDark,
    Color textColor,
  ) {
    return Column(
      children: [
        Divider(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
          thickness: 1,
        ),
        const SizedBox(height: 24),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showLogoutConfirmation(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    'logout'.tr,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${'version'.tr} 1.0.2 (Build 240507)',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white38 : Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      Dialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'logout_confirm_title'.tr,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'logout_confirm_message'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white70 : Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'cancel'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white60 : Colors.black45,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.find<AuthController>().logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'logout'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}

class _NotificationToggleItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isEnabled;
  final bool isLoading;
  final Color primaryColor;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _NotificationToggleItem({
    required this.label,
    required this.icon,
    required this.isEnabled,
    required this.isLoading,
    required this.primaryColor,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black;

    return AnimatedOpacity(
      opacity: isLoading ? 0.9 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isEnabled
                    ? primaryColor.withOpacity(0.1)
                    : (isDark ? Colors.white10 : Colors.black12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isEnabled ? primaryColor : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            Switch(
              value: isEnabled,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.primaryColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isActive
        ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
        : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F3F5));
    final borderColor = isActive ? primaryColor : Colors.transparent;
    final iconContainerBg = isActive
        ? primaryColor.withOpacity(0.1)
        : (isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB));
    final iconColor = isActive
        ? primaryColor
        : (isDark ? Colors.white70 : Colors.black87);
    final textColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: isActive && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconContainerBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CustomRadio(
                  isActive: isActive,
                  primaryColor: primaryColor,
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final bool isActive;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.label,
    this.subtitle,
    required this.icon,
    required this.isActive,
    required this.primaryColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isActive
        ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
        : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F3F5));
    final iconContainerBg = isActive
        ? primaryColor.withOpacity(0.1)
        : (isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB));
    final iconColor = isActive
        ? primaryColor
        : (isDark ? Colors.white70 : Colors.black54);
    final textColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isActive && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconContainerBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isActive)
              Icon(Icons.check_circle, color: primaryColor, size: 28)
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomRadio extends StatelessWidget {
  final bool isActive;
  final Color primaryColor;
  final bool isDark;

  const _CustomRadio({
    required this.isActive,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: primaryColor, width: 6),
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        ),
      );
    } else {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400, width: 2),
          color: Colors.transparent,
        ),
      );
    }
  }
}
