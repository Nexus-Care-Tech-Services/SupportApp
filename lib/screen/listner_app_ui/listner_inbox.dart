import 'dart:async';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support/main.dart';
import 'package:support/model/listner/listener_notification_model.dart';
import 'package:support/model/listner_display_model.dart';
import 'package:support/model/send_bell_icon_notification_model.dart';
import 'package:support/model/support_chat_model.dart';
import 'package:support/screen/call/call.dart';
import 'package:support/screen/support_chat/support_chat.dart';
import 'package:support/screen/video/video_call.dart';

import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/utils/color.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/reuasble_widget/image.dart';
import 'package:support/utils/reuasble_widget/utils.dart';

class ListnerInboxScreen extends StatefulWidget {
  const ListnerInboxScreen({Key? key}) : super(key: key);

  @override
  ListnerInboxScreenState createState() => ListnerInboxScreenState();
}

class ListnerInboxScreenState extends State<ListnerInboxScreen> {
  bool _loading = false;
  String id = "";
  String name = "";
  bool isListener = false;
  bool isProgressRunning = false;
  bool isFirstCall = true;
  Timer? _timer;
  bool ispopupVisible = false;
  final dateTimeFormat = DateFormat("dd-MM-yyyy hh:mm:ss a");

  ListenerNotification? _listenerNotification;
  ListnerDisplayModel? listenerDisplayModel1;

  SupportChatModel? supportChatModel;
  int chatCount = 0;
  dynamic response;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    id = prefs.getString("userId")!;
    name = prefs.getString("userName")!;
    isListener = prefs.getBool("isListener")!;

