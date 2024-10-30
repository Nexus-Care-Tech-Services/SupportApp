import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:support/utils/color.dart';
import 'package:support/screen/home/home_screen.dart';

import 'package:support/api/api_services.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/model/get_chat_request_from_user.dart';
import 'package:support/model/listner/update_chat_request_model.dart';
import 'package:support/model/send_chat_id.dart';
import 'package:support/model/user_chat_send_request.dart';
import 'package:support/model/listner_display_model.dart' as listner;
import 'package:support/screen/chat/chat_screen_2.dart';
import 'package:support/utils/reuasble_widget/toast_widget.dart';

class ChatRequestPending extends StatefulWidget {
  final UserChatSendRequest? userChatSendRequest;
  final String userId;
  final String userName;
  final String listenerId;
  final String listenerName;
  final String listenerImage;
  final String senderImageUrl;
  final listner.Data? listnerDisplayModel;

  const ChatRequestPending(
      {super.key,
      this.userChatSendRequest,
      required this.userId,
      required this.userName,
      required this.listenerId,
      required this.listenerName,
      required this.listenerImage,
      required this.senderImageUrl,
      this.listnerDisplayModel});

  @override
  State<ChatRequestPending> createState() => _ChatRequestPendingState();
}

class _ChatRequestPendingState extends State<ChatRequestPending>
    with TickerProviderStateMixin {
  AnimationController? controller;
  int levelClock = 45;
  GetChatRequestByUserModel? getChatRequestByUserModel;
  Timer? timer;
  SendChatIDModel? chatIdModel;

  UpdateChatRequestModel? updateChatRequestModel = UpdateChatRequestModel();
  String? docID;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  checkStatus() async {}

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }

    _firestore
        .collection('chatroom')
        .where('user', isEqualTo: widget.userId)
        .where('listener', isEqualTo: widget.listenerId)
        .get()
        .then((value) {
      setState(() {
        docID = value.docs.isNotEmpty ? value.docs.first.id : null;
      });
      checkStatus();
    }).then((value) => chatId());

    controller = AnimationController(
        vsync: this,
        duration: Duration(
            seconds:
                levelClock) // gameData.levelClock is a user entered number elsewhere in the applciation
        );

    controller?.forward();
    timer = Timer.periodic(
        const Duration(seconds: 5), (Timer t) => getChatRequestByUser());

    controller?.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        EasyLoading.show(indicator: const CircularProgressIndicator());
        updateChatRequestModel =
            await APIServices.updateChatRequestFromListnerAPI(
                widget.userChatSendRequest?.data?.id ?? 0, 'cancelled');

        if (updateChatRequestModel?.status == true) {
          EasyLoading.dismiss();
          if (mounted) {
            // Navigator.pop(context);
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false);
            toastshowDefaultSnackbar(
                context,
                '${widget.listnerDisplayModel?.name} is Unavailable at the moment'
                    .tr,
                false,
                primaryColor);
          }
          await APIServices.getBusyOnline(false, widget.listenerId);
          await APIServices.getBusyOnline(false, widget.userId);
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    timer?.cancel();
    super.dispose();
  }

  // Get Chat Id
  Future<SendChatIDModel?> chatId() async {
    try {
      chatIdModel = await APIServices.sendChatIDAPI(
        widget.userId, widget.listenerId,
        // 'message'
        docID ?? '0',
      );
    } catch (e) {
      APIServices.updateErrorLogs(widget.userId, 'APIServices.sendChatIDAPI');
      log(e.toString());
    }
    return chatIdModel;
  }

  Future<GetChatRequestByUserModel?> getChatRequestByUser() async {
    try {
      getChatRequestByUserModel = await APIServices.getChatRequestAPI(
        widget.userChatSendRequest?.data?.id.toString() ?? '0',
      );
      if (getChatRequestByUserModel?.data?[0].status == 'approve') {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => ChatRoomScreen(
                        userImage:
                            SharedPreference.getValue(PrefConstants.USER_IMAGE)
                                .toString(),
                        listnerDisplayModel: widget.listnerDisplayModel,
                        listenerId: widget.listnerDisplayModel!.id.toString(),
                        listenerName: widget.listnerDisplayModel!.name!,
                        senderImageUrl: widget.senderImageUrl,
                        userId: widget.userId,
                        userName: widget.userName,
                        chatId: chatIdModel?.data?.id,
                      )),
              (Route<dynamic> route) => false);
        }
      } else if (getChatRequestByUserModel?.data?[0].status == 'decline') {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false);

          String msg = 'Listner Declined the Request'.tr;
          toastshowDefaultSnackbar(context,
              '${widget.listnerDisplayModel?.name} $msg', false, primaryColor);
        }
        await APIServices.getBusyOnline(false, widget.listenerId);
        await APIServices.getBusyOnline(false, widget.userId);
      }
    } catch (e) {
      APIServices.updateErrorLogs(widget.userId, 'getChatRequestByUser');
      log(e.toString());
    } finally {}
    return getChatRequestByUserModel;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Decline the request
        showcancelChat(context);

        return true;
      },
      child: Scaffold(
        backgroundColor: cardColor,
        appBar: AppBar(
          backgroundColor: cardColor,
          leading: InkWell(
              onTap: () {
                // Decline the request
                showcancelChat(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: textColor,
              )),
          title: Text(
            'Please Wait'.tr,
            style: TextStyle(fontSize: 18, color: textColor),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 20, 15, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: MediaQuery.of(context).size.width * 0.4,
                      ),
                      const SizedBox(height: 40.0),
                      Text(
                        'Connecting....'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: textColor),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'You can Chat only after Listener Approve.'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: textColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Countdown(
                  animation: StepTween(
                    begin: levelClock, // THIS IS A USER ENTERED NUMBER
                    end: 0,
                  ).animate(controller!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Camcel the request

  showcancelChat(BuildContext context) {
    // set up the buttons
    Widget cancelRequestButton = TextButton(
      child: Text(
        "Yes".tr,
        style: TextStyle(color: textColor),
      ),
      onPressed: () async {
        EasyLoading.show(status: 'Please wait...'.tr);
        await APIServices.getBusyOnline(false, widget.listenerId);
        await APIServices.getBusyOnline(false, widget.userId);

        updateChatRequestModel =
            await APIServices.updateChatRequestFromListnerAPI(
                widget.userChatSendRequest?.data?.id ?? 0, 'cancelled');

        if (updateChatRequestModel?.status == true) {
          EasyLoading.dismiss();

          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false);
          }
        }
      },
    );
    Widget continueButton = TextButton(
      child: Text("No".tr, style: TextStyle(color: textColor)),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Are you Sure?".tr, style: TextStyle(color: textColor)),
      content: Text("You want to end this session?".tr,
          style: TextStyle(color: textColor)),
      actions: [
        cancelRequestButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

// ignore: must_be_immutable
class Countdown extends AnimatedWidget {
  Countdown({Key? key, this.animation})
      : super(key: key, listenable: animation!);
  Animation<int>? animation;

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation!.value);

    String timerText =
        '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return Text(
      timerText,
      style: TextStyle(
        fontSize: 50,
        color: textColor,
      ),
    );
  }
}
