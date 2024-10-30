import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:support/push_notification/push_notification.dart';
import 'package:support/screen/chat/incoming_chat_screen.dart';
import 'package:support/screen/listner_app_ui/listner_homescreen.dart';
import 'package:support/screen/video/incoming_video_call_screen.dart';

import 'package:support/screen/call/incoming_call_screen.dart';

class Messaging {
  static void showMessage() {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    firebaseMessaging.getInitialMessage().then((message) {
      if (message != null &&
          message.data['channel_id'] != null &&
          message.data['type'] == "video") {
        Get.to(
          () => IncomingVideoCallScreen(
            userid: message.data['userid'],
            listenerId: message.data['listenerId'],
            name: message.data['name'],
            senderImageUrl: message.data['sender_image'] ??
                'https://laravel.supportletstalk.com/manage/images/avatar/user.png',
            channelId: message.data['channel_id'],
            channelToken: message.data['channel_token'],
            uid: int.parse(message.data["user_id"] ?? "0"),
          ),
        );
      } else if (message != null &&
          message.data['channel_id'] != null &&
          message.data['type'] == "chat") {
        Get.to(
          () => IncomingChatScreen(
            userid: message.data['userid'],
            listenerId: message.data['listenerId'],
            name: message.data['name'],
            senderImageUrl: message.data['sender_image'] ??
                'https://laravel.supportletstalk.com/manage/images/avatar/user.png',
            channelId: message.data['channel_id'],
            channelToken: message.data['channel_token'],
            uid: int.parse(message.data["user_id"] ?? "0"),
            toUserId: '',
          ),
        );
      } else if (message != null && message.data['channel_id'] != null) {
        Get.to(
          () => IncomingCallScreen(
            usertype: message.data['usertype'],
            userid: message.data['userid'],
            listenerId: message.data['listenerId'],
            name: message.data['name'],
            senderImageUrl: message.data['sender_image'] ??
                'https://laravel.supportletstalk.com/manage/images/avatar/user.png',
            channelId: message.data['channel_id'],
            channelToken: message.data['channel_token'],
            uid: int.parse(message.data["user_id"] ?? "0"),
          ),
        );
      } else if (message != null) {
        if (message.data['chat'] != 'agora') {
          PushNotificationService.displayNotifications(message);
        }
        if (message.notification!.title!.contains("connect with you")) {
          Get.to(() => const ListnerHomeScreen(index: 1));
        }
      }
    });

    /// foreground work
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      if (message?.data['channel_id'] != null &&
          message?.data['type'] == "video") {
        PushNotificationService.display(message!);
        Get.to(
          () => IncomingVideoCallScreen(
            userid: message.data['userid'],
            listenerId: message.data['listenerId'],
            toUserId: message.data['to_user_id'],
            name: message.data['name'],
            senderImageUrl: message.data['sender_image'] ??
                'https://laravel.supportletstalk.com/manage/images/avatar/user.png',
            channelId: message.data['channel_id'],
            channelToken: message.data['channel_token'],
            uid: int.parse(message.data["user_id"] ?? "0"),
          ),
        );
      } else if (message != null &&
          message.data['channel_id'] != null &&
          message.data['type'] == "chat") {
        PushNotificationService.display(message);
        Get.to(
          () => IncomingChatScreen(
            userid: message.data['userid'],
            listenerId: message.data['listenerId'],
            name: message.data['name'],
            senderImageUrl: message.data['sender_image'] ??
                'https://laravel.supportletstalk.com/manage/images/avatar/user.png',
            channelId: message.data['channel_id'],
            channelToken: message.data['channel_token'],
            uid: int.parse(message.data["user_id"] ?? "0"),
            toUserId: '',
          ),
        );
      } else if (message?.data['channel_id'] != null) {
        PushNotificationService.display(message!);
        Get.to(
          () => IncomingCallScreen(
            usertype: message.data['usertype'],
            userid: message.data['userid'],
            listenerId: message.data['listenerId'],
            toUserId: message.data['to_user_id'],
            name: message.data['name'],
            senderImageUrl: message.data['sender_image'] ??
                'https://laravel.supportletstalk.com/manage/images/avatar/user.png',
            channelId: message.data['channel_id'],
            channelToken: message.data['channel_token'],
            uid: int.parse(message.data["user_id"] ?? "0"),
          ),
        );
      } else if (message != null) {
        if (message.data['chat'] != 'agora') {
          PushNotificationService.displayNotifications(message);
        }
      }
    });

    // When the app is in background but open and user taps
    // on the notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data['channel_id'] != null &&
          message.data['type'] == "video") {
        PushNotificationService.display(message);
        Get.to(
          () => IncomingVideoCallScreen(
            userid: message.data['userid'],
            listenerId: message.data['listenerId'],
            name: message.data['name'],
            senderImageUrl: message.data['sender_image'] ??
                'https://laravel.supportletstalk.com/manage/images/avatar/user.png',
            channelId: message.data['channel_id'],
            channelToken: message.data['channel_token'],
            uid: int.parse(message.data["user_id"] ?? "0"),
          ),
        );
      }
      else if (message.data['channel_id'] != null &&
          message.data['type'] == "chat") {
        PushNotificationService.display(message);
        Get.to(
              () => IncomingChatScreen(
            userid: message.data['userid'],
            listenerId: message.data['listenerId'],
            name: message.data['name'],
            senderImageUrl: message.data['sender_image'] ??
                'https://laravel.supportletstalk.com/manage/images/avatar/user.png',
            channelId: message.data['channel_id'],
            channelToken: message.data['channel_token'],
            uid: int.parse(message.data["user_id"] ?? "0"),
            toUserId: '',
          ),
        );
      }
      else if (message.data['channel_id'] != null) {
        PushNotificationService.display(message);
        Get.to(
          () => IncomingCallScreen(
            usertype: message.data['usertype'],
            userid: message.data['userid'],
            listenerId: message.data['listenerId'],
            name: message.data['name'],
            senderImageUrl: message.data['sender_image'] ??
                'https://laravel.supportletstalk.com/manage/images/avatar/user.png',
            channelId: message.data['channel_id'],
            channelToken: message.data['channel_token'],
            uid: int.parse(message.data["user_id"] ?? "0"),
          ),
        );
      } else {
        PushNotificationService.display(message);
        if (message.data['chat'] != 'agora') {
          PushNotificationService.displayNotifications(message);
        }
        if (message.notification!.title!.contains("connect with you")) {
          Get.to(() => const ListnerHomeScreen(index: 1));
        }
      }
    });
  }
}
