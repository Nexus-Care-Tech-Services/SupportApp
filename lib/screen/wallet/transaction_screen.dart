import 'dart:developer';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:support/main.dart';
import 'package:support/model/listner_display_model.dart';
import 'package:support/model/send_bell_icon_notification_model.dart';
import 'package:support/screen/home/helper_detail_screen.dart';
import 'package:support/screen/video/video_call.dart';

import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/utils/color.dart';
import 'package:support/model/listner_display_model.dart' as listner;
import 'package:support/model/show_transaction_model.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/reuasble_widget/shimmer_progress_widget.dart';
import 'package:support/screen/call/call.dart';
import 'package:support/utils/reuasble_widget/utils.dart';

class TransactionScreen extends StatefulWidget {
  final listner.Data? listnerDisplayModel;

  const TransactionScreen({
    Key? key,
    this.listnerDisplayModel,
  }) : super(key: key);

  @override
  TransactionScreenState createState() => TransactionScreenState();
}

class TransactionScreenState extends State<TransactionScreen> {
  bool isProgressRunning = false;
  final dateTimeFormat = DateFormat("dd-MM-yyyy hh:mm:ss a");
  ShowTransactionModel? transactionhistorydata = ShowTransactionModel();

  // TransactionHistory transactionHistory;
  bool isloading = true;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    Future.delayed(Duration.zero, () {
      isloading = false;
    });

