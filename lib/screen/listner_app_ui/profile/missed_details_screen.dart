import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/model/send_bell_icon_notification_model.dart';
import 'package:support/utils/color.dart';
import 'package:support/main.dart';
import 'package:support/model/listner_display_model.dart';
import 'package:support/model/missed_data_model.dart';
import 'package:support/screen/call/call.dart';
import 'package:support/screen/video/video_call.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/reuasble_widget/image.dart';
import 'package:support/utils/reuasble_widget/toast_widget.dart';
import 'package:support/utils/reuasble_widget/utils.dart';

class MissedDetailScreen extends StatefulWidget {
  final String type;

  const MissedDetailScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<MissedDetailScreen> createState() => _MissedDetailScreenState();
}

class _MissedDetailScreenState extends State<MissedDetailScreen> {
  List<MissedDataModel> list = [];
  ListnerDisplayModel? listenerDisplayModel1;
  final dateTimeFormat = DateFormat("dd-MM-yyyy hh:mm:ss a");
  int chat = 0, call = 0, vc = 0;
  String? missedcall = "0",
      missedchats = "0",
      missedvideocall = "0",
      missedcount = "0";

  dynamic response;

  void playDefaultNotificationSound() {
    FlutterRingtonePlayer.playNotification();
  }

  getListnerMissedData() async {
    List<MissedDataModel> data = await APIServices.getListnerMissedData(
        SharedPreference.getValue(PrefConstants.MERA_USER_ID));
    for (int i = 0; i < data.length; i++) {
      setState(() {
        list.add(data[i]);
      });
      if (data[i].type == "chat") {
        chat += 1;
      }
      if (data[i].type == "call") {
        call += 1;
      }
      if (data[i].type == "video") {
        vc += 1;
      }
    }
    setState(() {
      missedcall = call.toString();
      missedchats = chat.toString();
      missedvideocall = vc.toString();
      int total = call + vc + chat;
      missedcount = total.toString();
    });
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
              await APIServices.getBusyOnline(true, model.data![0].id!.toString());
              await APIServices.getBusyOnline(true, uid);
            }

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
        Navigator.of(context).pop();
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

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(Platform.isAndroid) {
      secureApp();
    }
    getListnerMissedData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: cardColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: colorWhite,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: primaryColor,
          centerTitle: true,
          title: Text(
            'Missed Details'.tr,
            style: const TextStyle(color: colorWhite),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: missedcount == "0"
              ? noMissedDataFound()
              : Column(
                  children: [
                    ListView.builder(
                      itemCount: list.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if (widget.type == list[index].type) {
                          return getMissedDataCard(index);
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget noMissedDataFound() {
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
                "No Missed Data".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ui_mode == "dark" ? colorWhite : colorBlack),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget getMissedDataCard(int index) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 5, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: detailScreenCardColor,
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
          list[index].userImage == "null"
              ? showIcon(24, colorWhite, Icons.person, 20, Colors.blueGrey)
              : list[index].userImage!.startsWith("https://")
                  ? showImage(
                      20,
                      NetworkImage(list[index].userImage!),
                    )
                  : showImage(
                      20,
                      NetworkImage(
                          APIConstants.BASE_URL + list[index].userImage!)),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                list[index].userName!,
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
                dateTimeFormat.format(DateTime.parse(list[index].date!)),
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (list[index].type == 'chat') ...{
            Icon(
              Icons.chat,
              color: textColor,
              size: 25,
            ),
          },
          if (list[index].type == 'call') ...{
            Icon(
              Icons.call,
              color: textColor,
              size: 25,
            ),
          },
          if (list[index].type == 'video') ...{
            Icon(
              Icons.videocam,
              color: textColor,
              size: 25,
            ),
          },
          const SizedBox(
            width: 10,
          ),
          PopupMenuButton<String>(
              icon: Icon(Icons.more_vert,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
              color: ui_mode == "dark"
                  ? const Color(0xff393E46)
                  : const Color(0xfff7f8fc),
              itemBuilder: (BuildContext context) {
                return [
                  if (list[index].type == 'call') ...{
                    PopupMenuItem(
                      value: 'Notify User',
                      child: InkWell(
                        onTap: () async {
                          Navigator.pop(context, "Notify User");
                          ListnerDisplayModel model = await APIServices.getUserDataById(list[index].userId!);
                          String token = model.data![0].deviceToken!;
                          EasyLoading.show(status: 'loading...'.tr);

                          SendBellNotificationModel? notificationModel =
                          await APIServices.sendNotificationUser(
                              SharedPreference.getValue(
                                  PrefConstants.LISTENER_NAME),
                              SharedPreference.getValue(
                                  PrefConstants.LISTENER_IMAGE),
                                  int.parse(list[index].userId!));

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
                          if (list[index].userImage!.startsWith('https://')) {
                            listenerDisplayModel1 =
                                await APIServices.getUserDataById(
                              list[index].userId.toString(),
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
                                    list[index].userId.toString(),
                                  );
                                } else {
                                  toastshowDefaultSnackbar(context,
                                      'User is Busy', false, primaryColor);
                                }
                              } else {
                                showInsufficientBalanceDialog(
                                    context, listenerDisplayModel1?.data![0].name);
                              }
                            }
                          } else {
                            listenerDisplayModel1 =
                                await APIServices.getListnerDataById(
                              list[index].userId.toString(),
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
                                if (listenerDisplayModel1!.data![0].onlineStatus ==
                                    1) {
                                  if (listenerDisplayModel1!.data![0].busyStatus ==
                                      0) {
                                    onCallPlaced(
                                      userId,
                                      token,
                                      list[index].userId.toString(),
                                    );
                                  } else {
                                    toastshowDefaultSnackbar(
                                        context,
                                        'Listner is Busy'.tr,
                                        false,
                                        primaryColor);
                                  }
                                } else {
                                  toastshowDefaultSnackbar(
                                      context,
                                      'Listner is Offline'.tr,
                                      false,
                                      primaryColor);
                                }
                              } else {
                                showInsufficientBalanceDialog(
                                    context, listenerDisplayModel1?.data![0].name);
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
                  },
                  if (list[index].type == 'video') ...{
                    PopupMenuItem(
                      value: 'Notify User',
                      child: InkWell(
                        onTap: () async {
                          Navigator.pop(context, "Notify User");
                          ListnerDisplayModel model = await APIServices.getUserDataById(list[index].userId!);
                          String token = model.data![0].deviceToken!;
                          EasyLoading.show(status: 'loading...'.tr);

                          SendBellNotificationModel? notificationModel =
                          await APIServices.sendNotificationUser(
                              SharedPreference.getValue(
                                  PrefConstants.LISTENER_NAME),
                              SharedPreference.getValue(
                                  PrefConstants.LISTENER_IMAGE),
                              int.parse(list[index].userId!));

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
                      value: 'VCall User',
                      child: InkWell(
                        onTap: () async {
                          Navigator.pop(context, "VCall User");
                          if (list[index].userImage!.startsWith('https://')) {
                            listenerDisplayModel1 =
                                await APIServices.getUserDataById(
                              list[index].userId.toString(),
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
                                    list[index].userId.toString(),
                                  );
                                } else {
                                  toastshowDefaultSnackbar(context,
                                      'User is Busy'.tr, false, primaryColor);
                                }
                              } else {
                                showInsufficientBalanceDialog(
                                    context, listenerDisplayModel1?.data![0].name);
                              }
                            }
                          } else {
                            listenerDisplayModel1 =
                                await APIServices.getListnerDataById(
                              list[index].userId.toString(),
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
                                if (listenerDisplayModel1!.data![0].onlineStatus ==
                                    1) {
                                  if (listenerDisplayModel1!.data![0].busyStatus ==
                                      0) {
                                    onVideoCallPlaced(
                                      userId,
                                      token,
                                      list[index].userId.toString(),
                                    );
                                  } else {
                                    toastshowDefaultSnackbar(
                                        context,
                                        'Listner is Busy'.tr,
                                        false,
                                        primaryColor);
                                  }
                                } else {
                                  toastshowDefaultSnackbar(
                                      context,
                                      'Listner is Offline'.tr,
                                      false,
                                      primaryColor);
                                }
                              } else {
                                showInsufficientBalanceDialog(
                                    context, listenerDisplayModel1?.data![0].name);
                              }
                            }
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.videocam,
                                color: Colors.blueAccent),
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
                  },
                  if (list[index].type == 'chat') ...{
                    PopupMenuItem(
                      value: 'Notify User',
                      child: InkWell(
                        onTap: () async {
                          Navigator.pop(context, "Notify User");
                          ListnerDisplayModel model = await APIServices.getUserDataById(list[index].userId!);
                          String token = model.data![0].deviceToken!;
                          EasyLoading.show(status: 'loading...'.tr);

                          SendBellNotificationModel? notificationModel =
                              await APIServices.sendNotificationUser(
                                  SharedPreference.getValue(
                                      PrefConstants.LISTENER_NAME),
                                  SharedPreference.getValue(
                                      PrefConstants.LISTENER_IMAGE),
                                  int.parse(list[index].userId!));

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
                  }
                ];
              }),
        ],
      ),
    );
  }
}
