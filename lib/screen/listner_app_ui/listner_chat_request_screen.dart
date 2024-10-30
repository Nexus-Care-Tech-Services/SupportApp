import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support/model/nickname_get_model.dart';

import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/utils/color.dart';
import 'package:support/model/listner/listner_chat_request_model.dart';
import 'package:support/model/listner/update_chat_request_model.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/reuasble_widget/image.dart';
import 'package:support/utils/reuasble_widget/shimmer_progress_widget.dart';
import 'package:support/screen/chat/chat_screen_2.dart';
import 'package:support/screen/listner_app_ui/listner_homescreen.dart';

class ListnerChatRequestScreen extends StatefulWidget {
  final int requestid;
  final String? fromid;

  const ListnerChatRequestScreen(
      {super.key, required this.requestid, this.fromid});

  @override
  State<ListnerChatRequestScreen> createState() =>
      _ListnerChatRequestScreenState();
}

class _ListnerChatRequestScreenState extends State<ListnerChatRequestScreen> {
  ListnerChatRequest? getListnerRequest = ListnerChatRequest();
  final audioPlayer = AudioPlayer();
  Timer? _timer;
  String id = "";
  String? name, nickName = "";
  String senderImageUrl =
      'https://supportletstalk.com/manage/images/avatar/user.png';
  bool isListener = false;
  bool loading = false;
  bool isProgressRunning = false;
  bool isFirstCall = false;
  NicknameGetModel? nickNameModel;
  String? userName;

  // Listner Chat Request

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  Future<ListnerChatRequest?> apigetListnerRequest() async {
    try {
      getListnerRequest = await APIServices.listnerChatRequestAPI();

      if (getListnerRequest?.message == 'Data not retrive') {
        FlutterRingtonePlayer.stop();
        _timer?.cancel();

        if (mounted) {
          _timer?.cancel();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => const ListnerHomeScreen(
                        index: 0,
                      )),
              (Route<dynamic> route) => false);

          return null;
        }
      }
    } catch (e) {
      APIServices.updateErrorLogs(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID),
          'apigetListnerRequest()');
      log(e.toString());
    }

    return null;
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    id = prefs.getString("userId")!;
    isListener = SharedPreference.getValue(PrefConstants.USER_TYPE) == 'user'
        ? false
        : true;
    if (isListener == true) {
      getUserData();
    }
    setState(() {
      loading = false;
    });
  }

  void getNickName() async {
    nickNameModel = await APIServices.getNickName(
        SharedPreference.getValue(PrefConstants.MERA_USER_ID), widget.fromid!);

    if (nickNameModel != null) {
      setState(() {
        nickName = nickNameModel!.nickname![0].nickname;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    audioPlayer.dispose();
    super.dispose();
    _timer?.cancel();
  }

  void isCallfirst() {
    if (isFirstCall == false) {
      _timer = Timer.periodic(
          const Duration(seconds: 5), (Timer t) => apigetListnerRequest());
      isFirstCall = true;
    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    loadData();
    userName =
        SharedPreference.getValue(PrefConstants.USER_NAME) ?? 'Anonymous';
    getNickName();
    isCallfirst();

    loading = true;
    FlutterRingtonePlayer.playRingtone(looping: true);
  }

  //Get Listener Data
  Future<void> getUserData() async {
    try {
      if (widget.fromid != null) {
        var listnerDisplayModel =
            await APIServices.getUserDataById(widget.fromid.toString());
        setState(() {
          name = listnerDisplayModel.data![0].name;
          senderImageUrl = listnerDisplayModel.data![0].image.toString();
        });
      }
    } catch (e) {
      log(e.toString());
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: cardColor,
        appBar: AppBar(
          backgroundColor: cardColor,
          centerTitle: true,
          leading: const SizedBox(),
          title: Text(
            "Chat Request",
            style: TextStyle(color: textColor),
          ),
        ),
        body: isProgressRunning
            ? ShimmerProgressWidget(
                count: 8, isProgressRunning: isProgressRunning)
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 40, 15, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      showImage(
                        MediaQuery.of(context).size.width * 0.15,
                        NetworkImage(senderImageUrl),
                      ),
                      const SizedBox(height: 40.0),
                      Text(
                        nickName != ""
                            ? "${name ?? 'Anonymous'} ($nickName) sent you chat request"
                            : "${name ?? 'Anonymous'} sent you chat request",
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
                              EasyLoading.show(status: 'loading...');
                              UpdateChatRequestModel? updateChatRequest =
                                  await APIServices
                                      .updateChatRequestFromListnerAPI(
                                          widget.requestid, 'approve');

                              if (updateChatRequest?.status == true) {
                                FlutterRingtonePlayer.stop();
                                EasyLoading.dismiss();
                                if (mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) => ChatRoomScreen(
                                              listenerId: id,
                                              listenerName:
                                                  SharedPreference.getValue(
                                                      PrefConstants
                                                          .LISTENER_NAME),
                                              userId: updateChatRequest
                                                      ?.data?.fromId
                                                      .toString() ??
                                                  '0',
                                              userName: name!,
                                              senderImageUrl: senderImageUrl
                                              // userName: 'Anonymous',
                                              )),
                                      (Route<dynamic> route) => false);
                                }
                              }
                            },
                            child: const Text(
                              'Accept',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 30.0),
                          TextButton(
                              onPressed: () async {
                                EasyLoading.show(status: 'loading...');
                                UpdateChatRequestModel? updateChatRequest =
                                    await APIServices
                                        .updateChatRequestFromListnerAPI(
                                            widget.requestid, 'decline');

                                await APIServices.getBusyOnline(
                                  false,
                                  SharedPreference.getValue(
                                      PrefConstants.MERA_USER_ID),
                                );

                                if (updateChatRequest?.status == true) {
                                  FlutterRingtonePlayer.stop();
                                  EasyLoading.dismiss();
                                  if (mounted) {
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ListnerHomeScreen(
                                                  index: 0,
                                                )),
                                        (Route<dynamic> route) => false);
                                  }
                                }
                              },
                              child: const Text(
                                'Reject',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: colorRed,
                                    fontWeight: FontWeight.bold),
                              )),
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