    _getTransactionHistory();
  }

  void playDefaultNotificationSound() {
    FlutterRingtonePlayer.playNotification();
  }

  Future<void> _getTransactionHistory() async {
    try {
      setState(() {
        isProgressRunning = true;
      });
      transactionhistorydata = (await APIServices.getTransactionHistory(
        SharedPreference.getValue(PrefConstants.MERA_USER_ID) ?? '',
      ));
    } catch (error) {
      debugPrint("$error error");
    } finally {
      if (mounted) {
        setState(() {
          isProgressRunning = false;
        });
      }
    }
  }

  dynamic response;
  listner.ListnerDisplayModel? listenerDisplayModel1;
  bool isListener = false;
  double ratingStore = 5;
  final feedbackController = TextEditingController();

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
      await Navigator.push(
        context,
        MaterialPageRoute(
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
          ),
        ),
      );
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
      await Navigator.push(
        context,
        MaterialPageRoute(
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
          ),
        ),
      );
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
        Navigator.pop(context);
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
    return isProgressRunning
        ? ShimmerProgressWidget(count: 8, isProgressRunning: isProgressRunning)
        : transactionhistorydata!.transections?.length != null &&
                transactionhistorydata!.transections!.isNotEmpty
            ? Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                ),
                height: MediaQuery.of(context).size.height,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: ListView.builder(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      physics: const ClampingScrollPhysics(),
                      itemCount:
                          transactionhistorydata?.transections?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        return transactionCard(context, index);
                      }),
                ),
              )
            : _noTransactionFound();
  }

  Widget transactionCard(BuildContext context, int index) {
    if(transactionhistorydata!.transections![index].userName != "" || transactionhistorydata!.transections![index].listnerName != "") {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: ui_mode == "dark"
                ? Colors.transparent
                : Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            transactionhistorydata?.transections?[index].crAmount?.toInt() != 0
                ? '+${transactionhistorydata?.transections?[index].crAmount}'
                : '-₹${transactionhistorydata?.transections?[index].drAmount ?? ''}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: transactionhistorydata?.transections?[index].crAmount
                          ?.toInt() !=
                      0
                  ? Colors.green
                  : colorRed,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (transactionhistorydata?.transections?[index].paymentId ==
                  null) ...{
                if (SharedPreference.getValue(PrefConstants.USER_TYPE) ==
                    'user') ...{
                  if (transactionhistorydata!.transections![index].mode! ==
                      "penalty") ...{
                    Text(
                      "${transactionhistorydata?.transections?[index].mode?.toUpperCase() ?? ''} for Unblock User",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.blueAccent,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  } else if (transactionhistorydata!
                          .transections![index].mode! ==
                      "reel gift") ...{
                    Text(
                      "${transactionhistorydata?.transections?[index].mode?.toUpperCase() ?? ''} sent to ${transactionhistorydata?.transections?[index].listnerName ?? ''}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.blueAccent,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  } else ...{
                    Text(
                      "${transactionhistorydata?.transections?[index].mode?.toUpperCase() ?? ''} with ${transactionhistorydata?.transections?[index].listnerName ?? ''}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.blueAccent,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  }
                } else ...{
                  if (transactionhistorydata!.transections![index].mode! ==
                      "penalty") ...{
                    Text(
                      "${transactionhistorydata?.transections?[index].mode?.toUpperCase() ?? ''} for Listner Avaliability",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.blueAccent,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  } else if (transactionhistorydata!
                          .transections![index].mode! ==
                      "reel gift") ...{
                    Text(
                      "${transactionhistorydata?.transections?[index].mode?.toUpperCase() ?? ''} recieved from ${transactionhistorydata?.transections?[index].userName ?? ''}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.blueAccent,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  } else ...{
                    if (transactionhistorydata?.transections?[index].crAmount
                            ?.toInt() !=
                        0) ...{
                      Text(
                        "${transactionhistorydata?.transections?[index].mode?.toUpperCase() ?? ''} with ${transactionhistorydata?.transections?[index].userName ?? ''}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.blueAccent,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    } else ...{
                      Text(
                        "${transactionhistorydata?.transections?[index].mode?.toUpperCase() ?? ''} with ${transactionhistorydata?.transections?[index].listnerName ?? ''}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.blueAccent,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    }
                  }
                }
              } else ...{
                Text(
                  "${transactionhistorydata?.transections?[index].mode?.toUpperCase() ?? ''}  ${transactionhistorydata?.transections?[index].paymentId ?? ''}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.blueAccent,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              },
              const SizedBox(
                height: 5,
              ),
              Text(
                "Duration: ${transactionhistorydata?.transections?[index].duration ?? '0'} min",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colorGrey,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                dateTimeFormat.format(DateTime.parse(transactionhistorydata!
                    .transections![index].createdAt
                    .toString())),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colorGrey,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (transactionhistorydata?.transections?[index].mode == 'Chat' ||
              transactionhistorydata?.transections?[index].mode == 'Call' ||
              transactionhistorydata?.transections?[index].mode == 'Video') ...{
            if (SharedPreference.getValue(PrefConstants.USER_TYPE) !=
                'user') ...{
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    color: ui_mode == "dark" ? colorWhite : colorBlack),
                color: ui_mode == "dark"
                    ? const Color(0xff393E46)
                    : const Color(0xfff7f8fc),
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'Notify User',
                      child: InkWell(
                        onTap: () async {
                          Navigator.pop(context, "Notify User");
                          EasyLoading.show(status: 'loading...'.tr);
                          ListnerDisplayModel model = await APIServices.getUserDataById(transactionhistorydata!
                              .transections![index].toId!);
                          String token = model.data![0].deviceToken!;

                          SendBellNotificationModel? notificationModel =
                              await APIServices.sendNotificationUser(
                                  SharedPreference.getValue(
                                      PrefConstants.LISTENER_NAME),
                                  SharedPreference.getValue(
                                      PrefConstants.LISTENER_IMAGE),
                                  int.parse(transactionhistorydata!
                                      .transections![index].toId!));

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
                          if (transactionhistorydata
                                  ?.transections?[index].crAmount
                                  ?.toInt() !=
                              0) {
                            listenerDisplayModel1 =
                                await APIServices.getUserDataById(
                              transactionhistorydata!
                                  .transections![index].toId!,
                            );

                            if (listenerDisplayModel1!.status!) {
                              debugPrint(
                                  "token ${listenerDisplayModel1?.data![0].deviceToken}");

                              String token =
                                  "${listenerDisplayModel1?.data![0].deviceToken}";
                              String userId =
                                  "${listenerDisplayModel1?.data![0].id}";

                              String? amount =
                                  await APIServices.getWalletAmount(userId);
                              debugPrint(
                                  'User Balance for UID $userId: $amount');
                              if (context.mounted) {
                                if (double.parse(amount!) >= 6) {
                                  debugPrint(double.parse(amount).toString());
                                  if (listenerDisplayModel1!
                                          .data![0].busyStatus ==
                                      0) {
                                    onCallPlaced(
                                      userId,
                                      token,
                                      transactionhistorydata!
                                          .transections![index].userId!,
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
                                transactionhistorydata!
                                    .transections![index].toId!,
                              );
                              log(listenerDisplayModel1!.data![0].id!
                                  .toString());

                              debugPrint(
                                  "token ${listenerDisplayModel1?.data![0].deviceToken}");

                              String token =
                                  "${listenerDisplayModel1?.data![0].deviceToken}";
                              String userId =
                                  "${listenerDisplayModel1?.data![0].id}";

                              String? amount =
                                  await APIServices.getWalletAmount(
                                      SharedPreference.getValue(
                                          PrefConstants.MERA_USER_ID));
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
                                        transactionhistorydata!
                                            .transections![index].userId!,
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
                          } else {
                            listenerDisplayModel1 =
                                await APIServices.getListnerDataById(
                              transactionhistorydata!
                                  .transections![index].toId!,
                            );
                            log(listenerDisplayModel1!.data![0].id!.toString());

                            debugPrint(
                                "token ${listenerDisplayModel1?.data![0].deviceToken}");

                            String token =
                                "${listenerDisplayModel1?.data![0].deviceToken}";
                            String userId =
                                "${listenerDisplayModel1?.data![0].id}";

                            String? amount = await APIServices.getWalletAmount(
                                SharedPreference.getValue(
                                    PrefConstants.MERA_USER_ID));
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
                                      transactionhistorydata!
                                          .transections![index].userId!,
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
                          if (transactionhistorydata
                                  ?.transections?[index].crAmount
                                  ?.toInt() !=
                              0) {
                            listenerDisplayModel1 =
                                await APIServices.getUserDataById(
                              transactionhistorydata!
                                  .transections![index].toId!,
                            );

                            if (listenerDisplayModel1!.status!) {
                              debugPrint(
                                  "token ${listenerDisplayModel1?.data![0].deviceToken}");

                              String token =
                                  "${listenerDisplayModel1?.data![0].deviceToken}";
                              String userId =
                                  "${listenerDisplayModel1?.data![0].id}";

                              String? amount =
                                  await APIServices.getWalletAmount(userId);
                              debugPrint(
                                  'User Balance for UID $userId: $amount');
                              if (context.mounted) {
                                if (double.parse(amount!) >= 18) {
                                  debugPrint(double.parse(amount).toString());
                                  if (listenerDisplayModel1!
                                          .data![0].busyStatus ==
                                      0) {
                                    onVideoCallPlaced(
                                      userId,
                                      token,
                                      transactionhistorydata!
                                          .transections![index].userId!,
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
                                transactionhistorydata!
                                    .transections![index].toId!,
                              );

                              debugPrint(
                                  "token ${listenerDisplayModel1?.data![0].deviceToken}");

                              String token =
                                  "${listenerDisplayModel1?.data![0].deviceToken}";
                              String userId =
                                  "${listenerDisplayModel1?.data![0].id}";

                              String? amount =
                                  await APIServices.getWalletAmount(
                                      SharedPreference.getValue(
                                          PrefConstants.MERA_USER_ID));
                              debugPrint(
                                  'User Balance for UID $userId: $amount');
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
                                        transactionhistorydata!
                                            .transections![index].userId!,
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
                          } else {
                            listenerDisplayModel1 =
                                await APIServices.getListnerDataById(
                              transactionhistorydata!
                                  .transections![index].toId!,
                            );

                            debugPrint(
                                "token ${listenerDisplayModel1?.data![0].deviceToken}");

                            String token =
                                "${listenerDisplayModel1?.data![0].deviceToken}";
                            String userId =
                                "${listenerDisplayModel1?.data![0].id}";

                            String? amount = await APIServices.getWalletAmount(
                                SharedPreference.getValue(
                                    PrefConstants.MERA_USER_ID));
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
                                      transactionhistorydata!
                                          .transections![index].userId!,
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
                  ];
                },
              ),
            } else ...{
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    color: ui_mode == "dark" ? colorWhite : colorBlack),
                color: ui_mode == "dark"
                    ? const Color(0xff393E46)
                    : const Color(0xfff7f8fc),
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'View Listener Details',
                      child: InkWell(
                        onTap: () async {
                          if (context.mounted) {
                            Navigator.pop(context, "View Listener Details");
                          }
                          ListnerDisplayModel listenerModel =
                              await APIServices.getListnerDataById(
                                  transactionhistorydata!
                                      .transections![index].toId!);
                          if (context.mounted) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => HelperDetailScreen(
                                      showFeedbackForm: false,
                                      listnerId:
                                          listenerModel.data![0].id!.toString(),
                                    )));
                          }
                        },
                        child: Text(
                          'View Listener Details'.tr,
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ];
                },
              ),
            },
          },
        ],
      ),
    );
    }
    return Container();
  }

  Widget _noTransactionFound() {
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
                "No Transaction History".tr,
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
}
