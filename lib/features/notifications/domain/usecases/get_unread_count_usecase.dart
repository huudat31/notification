import 'package:notification/data/repositories/notification_repository.dart';

class GetUnreadCountUseCase {
  final NotificationRepository _repository;

  GetUnreadCountUseCase(this._repository);

  Future<int> execute() async {
    return await _repository.getUnreadCount();
  }
}
