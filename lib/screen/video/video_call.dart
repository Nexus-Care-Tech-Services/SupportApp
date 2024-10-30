import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:floating/floating.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/main.dart';
import 'package:support/utils/color.dart';
import 'package:support/utils/reuasble_widget/image.dart';
import 'package:support/utils/reuasble_widget/notification.dart';
import 'package:support/utils/reuasble_widget/utils.dart';
import 'package:support/model/block_user.dart';
import 'package:support/model/charge_wallet_model.dart';
import 'package:support/model/listner_display_model.dart';
import 'package:support/model/nickname_get_model.dart';
import 'package:support/screen/listner_app_ui/listner_wallet.dart/listner_wallet.dart';
import 'package:support/screen/listner_app_ui/user_rate_give_screen.dart';
import 'package:support/screen/wallet/wallet_screen.dart';
import 'package:support/sharedpreference/sharedpreference.dart';

const agoraAppId = '11644e46dc56453b9da54562219452bd';

class VideoCall extends StatefulWidget {
  final String? channelName;
  final String userName;
  final int uid;
  final String toUserId;
  final bool incoming;
  final bool isCaller;
  final bool usertype;

  final String token;

  final String listenerId;
  final String userid;
  final String senderImageUrl;
  final int? callId;

  const VideoCall(
      {Key? key,
      this.channelName,
      required this.token,
      required this.uid,
      required this.userName,
      this.incoming = false,
      required this.listenerId,
      required this.senderImageUrl,
      this.toUserId = "",
      this.callId,
      required this.userid,
      required this.isCaller,
      required this.usertype})
      : super(key: key);

  @override
  State<VideoCall> createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> with WidgetsBindingObserver {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool speaker = false;
  bool camera = true;
  bool isLocalzoom = false, isdragged = false;
  late RtcEngine _engine;

  bool isListener = false;
  bool isFirstCall = false;
  bool isPageEnabled = true;
  String callRecordingId = "";
  final sessionId = getRandomString(16);
  int seconds = 0, ringingseconds = 0;
  int? userid;
  bool joined = false;
  String? resourceId, recordingId;
  double left = 15, top = 40;

  static const platform = MethodChannel('com.example.support/screen_control');

  ListnerDisplayModel? listnerDisplayModel;
  NicknameGetModel? nickNameModel;
  String? nickName, walletamt;
  String? deviceToken;

  final FlutterLocalNotificationsPlugin ongoingCallNotificaion =
      FlutterLocalNotificationsPlugin();
  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();

  Duration duration = const Duration();
  Timer? timer, timer1, counttimer, timer2;
  final player = AudioPlayer();
  late Floating pip;
  bool isPipAvaliable = false;
  bool userjoined = false, lowbalance = false;

  final StopWatchTimer stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    onChangeRawMinute: (value) => () {
      debugPrint('cut thr price');
    },
  );

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

