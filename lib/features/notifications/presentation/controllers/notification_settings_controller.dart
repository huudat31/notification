import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../domain/usecases/update_setting_usecase.dart';
import '../../domain/usecases/get_settings_usecase.dart';

class NotificationSettingsController extends GetxController {
  final UpdateSettingUseCase _updateSettingUseCase;
  final GetSettingsUseCase _getSettingsUseCase;
  final _box = GetStorage();

  static const String _emailKey = 'settings_email_enabled';
  static const String _pushKey = 'settings_push_enabled';
  static const String _smsKey = 'settings_sms_enabled';

  NotificationSettingsController({
    required UpdateSettingUseCase updateSettingUseCase,
    required GetSettingsUseCase getSettingsUseCase,
  }) : _updateSettingUseCase = updateSettingUseCase,
       _getSettingsUseCase = getSettingsUseCase;

  final emailEnabled = true.obs;
  final pushEnabled = true.obs;
  final smsEnabled = false.obs;

  final isLoading = false.obs;

  final loadingChannels = <String>{}.obs;

  final Map<String, Timer> _debounceTimers = {};

  @override
  void onInit() {
    super.onInit();
    _loadLocalSettings();
    fetchSettings();
  }

  void _loadLocalSettings() {
    emailEnabled.value = _box.read(_emailKey) ?? true;
    pushEnabled.value = _box.read(_pushKey) ?? true;
    smsEnabled.value = _box.read(_smsKey) ?? false;
  }

  void _saveLocalSettings() {
    _box.write(_emailKey, emailEnabled.value);
    _box.write(_pushKey, pushEnabled.value);
    _box.write(_smsKey, smsEnabled.value);
  }

  @override
  void onClose() {
    for (var timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    super.onClose();
  }

  bool isChannelLoading(String channel) => loadingChannels.contains(channel);

  Future<void> fetchSettings() async {
    isLoading.value = true;
    try {
      final settings = await _getSettingsUseCase.execute();
      _applySettings(settings);
      _saveLocalSettings();
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  void _applySettings(Map<String, dynamic> settings) {
    emailEnabled.value = _parseBool(
      settings['email'],
      fallback: emailEnabled.value,
    );
    pushEnabled.value = _parseBool(
      settings['push'],
      fallback: pushEnabled.value,
    );
    smsEnabled.value = _parseBool(settings['sms'], fallback: smsEnabled.value);
  }

  bool _parseBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true';
    return fallback;
  }

  void toggleSetting(String channel, bool isEnabled) {
    _setChannelValue(channel, isEnabled);
    _saveLocalSettings();

    loadingChannels.add(channel);
    loadingChannels.refresh();

    if (_debounceTimers.containsKey(channel)) {
      _debounceTimers[channel]?.cancel();
    }

    _debounceTimers[channel] = Timer(
      const Duration(milliseconds: 400),
      () async {
        try {
          await _updateSettingUseCase.execute(
            channel: channel,
            isEnabled: isEnabled,
          );
        } catch (e) {
          _setChannelValue(channel, !isEnabled);
          Get.snackbar(
            'Lỗi',
            'Không thể cập nhật "$channel". Vui lòng thử lại.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        } finally {
          loadingChannels.remove(channel);
          loadingChannels.refresh();
          _debounceTimers.remove(channel);
        }
      },
    );
  }

  void _setChannelValue(String channel, bool value) {
    switch (channel) {
      case 'email':
        emailEnabled.value = value;
        break;
      case 'push':
        pushEnabled.value = value;
        break;
      case 'sms':
        smsEnabled.value = value;
        break;
    }
  }
}
