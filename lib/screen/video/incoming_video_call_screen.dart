import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/utils/color.dart';
import 'package:support/utils/reuasble_widget/image.dart';
import 'package:support/utils/reuasble_widget/utils.dart';
import 'package:support/model/get_call_id_model.dart';
import 'package:support/model/nickname_get_model.dart';
import 'package:support/screen/video/video_call.dart';
import 'package:support/sharedpreference/sharedpreference.dart';

class IncomingVideoCallScreen extends StatefulWidget {
  final String name;
  final String senderImageUrl;
  final String channelId;
  final String? channelToken;
  final String toUserId;
  final int uid;
  final String userid;
  final String listenerId;

  const IncomingVideoCallScreen({
    Key? key,
    this.toUserId = "",
    required this.channelId,
    this.channelToken,
    required this.name,
    required this.senderImageUrl,
    required this.uid,
    required this.userid,
    required this.listenerId,
  }) : super(key: key);

  @override
  State<IncomingVideoCallScreen> createState() =>
      _IncomingVideoCallScreenState();
}

class _IncomingVideoCallScreenState extends State<IncomingVideoCallScreen> {
  final player = FlutterRingtonePlayer();

  // AudioPlayer();
  Timer? timer;
  int totalSecond = 0;
  bool canPop = false;
  bool isPageEnabled = true;
  int callIdfromAPI = 0;
  GetCallIdModel? callId;
  String? nickName;
  NicknameGetModel? nickNameModel;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  Future<void> onCallJoin() async {
    await AppUtils.handleMic(Permission.microphone, context);
    if (await Permission.microphone.isGranted) {
      if (context.mounted) {
        await AppUtils.handleCamera(Permission.camera, context);
        if (await Permission.camera.isGranted) {
          onCallActionTaken();
          FlutterRingtonePlayer.stop();

          EasyLoading.show(
              status: 'Connecting to the user, please wait . . .'.tr);

          // push video page with given channel name
          await SharedPreference.getValue(PrefConstants.MERA_USER_ID);

          // ignore: use_build_context_synchronously
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VideoCall(
                usertype:
                    SharedPreference.getValue(PrefConstants.USER_TYPE) == "user"
                        ? false
                        : true,
                isCaller: false,
                toUserId: widget.toUserId,
                userid: widget.userid,
                listenerId: widget.listenerId,
                incoming: true,
                uid: widget.uid,
                senderImageUrl: widget.senderImageUrl,
                channelName: widget.channelId,
                token: widget.channelToken!,
                userName: widget.name,
                callId: null,
              ),
            ),
          );
        } else {
          EasyLoading.showInfo('Camera Permission is Required');
        }
      }
    } else {
      EasyLoading.showInfo('Microphone Permission is Required');
    }
  }

  void getNickName() async {
    nickNameModel =
        await APIServices.getNickName(widget.listenerId, widget.userid);

    if (nickNameModel != null) {
      setState(() {
        nickName = nickNameModel!.nickname![0].nickname;
      });
    }
  }

  // // Get Call Id
  Future<void> getCallId() async {
    callId = await APIServices.getCallID(
        SharedPreference.getValue(PrefConstants.USER_TYPE) == 'user'
            ? 'user'
            : 'listener');
    if (callId?.status == true) {
      callIdfromAPI = callId?.data?.id ?? 0;
    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    // getCallId();
    if (SharedPreference.getValue(PrefConstants.USER_TYPE) != 'user') {
      getNickName();
    }
    FlutterRingtonePlayer.playRingtone(looping: true);
    timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => checkCall());
  }

  checkCall() async {
    totalSecond += 1;
    if (totalSecond >= 45) {
      closeCall();
      FlutterRingtonePlayer.stop();
      await FlutterLocalNotificationsPlugin().cancel(0);
    }
    var data = await APIServices.getAgoraChannelInfo(widget.channelId);
    if (data.success == true) {
      if (data.data!.broadcasters!.isEmpty) {
        closeCall();
        FlutterRingtonePlayer.stop();
      }
    }
  }

  closeCall() async {
    await APIServices.getBusyOnline(
        false, SharedPreference.getValue(PrefConstants.MERA_USER_ID));
    if (mounted) {
      if (Navigator.canPop(context)) {
        log('closeCall');
        Navigator.pop(context);
      }
    }
  }

  void _onCallEnd(BuildContext context) async {
    onCallActionTaken();
    FlutterRingtonePlayer.stop();
    EasyLoading.show(status: 'Disconnecting the call, please wait . . .'.tr);

    await APIServices.handleRecording(
        {"call_id": callIdfromAPI.toString()}, APIConstants.STOP_RECORDING);
    await APIServices.getBusyOnline(
        false, SharedPreference.getValue(PrefConstants.MERA_USER_ID));
    if (mounted) {
      EasyLoading.dismiss();
      Navigator.pop(context);
    }
  }

  void onCallActionTaken() {
    setState(() {
      isPageEnabled = false;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.deepPurple.shade900, colorBlack])),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AvatarGlow(
                    endRadius: 100,
                    child: Material(
                      elevation: 8.0,
                      shape: const CircleBorder(),
                      child: CircleAvatar(
                        radius: 60,
                        child: Text(
                          widget.name[0],
                          style: const TextStyle(
                              fontSize: 50.0,
                              fontWeight: FontWeight.bold,
                              color: colorWhite),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    nickName != null
                        ? "${widget.name} ($nickName)"
                        : widget.name,
                    style: const TextStyle(fontSize: 25.0, color: colorWhite),
                  ),
                ],
              ),
              const SizedBox(height: 15.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Ringing...".tr,
                    style: const TextStyle(fontSize: 16.0, color: colorWhite),
                  ),
                ],
              ),
              const Spacer(),
              if (isPageEnabled)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        if (SharedPreference.getValue(
                                PrefConstants.USER_TYPE) ==
                            "user") {
                          await AppUtils.handleCamera(
                              Permission.camera, context);
                          if (await Permission.camera.isGranted) {
                            onCallJoin();
                          } else {
                            if (context.mounted) {
                              _onCallEnd(context);
                            }
                          }
                        } else {
                          onCallJoin();
                        }
                      },
                      child: Column(
                        children: [
                          showIcon(
                              26, colorWhite, Icons.videocam, 28, colorBlue),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Answer".tr,
                            style: const TextStyle(color: colorWhite),
                          ),
                        ],
                      ),
                    ),
                    if (SharedPreference.getValue(PrefConstants.USER_TYPE) ==
                        "user") ...{
                      const SizedBox(width: 25.0),
                      InkWell(
                        onTap: () {
                          _onCallEnd(context);
                        },
                        child: Column(
                          children: [
                            showIcon(
                                26, colorWhite, Icons.call_end, 28, colorRed),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Decline".tr,
                              style: const TextStyle(color: colorWhite),
                            ),
                          ],
                        ),
                      )
                    }
                  ],
                ),
              const SizedBox(
                height: 50,
              ),
            ],
          )),
        ),
      ),
    );
  }
}
