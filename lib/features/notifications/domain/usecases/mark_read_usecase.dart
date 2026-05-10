import '../../../../data/repositories/notification_repository.dart';

class MarkReadResult {
  final bool success;
  final String? message;

  const MarkReadResult({required this.success, this.message});
}

class MarkReadUseCase {
  final NotificationRepository _repository;

  MarkReadUseCase(this._repository);

  Future<MarkReadResult> execute(String id) async {
    try {
      await _repository.markAsRead(id);

      return const MarkReadResult(success: true);
    } catch (e, st) {
      return MarkReadResult(success: false, message: e.toString());
    }
  }
}
