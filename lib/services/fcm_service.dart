import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notification/core/constants/hive_constants.dart';

import 'package:notification/data/models/notification_model.dart';
import 'package:notification/firebase_options.dart';
import 'package:notification/services/hive_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(HiveTypeIds.notificationModel)) {
    Hive.registerAdapter(NotificationModelAdapter());
  }

  final box = await Hive.openBox<NotificationModel>(HiveBoxes.notifications);

  final id = message.data['id'] as String?;
  if (id != null && id.isNotEmpty) {
    final model = NotificationModel()
      ..id = id
      ..title = message.notification?.title ?? (message.data['title'] ?? '')
      ..body = message.notification?.body ?? (message.data['body'] ?? '')
      ..status = 'unread'
      ..read = false
      ..channel = (message.data['channel'] as String?) ?? 'push'
      ..createdAt =
          DateTime.tryParse(message.data['created_at'] ?? '') ?? DateTime.now()
      ..imageUrl = message.data['image_url'] as String?
      ..actionUrl = message.data['action_url'] as String?;

    await box.put(id, model);
  }

  await Hive.close();
}

class FcmService {
  static const _channelId = 'notifications_channel';
  static const _channelName = 'App Notifications';

  final FirebaseMessaging? _injectedFcm;
  final FlutterLocalNotificationsPlugin? _injectedLocalNotif;

  late final FirebaseMessaging _fcm =
      _injectedFcm ?? FirebaseMessaging.instance;
  late final FlutterLocalNotificationsPlugin _localNotif =
      _injectedLocalNotif ?? FlutterLocalNotificationsPlugin();

  void Function(NotificationModel)? onForegroundNotification;
  void Function(NotificationModel)? onNotificationClick;

  FcmService({
    FirebaseMessaging? fcm,
    FlutterLocalNotificationsPlugin? localNotif,
  }) : _injectedFcm = fcm,
       _injectedLocalNotif = localNotif;

  FcmService.stub() : _injectedFcm = null, _injectedLocalNotif = null;

  Future<void> initialise() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await _setupLocalNotifications();

    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      _handleMessageOpenedApp(initial);
    }

    final token = await getToken();
  }

  Future<String?> getToken() async {
    String? token = await _fcm.getToken();

    if (token == null) {
      await Future.delayed(const Duration(seconds: 2));
      token = await _fcm.getToken();
    }

    return token;
  }

  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _showLocalNotification(message);

    final model = _parseMessage(message);
    if (model != null) {
      HiveService.saveNotifications([model]);
      onForegroundNotification?.call(model);
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    final model = _parseMessage(message);
    if (model != null) {
      onNotificationClick?.call(model);
    }
  }

  NotificationModel? _parseMessage(RemoteMessage message) {
    try {
      final data = message.data;

      if (data['id'] == null) return null;

      return NotificationModel()
        ..id = data['id'] as String
        ..title = message.notification?.title ?? (data['title'] ?? '')
        ..body = message.notification?.body ?? (data['body'] ?? '')
        ..status = 'unread'
        ..read = false
        ..channel = (data['channel'] as String?) ?? 'push'
        ..createdAt =
            DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now()
        ..imageUrl = data['image_url'] as String?
        ..actionUrl = data['action_url'] as String?;
    } catch (e, st) {
      return null;
    }
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotif.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);

          final model = NotificationModel()
            ..id = (data['id'] as String?) ?? ''
            ..title = (data['title'] as String?) ?? ''
            ..body = (data['body'] as String?) ?? ''
            ..status = 'unread'
            ..read = false
            ..channel = (data['channel'] as String?) ?? 'push'
            ..createdAt =
                DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now()
            ..imageUrl = data['image_url'] as String?
            ..actionUrl = data['action_url'] as String?;

          onNotificationClick?.call(model);
        }
      },
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.high,
      playSound: true,
    );

    await _localNotif
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? message.data['title'];
    final body = message.notification?.body ?? message.data['body'];

    if (title == null && body == null) return;

    await _localNotif.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }
}
