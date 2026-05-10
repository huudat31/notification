import 'package:notification/data/repositories/notification_local_repo.dart';

class GetSettingsUseCase {
  final NotificationLocalRepo _repository;

  GetSettingsUseCase(this._repository);

  Future<Map<String, dynamic>> execute() async {
    return await _repository.getSettings();
  }
}
