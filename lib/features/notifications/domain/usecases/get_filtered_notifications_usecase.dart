import 'package:notification/data/models/notification_model.dart';
import 'package:notification/data/repositories/notification_local_repo.dart';
import '../../../../core/constants/api_constants.dart';
import 'get_notifications_usecase.dart';

class GetFilteredNotificationsUseCase {
  final NotificationLocalRepo _repository;

  GetFilteredNotificationsUseCase(this._repository);

  List<NotificationModel> getCached({bool? read, String? channel}) {
    var cached = _repository.getCached();
    if (read != null) {
      cached = cached.where((n) => n.read == read).toList();
    }
    if (channel != null) {
      cached = cached.where((n) => n.channel == channel).toList();
    }
    return cached;
  }

  Future<GetNotificationsResult> execute({
    required List<NotificationModel> existing,
    bool? read,
    String? channel,
    String? cursor,
    int limit = ApiConstants.defaultPageLimit,
  }) async {
    final page = await _repository.getFilteredNotifications(
      read: read,
      channel: channel,
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
