import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/sharedpreference/sharedpreference.dart';

FlutterLocalNotificationsPlugin localNotification =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await localNotification.initialize(initializationSettings);
}

Future<void> showNotification(int val) async {
  initializeNotifications();
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'ongoing id',
    'ongoing content',
    importance: Importance.max,
    priority: Priority.high,
    ongoing: true,
    autoCancel: false,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  if (val == 1) {
    await localNotification.show(
      0,
      SharedPreference.getValue(PrefConstants.LISTENER_NAME),
      'You are Online on Support App!'.tr,
      platformChannelSpecifics,
    );
  } else if (val == 0) {
    await localNotification.cancel(0);
  }
}

Future<void> showChatNotification() async {
  initializeNotifications();
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'ongoing id',
    'ongoing content',
    importance: Importance.max,
    priority: Priority.high,
    ongoing: true,
    autoCancel: false,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await localNotification.show(
    0,
    'Chat Session Active'.tr,
    'GET BACK TO SESSION'.tr,
    platformChannelSpecifics,
  );
}
