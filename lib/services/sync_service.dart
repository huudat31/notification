import 'dart:async';

import '../features/notifications/domain/usecases/sync_queue_usecase.dart';
import 'connectivity_service.dart';

class SyncService {
  final ConnectivityService _connectivity;
  final SyncQueueUseCase _syncQueueUseCase;

  StreamSubscription<bool>? _sub;
  bool _isSyncing = false;

  SyncService({
    required ConnectivityService connectivity,
    required SyncQueueUseCase syncQueueUseCase,
  }) : _connectivity = connectivity,
       _syncQueueUseCase = syncQueueUseCase;

  void startListening() {
    _sub = _connectivity.statusStream.listen((isOnline) {
      if (isOnline) {
        processQueue();
      }
    });

    if (_connectivity.isOnline) processQueue();
  }

  Future<void> processQueue() async {
    if (_isSyncing) {
      return;
    }
    _isSyncing = true;
    try {
      await _syncQueueUseCase.execute();
    } catch (e, st) {
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() => _sub?.cancel();
}
