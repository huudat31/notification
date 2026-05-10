import 'package:notification/data/repositories/notification_repository.dart';

class DeleteNotificationUseCase {
  final NotificationRepository _repository;

  DeleteNotificationUseCase(this._repository);

  Future<void> execute(String id) async {
    return await _repository.deleteNotification(id);
  }
}
