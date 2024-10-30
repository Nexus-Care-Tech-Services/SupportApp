import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:support/api/api_services.dart';
import 'package:support/main.dart';
import 'package:support/model/block_user.dart';
import 'package:support/model/listner/nick_name_model.dart';
import 'package:support/model/nickname_get_model.dart';
import 'package:support/screen/home/helper_detail_screen.dart';
import 'package:support/utils/reuasble_widget/image.dart';
import 'package:support/utils/reuasble_widget/notification.dart';
import 'package:swipe_to/swipe_to.dart';

import 'package:support/api/api_constant.dart';
import 'package:support/utils/color.dart';
import 'package:support/utils/reuasble_widget/utils.dart';
import 'package:support/model/busy_online.dart';
import 'package:support/model/charge_wallet_model.dart';
import 'package:support/model/get_chat_end.dart';
import 'package:support/model/get_chat_end_model.dart';
import 'package:support/model/listner/block_user_model.dart';
import 'package:support/model/listner_display_model.dart' as listner;
import 'package:support/model/report_model.dart';
import 'package:support/model/send_chat_id.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/reuasble_widget/toast_widget.dart';
import 'package:support/screen/listner_app_ui/listner_homescreen.dart';
import 'package:support/screen/chat/reply_message_widget.dart';

class ChatRoomScreen extends StatefulWidget {
  final String userId;
  final String? userImage;
  final String userName;
  final String listenerId;
  final String listenerName;
  final String senderImageUrl;
  final listner.Data? listnerDisplayModel;
  final bool? isTextFieldVisible;
  final int? chatId;
  final bool isfromListnerInbox;

  const ChatRoomScreen(
      {Key? key,
      required this.listenerId,
      required this.listenerName,
      required this.userId,
      required this.userName,
      required this.senderImageUrl,
      this.listnerDisplayModel,
      this.isTextFieldVisible,
      this.isfromListnerInbox = false,
      this.chatId,
      this.userImage})
      : super(key: key);

  @override
  ChatRoomScreenState createState() => ChatRoomScreenState();
}