    setState(() {
      _loading = false;
    });
  }

  // Support Chat
  Future<void> apiSupportChat() async {
    try {
      setState(() {
        isProgressRunning = true;
      });

      supportChatModel = await APIServices.getSupportChatAPI(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID));
    } catch (e) {
      APIServices.updateErrorLogs(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID),
          'apiSupportChat()');
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          isProgressRunning = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    _loading = true;
    checkUIMode();
    loadData();
    apiSupportChat();
    getNotifications();
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
    _timer?.cancel();
  }

  void playDefaultNotificationSound() {
    FlutterRingtonePlayer.playNotification();
  }

  checkUIMode() async {
    ui_mode = SharedPreference.getValue(PrefConstants.UI_MODE) ?? "light";
  }

  //Get Listener Notifications
  Future<void> getNotifications() async {
    try {
      setState(() {
        isProgressRunning = true;
      });

      _listenerNotification = await APIServices.getListenerNotifications(
          int.parse(SharedPreference.getValue(PrefConstants.MERA_USER_ID)));
    } catch (e) {
      if (kDebugMode) {
        print("getNotifications $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          isProgressRunning = false;
        });
      }
    }
  }

  onCallPlaced(String uid, String? deviceToken, String listenerId) async {
    await AppUtils.handleMic(Permission.microphone, context);
    if (await Permission.microphone.isGranted) {
      EasyLoading.show(
          status: "Connecting with our secure server".tr,
          maskType: EasyLoadingMaskType.clear);
      var data = await APIServices.getAgoraTokens();

      if (deviceToken != null) {
        SharedPreference.setValue(
            PrefConstants.AGORA_UID_TWO, data["agora_uid_two"]);
        SharedPreference.setValue(
            PrefConstants.AGORA_TOKEN_TWO, data["token_two"]);

        ListnerDisplayModel model = await APIServices.getListnerDataById(
            SharedPreference.getValue(PrefConstants.MERA_USER_ID));
        if (model.data![0].busyStatus == 0) {
          await APIServices.getBusyOnline(true, model.data![0].id!.toString());
          await APIServices.getBusyOnline(true, uid);
        }

        Map<String, String> formData = {
          "from_id": SharedPreference.getValue(PrefConstants.MERA_USER_ID),
          "to_id": listenerId,
          "channel_name": data["room_id"],
          "user_id": data["agora_uid_one"],
          "token": data["token_one"],
        };

        // response = await APIServices.handleRecording(
            // formData, APIConstants.START_RECORDING);

        EasyLoading.dismiss();

        onCallJoin(
          channelId: data["room_id"],
          channelToken: data["token_one"],
          uid: int.parse(data["agora_uid_one"]),
          data: null,
        );
      }
    } else {
      EasyLoading.showInfo('Microphone Permission is Required'.tr);
    }
  }

  Future<void> onCallJoin({channelId, channelToken, uid, int? data}) async {
    if (listenerDisplayModel1 != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CallPage(
                usertype: listenerDisplayModel1!.data![0].userType == "user"
                    ? false
                    : true,
                isCaller: listenerDisplayModel1!.data![0].userType == "user"
                    ? false
                    : true,
                userid: listenerDisplayModel1!.data![0].userType == "user"
                    ? listenerDisplayModel1!.data![0].id.toString()
                    : SharedPreference.getValue(PrefConstants.MERA_USER_ID),
                listenerId: listenerDisplayModel1!.data![0].userType == "user"
                    ? SharedPreference.getValue(PrefConstants.MERA_USER_ID)
                    : listenerDisplayModel1!.data![0].id.toString(),
                senderImageUrl: listenerDisplayModel1!.data![0].image ??
                    'https://laravel.supportletstalk.com/manage/images/avatar/user.png',
                userName: listenerDisplayModel1?.data![0].name ?? "Seeker",
                uid: uid,
                channelName: channelId,
                token: channelToken,
                callId: data,
              )));
    } else {
      debugPrint('listenerDisplayModel1 is null');
    }
  }

  onVideoCallPlaced(String uid, String? deviceToken, String listenerId) async {
    await AppUtils.handleMic(Permission.microphone, context);
    if (await Permission.microphone.isGranted) {
      if (context.mounted) {
        await AppUtils.handleCamera(Permission.camera, context);
        if (await Permission.camera.isGranted) {
          EasyLoading.show(
              status: "Connecting with our secure server".tr,
              maskType: EasyLoadingMaskType.clear);
          var data = await APIServices.getAgoraTokens();

          if (deviceToken != null) {
            SharedPreference.setValue(
                PrefConstants.AGORA_UID_TWO, data["agora_uid_two"]);
            SharedPreference.setValue(
                PrefConstants.AGORA_TOKEN_TWO, data["token_two"]);

            ListnerDisplayModel model = await APIServices.getListnerDataById(
                SharedPreference.getValue(PrefConstants.MERA_USER_ID));
            if (model.data![0].busyStatus == 0) {
              await APIServices.getBusyOnline(
                  true, model.data![0].id!.toString());
              await APIServices.getBusyOnline(true, uid);
            }

            Map<String, String> formData = {
              "from_id": SharedPreference.getValue(PrefConstants.MERA_USER_ID),
              "to_id": listenerId,
              "channel_name": data["room_id"],
              "user_id": data["agora_uid_one"],
              "token": data["token_one"],
            };

            // response = await APIServices.handleRecording(
                // formData, APIConstants.START_RECORDING);

            EasyLoading.dismiss();

            onVideoCallJoin(
              channelId: data["room_id"],
              channelToken: data["token_one"],
              uid: int.parse(data["agora_uid_one"]),
              data: null,
            );
          }
        } else {
          EasyLoading.showInfo('Camera Permission is Required'.tr);
        }
      }
    } else {
      EasyLoading.showInfo('Microphone Permission is Required'.tr);
    }
  }

  Future<void> onVideoCallJoin(
      {channelId, channelToken, uid, int? data}) async {
    if (listenerDisplayModel1 != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => VideoCall(
                usertype: listenerDisplayModel1!.data![0].userType == "user"
                    ? false
                    : true,
                isCaller: listenerDisplayModel1!.data![0].userType == "user"
                    ? false
                    : true,
                userid: listenerDisplayModel1!.data![0].userType == "user"
                    ? listenerDisplayModel1!.data![0].id.toString()
                    : SharedPreference.getValue(PrefConstants.MERA_USER_ID),
                listenerId: listenerDisplayModel1!.data![0].userType == "user"
                    ? SharedPreference.getValue(PrefConstants.MERA_USER_ID)
                    : listenerDisplayModel1!.data![0].id.toString(),
                senderImageUrl: listenerDisplayModel1!.data![0].image ??
                    'https://laravel.supportletstalk.com/manage/images/avatar/user.png',
                userName: listenerDisplayModel1?.data![0].name ?? "Seeker",
                uid: uid,
                channelName: channelId,
                token: channelToken,
                callId: data,
              )));
    } else {
      debugPrint('listenerDisplayModel1 is null');
    }
  }

  void showInsufficientBalanceDialog(BuildContext context, String? name) {
    Widget rechargeButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: primaryColor,
        foregroundColor: colorWhite,
      ),
      child: Text("Cancel".tr),
      onPressed: () async {
        // Add logic to navigate to the recharge screen or perform recharge action
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Low Balance".tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            "$name has low balance".tr,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(
            height: 10,
          ),
          rechargeButton,
        ],
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              const SizedBox(height: 10),
              if (supportChatModel != null) ...{
                if (supportChatModel!.allMessages!.isNotEmpty) ...{
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: cardColor),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SupportChat(
                                  supportChatModel: supportChatModel,
                                )));
                      },
                      title: Text(
                        'Support'.tr,
                        style: TextStyle(color: textColor),
                      ),
                      subtitle: Text(
                        supportChatModel?.allMessages?[0].title ?? "",
                        style: TextStyle(
                          color: colorGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      leading: Image.asset(
                        "assets/logo.png",
                        // width: 100,
                        height: 80,
                      ),
                      trailing: Visibility(
                        visible: supportChatModel?.unreadMessages != 0
                            ? true
                            : false,
                        child: Container(
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                color: ui_mode == "dark"
                                    ? Colors.transparent
                                    : Colors.grey.shade300,
                                blurRadius: 10.0,
                                spreadRadius: 5.0),
                          ], shape: BoxShape.circle, color: Colors.green),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              supportChatModel?.unreadMessages.toString() ??
                                  "0",
                              style: TextStyle(color: textColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                },
              },
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const SizedBox(width: 15,),
                  Text(
                    'Notifcations',
                    style: TextStyle(
                      fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                    ),
                  ),
                  const SizedBox(width: 20,),
                  // InkWell(
                  //   onTap: () async {
                  //   },
                  //   child: Container(
                  //     padding: const EdgeInsets.all(10),
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(6),
                  //       color: ui_mode == "dark" ? detailScreenCardColor : primaryColor,
                  //     ),
                  //     alignment: Alignment.center,
                  //     child: const Text(
                  //       'Notify All',
                  //       style: TextStyle(
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.w700,
                  //         color: colorWhite,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 8,),
              _listenerNotification?.notifications?.length != null &&
                      _listenerNotification!.notifications!.isNotEmpty
                  ? Expanded(
                      child: Container(
                        color: backgroundColor,
                        padding:
                            const EdgeInsets.only(left: 15, right: 10, top: 10),
                        child: ListView.builder(
                          itemCount:
                              _listenerNotification!.notifications!.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return getNotificationCard(index);
                          },
                        ),
                      ),
                    )
                  : _noNotificationFound(),
              const SizedBox(
                height: 20,
              ),
            ],
          );
  }

  Widget _noNotificationFound() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "No Notifications".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget getNotificationCard(int index) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 5, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: ui_mode == "dark"
                ? Colors.transparent
                : const Color.fromARGB(255, 49, 49, 49).withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _listenerNotification!.notifications![index].userDp != ""
              ? showImage(
                  20,
                  _listenerNotification!.notifications![index].userDp!
                          .startsWith('https')
                      ? NetworkImage(
                          _listenerNotification!.notifications![index].userDp!)
                      : NetworkImage(APIConstants.BASE_URL +
                          _listenerNotification!.notifications![index].userDp!),
                )
              : showIcon(24, colorWhite, Icons.person, 20, Colors.blueGrey),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _listenerNotification!.notifications![index].userName!,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                dateTimeFormat.format(DateTime.parse(_listenerNotification!
                    .notifications![index].createdAt!
                    .toString())),
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          PopupMenuButton<String>(
              icon: Icon(Icons.more_vert,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
              color: ui_mode == "dark"
                  ? const Color(0xff393E46)
                  : const Color(0xfff7f8fc),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    value: 'Notify User',
                    child: InkWell(
                      onTap: () async {
                        Navigator.pop(context, "Notify User");
                        ListnerDisplayModel model = await APIServices.getUserDataById(_listenerNotification!.notifications![index].userId!.toString());
                        String token = model.data![0].deviceToken!;
                        EasyLoading.show(status: 'loading...'.tr);

                        SendBellNotificationModel? notificationModel =
                            await APIServices.sendNotificationUser(
                                SharedPreference.getValue(
                                    PrefConstants.LISTENER_NAME),
                                SharedPreference.getValue(
                                    PrefConstants.LISTENER_IMAGE),
                                _listenerNotification!
                                    .notifications![index].userId!);
                        await APIServices.notifyUser(deviceToken: token,name: SharedPreference.getValue(
                            PrefConstants.LISTENER_NAME),imageDP: SharedPreference.getValue(
                            PrefConstants.LISTENER_IMAGE),type: "listner");

                        if (notificationModel != null) {
                          EasyLoading.showSuccess('Notification Sent!!');
                          playDefaultNotificationSound();
                          EasyLoading.dismiss();
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.notifications,
                              color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          Text(
                            'Notify User'.tr,
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'Call User',
                    child: InkWell(
                      onTap: () async {
                        Navigator.pop(context, "Call User");
                        if (_listenerNotification!.notifications![index].userDp!
                            .startsWith('https://')) {
                          listenerDisplayModel1 =
                              await APIServices.getUserDataById(
                            _listenerNotification!.notifications![index].userId
                                .toString(),
                          );

                          debugPrint(
                              "token ${listenerDisplayModel1?.data![0].deviceToken}");

                          String token =
                              "${listenerDisplayModel1?.data![0].deviceToken}";
                          String userId =
                              "${listenerDisplayModel1?.data![0].id}";

                          String? amount =
                              await APIServices.getWalletAmount(userId);
                          debugPrint('User Balance for UID $userId: $amount');
                          if (context.mounted) {
                            if (double.parse(amount!) >= 6) {
                              debugPrint(double.parse(amount).toString());
                              if (listenerDisplayModel1!.data![0].busyStatus ==
                                  0) {
                                onCallPlaced(
                                  userId,
                                  token,
                                  _listenerNotification!
                                      .notifications![index].userId
                                      .toString(),
                                );
                              } else {
                                EasyLoading.showInfo('User is Busy');
                              }
                            } else {
                              showInsufficientBalanceDialog(context,
                                  listenerDisplayModel1?.data![0].name);
                            }
                          }
                        } else {
                          listenerDisplayModel1 =
                              await APIServices.getListnerDataById(
                            _listenerNotification!.notifications![index].userId
                                .toString(),
                          );

                          debugPrint(
                              "token ${listenerDisplayModel1?.data![0].deviceToken}");

                          String token =
                              "${listenerDisplayModel1?.data![0].deviceToken}";
                          String userId =
                              "${listenerDisplayModel1?.data![0].id}";

                          String? amount =
                              await APIServices.getWalletAmount(userId);
                          debugPrint('User Balance for UID $userId: $amount');
                          if (context.mounted) {
                            if (double.parse(amount!) >= 6) {
                              debugPrint(double.parse(amount).toString());
                              if (listenerDisplayModel1!
                                      .data![0].onlineStatus ==
                                  1) {
                                if (listenerDisplayModel1!
                                        .data![0].busyStatus ==
                                    0) {
                                  onCallPlaced(
                                    userId,
                                    token,
                                    _listenerNotification!
                                        .notifications![index].userId
                                        .toString(),
                                  );
                                } else {
                                  EasyLoading.showInfo('Listner is Busy');
                                }
                              } else {
                                EasyLoading.showInfo('Listner is Offline');
                              }
                            } else {
                              showInsufficientBalanceDialog(context,
                                  listenerDisplayModel1?.data![0].name);
                            }
                          }
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.call, color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          Text(
                            'Call User'.tr,
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'VCall User',
                    child: InkWell(
                      onTap: () async {
                        Navigator.pop(context, "VCall User");
                        if (_listenerNotification!.notifications![index].userDp!
                            .startsWith('https://')) {
                          listenerDisplayModel1 =
                              await APIServices.getUserDataById(
                            _listenerNotification!.notifications![index].userId
                                .toString(),
                          );

                          debugPrint(
                              "token ${listenerDisplayModel1?.data![0].deviceToken}");

                          String token =
                              "${listenerDisplayModel1?.data![0].deviceToken}";
                          String userId =
                              "${listenerDisplayModel1?.data![0].id}";

                          String? amount =
                              await APIServices.getWalletAmount(userId);
                          debugPrint('User Balance for UID $userId: $amount');
                          if (context.mounted) {
                            if (double.parse(amount!) >= 18) {
                              debugPrint(double.parse(amount).toString());

                              if (listenerDisplayModel1!.data![0].busyStatus ==
                                  0) {
                                onVideoCallPlaced(
                                  userId,
                                  token,
                                  _listenerNotification!
                                      .notifications![index].userId
                                      .toString(),
                                );
                              } else {
                                EasyLoading.showInfo('User is Busy');
                              }
                            } else {
                              showInsufficientBalanceDialog(context,
                                  listenerDisplayModel1?.data![0].name);
                            }
                          }
                        } else {
                          listenerDisplayModel1 =
                              await APIServices.getListnerDataById(
                            _listenerNotification!.notifications![index].userId
                                .toString(),
                          );

                          debugPrint(
                              "token ${listenerDisplayModel1?.data![0].deviceToken}");

                          String token =
                              "${listenerDisplayModel1?.data![0].deviceToken}";
                          String userId =
                              "${listenerDisplayModel1?.data![0].id}";

                          String? amount =
                              await APIServices.getWalletAmount(userId);
                          debugPrint('User Balance for UID $userId: $amount');
                          if (context.mounted) {
                            if (double.parse(amount!) >= 18) {
                              debugPrint(double.parse(amount).toString());
                              if (listenerDisplayModel1!
                                      .data![0].onlineStatus ==
                                  1) {
                                if (listenerDisplayModel1!
                                        .data![0].busyStatus ==
                                    0) {
                                  onVideoCallPlaced(
                                    userId,
                                    token,
                                    _listenerNotification!
                                        .notifications![index].userId
                                        .toString(),
                                  );
                                } else {
                                  EasyLoading.showInfo('Listner is Busy');
                                }
                              } else {
                                EasyLoading.showInfo('Listner is Offline');
                              }
                            } else {
                              showInsufficientBalanceDialog(context,
                                  listenerDisplayModel1?.data![0].name);
                            }
                          }
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.videocam, color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          Text(
                            'VCall User'.tr,
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              }),
        ],
      ),
    );
  }
}
