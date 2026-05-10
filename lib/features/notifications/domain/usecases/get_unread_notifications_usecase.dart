import 'package:notification/data/models/notification_model.dart';
import 'package:notification/data/repositories/notification_local_repo.dart';
import '../../../../core/constants/api_constants.dart';
import 'get_notifications_usecase.dart';

class GetUnreadNotificationsUseCase {
  final NotificationLocalRepo _repository;

  GetUnreadNotificationsUseCase(this._repository);

  List<NotificationModel> getCached() =>
      _repository.getCached().where((n) => n.isUnread).toList();

  Future<GetNotificationsResult> execute({
    required List<NotificationModel> existing,
    String? cursor,
    int limit = ApiConstants.defaultPageLimit,
  }) async {
    final page = await _repository.getUnreadNotifications(
      cursor: cursor,
      limit: limit,
    );
    final existingIds = {for (final n in existing) n.id};
    final newItems = page.items
        .where((n) => !existingIds.contains(n.id))
        .toList();
    final merged = cursor == null ? page.items : [...existing, ...newItems];

    return GetNotificationsResult(
      notifications: merged,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
  }
}
