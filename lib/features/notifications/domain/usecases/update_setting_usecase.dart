import 'package:notification/data/repositories/notification_local_repo.dart';

class UpdateSettingUseCase {
  final NotificationLocalRepo _repository;

  UpdateSettingUseCase(this._repository);

  Future<void> execute({
    required String channel,
    required bool isEnabled,
  }) async {
    await _repository.updateSetting(channel: channel, isEnabled: isEnabled);
  }
}