class ChatRoomScreenState extends State<ChatRoomScreen>
    with WidgetsBindingObserver {
  late ScrollController _scrollController;
  final TextEditingController nickNameController = TextEditingController();
  String? docID;
  final TextEditingController _chatController = TextEditingController();
  BusyOnlineModel? busyOnlineModel;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isListener = false;
  DateTime lastTime = DateTime.now().subtract(const Duration(seconds: 60));
  final sessionId = getRandomString(16);

  final isHours = true;
  NicknameGetModel? nickNameModel;
  String? nickName;

  int? sendvalue;
  String? replyMessage, replyName, replyTime;
  String chatDocId = '';
  String attherate = '@';
  String hash = '#';
  String dotCom = '.com';

  // NickName for Listner Profile

  bool isProgressRunning = false;
  bool isFirstCall = false;

  final DateTime now = DateTime.now();
  final formattedDate = DateFormat('yyyy-MM-dd - kk:mm');
  String walletAmount = "0.0";

  int? getchatId;
  SendChatIDModel? chatIdModel;
  APIGetChatEndModel? getChatEndModel = APIGetChatEndModel();
  Timer? _timer;
  int? chatIdAssignToListener;

  FocusNode focusNode = FocusNode();
  bool sendButton = false;
  listner.ListnerDisplayModel? listnerDisplayModel;
  String? listenerProfileUrl;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  void checkUserWalletBalance(value) async {
    await Future.delayed(const Duration(seconds: 5));

    String meraAmount = await APIServices.getWalletAmount(
            SharedPreference.getValue(PrefConstants.MERA_USER_ID)) ??
        "0.0";
    SharedPreference.setValue(
        PrefConstants.WALLET_AMOUNT, meraAmount.toString());

    String userAmount =
        await APIServices.getWalletAmount(widget.userId) ?? "0.0";
    SharedPreference.setValue(PrefConstants.USER_AVAILABLE_BALANCE, userAmount);

    if (double.parse(userAmount) + 5.0 <= 5.0) {
      log("New User Called THIS");
      debugPrint("Amount: $userAmount");
      _firestore
          .collection('chatroom')
          .doc(docID)
          .update({'is_user_online': false});
      changeTypingStatus(false);

      EasyLoading.show(status: 'loading...'.tr);

      await stopWatchTimer.dispose();
      await APIServices.getBusyOnline(false, widget.listenerId);
      await APIServices.getBusyOnline(false, widget.userId);

      getChatEndModel = await APIServices.getChatIdListnerSideAPI(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID), 'listener');

      if (getChatEndModel?.status == true) {
        EasyLoading.dismiss();
        _timer?.cancel();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const ListnerHomeScreen(
                  index: 0,
                )));
        Fluttertoast.showToast(msg: 'Chat End'.tr);
      }
      return;
    }

    String useramount =
        await APIServices.getWalletAmount(widget.userId) ?? "0.0";
    if (double.parse(useramount) <= 6) {
      if(context.mounted) {
        showLowBalancePopup(context);
      }
    }
    if (double.parse(useramount) <= 0) {
      _firestore
          .collection('chatroom')
          .doc(docID)
          .update({'is_user_online': false});
      changeTypingStatus(false);

      EasyLoading.show(status: 'loading...'.tr);

      await stopWatchTimer.dispose();
      await APIServices.getBusyOnline(false, widget.listenerId);
      await APIServices.getBusyOnline(false, widget.userId);

      getChatEndModel = await APIServices.getChatIdListnerSideAPI(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID), 'listener');

      if (getChatEndModel?.status == true) {
        EasyLoading.dismiss();
        _timer?.cancel();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const ListnerHomeScreen(
                  index: 0,
                )));
        Fluttertoast.showToast(msg: 'Chat End'.tr);
      }
    }
  }

  showLowBalancePopup(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text(
        "OK",
        style: TextStyle(
          color: ui_mode == "dark" ? colorWhite : colorBlack,
        ),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: detailScreenCardColor,
      title: Text(
        "Low Balance Info",
        style: TextStyle(
          color: ui_mode == "dark" ? colorWhite : colorBlack,
        ),
      ),
      content: Text(
        "User Balance is about to end.",
        style: TextStyle(
          color: ui_mode == "dark" ? colorWhite : colorBlack,
        ),
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  int count = 0;

  void amountKaatLo(value) async {
    if (!isFirstCall) {
      isFirstCall = true;
      return;
    }
    String amount = await APIServices.getWalletAmount(
            SharedPreference.getValue(PrefConstants.MERA_USER_ID)) ??
        "0.0";
    log(amount);
    if (double.parse(amount) <= 6.0) {
      debugPrint("Amount: $amount");
      _firestore
          .collection('chatroom')
          .doc(docID)
          .update({'is_user_online': false});
      changeTypingStatus(false);

      EasyLoading.show(status: 'loading...'.tr);

      await stopWatchTimer.dispose();
      await APIServices.getBusyOnline(false, widget.listenerId);
      await APIServices.getBusyOnline(false, widget.userId);

      GetChatEndModel? getChatEndModel =
          await APIServices.chatEndAPI(widget.chatId ?? 0);

      if (getChatEndModel?.status == true) {
        EasyLoading.dismiss();
        FlutterLocalNotificationsPlugin().cancelAll();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => HelperDetailScreen(
                  showFeedbackForm: true,
                  listnerId: widget.listenerId,
                )));
      }
      return;
    } else {
      int addminute = 1;

      ChargeWalletModel chargeWalletModel =
          await APIServices.chargeWalletDeductionApi(
              SharedPreference.getValue(PrefConstants.MERA_USER_ID),
              widget.listenerId,
              addminute.toString(),
              'Chat',
              sessionId);
      count++;
      if (chargeWalletModel.status == true) {
        SharedPreference.setValue(PrefConstants.WALLET_AMOUNT,
            chargeWalletModel.remaningWallet!.walletAmount.toString());
      } else {
        apigetChatEndAPI();
        return;
      }
    }
  }

  // Online Busy Display API

  Future<void> apiOnlineBusy() async {
    try {
      setState(() {
        isProgressRunning = true;
      });
      busyOnlineModel = await APIServices.getBusyOnline(
        true,
        SharedPreference.getValue(PrefConstants.MERA_USER_ID),
      );
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() {
        isProgressRunning = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _firestore
          .collection('chatroom')
          .doc(docID)
          .collection('chats')
          .where('user_type', isEqualTo: isListener ? 'user' : 'listener')
          .get()
          .then((value) {
        for (var element in value.docs) {
          element.reference.update({'is_seen': true});
        }
      });
      // set status online
      if (!isListener) {
        _firestore
            .collection('chatroom')
            .doc(docID)
            .update({'is_user_online': true});
      } else {
        _firestore
            .collection('chatroom')
            .doc(docID)
            .update({'is_listner_online': true});
      }
    } else if (state == AppLifecycleState.inactive) {
      // log('inactive');
      if (!isListener) {
        _firestore
            .collection('chatroom')
            .doc(docID)
            .update({'is_user_online': false});
      } else {
        _firestore
            .collection('chatroom')
            .doc(docID)
            .update({'is_listner_online': false});
      }
    } else if (state == AppLifecycleState.paused) {
      // log('paused');
      if (!isListener) {
        _firestore
            .collection('chatroom')
            .doc(docID)
            .update({'is_user_online': false});
      } else {
        _firestore
            .collection('chatroom')
            .doc(docID)
            .update({'is_listner_online': false});
      }
    } else if (state == AppLifecycleState.detached) {
      log('detached');
      _firestore
          .collection('chatroom')
          .doc(docID)
          .update({'is_user_online': false});
      _firestore
          .collection('chatroom')
          .doc(docID)
          .update({'is_listner_online': false});
    }

    super.didChangeAppLifecycleState(state);
  }

  void getNickName() async {
    nickNameModel =
        await APIServices.getNickName(widget.listenerId, widget.userId);

    if (nickNameModel != null) {
      setState(() {
        nickName =
            "${widget.userName} (${nickNameModel!.nickname![0].nickname})";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    WidgetsBinding.instance.addObserver(this);
    widget.isfromListnerInbox == false ? apiOnlineBusy() : const SizedBox();
    log("User Name at ChatRoom Screen: ${widget.userName}");
    showChatNotification();
    isListener = SharedPreference.getValue("isListener");
    _timer = Timer.periodic(
        const Duration(seconds: 5),
        (Timer t) => WidgetsBinding.instance.addPostFrameCallback((_) {
              apigetChatEndAPI();
            }));

    _firestore
        .collection('chatroom')
        .where('user', isEqualTo: widget.userId)
        .where('listener', isEqualTo: widget.listenerId)
        .get()
        .then((value) {
      setState(() {
        docID = value.docs.isNotEmpty ? value.docs.first.id : null;
      });

      if (docID == null) {
        _firestore
            .collection('chatroom')
            .where('user', isEqualTo: widget.userId)
            .where('listener', isEqualTo: widget.listenerId)
            .snapshots()
            .listen((value) {
          docID = value.docs.isNotEmpty ? value.docs.first.id : null;
          // ignore: avoid_function_literals_in_foreach_calls
          value.docs.forEach((element) {
            element.reference.update({'is_seen': true});
          });
        });
        // set status online
        if (isListener) {
          _firestore.collection('chatroom').doc(docID).update({
            'is_listner_online': true,
            'is_user_typing': false,
            'is_listner_typing': false
          });
        } else {
          _firestore.collection('chatroom').doc(docID).update({
            'is_user_online': true,
            'is_user_typing': false,
            'is_listner_typing': false
          });
        }
      }

      // is Seen
      if (docID != null) {
        _firestore
            .collection('chatroom')
            .doc(docID)
            .collection('chats')
            .where('user_type', isEqualTo: isListener ? 'user' : 'listener')
            .get()
            .then((value) {
          // ignore: avoid_function_literals_in_foreach_calls
          value.docs.forEach((element) {
            element.reference.update({'is_seen': true});
          });
        });
        // set status online
        if (isListener) {
          _firestore.collection('chatroom').doc(docID).update({
            'is_listner_online': true,
            'is_user_typing': false,
            'is_listner_typing': false
          });
        } else {
          _firestore.collection('chatroom').doc(docID).update({
            'is_user_online': true,
            'is_user_typing': false,
            'is_listner_typing': false
          });
        }
      }

      checkStatus();
      if (isListener) {
        getNickName();
      }

      //Uncomwent

      stopWatchTimer.onStartTimer();
      !isListener
          ? stopWatchTimer.minuteTime.listen(amountKaatLo)
          : stopWatchTimer.minuteTime.listen(checkUserWalletBalance);
    });

    Future.delayed(Duration.zero, () async {
      String amount = await APIServices.getWalletAmount(
              SharedPreference.getValue(PrefConstants.MERA_USER_ID)) ??
          "0.0";
      setState(() {
        walletAmount = amount;
        SharedPreference.setValue(PrefConstants.WALLET_AMOUNT, walletAmount);
      });
    });

    _scrollController = ScrollController();
  }

  void getchatIdRoomId() {
    SharedPreference.getValue(PrefConstants.USER_TYPE) == 'user'
        ? chatId()
        : const SizedBox();
  }

  Future<SendChatIDModel?> chatId() async {
    try {
      if (SharedPreference.getValue(PrefConstants.USER_TYPE) == 'user') {
        chatIdModel = await APIServices.sendChatIDAPI(
          widget.userId,
          widget.listenerId,
          docID ?? '0',
        );
      }
    } catch (e) {
      log(e.toString());
    }
    return chatIdModel;
  }

  // GetChat Listner Side API

  Future<GetChatEndModel?> apigetChatEndAPI() async {
    try {
      if (widget.isfromListnerInbox == false) {
        if (SharedPreference.getValue(PrefConstants.USER_TYPE) == 'user') {
          getChatEndModel = await APIServices.getChatIdListnerSideAPI(
              SharedPreference.getValue(PrefConstants.MERA_USER_ID), 'user');
          if (getChatEndModel?.data != null) {
            debugPrint(getChatEndModel?.data?.status);
            if (getChatEndModel?.data?.status == 'end') {
              await stopWatchTimer.dispose();
              await APIServices.getBusyOnline(false, widget.listenerId);
              await APIServices.getBusyOnline(false, widget.userId);

              if (mounted) {
                _timer?.cancel();
                FlutterLocalNotificationsPlugin().cancelAll();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => HelperDetailScreen(
                          listnerId: widget.listenerId,
                          showFeedbackForm: true,
                        )));
                Fluttertoast.showToast(msg: 'Chat End'.tr);
              }
            }
          }
        } else {
          getChatEndModel = await APIServices.getChatIdListnerSideAPI(
              SharedPreference.getValue(PrefConstants.MERA_USER_ID),
              'listener');
          if (getChatEndModel?.data != null) {
            chatIdAssignToListener = getChatEndModel?.data?.id;
            debugPrint(
                "$chatIdAssignToListener ${getChatEndModel!.data!.status}");

            if (getChatEndModel?.data?.status == 'end') {
              await stopWatchTimer.dispose();
              await APIServices.getBusyOnline(false, widget.listenerId);
              await APIServices.getBusyOnline(false, widget.userId);

              if (mounted) {
                _timer?.cancel();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const ListnerHomeScreen(
                          index: 0,
                        )));
                Fluttertoast.showToast(msg: 'Chat End'.tr);
              }
            }
          }
        }
      }
    } catch (e) {
      APIServices.updateErrorLogs(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID),
          'apigetChatEndAPI');
      log(e.toString());
    }
    return null;
  }

  @override
  void dispose() async {
    try {} catch (e) {
      log(e.toString(), name: 'StopWatchTimer');
    }
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _scrollController.dispose();
    _chatController.dispose();
    nickNameController.dispose();
    super.dispose();
  }

  checkStatus() async {}

  void scrollToBottom() {
    final bottomOffset = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      bottomOffset,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  //Change typing status
  void changeTypingStatus(bool isTyping) async {
    if (docID == null) {
      return;
    }

    if (isListener) {
      _firestore
          .collection('chatroom')
          .doc(docID)
          .update({"is_listner_typing": isTyping});
    } else {
      _firestore
          .collection('chatroom')
          .doc(docID)
          .update({"is_user_typing": isTyping});
    }
  }

  Future<void> onSendMessage(String id, String message) async {
    if (docID == null) {
      _firestore
          .collection('chatroom')
          .where('user', isEqualTo: widget.userId)
          .where('listener', isEqualTo: widget.listenerId)
          .get()
          .then((value) {
        setState(() {
          docID = value.docs.isNotEmpty ? value.docs.first.id : null;
        });
        // ignore: avoid_function_literals_in_foreach_calls
        value.docs.forEach((element) {
          element.reference.update({'is_seen': true});
        });
      });
      // set status online
      if (isListener) {
        _firestore.collection('chatroom').doc(docID).update({
          'is_listner_online': true,
          'is_user_typing': false,
          'is_listner_typing': false
        });
      } else {
        _firestore.collection('chatroom').doc(docID).update({
          'is_user_online': true,
          'is_user_typing': false,
          'is_listner_typing': false
        });
      }
    }
    if (message != "") {
      final chatRoomDetails =
          await _firestore.collection('chatroom').doc(docID).get();
      Map<String, dynamic> messages = {
        // "isImage": false,
        "sendby": isListener ? widget.listenerName : widget.userName,
        "message": message,
        "time": FieldValue.serverTimestamp(),
        "is_seen": isListener &&
                chatRoomDetails.exists &&
                chatRoomDetails.data()!.containsKey("is_user_online") &&
                chatRoomDetails["is_user_online"]
            ? true
            : !isListener &&
                    chatRoomDetails.exists &&
                    chatRoomDetails.data()!.containsKey("is_listner_online") &&
                    chatRoomDetails["is_listner_online"]
                ? true
                : false,
        "user_type": isListener ? "listener" : "user",
        "replyId": replyMessage != null ? id : ""
      };
      if (docID == null) {
        var data = await _firestore.collection('chatroom').add({
          'user': widget.userId,
          'user_name': widget.userName,
          'listener': widget.listenerId,
          'listener_name': widget.listenerName,
          "last_time": FieldValue.serverTimestamp(),
          "listener_count": isListener ? 1 : 0,
          "user_count": isListener ? 0 : 1,
          "listener_photo": widget.listnerDisplayModel?.image ?? "",
          "is_user_typing": false,
          "is_listner_typing": false,
          "is_user_online": !isListener,
          "is_listner_online": isListener,
        });
        setState(() {
          docID = data.id;
        });
        APIServices.sendChatIDAPI(
          widget.userId,
          widget.listenerId,
          data.id,
        );

        _firestore
            .collection('chatroom')
            .doc(docID)
            .collection('chats')
            .add(messages);

        _chatController.clear();
        cancelReply();
      } else {
        var data = await _firestore.collection('chatroom').doc(docID).get();

        await _firestore
            .collection('chatroom')
            .doc(docID)
            .collection('chats')
            .add(messages);
        await _firestore.collection('chatroom').doc(docID).update({
          "last_time": FieldValue.serverTimestamp(),
          "listener_count": isListener ? data["listener_count"] + 1 : 0,
          "user_count": isListener ? 0 : data["user_count"] + 1,
          if (!isListener)
            if (data["listener_photo"] != widget.listnerDisplayModel?.image)
              "listener_photo": widget.listnerDisplayModel?.image ?? "",
        });
      }
      await _firestore
          .collection('chatroom')
          .doc(docID)
          .get()
          .then((value) async {
        if (value["is_user_online"]) {
          log(
            "Send Message is user online is ${value["is_user_online"].toString()}",
          );
          await _firestore
              .collection('chatroom')
              .doc(docID)
              .collection('chats')
              .where('user_type', isEqualTo: isListener ? 'user' : 'listener')
              .where("is_seen", isEqualTo: false)
              .get()
              .then((value) {
            log(
              "Send Message something is updating",
            );
            // ignore: avoid_function_literals_in_foreach_calls
            value.docs.forEach((element) async {
              log(
                "Send Message something is updating 2",
              );
              await _firestore
                  .collection('chatroom')
                  .doc(docID)
                  .collection('chats')
                  .doc(element.id)
                  .update({"is_seen": true});
            });
          });
        }
        if (value["is_listner_online"]) {
          await _firestore
              .collection('chatroom')
              .doc(docID)
              .collection('chats')
              .where('user_type', isEqualTo: isListener ? 'user' : 'listener')
              .where("is_seen", isEqualTo: false)
              .get()
              .then((value) {
            // ignore: avoid_function_literals_in_foreach_calls
            value.docs.forEach((element) async {
              await _firestore
                  .collection('chatroom')
                  .doc(docID)
                  .collection('chats')
                  .doc(element.id)
                  .update({"is_seen": true});
            });
          });
        }
      });
      _chatController.clear();
      cancelReply();
      // If user is listner then update seen property of message for listner is true only if user is online
    } else {
      toastshowDefaultSnackbar(
          context, 'Enter some message'.tr, false, primaryColor);
    }
  }

  onChatPushNotify() async {
    if (widget.listnerDisplayModel?.deviceToken != null) {
      EasyLoading.show(
          status: "Connecting with our secure server".tr,
          maskType: EasyLoadingMaskType.clear);
      EasyLoading.dismiss();
      APIServices.sendChatNotification(
        deviceToken: widget.listnerDisplayModel!.deviceToken!,
        senderName: isListener ? widget.userName : widget.listenerName,
      );
    }
  }

  final StopWatchTimer stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    onChangeRawMinute: (value) => () {},
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (widget.isfromListnerInbox == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ListnerHomeScreen(
                      index: 0,
                    )),
          );

          return true;
        } else {
          await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: colorWhite,
                title: Text('Are you sure?'.tr),
                content: Text('You want to close this session?'.tr),
                actions: [
                  if (isListener) ...{
                    ElevatedButton(
                        onPressed: () async {
                          _firestore
                              .collection('chatroom')
                              .doc(docID)
                              .update({'is_listner_online': false});

                          changeTypingStatus(false);

                          EasyLoading.show(status: 'loading...'.tr);

                          await stopWatchTimer.dispose();
                          await APIServices.getBusyOnline(
                              false, widget.listenerId);
                          await APIServices.getBusyOnline(false, widget.userId);

                          GetChatEndModel? getChatEndModel =
                              await APIServices.chatEndAPI(
                                  chatIdAssignToListener ?? 0);

                          if (getChatEndModel?.status == true) {
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
                        child: Text(
                          'Yes'.tr,
                        )),
                    ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'No, Continue'.tr,
                        )),
                  } else ...{
                    ElevatedButton(
                        onPressed: () async {
                          _firestore
                              .collection('chatroom')
                              .doc(docID)
                              .update({'is_user_online': false});
                          changeTypingStatus(false);

                          EasyLoading.show(status: 'loading...'.tr);

                          await stopWatchTimer.dispose();
                          await APIServices.getBusyOnline(
                              false, widget.listenerId);
                          await APIServices.getBusyOnline(false, widget.userId);

                          GetChatEndModel? getChatEndModel =
                              await APIServices.chatEndAPI(widget.chatId ?? 0);

                          if (getChatEndModel?.status == true) {
                            EasyLoading.dismiss();
                            if (mounted) {
                              FlutterLocalNotificationsPlugin().cancelAll();
                              Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(
                                      builder: (context) => HelperDetailScreen(
                                            showFeedbackForm: true,
                                            listnerId: widget.listenerId,
                                          )));
                            }
                          }
                        },
                        child: Text(
                          'Yes'.tr,
                        )),
                    ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'No, Continue'.tr,
                        )),
                  }
                ],
              );
            },
          );
        }

        return false;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: AppBar(
              backgroundColor: backgroundColor,
              leadingWidth: nickName != null ? 250 : size.width / 2,
              leading: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 15,
                  ),
                  !isListener
                      ? showImage(
                          20,
                          NetworkImage(APIConstants.BASE_URL +
                              widget.listnerDisplayModel!.image!),
                        )
                      : widget.senderImageUrl != ''
                          ? showImage(
                              20,
                              NetworkImage(widget.senderImageUrl),
                            )
                          : showIcon(24, colorWhite, Icons.person, 20,
                              Colors.blueGrey),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(top: 5, bottom: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isListener
                                ? nickName != null
                                    ? nickName.toString()
                                    : widget.userName
                                : widget.listenerName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  ui_mode == "dark" ? colorWhite : colorBlack,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 3),
                          StreamBuilder(
                              // isTyping
                              stream: FirebaseFirestore.instance
                                  .collection('chatroom')
                                  .doc(docID)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  var data = snapshot.data as DocumentSnapshot;
                                  if (data.exists) {
                                    if (isListener) {
                                      if (data['is_user_typing']) {
                                        return Text(
                                          "typing....".tr,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: ui_mode == "dark"
                                                ? colorWhite
                                                : colorBlack,
                                          ),
                                        );
                                      }
                                    } else {
                                      if (data['is_listner_typing']) {
                                        return Text(
                                          "typing....".tr,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: ui_mode == "dark"
                                                ? colorWhite
                                                : colorBlack,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                }
                                return const SizedBox();
                              }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              title: nickName != null
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: StreamBuilder<int>(
                        stream: stopWatchTimer.rawTime,
                        initialData: stopWatchTimer.rawTime.value,
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return const SizedBox();
                          }
                          final value = snap.data!;
                          sendvalue = snap.data!;
                          final displayTime = StopWatchTimer.getDisplayTime(
                            value,
                            hours: isHours,
                            milliSecond: false,
                          );
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              displayTime,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: ui_mode == "dark"
                                      ? colorWhite
                                      : colorBlack,
                                  fontFamily: 'Helvetica',
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                    ),
              actions: [
                if (nickName != null) ...{
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: StreamBuilder<int>(
                      stream: stopWatchTimer.rawTime,
                      initialData: stopWatchTimer.rawTime.value,
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return const SizedBox();
                        }
                        final value = snap.data!;
                        sendvalue = snap.data!;
                        final displayTime = StopWatchTimer.getDisplayTime(
                          value,
                          hours: isHours,
                          milliSecond: false,
                        );
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            displayTime,
                            style: TextStyle(
                                fontSize: 16,
                                color:
                                    ui_mode == "dark" ? colorWhite : colorBlack,
                                fontFamily: 'Helvetica',
                                fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                },
                InkWell(
                  onTap: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: cardColor,
                          title: Text(
                            'Are you sure?'.tr,
                            style: TextStyle(color: textColor),
                          ),
                          content: Text('You want to close this session?'.tr,
                              style: TextStyle(color: textColor)),
                          actions: [
                            if (isListener) ...{
                              ElevatedButton(
                                  onPressed: () async {
                                    debugPrint("Listener Chat End");
                                    _firestore
                                        .collection('chatroom')
                                        .doc(docID)
                                        .update({'is_listner_online': false});

                                    changeTypingStatus(false);

                                    EasyLoading.show(status: 'loading...'.tr);

                                    await stopWatchTimer.dispose();
                                    await APIServices.getBusyOnline(
                                        false, widget.listenerId);
                                    await APIServices.getBusyOnline(
                                        false, widget.userId);

                                    GetChatEndModel? getChatEndModel =
                                        await APIServices.chatEndAPI(
                                            chatIdAssignToListener ?? 0);

                                    if (getChatEndModel?.status == true) {
                                      EasyLoading.dismiss();

                                      if (mounted) {
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ListnerHomeScreen(
                                                          index: 0,
                                                        )),
                                                (Route<dynamic> route) =>
                                                    false);
                                      }
                                    }
                                  },
                                  child: Text('Yes'.tr,
                                      style: TextStyle(color: textColor))),
                              ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                  },
                                  child: Text('No, Continue'.tr,
                                      style: TextStyle(color: textColor))),
                            } else ...{
                              ElevatedButton(
                                  onPressed: () async {
                                    debugPrint("User Chat End");
                                    _firestore
                                        .collection('chatroom')
                                        .doc(docID)
                                        .update({'is_user_online': false});
                                    changeTypingStatus(false);

                                    EasyLoading.show(status: 'loading...'.tr);

                                    await stopWatchTimer.dispose();
                                    await APIServices.getBusyOnline(
                                        false, widget.listenerId);
                                    await APIServices.getBusyOnline(
                                        false, widget.userId);

                                    GetChatEndModel? getChatEndModel =
                                        await APIServices.chatEndAPI(
                                            widget.chatId ?? 0);

                                    if (getChatEndModel?.status == true) {
                                      EasyLoading.dismiss();
                                      if (mounted) {
                                        FlutterLocalNotificationsPlugin().cancelAll();
                                        Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HelperDetailScreen(
                                                      listnerId:
                                                          widget.listenerId,
                                                      showFeedbackForm: true,
                                                    )));
                                      }
                                    }
                                  },
                                  child: Text(
                                    'Yes'.tr,
                                  )),
                              ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'No, Continue'.tr,
                                  )),
                            }
                          ],
                        );
                      },
                    );
                  },
                  child: Visibility(
                    visible: !isListener,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Center(
                            child: showIcon(20, colorWhite,
                                Icons.call_end_sharp, 20, colorRed),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isListener) ...[
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert,
                        color: ui_mode == "dark" ? colorWhite : colorBlack),
                    color: ui_mode == "dark" ? detailScreenBgColor : colorGrey,
                    padding: const EdgeInsets.all(0),
                    itemBuilder: (BuildContext context) {
                      return [
                        if (!widget.isfromListnerInbox) ...[
                          PopupMenuItem(
                            value: 'Wallet Amount',
                            child: Text(
                              '\u{20B9}${SharedPreference.getValue(PrefConstants.WALLET_AMOUNT)}',
                              style: TextStyle(
                                color:
                                    ui_mode == "dark" ? colorWhite : colorBlack,
                              ),
                            ),
                          ),
                        ],
                        PopupMenuItem(
                          value: 'Block',
                          child: InkWell(
                            onTap: () {
                              _showConfirmationDialog(context);
                            },
                            child: Text(
                              'Block'.tr,
                              style: TextStyle(
                                color:
                                    ui_mode == "dark" ? colorWhite : colorBlack,
                              ),
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'Nick Name',
                          child: InkWell(
                            onTap: () {
                              showAlertDialog(context);
                            },
                            child: Text(
                              'Nick Name'.tr,
                              style: TextStyle(
                                color:
                                    ui_mode == "dark" ? colorWhite : colorBlack,
                              ),
                            ),
                          ),
                        ),
                        if (!widget.isfromListnerInbox) ...[
                          PopupMenuItem(
                            value: 'End Chat',
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: colorWhite,
                                      title: Text('Are you sure?'.tr),
                                      content: Text(
                                          'You want to close this session?'.tr),
                                      actions: [
                                        if (isListener) ...{
                                          ElevatedButton(
                                              onPressed: () async {
                                                debugPrint("Listener Chat End");
                                                _firestore
                                                    .collection('chatroom')
                                                    .doc(docID)
                                                    .update({
                                                  'is_listner_online': false
                                                });

                                                changeTypingStatus(false);

                                                EasyLoading.show(
                                                    status: 'loading...'.tr);

                                                await stopWatchTimer.dispose();
                                                await APIServices.getBusyOnline(
                                                    false, widget.listenerId);
                                                await APIServices.getBusyOnline(
                                                    false, widget.userId);

                                                GetChatEndModel?
                                                    getChatEndModel =
                                                    await APIServices.chatEndAPI(
                                                        chatIdAssignToListener ??
                                                            0);

                                                if (getChatEndModel?.status ==
                                                    true) {
                                                  EasyLoading.dismiss();

                                                  if (mounted) {
                                                    Navigator.of(context)
                                                        .pushAndRemoveUntil(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const ListnerHomeScreen(
                                                                          index:
                                                                              0,
                                                                        )),
                                                            (Route<dynamic>
                                                                    route) =>
                                                                false);
                                                  }
                                                }
                                              },
                                              child: Text(
                                                'Yes'.tr,
                                              )),
                                          ElevatedButton(
                                              onPressed: () async {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'No, Continue'.tr,
                                              )),
                                        } else ...{
                                          ElevatedButton(
                                              onPressed: () async {
                                                _firestore
                                                    .collection('chatroom')
                                                    .doc(docID)
                                                    .update({
                                                  'is_user_online': false
                                                });
                                                changeTypingStatus(false);

                                                EasyLoading.show(
                                                    status: 'loading...'.tr);

                                                await stopWatchTimer.dispose();
                                                await APIServices.getBusyOnline(
                                                    false, widget.listenerId);
                                                await APIServices.getBusyOnline(
                                                    false, widget.userId);

                                                GetChatEndModel?
                                                    getChatEndModel =
                                                    await APIServices
                                                        .chatEndAPI(
                                                            widget.chatId ?? 0);

                                                if (getChatEndModel?.status ==
                                                    true) {
                                                  EasyLoading.dismiss();
                                                  if (mounted) {
                                                    FlutterLocalNotificationsPlugin().cancelAll();
                                                    Navigator.of(context)
                                                        .pushReplacement(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        HelperDetailScreen(
                                                                          listnerId:
                                                                              widget.listenerId,
                                                                          showFeedbackForm:
                                                                              true,
                                                                        )));
                                                  }
                                                }
                                              },
                                              child: Text(
                                                'Yes'.tr,
                                              )),
                                          ElevatedButton(
                                              onPressed: () async {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'No, Continue'.tr,
                                              )),
                                        }
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Text(
                                'End Chat'.tr,
                                style: TextStyle(
                                  color: ui_mode == "dark"
                                      ? colorWhite
                                      : colorBlack,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ];
                    },
                  ),
                ],
              ],
            ),
          ),
          body: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: ui_mode == "dark"
                          ? const AssetImage("assets/images/chat_dark_bg.jpg")
                          : const AssetImage("assets/images/chat_bg.jpg"))),
              height: size.height,
              width: size.width,
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('chatroom')
                            .doc(docID)
                            .collection('chats')
                            .orderBy('time', descending: true)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            _firestore
                                .collection('chatroom')
                                .doc(docID)
                                .get()
                                .then((value) {
                              _firestore
                                  .collection('chatroom')
                                  .doc(docID)
                                  .update({
                                "last_time": FieldValue.serverTimestamp(),
                                "listener_count": isListener
                                    ? value.exists &&
                                            value
                                                .data()!
                                                .containsKey("listener_count")
                                        ? value["listener_count"]
                                        : 0
                                    : 0,
                                "user_count": isListener
                                    ? 0
                                    : value.exists &&
                                            value
                                                .data()!
                                                .containsKey("user_count")
                                        ? value["user_count"]
                                        : 0,
                              });
                            });

                            return ListView.builder(
                                controller: _scrollController,
                                reverse: true,
                                shrinkWrap: true,
                                itemCount: snapshot.data?.docs.length ?? 0,
                                itemBuilder: (context, index) {
                                  if (snapshot.data!.docs[index]['time'] !=
                                          null &&
                                      lastTime.isAfter(
                                          DateTime.fromMicrosecondsSinceEpoch(
                                              (snapshot.data!.docs[index]
                                                      ['time'] as Timestamp)
                                                  .microsecondsSinceEpoch))) {
                                    final displayTime =
                                        StopWatchTimer.getDisplayTime(
                                            sendvalue?.toInt() ?? 0,
                                            hours: false,
                                            second: false,
                                            minute: true,
                                            milliSecond: false,
                                            secondRightBreak: '..');
                                    int minutess = int.parse(displayTime);
                                    int addminute = minutess + 1;
                                    log(addminute.toString());

                                    return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 15.0),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 5, 10, 5),
                                              decoration: BoxDecoration(
                                                  color: Colors
                                                      .lightGreen.shade700,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25)),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.check_circle,
                                                      color: Colors.lightGreen),
                                                  const SizedBox(width: 5.0),
                                                  Text(
                                                    "Chat - ${DateFormat('dd-MM-yyyy hh:mm a').format(snapshot.data!.docs[index]['time'].toDate())}",
                                                    style: const TextStyle(
                                                      color: colorWhite,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ]);
                                  }
                                  return SwipeTo(
                                    key:
                                        ValueKey(snapshot.data!.docs[index].id),
                                    onLeftSwipe: (updateDetails) {
                                      // Each message reply bu sender name

                                      setState(() {
                                        replyMessage = snapshot
                                            .data!.docs[index]['message'];
                                        chatDocId =
                                            snapshot.data!.docs[index].id;
                                        replyName = snapshot.data!.docs[index]
                                            ['sendby'];
                                      });
                                    },
                                    child: Container(
                                      width: size.width,
                                      key: ValueKey(
                                          snapshot.data!.docs[index].id),
                                      alignment: isListener
                                          ? snapshot.data!.docs[index]
                                                      ['sendby'] ==
                                                  widget.listenerName
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft
                                          : snapshot.data!.docs[index]
                                                      ['sendby'] ==
                                                  widget.userName
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              45,
                                        ),
                                        child: Card(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          color: isListener
                                              ? snapshot.data!.docs[index]
                                                          ['sendby'] ==
                                                      widget.listenerName
                                                  ? const Color.fromRGBO(
                                                      16, 97, 79, 1)
                                                  : const Color.fromRGBO(
                                                      93, 116, 154, 1)
                                              : snapshot.data!.docs[index]
                                                          ['sendby'] ==
                                                      widget.userName
                                                  ? const Color.fromRGBO(
                                                      16, 97, 79, 1)
                                                  : const Color.fromRGBO(
                                                      93, 116, 154, 1),
                                          child: Stack(
                                            children: [
                                              Column(
                                                children: [
                                                  if (snapshot.data!.docs[index]
                                                          ['replyId'] !=
                                                      '') ...[
                                                    StreamBuilder(
                                                        stream: FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'chatroom')
                                                            .doc(docID)
                                                            .collection('chats')
                                                            .doc(snapshot.data!
                                                                    .docs[index]
                                                                ['replyId'])
                                                            .snapshots(),
                                                        // .snapshots(),
                                                        builder: (context,
                                                            AsyncSnapshot<
                                                                    DocumentSnapshot>
                                                                snapshot2) {
                                                          if (snapshot2
                                                              .hasData) {
                                                            final senderReplyName =
                                                                snapshot2.data![
                                                                    'sendby'];

                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      10,
                                                                      5,
                                                                      10,
                                                                      10),
                                                              child: ReplyMessageWidget(
                                                                  message: snapshot2.data?[
                                                                          'message'] ??
                                                                      '',
                                                                  senderName:
                                                                      senderReplyName,
                                                                  textColor:
                                                                      true,
                                                                  chatDocId: snapshot
                                                                          .data!
                                                                          .docs[index]
                                                                      [
                                                                      'replyId']),
                                                            );
                                                          }
                                                          return const SizedBox
                                                              .shrink();
                                                        }),
                                                  ],
                                                  snapshot.data!.docs[index]
                                                              ['replyId'] !=
                                                          ''
                                                      ? snapshot.data!.docs[
                                                                      index]
                                                                  ['time'] !=
                                                              null
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 10,
                                                                      bottom:
                                                                          15,
                                                                      right:
                                                                          70),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Expanded(
                                                                    child: isListener
                                                                        ? Text(
                                                                            snapshot.data!.docs[index]['message'],
                                                                            style:
                                                                                const TextStyle(
                                                                              color: colorWhite,
                                                                              fontSize: 16.0,
                                                                            ),
                                                                          )
                                                                        : Text(
                                                                            lastTime.isBefore(snapshot.data!.docs[index]['time'].toDate())
                                                                                ? snapshot.data!.docs[index]['message']
                                                                                : "",
                                                                            style:
                                                                                const TextStyle(
                                                                              color: colorWhite,
                                                                              fontSize: 16.0,
                                                                            ),
                                                                          ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          : const SizedBox
                                                              .shrink()
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 10,
                                                                  top: 10,
                                                                  bottom: 10,
                                                                  right: 90),
                                                          child: snapshot.data!
                                                                              .docs[
                                                                          index]
                                                                      [
                                                                      'time'] !=
                                                                  null
                                                              ? isListener
                                                                  ? Text(
                                                                      snapshot
                                                                          .data!
                                                                          .docs[index]['message'],
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            16.0,
                                                                      ),
                                                                    )
                                                                  : Text(
                                                                      lastTime.isBefore(snapshot
                                                                              .data!
                                                                              .docs[index][
                                                                                  'time']
                                                                              .toDate())
                                                                          ? snapshot
                                                                              .data!
                                                                              .docs[index]['message']
                                                                          : "",
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            16.0,
                                                                      ),
                                                                    )
                                                              : const SizedBox
                                                                  .shrink(),
                                                        ),
                                                ],
                                              ),
                                              Positioned(
                                                right: 10,
                                                bottom: 4,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        snapshot.data!.docs[
                                                                        index]
                                                                    ['time'] ==
                                                                null
                                                            ? DateFormat(
                                                                    'hh:mm a')
                                                                .format(DateTime
                                                                    .now())
                                                            : DateFormat(
                                                                    'hh:mm a')
                                                                .format(snapshot
                                                                    .data!
                                                                    .docs[index]
                                                                        ['time']
                                                                    .toDate()),
                                                        style: const TextStyle(
                                                          color: colorWhite,
                                                          fontSize: 10.0,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      StreamBuilder(
                                                          stream:
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'chatroom')
                                                                  .doc(docID)
                                                                  .collection(
                                                                      'chats')
                                                                  .doc(snapshot
                                                                      .data!
                                                                      .docs[
                                                                          index]
                                                                      .id)
                                                                  .snapshots(),
                                                          builder: (context,
                                                              AsyncSnapshot<
                                                                      DocumentSnapshot>
                                                                  snapshot2) {
                                                            // Is seen double check
                                                            if (snapshot2
                                                                    .hasData &&
                                                                snapshot2
                                                                        .data !=
                                                                    null) {
                                                              if (snapshot2
                                                                      .data![
                                                                  'is_seen']) {
                                                                return const Icon(
                                                                  Icons
                                                                      .done_all,
                                                                  color: Colors
                                                                      .lightGreenAccent,
                                                                  size: 15,
                                                                );
                                                              } else {
                                                                return const Icon(
                                                                  Icons.done,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 15,
                                                                );
                                                              }
                                                            }
                                                            return const SizedBox
                                                                .shrink();
                                                          })
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                  // Text(
                                  //     snapshot.data!.docs[index]['message']);
                                });
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            return Container();
                          }
                        }),
                  ),
                  if (widget.isTextFieldVisible == false) ...{
                    const SizedBox(
                      height: 10,
                    ),
                  } else ...{
                    buildReply(),
                    Container(
                      width: size.width,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: size.width / 1.1,
                        child: Row(
                          children: [
                            SizedBox(
                              width: size.width / 1.32,
                              child: Card(
                                color: colorWhite,
                                margin: const EdgeInsets.only(
                                    left: 2, right: 2, bottom: 8, top: 5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        focusNode: focusNode,
                                        autofocus: true,
                                        minLines: 1,
                                        maxLines: 4,
                                        // scrollPhysics: AlwaysScrollableScrollPhysics(),
                                        controller: _chatController,
                                        decoration: InputDecoration(
                                          hintText: 'Message'.tr,
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.only(
                                              left: 5, top: 5, bottom: 5),
                                        ),
                                        onChanged: (value) {
                                          if (value.isNotEmpty) {
                                            changeTypingStatus(true);
                                            // log(value, name: 'onChanged');
                                          } else {
                                            changeTypingStatus(false);
                                            // log(value, name: 'else onChanged');
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                                onTap: () {
                                  if (_chatController.text.isValidEmail() ||
                                      _chatController.text.toLowerCase() ==
                                          dotCom ||
                                      _chatController.text == hash ||
                                      _chatController.text == attherate) {
                                    _chatController.text = 'Xxxxxx';
                                    onSendMessage(
                                        chatDocId, _chatController.text.trim());
                                    _chatController.clear();
                                    onChatPushNotify();
                                  } else {
                                    onSendMessage(
                                        chatDocId, _chatController.text.trim());
                                    _chatController.clear();
                                    onChatPushNotify();
                                  }
                                  changeTypingStatus(false);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8.0, left: 2, right: 2, top: 5),
                                  child: showIcon(0.0, colorWhite, Icons.send,
                                      25, const Color.fromRGBO(1, 168, 132, 1)),
                                )),
                          ],
                        ),
                      ),
                    ),
                  }
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Show Alert Box for Add nick name

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
        child: Text(
          "OK".tr,
          style: TextStyle(
            color: ui_mode == "dark" ? colorWhite : colorBlack,
          ),
        ),
        onPressed: () async {
          if (nickNameController.text.isNotEmpty) {
            NickNameModel? nickNameModel = await APIServices.setNickName(
                SharedPreference.getValue(PrefConstants.MERA_USER_ID),
                widget.userId,
                nickNameController.text);

            if (nickNameModel?.status == true) {
              Fluttertoast.showToast(msg: 'Nickname Added Successfully'.tr);
              setState(() {
                nickName = "${widget.userName} (${nickNameController.text})";
                nickNameController.clear();
              });
              if (!mounted) return;
              Navigator.pop(context);
            } else {
              Fluttertoast.showToast(msg: 'Please Enter Nick Name'.tr);
            }
          } else {
            Fluttertoast.showToast(msg: 'Please Enter Nick Name'.tr);
          }
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: detailScreenCardColor,
      title: Column(
        children: [
          // widget.userId
          Text(
            "Please enter nick name".tr,
            style: TextStyle(
              color: ui_mode == "dark" ? colorWhite : colorBlack,
            ),
          ),
          TextField(
            style: TextStyle(
              color: ui_mode == "dark" ? colorWhite : colorBlack,
            ),
            controller: nickNameController,
            decoration: InputDecoration(
              hintText: 'Enter Nick Name'.tr,
              hintStyle: TextStyle(
                color: ui_mode == "dark" ? colorWhite : colorBlack,
              ),
            ),
          ),
        ],
      ),
      // content:
      actions: [
        okButton,
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

  // Show FeedBack Alert Dialog

  // Show Alert Dialog for Report

  //! Block user
  TextEditingController textEditingController = TextEditingController();
  String selectedOption = 'Obscenity';

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: detailScreenCardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            title: Text(
              'Are you sure you want to block ${widget.userName}?',
              style: TextStyle(
                color: ui_mode == "dark" ? colorWhite : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select reason:',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  RadioListTile(
                    title: const Text('Obscenity'),
                    value: 'Obscenity',
                    groupValue: selectedOption,
                    activeColor: colorBlue,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value.toString();
                        debugPrint(selectedOption);
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('Misbehaving'),
                    value: 'Misbehaving',
                    groupValue: selectedOption,
                    activeColor: colorBlue,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value.toString();
                        debugPrint(selectedOption);
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('Abusing'),
                    value: 'Abusing',
                    groupValue: selectedOption,
                    activeColor: colorBlue,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value.toString();
                        debugPrint(selectedOption);
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('Asking personal info'),
                    value: 'Asking personal info',
                    groupValue: selectedOption,
                    activeColor: colorBlue,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value.toString();
                        debugPrint(selectedOption);
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('Approaching me for another app'),
                    value: 'Approaching me for another app',
                    groupValue: selectedOption,
                    activeColor: colorBlue,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value.toString();
                        debugPrint(selectedOption);
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('Other'),
                    value: 'Other',
                    groupValue: selectedOption,
                    activeColor: colorBlue,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value.toString();
                        debugPrint(selectedOption);
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Visibility(
                    visible: selectedOption == 'Other',
                    child: TextFormField(
                      controller: textEditingController,
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      decoration: InputDecoration(
                        filled: true,
                        alignLabelWithHint: true,
                        hintText: 'Write reasons here...',
                        fillColor: colorWhite,
                        labelStyle: TextStyle(
                          color:
                              ui_mode == "dark" ? colorWhite : Colors.black54,
                          fontSize: 18,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: colorBlue,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity / 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        EasyLoading.show(status: 'loading');
                        BlockUser? model;
                        if (selectedOption == 'Other') {
                          model = await APIServices.blockUser(widget.userId,
                              widget.listenerId, textEditingController.text);
                        } else {
                          model = await APIServices.blockUser(
                              widget.userId, widget.listenerId, selectedOption);
                        }
                        if (model!.message == 'Blocked successfully') {
                          EasyLoading.dismiss();
                          EasyLoading.showSuccess(model.message.toString());
                          if (isListener) {
                            debugPrint("Listener Chat End");
                            _firestore
                                .collection('chatroom')
                                .doc(docID)
                                .update({'is_listner_online': false});

                            changeTypingStatus(false);

                            EasyLoading.show(status: 'loading...'.tr);

                            await stopWatchTimer.dispose();
                            await APIServices.getBusyOnline(
                                false, widget.listenerId);
                            await APIServices.getBusyOnline(
                                false, widget.userId);

                            GetChatEndModel? getChatEndModel =
                                await APIServices.chatEndAPI(
                                    chatIdAssignToListener ?? 0);

                            if (getChatEndModel?.status == true) {
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
                          } else {
                            _firestore
                                .collection('chatroom')
                                .doc(docID)
                                .update({'is_user_online': false});
                            changeTypingStatus(false);

                            EasyLoading.show(status: 'loading...'.tr);

                            await stopWatchTimer.dispose();
                            await APIServices.getBusyOnline(
                                false, widget.listenerId);
                            await APIServices.getBusyOnline(
                                false, widget.userId);

                            GetChatEndModel? getChatEndModel =
                                await APIServices.chatEndAPI(
                                    widget.chatId ?? 0);

                            if (getChatEndModel?.status == true) {
                              EasyLoading.dismiss();
                              if (mounted) {
                                FlutterLocalNotificationsPlugin().cancelAll();
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            HelperDetailScreen(
                                              listnerId: widget.listenerId,
                                              showFeedbackForm: true,
                                            )));
                              }
                            }
                          }
                        } else {
                          EasyLoading.dismiss();
                        }
                      },
                      child: const Text(
                        'Block',
                        style: TextStyle(
                          color: colorWhite,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity / 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        backgroundColor: colorWhite,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: colorBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  showReportDialog(BuildContext context) {
    // set up the button
    Widget reportButton = TextButton(
      child: Text(
        "REPORT".tr,
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor),
      ),
      onPressed: () async {
        EasyLoading.show(status: 'loading...'.tr);
        ReportModel? reportModel = await APIServices.reportAPI(
            SharedPreference.getValue(PrefConstants.MERA_USER_ID),
            widget.userId.toString(),
            '""');

        if (reportModel?.status == true) {
          EasyLoading.showSuccess(reportModel?.message.toString() ?? '');
          EasyLoading.dismiss();

          if (!mounted) return;
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const ListnerHomeScreen(
                        index: 0,
                      )));
        } else {
          EasyLoading.dismiss();
          if (!mounted) return;
          toastshowDefaultSnackbar(
              context, 'Something went wrong'.tr, false, colorRed);
        }
      },
    );

    Widget blockButton = TextButton(
      child: Text(
        "BLOCK".tr,
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor),
      ),
      onPressed: () async {
        EasyLoading.show(status: 'loading...'.tr);
        BlockUserModel? blockModel = await APIServices.blockAPI(
          widget.userId.toString(),
        );

        if (blockModel?.status == true) {
          EasyLoading.showSuccess(blockModel?.message.toString() ?? '');
          EasyLoading.dismiss();

          if (!mounted) return;
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const ListnerHomeScreen(
                        index: 0,
                      )));
        } else {
          EasyLoading.dismiss();
          if (!mounted) return;
          toastshowDefaultSnackbar(
              context, 'Something went wrong'.tr, false, colorRed);
        }
      },
    );
    Widget cancelButton = TextButton(
      child: Text(
        "CANCEL".tr,
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor),
      ),
      onPressed: () async {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: colorWhite,
      buttonPadding: const EdgeInsets.symmetric(vertical: 0),
      title: Text(
        "Report ${widget.userName}".tr,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorBlack,
        ),
      ),
      content: Text(
        'The last session with ${widget.userName} was not good. Do you want to report this user?'
            .tr,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      actions: [
        reportButton,
        blockButton,
        cancelButton,
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

  // If Replying
  Widget buildReply() => replyMessage == null
      ? const SizedBox.shrink()
      : Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(24),
            ),
          ),
          child: ReplyMessageWidget(
            senderName: replyName,
            message: replyMessage,
            onCancelReply: cancelReply,
            isReplyDesign: true,
          ),
        );

  void cancelReply() {
    setState(() {
      replyMessage = null;
    });
  }
}
