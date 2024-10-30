// ignore_for_file: file_names

import 'dart:developer';

// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:support/utils/color.dart';
import 'package:vibration/vibration.dart';

class PushNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'));

    _notificationsPlugin.initialize(initializationSettings);
  }

  static void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      NotificationDetails notificationDetails = const NotificationDetails(
          android: AndroidNotificationDetails(
        'support1',
        'ride',
        channelDescription: 'Start | Ride',
        importance: Importance.high,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        playSound: true,
        onlyAlertOnce: true,
        timeoutAfter: 30,
        sound: RawResourceAndroidNotificationSound('customsound'),
      ));
      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: message.data['route'],
      );
    } catch (error) {
      log("$error");
    }
  }

  //Vibrating the Device for 500milliseconds
  static void vibrateDevice() {
    Vibration.vibrate(duration: 500);
  }

//Playing Notification Sound
  static void playNotificationSound() {
    FlutterRingtonePlayer.playNotification();
  }

  static void displayNotifications(RemoteMessage message) async {
    try {
      //Displaying a snack bar notification with customizable parameters.
      if (message.notification!.title!.startsWith("Incoming Chat")) {
      } else {
        playNotificationSound();
        vibrateDevice();
        Get.snackbar(
          '',
          '',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
          backgroundColor: colorWhite,
          dismissDirection: DismissDirection.horizontal,
          titleText: Row(
            children: [
              Container(
                  color: Colors.white54,
                  width: 15,
                  height: 15,
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/logo2.png',
                    height: 10,
                    width: 10,
                  )),
              const SizedBox(
                width: 8,
              ),
              const Text(
                'Support \u2022 now',
                style: TextStyle(
                  fontSize: 11,
                ),
              ),
            ],
          ),
          messageText: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.notification!.title ?? 'Notification',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                message.notification!.body ?? 'Notification body',
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
              if (message.data.containsKey("link")) ...{
                const SizedBox(
                  height: 8,
                ),
                Text(
                  message.data["link"],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
              },
            ],
          ),
        );
      }
    } catch (error) {
      log("$error");
    }
  }
}
