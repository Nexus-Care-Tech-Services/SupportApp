import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/utils/color.dart';
import 'package:support/model/nickname_get_model.dart';
import 'package:support/screen/chat/agora_chat_screen.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/reuasble_widget/image.dart';

class IncomingChatScreen extends StatefulWidget {
  final String name;
  final String senderImageUrl;
  final String channelId;
  final String? channelToken;
  final String toUserId;
  final int uid;
  final String userid;
  final String listenerId;

  const IncomingChatScreen(
      {super.key,
      required this.name,
      required this.senderImageUrl,
      required this.channelId,
      this.channelToken,
      required this.toUserId,
      required this.uid,
      required this.userid,
      required this.listenerId});

  @override
  State<IncomingChatScreen> createState() => _IncomingChatScreenState();
}

class _IncomingChatScreenState extends State<IncomingChatScreen> {
  final player = FlutterRingtonePlayer();
  Timer? timer;
  int totalSecond = 0;
  bool canPop = false;
  bool isPageEnabled = true;
  int callIdfromAPI = 0;
  String? nickName;
  NicknameGetModel? nickNameModel;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  void getNickName() async {
    nickNameModel =
        await APIServices.getNickName(widget.listenerId, widget.userid);

    if (nickNameModel != null) {
      setState(() {
        nickName = nickNameModel!.nickname![0].nickname;
      });
    }
  }

  Future<void> onChatJoin() async {
    onCallActionTaken();
    FlutterRingtonePlayer.stop();
    EasyLoading.show(status: 'Connecting to the user, please wait . . .'.tr);

    // push video page with given channel name
    await SharedPreference.getValue(PrefConstants.MERA_USER_ID);

    // ignore: use_build_context_synchronously
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AgoraChatScreen(
          userid: widget.userid,
          toUserId: widget.toUserId,
          listnerid: widget.listenerId,
          incoming: true,
          uid: widget.uid,
          senderImageUrl: widget.senderImageUrl,
          channelName: widget.channelId,
          token: widget.channelToken!,
          userName: widget.name,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
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
    if (mounted) {
      if (Navigator.canPop(context)) {
        log('closeCall');
        Navigator.pop(context);
      }
    }
  }

  void _onChatEnd(BuildContext context) async {
    onCallActionTaken();
    FlutterRingtonePlayer.stop();
    EasyLoading.show(status: 'Disconnecting the chat, please wait . . .'.tr);

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
      onWillPop: () async {
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: cardColor,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 40, 15, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                showImage(
                  MediaQuery.of(context).size.width * 0.15,
                  NetworkImage(widget.senderImageUrl),
                ),
                const SizedBox(height: 40.0),
                Text(
                  "${widget.name} sent you chat request",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                      color: textColor),
                ),
                const SizedBox(height: 40.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () async {
                        onChatJoin();
                      },
                      child: const Text(
                        'Accept',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