  void ringingTime() {
    timer1 = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        ringingseconds += 1;
      });
      if (ringingseconds > 5 && ringingseconds < 30) {
        if (!joined) {
          timer.cancel();
          timer1!.cancel();
          _onCallEnd(6);
        }
        if (widget.incoming && !userjoined) {
          timer.cancel();
          timer1!.cancel();
          _onCallEnd(6);
        }
      }
    });
    timer = Timer.periodic(const Duration(seconds: 30), (Timer t) {
      if (duration.inSeconds <= 0) {
        if (ringingseconds >= 30) {
          timer1!.cancel();
          _onCallEnd(3);
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
    if (mounted) {
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

      if (!userjoined && joined) {
        timer!.cancel();
        timer2!.cancel();
        _onCallEnd(2);
      }
      if (lowbalance) {
        timer!.cancel();
        timer2!.cancel();
        isListener ? _onCallEnd(2) : _onCallEnd(4);
      }
    });
    timer2 = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (isListener) {
        if (widget.isCaller) {
          amountKaatLo(1);
        } else {
          checkUserWalletBalance(1);
        }
      } else {
        amountKaatLo(1);
      }
    });
  }

  void initializeDeduct(int seconds) {
    counttimer = Timer.periodic(Duration(seconds: seconds), (timer) {
      if (isListener) {
        if (widget.isCaller) {
          amountKaatLo(1);
        } else {
          checkUserWalletBalance(1);
        }
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
            if (widget.isCaller) {
              amountKaatLo(1);
            }
          } else {
            amountKaatLo(1);
          }
        }
      });
    }
  }

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
    if (double.parse(amount) <= 18.0) {
      if (mounted) {
        showLowBalancePopup(context);
      }
      return;
    } else {
      ChargeWalletModel chargeWalletModel =
          await APIServices.chargeVideoCallApi(
              widget.userid, widget.listenerId, '1', sessionId);

      if (chargeWalletModel.status == true) {
        String meraAmount = await APIServices.getWalletAmount(
                SharedPreference.getValue(PrefConstants.MERA_USER_ID)) ??
            "0.0";
        SharedPreference.setValue(PrefConstants.WALLET_AMOUNT, meraAmount);
      } else {
        _onCallEnd(5);
      }
    }
    checkBalancePeriodically();
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
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: colorWhite, fontSize: 14),
      );

  @override
  void dispose() {
    _users.clear();
    WidgetsBinding.instance.removeObserver(this);
    pip.dispose();
    _dispose();
    if (timer!.isActive) {
      timer?.cancel();
    }
    if (timer2!.isActive) {
      timer2!.cancel();
    }
    ongoingCallNotificaion.cancelAll();
    unregisterSensor();
    super.dispose();
  }

  Future<void> _dispose() async {
    // destroy sdk
    if (widget.callId != null) {
      EasyLoading.show(
          status: 'Please wait, updating your wallet balance'.tr,
          maskType: EasyLoadingMaskType.clear);
      EasyLoading.dismiss();
    }
    await APIServices.getBusyOnline(false, widget.listenerId);
    await APIServices.getBusyOnline(false, widget.userid);

    await _engine.leaveChannel();
    await _engine.release();
    unregisterSensor();

    player.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    player.setUrl("asset:assets/sound/ringing.mp3");
    player.play();
    initialize();
    EasyLoading.dismiss();
    registerSensor();
    initializeNotifications();
    WidgetsBinding.instance.addObserver(this);
    pip = Floating();
    checkPipAvaliablility();
    _configureHangupButton();
    SharedPreference.setValue(
        PrefConstants.USER_AVAILABLE_BALANCE, "Loading...");
    if (SharedPreference.getValue(PrefConstants.USER_TYPE) != 'user') {
      getNickName();
    }
  }

  checkPipAvaliablility() async {
    isPipAvaliable = await pip.isPipAvailable;
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      await pip.enable(aspectRatio: const Rational.vertical());
    }
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
      if (kDebugMode) {
        print('error occured');
      }
    }
  }

  Future<void> initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isListener = prefs.getBool("isListener") ?? false;
    });
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
    if (isListener) {
      await _engine.joinChannel(
          token: widget.token,
          channelId: widget.channelName!,
          options: const ChannelMediaOptions(),
          uid: widget.uid);
    } else {
      await _engine.joinChannel(
          token: widget.token,
          channelId: widget.channelName!,
          options: const ChannelMediaOptions(),
          uid: widget.uid);
    }
    String? amt = await APIServices.getWalletAmount(
        SharedPreference.getValue(PrefConstants.MERA_USER_ID));
    setState(() {
      walletamt = amt;
    });
    ringingTime();
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
        appId: agoraAppId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting));
    await _engine.setVideoEncoderConfiguration(const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 1920, height: 1080)));
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    debugPrint('start handler');
    _engine.registerEventHandler(RtcEngineEventHandler(onError:
        (ErrorCodeType code, String msg) {
      setState(() {
        final info = 'onError: $code $msg';
        debugPrint(info);
        _infoStrings.add(info);
      });
    }, onJoinChannelSuccess: (RtcConnection channel, int uid) async {
      setState(() {
        final info =
            'onJoinChannel: ${channel.channelId} ${channel.localUid}, uid: $uid';
        debugPrint(info);
        _infoStrings.add(info);
        joined = true;
        getListnerDetails();
      });
    }, onLeaveChannel: (RtcConnection connect, RtcStats stats) {
      setState(() {
        _infoStrings.add(
            'onLeaveChannel ${connect.channelId} ${connect.localUid} ${stats.toString()}');
        _users.clear();
        debugPrint(
            'onLeaveChannel ${connect.channelId} ${connect.localUid} ${stats.toString()}');
        joined = false;
        if (userjoined) {
          timer!.cancel();
          _onCallEnd(2);
        }
      });
    }, onUserJoined: (RtcConnection connect, int uid, int elapsed) async {
      if (player.playing) {
        player.stop();
      }
      startTimer();
      initializeDeduct(1);
      _showNotificationForOngoingCall();
      await _engine.setEnableSpeakerphone(true);
      setState(() {
        final info = 'userJoined: ${connect.channelId} $uid $elapsed';
        debugPrint(info);
        _infoStrings.add(info);
        _users.add(uid);
        userjoined = true;
        userid = uid;
      });
      if (timer1!.isActive) {
        timer1!.cancel();
      }
    }, onUserOffline: (RtcConnection connect, int remoteuid,
        UserOfflineReasonType elapsed) async {
      setState(() {
        final info = 'userOffline: ${connect.channelId} $remoteuid $elapsed';
        _infoStrings.add(info);
        _users.remove(remoteuid);
        debugPrint(info);
        if (joined) {
          userjoined = false;
        }
      });
    }, onFirstRemoteVideoFrame:
        (RtcConnection connect, int uid, int width, int height, int elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid $width x $height';
        debugPrint(info);
        _infoStrings.add(info);
      });
    }, onFirstLocalVideoFrame:
        (VideoSourceType source, int width, int height, int elapsed) {
      setState(() {
        final info = 'firstLocalVideo: $source $width x $height';
        debugPrint(info);
        _infoStrings.add(info);
      });
    }));
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: isListener
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RawMaterialButton(
                  onPressed: _onToggleMute,
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: muted
                      ? ui_mode == "dark"
                          ? colorBlack
                          : Colors.blueAccent
                      : colorWhite,
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    muted ? Icons.mic_off : Icons.mic,
                    color: muted
                        ? colorWhite
                        : ui_mode == "dark"
                            ? colorBlack
                            : Colors.blueAccent,
                    size: 20.0,
                  ),
                ),
                RawMaterialButton(
                  onPressed: () => _onSwitchCamera(),
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: colorWhite,
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.cameraswitch_rounded,
                    color: ui_mode == "dark" ? colorBlack : Colors.blueAccent,
                    size: 20.0,
                  ),
                ),
                RawMaterialButton(
                  onPressed: _onCameraOff,
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: camera
                      ? colorWhite
                      : ui_mode == "dark"
                          ? colorBlack
                          : Colors.blueAccent,
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    camera
                        ? Icons.videocam_rounded
                        : Icons.videocam_off_rounded,
                    color: camera
                        ? ui_mode == "dark"
                            ? colorBlack
                            : Colors.blueAccent
                        : colorWhite,
                    size: 20.0,
                  ),
                ),
                RawMaterialButton(
                  onPressed: () => _onCallEnd(1),
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.redAccent,
                  padding: const EdgeInsets.all(15.0),
                  child: const Icon(
                    Icons.call_end,
                    color: colorWhite,
                    size: 30.0,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RawMaterialButton(
                  onPressed: _onToggleMute,
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: muted
                      ? ui_mode == "dark"
                          ? colorBlack
                          : Colors.blueAccent
                      : colorWhite,
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    muted ? Icons.mic_off : Icons.mic,
                    color: muted
                        ? colorWhite
                        : ui_mode == "dark"
                            ? colorBlack
                            : Colors.blueAccent,
                    size: 20.0,
                  ),
                ),
                RawMaterialButton(
                  onPressed: () => _onCallEnd(1),
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.redAccent,
                  padding: const EdgeInsets.all(15.0),
                  child: const Icon(
                    Icons.call_end,
                    color: colorWhite,
                    size: 30.0,
                  ),
                ),
                RawMaterialButton(
                  onPressed: () => _onSwitchCamera(),
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: colorWhite,
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.cameraswitch_rounded,
                    color: ui_mode == "dark" ? colorBlack : Colors.blueAccent,
                    size: 20.0,
                  ),
                )
              ],
            ),
    );
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
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

  void _onCallEnd(type) async {
    onCallDisconnect();
    await APIServices.getBusyOnline(false, widget.listenerId);
    await APIServices.getBusyOnline(false, widget.userid);

    if (type == 3) {
      if (timer1!.isActive) {
        timer1!.cancel();
      }
      if (!isListener || widget.isCaller) {
        APIServices.updateCallChatLogs(
            SharedPreference.getValue(PrefConstants.MERA_USER_ID),
            widget.listenerId,
            type,
            'video');
        await APIServices.setListnerOffline(widget.listenerId);
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
          isListener ? 'User disconnected the call!' : 'Call disconnected!'.tr);
    } else if (type == 4) {
      EasyLoading.showInfo('Low Balance, Please Recharge!'.tr);
    } else {
      EasyLoading.showInfo('Disconnecting the call, please wait . . .'.tr);
    }

    if (mounted) {
      if (duration.inSeconds > 0) {
        if (isListener) {
          checkOnlineStatus();
          widget.isCaller
              ? Navigator.pop(context, true)
              : Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserRateGiveScreen(userId: widget.userid.toString()),
                  ));
        } else {
          await ongoingCallNotificaion.cancelAll();
          if (mounted) {
            if(widget.incoming == true) {
              Navigator.pop(context);
            }
            else {
              Navigator.pop(context, true);
            }
          }
        }
      } else {
        Navigator.pop(context, false);
      }
    }
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onCameraOff() {
    setState(() {
      camera = !camera;
    });
    _engine.enableLocalVideo(camera);
  }

  void onCallDisconnect() {
    setState(() {
      isPageEnabled = false;
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
                              widget.listenerId, textEditingController.text);
                        } else {
                          model = await APIServices.blockUser(
                              widget.userid, widget.listenerId, selectedOption);
                        }
                        if (model!.message == 'Blocked successfully') {
                          EasyLoading.dismiss();
                          EasyLoading.showSuccess(model.message.toString());
                          _onCallEnd(2);
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

  @override
  Widget build(BuildContext context) {
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
                      _onCallEnd(1);
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
      child: PiPSwitcher(
        childWhenDisabled: Scaffold(
          backgroundColor: cardColor,
          body: SafeArea(
            child: Stack(
              children: <Widget>[
                if (userid == null) ...{
                  joined
                      ? AgoraVideoView(
                          controller: VideoViewController(
                          rtcEngine: _engine,
                          useAndroidSurfaceView: true,
                          canvas: const VideoCanvas(uid: 0),
                        ))
                      : Container(),
                  SafeArea(
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        const SizedBox(height: 80.0),
                        Icon(
                          Icons.lock_rounded,
                          size: 18,
                          color: textColor,
                        ),
                        Text(
                          'End-to-end encrypted'.tr,
                          style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.normal,
                              fontSize: 14.0),
                        ),
                      ])),
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 100.0),
                        showImage(
                          MediaQuery.of(context).size.width * 0.1,
                          isListener
                              ? widget.isCaller
                                  ? NetworkImage(APIConstants.BASE_URL +
                                      widget.senderImageUrl)
                                  : NetworkImage(widget.senderImageUrl)
                              : NetworkImage(APIConstants.BASE_URL +
                                  widget.senderImageUrl),
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          nickName != null
                              ? "${widget.userName} ($nickName)"
                              : widget.userName,
                          style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.normal,
                              fontSize: 24.0),
                        ),
                        const SizedBox(height: 30.0),
                        duration.inSeconds <= 0
                            ? Text(
                                'Ringing...'.tr,
                                style: const TextStyle(color: colorWhite),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                },
                if (userid != null) ...{
                  userid != null
                      ? isLocalzoom
                          ? AgoraVideoView(
                              controller: VideoViewController(
                              rtcEngine: _engine,
                              useAndroidSurfaceView: true,
                              canvas: const VideoCanvas(uid: 0),
                            ))
                          : AgoraVideoView(
                              controller: VideoViewController.remote(
                                  rtcEngine: _engine,
                                  canvas: VideoCanvas(uid: userid),
                                  connection: RtcConnection(
                                      channelId: widget.channelName)))
                      : Center(
                          child: Text(isListener
                              ? 'Please Wait for User to Join'
                              : 'Please Wait for Listener to Join')),
                  if (joined) ...{
                    Positioned(
                      top: top,
                      left: left,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            top = max(40, top + details.delta.dy);
                            top = top.clamp(
                                40, MediaQuery.of(context).size.height - 270);
                            left = max(15, left + details.delta.dx);
                            left = left.clamp(
                                15, MediaQuery.of(context).size.width - 115);
                          });
                        },
                        onTap: () {
                          setState(() {
                            isLocalzoom = !isLocalzoom;
                          });
                        },
                        child: SizedBox(
                          height: 130,
                          width: 100,
                          child: isLocalzoom
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20)),
                                  child: AgoraVideoView(
                                      controller: VideoViewController.remote(
                                          rtcEngine: _engine,
                                          canvas: VideoCanvas(uid: userid),
                                          connection: RtcConnection(
                                              channelId: widget.channelName))),
                                )
                              : ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20)),
                                  child: AgoraVideoView(
                                      controller: VideoViewController(
                                    rtcEngine: _engine,
                                    useAndroidSurfaceView: true,
                                    canvas: const VideoCanvas(uid: 0),
                                  ))),
                        ),
                      ),
                    ),
                  },
                  Align(
                    alignment: Alignment.topCenter,
                    child: duration.inSeconds > 0 ? buildTime() : Container(),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, right: 10),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => isListener
                                      ? const ListnerWalletScreen()
                                      : const WalletScreen()));
                        },
                        // child: const Icon(
                        //   Icons.wallet,
                        //   size: 26,
                        // ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: colorWhite, width: 1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              '\u{20B9}$walletamt',
                              style: const TextStyle(color: colorWhite),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  isListener && duration.inSeconds > 0
                      ? Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: IconButton(
                              onPressed: () => _showConfirmationDialog(context),
                              icon: const Icon(
                                Icons.person_off_outlined,
                                size: 30,
                                color: colorWhite,
                              ),
                            ),
                          ),
                        )
                      : Container(),
                },
                // if (kDebugMode) _panel(),
                if (isPageEnabled) _toolbar(),
              ],
            ),
          ),
        ),
        childWhenEnabled: SafeArea(
          child: Stack(
            children: <Widget>[
              if (userid == null) ...{
                joined
                    ? AgoraVideoView(
                        controller: VideoViewController(
                        rtcEngine: _engine,
                        useAndroidSurfaceView: true,
                        canvas: const VideoCanvas(uid: 0),
                      ))
                    : Container(),
                Center(
                  child: showImage(
                    MediaQuery.of(context).size.width * 0.1,
                    isListener
                        ? widget.isCaller
                            ? NetworkImage(
                                APIConstants.BASE_URL + widget.senderImageUrl)
                            : NetworkImage(widget.senderImageUrl)
                        : NetworkImage(
                            APIConstants.BASE_URL + widget.senderImageUrl),
                  ),
                ),
              },
              if (userid != null) ...{
                userid != null
                    ? isLocalzoom
                        ? AgoraVideoView(
                            controller: VideoViewController(
                            rtcEngine: _engine,
                            useAndroidSurfaceView: true,
                            canvas: const VideoCanvas(uid: 0),
                          ))
                        : AgoraVideoView(
                            controller: VideoViewController.remote(
                                rtcEngine: _engine,
                                canvas: VideoCanvas(uid: userid),
                                connection: RtcConnection(
                                    channelId: widget.channelName)))
                    : Center(
                        child: Text(isListener
                            ? 'Please Wait for User to Join'
                            : 'Please Wait for Listener to Join')),
                if (joined) ...{
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin: const EdgeInsets.only(right: 5, bottom: 10),
                      height: 90,
                      width: 60,
                      child: isLocalzoom
                          ? ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                              child: AgoraVideoView(
                                  controller: VideoViewController.remote(
                                      rtcEngine: _engine,
                                      canvas: VideoCanvas(uid: userid),
                                      connection: RtcConnection(
                                          channelId: widget.channelName))),
                            )
                          : ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                              child: AgoraVideoView(
                                  controller: VideoViewController(
                                rtcEngine: _engine,
                                useAndroidSurfaceView: true,
                                canvas: const VideoCanvas(uid: 0),
                              ))),
                    ),
                  ),
                },
              }
            ],
          ),
        ),
      ),
    );
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/video_call');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await ongoingCallNotificaion.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) {
      switch (notificationResponse.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          // selectNotificationStream.add(notificationResponse.payload);
          break;
        case NotificationResponseType.selectedNotificationAction:
          if (notificationResponse.actionId == 'call_hang_up') {
            selectNotificationStream.add(notificationResponse.payload);
          }
          break;
      }
    });
  }

  void _configureHangupButton() {
    selectNotificationStream.stream.listen((String? payload) async {
      // _onCallEnd(1);
    });
  }

  Future<void> _showNotificationForOngoingCall() async {
    // await ongoingCallNotificaion.cancelAll();
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'ongoing id',
      'ongoing content',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      when: DateTime.now().millisecondsSinceEpoch - 0 * 1000,
      usesChronometer: true,
      ongoing: true,
      chronometerCountDown: false,
      autoCancel: false,
      styleInformation: const BigTextStyleInformation(''),
      actions: [
        AndroidNotificationAction(
          'call_hang_up',
          'BACK TO SESSION'.tr,
          showsUserInterface: true,
        ),
      ],
    );
    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await ongoingCallNotificaion.show(
      seconds++,
      widget.userName,
      'Video Call Session Active'.tr,
      notificationDetails,
      payload: 'action_hangup',
    );
  }

  void getListnerDetails() async {
    if (widget.incoming == false) {
      if (SharedPreference.getValue(PrefConstants.USER_TYPE) == 'user') {
        ListnerDisplayModel? model =
            await APIServices.getListnerDataById(widget.listenerId);

        APIServices.sendVideoCallNotification(
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
        if (widget.isCaller) {
          ListnerDisplayModel? model =
              await APIServices.getListnerDataById(widget.listenerId);

          APIServices.sendVideoCallNotification(
              userid: SharedPreference.getValue(PrefConstants.MERA_USER_ID),
              listenerId: model.data![0].id.toString(),
              deviceToken: model.data![0].deviceToken!,
              senderName:
                  SharedPreference.getValue(PrefConstants.LISTENER_NAME),
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
              await APIServices.getListnerDataById(widget.listenerId);

          APIServices.sendVideoCallNotification(
              listenerId: SharedPreference.getValue(PrefConstants.MERA_USER_ID),
              userid: widget.userid,
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
      }
    }
  }
}
