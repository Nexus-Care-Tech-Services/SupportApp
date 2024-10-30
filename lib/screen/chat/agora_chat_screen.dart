import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/main.dart';
import 'package:support/model/listner/nick_name_model.dart';
import 'package:support/screen/listner_app_ui/listner_wallet.dart/listner_wallet.dart';
import 'package:support/utils/color.dart';
import 'package:support/utils/reuasble_widget/image.dart';
import 'package:support/utils/reuasble_widget/notification.dart';
import 'package:support/utils/reuasble_widget/toast_widget.dart';
import 'package:support/utils/reuasble_widget/utils.dart';
import 'package:support/model/block_user.dart';
import 'package:support/model/charge_wallet_model.dart';
import 'package:support/model/chat_model.dart';
import 'package:support/model/listner_display_model.dart';
import 'package:support/model/nickname_get_model.dart';
import 'package:support/screen/chat/reply_message_widget.dart';
import 'package:support/screen/listner_app_ui/user_rate_give_screen.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:swipe_to/swipe_to.dart';

const agoraAppId = '11644e46dc56453b9da54562219452bd';
const appkey = '611174610#1361852';

class AgoraChatScreen extends StatefulWidget {
  final String channelName;
  final String token;
  final String userid;
  final String listnerid;
  final bool incoming;
  final String senderImageUrl;
  final int uid;
  final String toUserId;
  final String userName;

  const AgoraChatScreen(
      {super.key,
      required this.channelName,
      required this.token,
      required this.userid,
      required this.listnerid,
      this.incoming = false,
      required this.senderImageUrl,
      required this.uid,
      this.toUserId = "",
      required this.userName});

  @override
  State<AgoraChatScreen> createState() => _AgoraChatScreenState();
}

class _AgoraChatScreenState extends State<AgoraChatScreen> with TickerProviderStateMixin {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  late RtcEngine _engine;
  bool isListener = false;
  bool isFirstCall = false;
  bool isPageEnabled = true;
  bool isjoined = false;
  final sessionId = getRandomString(16);
  int seconds = 0, ringingseconds = 0;
  NicknameGetModel? nickNameModel;
  String? nickName, walletamt;
  String? chatid = "";
  String? deviceToken;

  AnimationController? controller;
  int levelClock = 30;

  ListnerDisplayModel? listnerDisplayModel;

  static const platform = MethodChannel('com.example.support/screen_control');

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  Duration duration = const Duration();
  Timer? timer, timer1, counttimer, timer2;

  late ChatClient agoraChatClient;
  final TextEditingController _chatController = TextEditingController();
  final TextEditingController nickNameController = TextEditingController();
  FocusNode focusNode = FocusNode();
  ScrollController scrollController = ScrollController();
  final List<ChatModel> list = [];

  String attherate = '@';
  String hash = '#';
  String dotCom = '.com';
  String? replyId;
  String? replyMessage, replyName;

  bool userjoined = false, lowbalance = false;

  final StopWatchTimer stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    onChangeRawMinute: (value) => () {
      debugPrint('cut thr price');
    },
  );

  void getNickName() async {
    nickNameModel =
        await APIServices.getNickName(widget.listnerid, widget.userid);

    if (nickNameModel != null) {
      setState(() {
        nickName = nickNameModel!.nickname![0].nickname;
      });
    }
  }

  void ringingTime() {
    timer1 = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        ringingseconds += 1;
      });
      if (ringingseconds > 5 && ringingseconds < 30) {
        if (!isjoined) {
          timer.cancel();
          timer1!.cancel();
          _onChatEnd(6);
        }
        if (widget.incoming && !userjoined) {
          timer.cancel();
          timer1!.cancel();
          _onChatEnd(6);
        }
      }
    });
    timer = Timer.periodic(const Duration(seconds: 30), (Timer t) {
      if (duration.inSeconds <= 0) {
        if (ringingseconds >= 30) {
          timer!.cancel();
          timer1!.cancel();
          _onChatEnd(3);
        }
      }
    });
  }

  void checkBalancePeriodically() {
    Future.delayed(const Duration(seconds: 10), () {
      double walletAmount = double.tryParse(SharedPreference.getValue(
          PrefConstants
              .WALLET_AMOUNT))!; // get wallet amount from wherever it's stored;
      if (walletAmount <= 20.0) {
        AppUtils.showLowBalanceBottomSheet(context,
            "Your Balance is ₹20 or below, recharge now to keep connected");
      }
    });
  }

  void getWalletAmt() async {
    String? amt = await APIServices.getWalletAmount(
        SharedPreference.getValue(PrefConstants.MERA_USER_ID));
    if(mounted) {
      setState(() {
        walletamt = amt;
      });
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      addTime();
      getWalletAmt();

      String useramount = await APIServices.getWalletAmount(widget.incoming
              ? widget.userid
              : SharedPreference.getValue(PrefConstants.MERA_USER_ID)) ??
          "0.0";
      if (double.parse(useramount) <= 6) {
        setState(() {
          lowbalance = true;
        });
      }

      if ((!userjoined && isjoined) || (userjoined && !isjoined)) {
        timer!.cancel();
        timer2!.cancel();
        _onChatEnd(2);
      }
      if (lowbalance) {
        timer!.cancel();
        timer2!.cancel();
        isListener ? _onChatEnd(2) : _onChatEnd(4);
      }
    });
    timer2 = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (isListener) {
        checkUserWalletBalance(1);
      } else {
        amountKaatLo(1);
      }
    });
  }

  void initializeDeduct(int seconds) {
    counttimer = Timer.periodic(Duration(seconds: seconds), (timer) {
      if (isListener) {
        checkUserWalletBalance(1);
      } else {
        amountKaatLo(1);
      }

      if (seconds == 1 && counttimer!.isActive) {
        counttimer!.cancel();
      }
    });
  }

  void addTime() {
    if (mounted) {
      setState(() {
        final seconds = duration.inSeconds + 1;
        if (seconds < 0) {
          timer?.cancel();
        } else {
          duration = Duration(seconds: seconds);
        }
        if (duration.inSeconds == 1) {
          if (isListener) {
            checkUserWalletBalance(1);
          } else {
            amountKaatLo(1);
          }
        }
      });
    }
  }

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      buildTimeCard(time: hours, header: 'HOURS'),
      const SizedBox(
        width: 8,
      ),
      buildTimeCard(time: minutes, header: 'MINUTES'),
      const SizedBox(
        width: 8,
      ),
      buildTimeCard(time: seconds, header: 'SECONDS'),
    ]);
  }

  Widget buildTimeCard({required String time, required String header}) => Text(
        time,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ui_mode == "dark" ? colorWhite : colorBlack,
            fontSize: 18),
      );

  showLowBalancePopup(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text(
        "OK".tr,
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
      backgroundColor: ui_mode == "dark" ? const Color(0xff393E46) : cardColor,
      title: Text(
        "Low Balance Info".tr,
        style: TextStyle(
          color: ui_mode == "dark" ? colorWhite : colorBlack,
        ),
      ),
      content: Text(
        "User Balance is about to end.".tr,
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

  void checkUserWalletBalance(value) async {
    await Future.delayed(const Duration(seconds: 5));
    String amount = await APIServices.getWalletAmount(widget.toUserId) ?? "0.0";
    SharedPreference.setValue(
        PrefConstants.USER_AVAILABLE_BALANCE, amount.toString());

    String meraAmount = await APIServices.getWalletAmount(
            SharedPreference.getValue(PrefConstants.MERA_USER_ID)) ??
        "0.0";
    SharedPreference.setValue(
        PrefConstants.WALLET_AMOUNT, meraAmount.toString());
  }

  void amountKaatLo(value) async {
    if (!isFirstCall) {
      isFirstCall = true;
      return;
    }
    String amount = await APIServices.getWalletAmount(
            SharedPreference.getValue(PrefConstants.MERA_USER_ID)) ??
        "0.0";
    if (double.parse(amount) <= 6.0) {
      if (mounted) {
        showLowBalancePopup(context);
      }
    } else {
      ChargeWalletModel chargeWalletModel =
          await APIServices.chargeWalletDeductionApi(
              widget.userid, widget.listnerid, '1', 'Chat', sessionId);

      if (chargeWalletModel.status == true) {
        String meraAmount = await APIServices.getWalletAmount(
                SharedPreference.getValue(PrefConstants.MERA_USER_ID)) ??
            "0.0";
        SharedPreference.setValue(PrefConstants.WALLET_AMOUNT, meraAmount);
      } else {
        _onChatEnd(5);
      }
    }
    checkBalancePeriodically();
  }

  @override
  void dispose() {
    _users.clear();
    _dispose();
    if (timer!.isActive) {
      timer?.cancel();
    }
    if (timer2!.isActive) {
      timer2!.cancel();
    }
    unregisterSensor();
    super.dispose();
  }

  Future<void> _dispose() async {
    // destroy sdk
    EasyLoading.show(
        status: 'Please wait, updating your wallet balance'.tr,
        maskType: EasyLoadingMaskType.clear);
    await APIServices.getBusyOnline(false, widget.listnerid);
    await APIServices.getBusyOnline(false, widget.userid);
    EasyLoading.dismiss();
    await _engine.leaveChannel();
    await _engine.release();
    unregisterSensor();
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    initialize();
    EasyLoading.dismiss();
    registerSensor();
    SharedPreference.setValue(
        PrefConstants.USER_AVAILABLE_BALANCE, "Loading...");
    if (SharedPreference.getValue(PrefConstants.USER_TYPE) != 'user') {
      getNickName();
    }

    controller = AnimationController(
        vsync: this,
        duration: Duration(
            seconds:
            levelClock) // gameData.levelClock is a user entered number elsewhere in the applciation
    );

    controller?.forward();
  }

  Future<void> registerSensor() async {
    try {
      await platform.invokeMethod('registerSensor');
    } catch (e) {
      // Handle error
    }
  }

  Future<void> unregisterSensor() async {
    try {
      await platform.invokeMethod('unregisterSensor');
    } catch (e) {
      // Handle error
      log('error occured');
    }
  }

  Future<void> initialize() async {
    if (agoraAppId.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.joinChannel(
        token: widget.token,
        channelId: widget.channelName,
        options: const ChannelMediaOptions(),
        uid: widget.uid);
    String? amt = await APIServices.getWalletAmount(
        SharedPreference.getValue(PrefConstants.MERA_USER_ID));
    setState(() {
      walletamt = amt;
    });
    ringingTime();
    setupChatClient();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isListener = prefs.getBool("isListener") ?? false;
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
        appId: agoraAppId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting));
    await _engine
        .setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    await _engine.muteLocalAudioStream(true);
    await _engine.muteAllRemoteAudioStreams(true);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    debugPrint('start handler');
    _engine.registerEventHandler(RtcEngineEventHandler(onError:
        (ErrorCodeType code, String msg) {
      setState(() {
        final info = 'onError: $code $msg';
        _infoStrings.add(info);
        debugPrint(info);
      });
    }, onJoinChannelSuccess: (RtcConnection channel, int uid) {
      setState(() {
        final info =
            'onJoinChannel: ${channel.channelId} ${channel.localUid}, uid: $uid';
        _infoStrings.add(info);
        debugPrint(info);
        isjoined = true;
        getListnerDetails();
      });
    }, onLeaveChannel: (RtcConnection connect, RtcStats stats) {
      setState(() {
        _infoStrings.add(
            'onLeaveChannel ${connect.channelId} ${connect.localUid} $stats');
        _users.clear();
        debugPrint('onLeaveChannel $stats');
        isjoined = false;
        if (userjoined) {
          timer!.cancel();
          timer2!.cancel();
          _onChatEnd(2);
        }
      });
    }, onUserJoined: (RtcConnection connect, int uid, int elapsed) async {
      startTimer();
      initializeDeduct(1);
      showChatNotification();
      if (!isListener) {
        getStartChat();
      }
      setState(() {
        final info =
            'userJoined: ${connect.channelId} ${connect.localUid} $uid';
        _infoStrings.add(info);
        _users.add(uid);
        userjoined = true;
        debugPrint(info);
      });
      if (timer1!.isActive) {
        timer1!.cancel();
      }
      await _engine.setEnableSpeakerphone(false);
    }, onUserOffline:
        (RtcConnection connect, int uid, UserOfflineReasonType elapsed) {
      setState(() {
        final info =
            'userOffline: ${connect.channelId} ${connect.localUid} $uid $elapsed';
        _infoStrings.add(info);
        _users.remove(uid);
        debugPrint(info);
        if (isjoined) {
          userjoined = false;
        }
      });
    }, onFirstRemoteVideoFrame:
        (RtcConnection connect, int uid, int width, int height, int elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
        debugPrint(info);
      });
    }));
  }

  checkOnlineStatus() async {
    ListnerDisplayModel model = await APIServices.getListnerDataById(
        SharedPreference.getValue(PrefConstants.MERA_USER_ID));
    if (model.data![0].onlineStatus == 1) {
      showNotification(1);
    } else {
      showNotification(0);
    }
  }

  void _onChatEnd(type) async {
    if (!isListener && chatid != "") {
      await APIServices.endAgoraChat(chatid!);
    }
    signout();

    onCallDisconnect();
    await APIServices.getBusyOnline(false, widget.listnerid);
    await APIServices.getBusyOnline(false, widget.userid);

    if (type == 3) {
      if (timer1!.isActive) {
        timer1!.cancel();
      }
      if (!isListener) {
        APIServices.updateCallChatLogs(
            SharedPreference.getValue(PrefConstants.MERA_USER_ID),
            widget.listnerid,
            type,
            'chat');
        await APIServices.setListnerOffline(widget.listnerid);
        await APIServices.sendCustomNotification(
            deviceToken: deviceToken,
            message:
                "Missed Call from ${SharedPreference.getValue(PrefConstants.LISTENER_NAME)}");
      }
      EasyLoading.showInfo(isListener
          ? 'User is not responding, please try again later'
          : 'Listner is not responding, please try again later'.tr);
    } else if (type == 2) {
      EasyLoading.showInfo(
          isListener ? 'User disconnected the chat!' : 'Chat disconnected!'.tr);
    } else if (type == 4) {
      EasyLoading.showInfo('Low Balance, Please Recharge!'.tr);
    } else {
      EasyLoading.showInfo('Disconnecting the chat, please wait . . .'.tr);
    }

    if (mounted) {
      if (duration.inSeconds > 0) {
        if (isListener) {
          checkOnlineStatus();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    UserRateGiveScreen(userId: widget.userid.toString()),
              ));
        } else {
          await FlutterLocalNotificationsPlugin().cancelAll();
          if (mounted) {
            Navigator.pop(context, true);
          }
        }
      } else {
        Navigator.pop(context, false);
      }
    }
  }

  void onCallDisconnect() {
    setState(() {
      isPageEnabled = false;
    });
    unregisterSensor();
  }

  void getStartChat() async {
    String id =
        await APIServices.startAgoraChat(widget.userid, widget.listnerid);
    setState(() {
      chatid = id;
    });
  }

  //! Block user
  TextEditingController textEditingController = TextEditingController();
  String selectedOption = 'Obscenity';

  void _showConfirmationDialog(BuildContext contxt) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor:
                ui_mode == "dark" ? const Color(0xff393E46) : cardColor,
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
                  Text(
                    'Select reason:',
                    style: TextStyle(
                      color: ui_mode == "dark" ? colorWhite : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  RadioListTile(
                    title: Text('Obscenity',
                        style: TextStyle(
                            color:
                                ui_mode == "dark" ? colorWhite : colorBlack)),
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
                    title: Text('Misbehaving',
                        style: TextStyle(
                            color:
                                ui_mode == "dark" ? colorWhite : colorBlack)),
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
                    title: Text('Abusing',
                        style: TextStyle(
                            color:
                                ui_mode == "dark" ? colorWhite : colorBlack)),
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
                    title: Text('Asking personal info',
                        style: TextStyle(
                            color:
                                ui_mode == "dark" ? colorWhite : colorBlack)),
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
                    title: Text('Approaching me for another app',
                        style: TextStyle(
                            color:
                                ui_mode == "dark" ? colorWhite : colorBlack)),
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
                    title: Text('Other',
                        style: TextStyle(
                            color:
                                ui_mode == "dark" ? colorWhite : colorBlack)),
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
                        backgroundColor:
                            ui_mode == "dark" ? colorBlack : colorBlue,
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
                          model = await APIServices.blockUser(widget.userid,
                              widget.listnerid, textEditingController.text);
                        } else {
                          model = await APIServices.blockUser(
                              widget.userid, widget.listnerid, selectedOption);
                        }
                        if (model!.message == 'Blocked successfully') {
                          EasyLoading.dismiss();
                          EasyLoading.showSuccess(model.message.toString());
                          _onChatEnd(2);
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

  void setupListeners() {
    agoraChatClient.addConnectionEventHandler(
        "CONNECTION_HANDLER",
        ConnectionEventHandler(onConnected: () {
          debugPrint("Connected");
          _infoStrings.add("Connected");
        }, onDisconnected: () {
          debugPrint("Disconnected");
          _infoStrings.add("Disconnected");
        }));

    agoraChatClient.chatManager.addEventHandler("MESSAGE_HANDLER",
        ChatEventHandler(
      onMessagesReceived: (message) async {
        for (var msg in message) {
          switch (msg.body.type) {
            case MessageType.CUSTOM:
              ChatCustomMessageBody body = msg.body as ChatCustomMessageBody;
              // ChatTextMessageBody body = msg.body as ChatTextMessageBody;
              list.add(ChatModel(
                  msg.msgId,
                  body.params!["message"],
                  false,
                  false,
                  body.params!["reply_id"] != ''
                      ? body.params!["reply_id"]
                      : '',
                  body.params!['replyMessage'] != ''
                      ? body.params!['replyMessage']
                      : '',
                  body.params!['sender'] != '' ? body.params!['sender'] : ''));
              debugPrint(
                  "Message Recieved ${msg.from} ${body.params} ${msg.msgId}");
              if (!isListener) {
                await APIServices.agoraChatHistory(
                    chatid!, body.params!["message"]!, "listner");
              }
              break;
            case MessageType.TXT:
              // TODO: Handle this case.
              break;
            case MessageType.IMAGE:
              // TODO: Handle this case.
              break;
            case MessageType.VIDEO:
              // TODO: Handle this case.
              break;
            case MessageType.LOCATION:
              // TODO: Handle this case.
              break;
            case MessageType.VOICE:
              // TODO: Handle this case.
              break;
            case MessageType.FILE:
              // TODO: Handle this case.
              break;
            case MessageType.CMD:
              // TODO: Handle this case.
              break;
            case MessageType.COMBINE:
              // TODO: Handle this case.
              break;
          }
        }
      },
    ));
  }

  Widget displayMessage(ChatModel model) {
    final size = MediaQuery.of(context).size;
    log("${model.replyid}");
    return Container(
      width: size.width,
      alignment: model.isSent! ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          margin: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          color: model.isSent!
              ? const Color.fromRGBO(16, 97, 79, 1)
              : const Color.fromRGBO(93, 116, 154, 1),
          child: Stack(
            children: [
              Column(
                children: [
                  if (model.replyid != '') ...{
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                      child: ReplyMessageWidget(
                          message: replyMessage ?? '',
                          senderName: replyName,
                          textColor: true),
                    ),
                  },
                  model.replyid != ''
                      ? Padding(
                          padding: const EdgeInsets.only(
                              left: 10, bottom: 15, right: 70),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  model.message!,
                                  style: const TextStyle(
                                    color: colorWhite,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(
                              left: 10, top: 10, bottom: 10, right: 90),
                          child: Text(
                            model.message!,
                            style: const TextStyle(
                              color: colorWhite,
                              fontSize: 16.0,
                            ),
                          )),
                ],
              ),
              Positioned(
                right: 10,
                bottom: 4,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        getCurrentTime(),
                        style: const TextStyle(
                          color: colorWhite,
                          fontSize: 10.0,
                        ),
                      ),
                      const SizedBox(width: 5),
                      if (model.isSent!) ...{
                        model.isRead!
                            ? const Icon(
                                Icons.done_all,
                                color: Colors.lightGreenAccent,
                                size: 15,
                              )
                            : const Icon(
                                Icons.done,
                                color: colorRed,
                                size: 15,
                              ),
                      },
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void signIn() async {
    try {
      String username = SharedPreference.getValue(PrefConstants.MERA_USER_ID);
      String token = await APIServices.getAgoraChatUserToken(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID));
      agoraChatClient.loginWithAgoraToken(username, token);
      setState(() {
        isjoined = true;
      });
    } on ChatError catch (e) {
      if (e.code != 200) {
        debugPrint("Login failed, code: ${e.code}, desc: ${e.description}");
        _onChatEnd(2);
      }
    }
  }

  void setupChatClient() async {
    ChatOptions options = ChatOptions(
      appKey: appkey,
      autoLogin: false,
      requireAck: true,
    );
    agoraChatClient = ChatClient.getInstance;
    await agoraChatClient.init(options);
    // Notify the SDK that the Ul is ready. After the following method is executed, callbacks within ChatRoomEventHandler and ChatGroupEventHandler can be triggered.
    await ChatClient.getInstance.startCallback();
    setupListeners();
    signIn();
  }

  void signout() async {
    agoraChatClient.chatManager.removeEventHandler("MESSAGE_HANDLER");
    agoraChatClient.removeConnectionEventHandler("CONNECTION_HANDLER");
    try {
      await agoraChatClient.logout(true);
    } on ChatError catch (e) {
      debugPrint("SignOut Failed ${e.code} ${e.description}");
    }
  }

  void sendMessage(String message, String reply, String sender) async {
    bool isRead = false;
    if (message == "") {
      if (context.mounted) {
        toastshowDefaultSnackbar(
            context, 'Enter some message'.tr, false, primaryColor);
      }
      return;
    }

    Map<String, String> params = {
      "message": message,
      "reply_id": reply != '' ? replyId! : '',
      "replyMessage": reply != '' ? reply : '',
      "sender": reply != '' ? sender : '',
    };
    var msg = ChatMessage.createCustomSendMessage(
        targetId: isListener ? widget.userid : widget.listnerid,
        event: "Chat",
        params: params);

    agoraChatClient.chatManager.addMessageEvent(
        "SEND_MESSAGE_EVENT",
        ChatMessageEvent(onSuccess: (msgId, msg) async {
          log("Message Succeed $msgId, $msg ${msg.msgId}");
          if (msg.hasRead) {
            isRead = true;
            setState(() {
              list.add(ChatModel(
                  msg.msgId,
                  message,
                  true,
                  isRead,
                  reply != '' ? msg.msgId : '',
                  reply != '' ? reply : '',
                  reply != '' ? sender : ''));
            });
          } else {
            isRead = false;
            setState(() {
              list.add(ChatModel(
                  msg.msgId,
                  message,
                  true,
                  isRead,
                  reply != '' ? msg.msgId : '',
                  reply != '' ? reply : '',
                  reply != '' ? sender : ''));
            });
          }
        }, onProgress: (msgId, progress) {
          debugPrint("Message Progress");
        }, onError: (msgId, msg, error) {
          debugPrint("onError $msg, ${error.code} ${error.description}");
        }));

    agoraChatClient.chatManager.sendMessage(msg);
    await APIServices.sendChatNotifyNotification(
        deviceToken: deviceToken,
        message: message,
        id: widget.token,
        sender: SharedPreference.getValue(PrefConstants.LISTENER_NAME));
    // agoraChatClient.chatManager.removeMessageEvent("SEND_MESSAGE_EVENT");
    cancelReply();
    if (message != "") {
      if (!isListener) {
        await APIServices.agoraChatHistory(
            chatid!, message, isListener ? "listner" : "user");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        bool end = false;
        await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                backgroundColor:
                    ui_mode == "dark" ? const Color(0xff393E46) : cardColor,
                title: Text(
                  'Are you sure?'.tr,
                  style: TextStyle(
                      color: ui_mode == "dark" ? colorWhite : colorBlack),
                ),
                content: Text(
                  'You want to close this session?'.tr,
                  style: TextStyle(
                      color: ui_mode == "dark" ? colorWhite : colorBlack),
                ),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            ui_mode == "dark" ? colorBlack : colorBlue),
                    onPressed: () {
                      end = true;
                      _onChatEnd(1);
                    },
                    child: Text(
                      'Yes'.tr,
                      style: TextStyle(
                          color: ui_mode == "dark" ? colorWhite : colorBlack),
                    ),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              ui_mode == "dark" ? colorBlack : colorBlue),
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'No, Continue'.tr,
                        style: TextStyle(
                            color: ui_mode == "dark" ? colorWhite : colorBlack),
                      )),
                ],
              );
            });
        return end;
      },
      child: duration.inSeconds > 0
          ? GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: AppBar(
                    backgroundColor: ui_mode == "dark"
                        ? const Color(0xff181818)
                        : const Color(0xffF9FAFC),
                    leadingWidth: size.width / 2,
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
                                    widget.senderImageUrl),
                              )
                            : widget.senderImageUrl != ''
                                ? showImage(
                                    20, NetworkImage(widget.senderImageUrl))
                                : showIcon(24, colorWhite, Icons.person, 20,
                                    Colors.blueGrey),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          width: 130,
                          margin: const EdgeInsets.only(top: 5, bottom: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nickName != null
                                    ? "${widget.userName} ($nickName)"
                                    : widget.userName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: ui_mode == "dark"
                                      ? colorWhite
                                      : colorBlack,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 3),
                            ],
                          ),
                        ),
                      ],
                    ),
                    centerTitle: true,
                    title: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: buildTime(),
                    ),
                    actions: [
                      InkWell(
                        onTap: () {
                          _onChatEnd(1);
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
                              color:
                                  ui_mode == "dark" ? colorWhite : colorBlack),
                          color: ui_mode == "dark"
                              ? detailScreenBgColor
                              : colorGrey,
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem(
                                value: 'Wallet Amount',
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ListnerWalletScreen()));
                                  },
                                  child: Text(
                                    '\u{20B9}$walletamt',
                                    style: TextStyle(
                                      color: ui_mode == "dark"
                                          ? colorWhite
                                          : colorBlack,
                                    ),
                                  ),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'Block',
                                child: InkWell(
                                  onTap: () {
                                    _showConfirmationDialog(context);
                                  },
                                  child: Text(
                                    'Block'.tr,
                                    style: TextStyle(
                                      color: ui_mode == "dark"
                                          ? colorWhite
                                          : colorBlack,
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
                                      color: ui_mode == "dark"
                                          ? colorWhite
                                          : colorBlack,
                                    ),
                                  ),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'End Chat',
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context, "End Chat");
                                    _onChatEnd(1);
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
                                ? const AssetImage(
                                    "assets/images/chat_dark_bg.jpg")
                                : const AssetImage(
                                    "assets/images/chat_bg.jpg"))),
                    height: size.height,
                    width: size.width,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            reverse: true,
                            child: ListView.builder(
                              controller: scrollController,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return SwipeTo(
                                  onLeftSwipe: (updateDetails) {
                                    setState(() {
                                      replyId = list[index].chatid;
                                      replyMessage = list[index].message;
                                      replyName = list[index].isSent!
                                          ? SharedPreference.getValue(
                                              PrefConstants.LISTENER_NAME)
                                          : widget.userName;
                                    });
                                  },
                                  child: Container(
                                    width: size.width,
                                    alignment: list[index].isSent!
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width -
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
                                        color: list[index].isSent!
                                            ? const Color.fromRGBO(
                                                16, 97, 79, 1)
                                            : const Color.fromRGBO(
                                                93, 116, 154, 1),
                                        child: Stack(
                                          children: [
                                            Column(
                                              children: [
                                                if (list[index].replyid !=
                                                    '') ...{
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        10, 5, 10, 10),
                                                    child: ReplyMessageWidget(
                                                        message: list[index]
                                                                .replymessage ??
                                                            '',
                                                        senderName:
                                                            list[index].sender,
                                                        textColor: true),
                                                  ),
                                                },
                                                list[index].replyid != ''
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10,
                                                                bottom: 15,
                                                                right: 70),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                list[index]
                                                                    .message!,
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      16.0,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10,
                                                                top: 10,
                                                                bottom: 10,
                                                                right: 90),
                                                        child: Text(
                                                          list[index].message!,
                                                          style:
                                                              const TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 16.0,
                                                          ),
                                                        )),
                                              ],
                                            ),
                                            Positioned(
                                              right: 10,
                                              bottom: 4,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      getCurrentTime(),
                                                      style: const TextStyle(
                                                        color: colorWhite,
                                                        fontSize: 10.0,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    if (list[index]
                                                        .isSent!) ...{
                                                      list[index].isRead!
                                                          ? const Icon(
                                                              Icons.done_all,
                                                              color: Colors
                                                                  .lightGreenAccent,
                                                              size: 15,
                                                            )
                                                          : const Icon(
                                                              Icons.done,
                                                              color: colorRed,
                                                              size: 15,
                                                            ),
                                                    },
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
                              },
                              itemCount: list.length,
                            ),
                          ),
                        ),
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
                                        borderRadius:
                                            BorderRadius.circular(25)),
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
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      left: 5,
                                                      top: 5,
                                                      bottom: 5),
                                            ),
                                            onChanged: (value) {
                                              if (value.isNotEmpty) {
                                                // changeTypingStatus(true);
                                                // log(value, name: 'onChanged');
                                              } else {
                                                // changeTypingStatus(false);
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
                                      // if (_chatController.text.toLowerCase() ==
                                      //     'welcome') {
                                      //   _chatController.text = 'Welcome';
                                      //   onSendMessage(chatDocId);
                                      //   onChatPushNotify();
                                      // } else
                                      if (_chatController.text.isValidEmail() ||
                                              _chatController.text
                                                      .toLowerCase() ==
                                                  dotCom ||
                                              _chatController.text == hash ||
                                              _chatController.text == attherate
                                          // _chatController.text.isAbuseMessage() ||
                                          // _chatController.text.isSocialSite()
                                          ) {
                                        _chatController.text = 'xxxxxx';
                                        sendMessage(
                                            _chatController.text,
                                            replyMessage != null
                                                ? replyMessage!
                                                : '',
                                            replyName != null
                                                ? replyName!
                                                : '');
                                        _chatController.clear();
                                      } else {
                                        sendMessage(
                                            _chatController.text,
                                            replyMessage != null
                                                ? replyMessage!
                                                : '',
                                            replyName != null
                                                ? replyName!
                                                : '');
                                        _chatController.clear();
                                      }
                                      // changeTypingStatus(false);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                          left: 2,
                                          right: 2,
                                          top: 5),
                                      child: showIcon(
                                          0.0,
                                          colorWhite,
                                          Icons.send,
                                          25,
                                          const Color.fromRGBO(1, 168, 132, 1)),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : Scaffold(
              backgroundColor: cardColor,
              appBar: AppBar(
                backgroundColor: detailScreenBgColor,
                leading: InkWell(
                    onTap: () {
                      // Decline the request
                      showcancelChat(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: ui_mode == "dark" ? colorWhite : colorBlack,
                    )),
                title: Text(
                  'Please Wait'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    color: ui_mode == "dark" ? colorWhite : colorBlack,
                  ),
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
                            !isListener
                                ? showImage(
                                    40,
                                    NetworkImage(APIConstants.BASE_URL +
                                        widget.senderImageUrl),
                                  )
                                : widget.senderImageUrl != ''
                                    ? showImage(
                                        40, NetworkImage(widget.senderImageUrl))
                                    : showIcon(24, colorWhite, Icons.person, 30,
                                        Colors.blueGrey),
                            const SizedBox(height: 40.0),
                            Text(
                              'Connecting....'.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, color: textColor),
                            ),
                            const SizedBox(height: 20),
                            if (!widget.incoming) ...{
                              Text(
                                'You can Chat only after Listener Approves.'.tr,
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: 18, color: textColor),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Countdown(
                                animation: StepTween(
                                  begin: levelClock, // THIS IS A USER ENTERED NUMBER
                                  end: 0,
                                ).animate(controller!),
                              ),
                            },
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  String getCurrentTime() {
    String currentTime = DateFormat('hh:mm a').format(DateTime.now());
    return currentTime;
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
                widget.userid,
                nickNameController.text);

            if (nickNameModel?.status == true) {
              if (mounted) {
                toastshowDefaultSnackbar(context,
                    "Nickname Added Successfully".tr, false, primaryColor);
              }
              setState(() {
                nickName = nickNameController.text;
                nickNameController.clear();
              });
              if (!mounted) return;
              Navigator.pop(context);
            } else {
              if (mounted) {
                toastshowDefaultSnackbar(
                    context, 'Please Enter Nick Name'.tr, false, primaryColor);
              }
            }
          } else {
            toastshowDefaultSnackbar(
                context, 'Please Enter Nick Name', false, primaryColor);
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

  //cancel Chat Request
  showcancelChat(BuildContext context) {
    // set up the buttons
    Widget cancelRequestButton = TextButton(
      child: Text(
        "Yes".tr,
        style: TextStyle(
          color: ui_mode == "dark" ? colorWhite : colorBlack,
        ),
      ),
      onPressed: () async {
        _onChatEnd(1);
      },
    );
    Widget continueButton = TextButton(
      child: Text("No".tr,
          style: TextStyle(
            color: ui_mode == "dark" ? colorWhite : colorBlack,
          )),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: detailScreenCardColor,
      title: Text("Are you Sure?".tr,
          style: TextStyle(
            color: ui_mode == "dark" ? colorWhite : colorBlack,
          )),
      content: Text("You want to end this session?".tr,
          style: TextStyle(
            color: ui_mode == "dark" ? colorWhite : colorBlack,
          )),
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

  void getListnerDetails() async {
    if (widget.incoming == false) {
      if (SharedPreference.getValue(PrefConstants.USER_TYPE) == 'user') {
        ListnerDisplayModel? model =
        await APIServices.getListnerDataById(widget.listnerid);

        APIServices.sendAgoraChatNotification(
            userid: SharedPreference.getValue(PrefConstants.MERA_USER_ID),
            listenerId: model.data![0].id.toString(),
            deviceToken: model.data![0].deviceToken!,
            senderName: SharedPreference.getValue(PrefConstants.LISTENER_NAME),
            senderImageUrl:
            SharedPreference.getValue(PrefConstants.LISTENER_IMAGE),
            cId: widget.channelName,
            cTn: SharedPreference.getValue(PrefConstants.AGORA_TOKEN_TWO),
            uid: SharedPreference.getValue(PrefConstants.AGORA_UID_TWO));
        setState(() {
          deviceToken = model.data![0].deviceToken;
        });
      } else {
        ListnerDisplayModel? model =
        await APIServices.getUserDataById(widget.userid);

        ListnerDisplayModel? listner =
        await APIServices.getListnerDataById(widget.listnerid);

        APIServices.sendAgoraChatNotification(
            listenerId: SharedPreference.getValue(PrefConstants.MERA_USER_ID),
            userid: model.data![0].id.toString(),
            deviceToken: model.data![0].deviceToken!,
            senderName: listner.data![0].name!,
            senderImageUrl:
            SharedPreference.getValue(PrefConstants.LISTENER_IMAGE),
            cId: widget.channelName,
            cTn: SharedPreference.getValue(PrefConstants.AGORA_TOKEN_TWO),
            uid: SharedPreference.getValue(PrefConstants.AGORA_UID_TWO));
        setState(() {
          deviceToken = model.data![0].deviceToken;
        });
      }
    } else {
      if (SharedPreference.getValue(PrefConstants.USER_TYPE) == 'user') {
        ListnerDisplayModel? model =
        await APIServices.getListnerDataById(widget.listnerid);

        setState(() {
          deviceToken = model.data![0].deviceToken;
        });
      } else {
        ListnerDisplayModel? model =
        await APIServices.getUserDataById(widget.userid);

        setState(() {
          deviceToken = model.data![0].deviceToken;
        });
      }
    }
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