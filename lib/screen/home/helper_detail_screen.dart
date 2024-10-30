// ignore_for_file: use_build_context_synchronouslyprimaryColor

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_version_checker/flutter_app_version_checker.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support/api/api_services.dart';
import 'package:support/model/reel_model.dart';
import 'package:support/utils/color.dart';
import 'package:support/main.dart';
import 'package:support/model/block_user_list.dart';
import 'package:support/model/listner_display_model.dart';
import 'package:support/model/send_bell_icon_notification_model.dart';
import 'package:support/screen/chat/agora_chat_screen.dart';
import 'package:support/screen/reels/reels_screen.dart';
import 'package:support/screen/home/home_screen.dart';
import 'package:support/utils/reuasble_widget/image.dart';
import 'package:support/utils/reuasble_widget/listner_image.dart';
import 'package:support/utils/reuasble_widget/marquee_widget.dart';
import 'package:support/utils/reuasble_widget/review_data.dart';
import 'package:support/screen/video/video_call.dart';
import 'package:support/screen/wallet/wallet_screen.dart';
import 'package:support/utils/reuasble_widget/utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

import 'package:support/api/api_constant.dart';
import 'package:support/model/busy_online.dart';
import 'package:support/model/feedback_model.dart';
import 'package:support/model/listner_display_model.dart' as listner;
import 'package:support/model/report_model.dart';
import 'package:support/model/user_chat_send_request.dart';
import 'package:support/utils/reuasble_widget/appbar.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/reuasble_widget/toast_widget.dart';
import 'package:support/screen/call/call.dart';
import 'package:support/screen/home/chat_request_screen.dart';

class HelperDetailScreen extends StatefulWidget {
  final String? listnerId;
  final bool? showFeedbackForm;

  const HelperDetailScreen({
    Key? key,
    this.showFeedbackForm,
    this.listnerId,
  }) : super(key: key);

  @override
  State<HelperDetailScreen> createState() => _HelperDetailScreenState();
}

class _HelperDetailScreenState extends State<HelperDetailScreen>
    with SingleTickerProviderStateMixin {
  num? percent5, percent4, percent3, percent2, percent1;
  final feedbackController = TextEditingController();

  double ratingStore = 5;
  String walletAmount = "0.0";
  bool isListener = false;
  BusyOnlineModel? busyOnlineModel;

  bool isProgressRunning = false;
  bool isFirstCall = true;
  String name = '';
  bool onlineStatus = true;
  Widget? image;
  double? width = 150;
  double? height = 150;
  dynamic response;
  late int onlinestatus;
  late dynamic lastActiveTime;
  bool isFetching = false;
  bool isBlocked = false;
  listner.ListnerDisplayModel? listenerDisplayModel1;
  int blockcount = 0;

  bool isAppUpdated = true;

  int amounytController = 100;
  String? orderId, paymentId, signature;

  int bioLiked = 0, profileLiked = 0;
  bool isBioLiked = false, isProfileLiked = false;
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;

  //List of ReviewData
  List<ReviewData> reviewData = [];
  List<bool> review = [];

// variable to calculate total no. of reviews
  int totalReviews = 0;

// variable to calculate average rating
  double avgRating = 0.0;
  String interest = '';
  String language = '';

  TabController? tabController;
  int selectedIndex = 0;
  ReelModel? listenerReels;
  List<String> thumbnails = [];
  List<Map<String, dynamic>> giftsList = [];

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  imagedata(width, height) {
    return getImage(
        height,
        width,
        "${APIConstants.BASE_URL}${listenerDisplayModel1?.data![0].image}",
        width,
        "assets/logo.png",
        BoxShape.circle,
        context);
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    tabController = TabController(length: 2, vsync: this);
    tabController!.addListener(() {
      setState(() {
        selectedIndex = tabController!.index;
      });
    });
    setReels();
    checkAppVersion();
    getBlockCount();
    getLikesCount();
    fetchListnerData();
    checkListener();
    Future.delayed(Duration.zero, () async {
      String amount = await APIServices.getWalletAmount(
              SharedPreference.getValue(PrefConstants.MERA_USER_ID)) ??
          "0.0";
      setState(() {
        walletAmount = amount;
        SharedPreference.setValue(PrefConstants.WALLET_AMOUNT, walletAmount);
      });
    });
    // apiOnlineBusy();
    Future.delayed(Duration.zero, () {
      if (widget.showFeedbackForm! == true) {
        showFeedBackDialog(context);
      }
    });
    Future.delayed(const Duration(seconds: 5), () async {
      setTotalAndAvgRatings();
      setLangAndInterest();
      getReportedReviews();
    });
  }

  Future<void> setReels() async {
    listenerReels = await APIServices.fetchReelData(
        filterReel: true, listnerId: widget.listnerId);
    if (listenerReels!.data!.isNotEmpty) {
      for (int i = 0; i < listenerReels!.data!.length; i++) {
        debugPrint('##${listenerReels!.data![i].listnerId}');
        if (listenerReels!.data![i].listnerId.toString() == widget.listnerId) {
          thumbnails.add("");
          final gifts = await APIServices.fetchGifts(
              listenerReels!.data![i].listnerId.toString(),
              listenerReels!.data![i].reelId!);
          giftsList.add(gifts);
        }
      } //var data in listenerReels)
      debugPrint('##$giftsList');
      for (int i = 0; i < listenerReels!.data!.length; i++) {
        if (listenerReels!.data![i].listnerId.toString() == widget.listnerId) {
          String? videoUrl = listenerReels!.data![i].reelUrl!;
          try {
            final thumbnailPath = await VideoThumbnail.thumbnailFile(
              video: videoUrl,
              thumbnailPath: (await getTemporaryDirectory()).path,
              imageFormat: ImageFormat.JPEG,
              maxWidth: 500,
              // Adjust thumbnail size as needed
              maxHeight: 500,

              quality: 100, // Adjust thumbnail quality as needed
            );

            if (thumbnailPath != null) {
              setState(() {
                thumbnails[i] = thumbnailPath;
              });
            }
          } catch (e) {
            log("reels gift $e");
          }
        }
      }
    }
  }

  Widget reelGifts(Image? image, String text) {
    List<String> items = text.split(', ');
    return SizedBox(
      height: 160,
      child: Card(
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 80,
                  width: 80,
                  child: image ?? Container(),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              SizedBox(
                height: 140,
                width: 260,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  // Disable scrolling
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Number of items per row
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 6,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Text(
                      items[index],
                      style: TextStyle(
                          fontSize: 16,
                          color: ui_mode == "dark" ? colorWhite : colorBlack),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getBlockCount() async {
    BlockUserList? model = await APIServices.blockUserList();
    if (model != null && listenerDisplayModel1 != null) {
      for (int i = 0; i < model.blockedListeners!.length; i++) {
        if (model.blockedListeners![i].id ==
            listenerDisplayModel1!.data![0].id) {
          setState(() {
            isBlocked = true;
            blockcount = model.blockedListeners![i].blockCount!;
          });
        }
      }
    }
  }

  void getLikesCount() async {
    DocumentSnapshot biodoc =
        await _firebase.collection("bio-likes").doc(widget.listnerId!).get();
    if (biodoc.exists) {
      List<dynamic> list = biodoc['likes'];
      if (list.contains(
          int.parse(SharedPreference.getValue(PrefConstants.MERA_USER_ID)))) {
        setState(() {
          isBioLiked = true;
        });
      }
      setState(() {
        bioLiked = list.length;
      });
    }

    DocumentSnapshot doc = await _firebase
        .collection("listner-likes")
        .doc(widget.listnerId!)
        .get();
    if (doc.exists) {
      List<dynamic> list = doc['likes'];
      if (list.contains(
          int.parse(SharedPreference.getValue(PrefConstants.MERA_USER_ID)))) {
        setState(() {
          isProfileLiked = true;
        });
      }
      setState(() {
        profileLiked = list.length;
      });
    }
  }

  void getReportedReviews() async {
    if (listenerDisplayModel1 != null) {
      FirebaseFirestore firebase = FirebaseFirestore.instance;
      var collection = firebase.collection("reported_reviews");
      for (int i = 0;
          i < listenerDisplayModel1!.data![0].ratingReviews!.allReviews!.length;
          i++) {
        var doc = await collection
            .doc(listenerDisplayModel1!
                .data![0].ratingReviews!.allReviews![i].id!)
            .get();
        setState(() {
          if (doc.exists) {
            review[i] = true;
          } else {
            review[i] = false;
          }
        });
      }
    }
  }

  Future<void> fetchListnerData() async {
    try {
      setState(() {
        isFetching = true;
      });

      ListnerDisplayModel listnerDisplayModel =
          await APIServices.getListnerDataById(widget.listnerId!);
      setState(() {
        listenerDisplayModel1 = listnerDisplayModel;
      });
      setState(() {
        onlinestatus = listenerDisplayModel1!.data![0].onlineStatus!;
      });
      lastActiveTime = listenerDisplayModel1!.data![0].updatedAt;
      image = CachedNetworkImage(
        imageUrl:
            "${APIConstants.BASE_URL}${listenerDisplayModel1!.data![0].image}",
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Image.asset(
          "assets/logo.png",
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
        placeholder: (context, url) => Image.asset(
          "assets/logo.png",
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      );

      for (int i = 0;
          i < listnerDisplayModel.data![0].ratingReviews!.allReviews!.length;
          i++) {
        review.add(false);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          // initializing the reviewData variable with the listener's ratings
          reviewData = [
            ReviewData(
              '1★',
              listenerDisplayModel1!.data![0].ratingReviews!.rating1 ?? 0,
              ui_mode == 'dark'
                  ? const Color.fromRGBO(250, 141, 125, 1)
                  : const Color.fromRGBO(255, 105, 97, 1),
            ),
            ReviewData(
              '2★',
              listenerDisplayModel1!.data![0].ratingReviews!.rating2 ?? 0,
              ui_mode == 'dark'
                  ? const Color.fromRGBO(255, 207, 61, 1)
                  : const Color.fromARGB(255, 163, 170, 255),
            ),
            ReviewData(
              '3★',
              listenerDisplayModel1!.data![0].ratingReviews!.rating3 ?? 0,
              ui_mode == 'dark'
                  ? const Color.fromRGBO(185, 159, 229, 1)
                  : const Color.fromRGBO(233, 236, 107, 1),
            ),
            ReviewData(
              '4★',
              listenerDisplayModel1!.data![0].ratingReviews!.rating4 ?? 0,
              ui_mode == 'dark'
                  ? const Color.fromRGBO(129, 176, 217, 1)
                  : const Color.fromRGBO(137, 207, 240, 1),
            ),
            ReviewData(
              '5★',
              listenerDisplayModel1!.data![0].ratingReviews!.rating5 ?? 0,
              ui_mode == 'dark'
                  ? const Color.fromRGBO(88, 161, 81, 1)
                  : const Color.fromRGBO(119, 221, 119, 1),
            ),
          ];
          isFetching = false;
        });
      }
    }
  }

  // function to calculate total no. of ratings and average rating
  void setTotalAndAvgRatings() async {
    if (listenerDisplayModel1 != null) {
      setState(() {
        final review = listenerDisplayModel1!.data![0].ratingReviews!;
        totalReviews = review.rating1! +
            review.rating2! +
            review.rating3! +
            review.rating4! +
            review.rating5!;
        avgRating = review.averageRating!.toDouble();
      });
    }
  }

  void setLangAndInterest() {
    if (listenerDisplayModel1 != null) {
      setState(() {
        // replacing ',' and ' ' with new line(\n)
        interest =
            (listenerDisplayModel1?.data![0].interest ?? '').replaceAllMapped(
          RegExp(r'(,|\s)+'),
          (match) {
            return '\n';
          },
        );

        // replacing ',' and ' ' with new line(\n)
        language =
            (listenerDisplayModel1?.data![0].language ?? '').replaceAllMapped(
          RegExp(r'(,|\s)+'),
          (match) {
            return '\n';
          },
        );
      });
    }
  }

  checkListener() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isListener = prefs.getBool("isListener")!;
    setState(() {});
  }

  Future<void> checkAppVersion() async {
    final appchecker = AppVersionChecker(appId: "com.support2heal.app");
    appchecker.checkUpdate().then((value) {
      int current = int.parse(value.currentVersion.replaceAll(".", ""));
      int newVersion = int.parse(value.newVersion!.replaceAll(".", ""));
      debugPrint("$current $newVersion");
      if (current < newVersion) {
        setState(() {
          isAppUpdated = false;
        });
        toastshowDefaultSnackbar(
            context, "App Updation is required".tr, true, primaryColor);
      } else {
        setState(() {
          isAppUpdated = true;
        });
      }
    });
  }

  onVideoCallPlaced() async {
    await AppUtils.handleMic(Permission.microphone, context);
    if (await Permission.microphone.isGranted) {
      if (context.mounted) {
        await AppUtils.handleCamera(Permission.camera, context);
        if (await Permission.camera.isGranted) {
          EasyLoading.show(
              status: "Connecting with our secure server".tr,
              maskType: EasyLoadingMaskType.clear);
          var data = await APIServices.getAgoraTokens();

          if (listenerDisplayModel1?.data![0].deviceToken != null) {
            SharedPreference.setValue(
                PrefConstants.AGORA_UID_TWO, data["agora_uid_two"]);
            SharedPreference.setValue(
                PrefConstants.AGORA_TOKEN_TWO, data["token_two"]);
            ListnerDisplayModel model = await APIServices.getListnerDataById(
                listenerDisplayModel1!.data![0].id!.toString());
            if (model.data![0].busyStatus == 0) {
              await APIServices.getBusyOnline(
                  true, listenerDisplayModel1?.data![0].id!.toString());
              await APIServices.getBusyOnline(
                  true, SharedPreference.getValue(PrefConstants.MERA_USER_ID));

              EasyLoading.dismiss();

              onVideoCallJoin(
                  channelId: data["room_id"],
                  channelToken: data["token_one"],
                  uid: int.parse(data["agora_uid_one"]),
                  data: null);
            } else {
              EasyLoading.dismiss();
              EasyLoading.showInfo('Listner is Busy'.tr);
            }
          } else {
            EasyLoading.showError("User not available".tr);
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
    // await for camera and mic permissions before pushing video page

    // push video page with given channel name
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCall(
          usertype: SharedPreference.getValue(PrefConstants.USER_TYPE) == "user"
              ? false
              : true,
          isCaller: SharedPreference.getValue(PrefConstants.USER_TYPE) == "user"
              ? false
              : true,
          userid: SharedPreference.getValue(PrefConstants.MERA_USER_ID),
          listenerId: listenerDisplayModel1!.data![0].id.toString(),
          senderImageUrl: listenerDisplayModel1!.data![0].image.toString(),
          userName: listenerDisplayModel1?.data![0].name ?? "Seeker",
          uid: uid,
          channelName: channelId,
          token: channelToken,
          callId: data,
        ),
      ),
    );

    if (result) {
      if (context.mounted) {
        showFeedBackDialog(context);
      }
    }
  }

  onCallPlaced() async {
    await AppUtils.handleMic(Permission.microphone, context);
    if (await Permission.microphone.isGranted) {
      EasyLoading.show(
          status: "Connecting with our secure server".tr,
          maskType: EasyLoadingMaskType.clear);
      var data = await APIServices.getAgoraTokens();

      if (listenerDisplayModel1?.data![0].deviceToken != null) {
        SharedPreference.setValue(
            PrefConstants.AGORA_UID_TWO, data["agora_uid_two"]);
        SharedPreference.setValue(
            PrefConstants.AGORA_TOKEN_TWO, data["token_two"]);
        ListnerDisplayModel model = await APIServices.getListnerDataById(
            listenerDisplayModel1!.data![0].id!.toString());
        if (model.data![0].busyStatus == 0) {
          await APIServices.getBusyOnline(
              true, listenerDisplayModel1?.data![0].id!.toString());
          await APIServices.getBusyOnline(
              true, SharedPreference.getValue(PrefConstants.MERA_USER_ID));

          EasyLoading.dismiss();

          onCallJoin(
              channelId: data["room_id"],
              channelToken: data["token_one"],
              uid: int.parse(data["agora_uid_one"]),
              data: null);
        } else {
          EasyLoading.dismiss();
          EasyLoading.showInfo('Listner is Busy'.tr);
        }
      } else {
        EasyLoading.showError("User not available".tr);
      }
    } else {
      if (context.mounted) {
        toastshowDefaultSnackbar(context,
            'Microphone Permission is Required'.tr, false, primaryColor);
      }
    }
  }

  Future<void> onCallJoin({channelId, channelToken, uid, int? data}) async {
    // await for camera and mic permissions before pushing video page

    // push video page with given channel name
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallPage(
          usertype: SharedPreference.getValue(PrefConstants.USER_TYPE) == "user"
              ? false
              : true,
          isCaller: isListener ? true : false,
          userid: SharedPreference.getValue(PrefConstants.MERA_USER_ID),
          listenerId: listenerDisplayModel1!.data![0].id.toString(),
          senderImageUrl: listenerDisplayModel1!.data![0].image.toString(),
          userName: listenerDisplayModel1?.data![0].name ?? "Seeker",
          uid: uid,
          channelName: channelId,
          token: channelToken,
          callId: data,
        ),
      ),
    );

    if (result) {
      if (context.mounted) {
        showFeedBackDialog(context);
      }
    }
  }

  onChatPlaced() async {
    EasyLoading.show(
        status: "Connecting with our secure server".tr,
        maskType: EasyLoadingMaskType.clear);
    var data = await APIServices.getAgoraTokens();

    if (listenerDisplayModel1?.data![0].deviceToken != null) {
      SharedPreference.setValue(
          PrefConstants.AGORA_UID_TWO, data["agora_uid_two"]);
      SharedPreference.setValue(
          PrefConstants.AGORA_TOKEN_TWO, data["token_two"]);
      ListnerDisplayModel model = await APIServices.getListnerDataById(
          listenerDisplayModel1!.data![0].id!.toString());
      if (model.data![0].busyStatus == 0) {
        await APIServices.getBusyOnline(
            true, listenerDisplayModel1?.data![0].id!.toString());
        await APIServices.getBusyOnline(
            true, SharedPreference.getValue(PrefConstants.MERA_USER_ID));

        EasyLoading.dismiss();

        onChatJoin(
            channelId: data["room_id"],
            channelToken: data["token_one"],
            uid: int.parse(data["agora_uid_one"]),
            data: null);
      } else {
        EasyLoading.dismiss();
        EasyLoading.showInfo('Listner is Busy'.tr);
      }
    } else {
      EasyLoading.showError("User not available".tr);
    }
  }

  Future<void> onChatJoin({channelId, channelToken, uid, int? data}) async {
    // await for camera and mic permissions before pushing video page

    // push video page with given channel name
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgoraChatScreen(
          userid: SharedPreference.getValue(PrefConstants.MERA_USER_ID),
          listnerid: listenerDisplayModel1!.data![0].id.toString(),
          senderImageUrl: listenerDisplayModel1!.data![0].image.toString(),
          userName: listenerDisplayModel1?.data![0].name ?? "Seeker",
          uid: uid,
          channelName: channelId,
          token: channelToken,
        ),
      ),
    );

    if (result) {
      if (context.mounted) {
        showFeedBackDialog(context);
      }
    }
  }

  Future registerqueryAgoraChatListener(
      listner.ListnerDisplayModel model) async {
    bool listenerResponse = await APIServices.queryingUserAgoraChat(
        listenerDisplayModel1!.data![0].id!.toString());
    if (!listenerResponse) {
      bool registerListener = await APIServices.registerUserAgoraChat(
          listenerDisplayModel1!.data![0].id!.toString(),
          listenerDisplayModel1!.data![0].name.toString());
      return registerListener;
    } else {
      return listenerResponse;
    }
  }

  Future registerqueryAgoraChatUser() async {
    bool userResponse = await APIServices.queryingUserAgoraChat(
        SharedPreference.getValue(PrefConstants.MERA_USER_ID));
    if (!userResponse) {
      bool registerUser = await APIServices.registerUserAgoraChat(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID),
          SharedPreference.getValue(PrefConstants.LISTENER_NAME));
      return registerUser;
    } else {
      return userResponse;
    }
  }

  @override
  void dispose() {
    // timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return WillPopScope(
      onWillPop: () async {
        // if (isListener) {
        //   Navigator.pushReplacement(
        //       context,
        //       MaterialPageRoute(
        //           builder: (context) => const ListnerHomeScreen(index: 0)));
        // } else {
        //   Navigator.pushReplacement(context,
        //       MaterialPageRoute(builder: (context) => const HomeScreen()));
        // }
        Navigator.pop(context);
        return true;
      },
      child: isFetching
          ? SafeArea(
              child: Container(
                color: backgroundColor,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.fromLTRB(15.0, 20, 15, 10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomBackButton(
                                        isfromLoginScreen: false,
                                        isListner: isListener),
                                    if (SharedPreference.getValue(
                                            PrefConstants.USER_TYPE) ==
                                        'user') ...{
                                      Row(children: [
                                        InkWell(
                                          onTap: () {
                                            showReportDialog(context);
                                          },
                                          child: const Text(
                                            '',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const CustomShareButton(),
                                      ])
                                    }
                                  ],
                                )
                              ])),
                      SizedBox(
                        height: mediaQuery.size.height * 0.350,
                      ),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
              ),
            )
          : DefaultTabController(
              length: 2,
              initialIndex: 0,
              child: Scaffold(
                backgroundColor: detailScreenCardColor,
                floatingActionButton: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isAppUpdated
                        ? isBlocked
                            ? InkWell(
                                onTap: () async {
                                  if (blockcount == 1) {
                                    EasyLoading.show(status: 'loading'.tr);
                                    String? amount =
                                        await APIServices.getWalletAmount(
                                            SharedPreference.getValue(
                                                PrefConstants.MERA_USER_ID));
                                    if (double.parse(amount!) >= 199) {
                                      bool? result =
                                          await APIServices.unblockPenalty(
                                              SharedPreference.getValue(
                                                  PrefConstants.MERA_USER_ID),
                                              listenerDisplayModel1!
                                                  .data![0].id!
                                                  .toString(),
                                              "199");
                                      if (result!) {
                                        bool? result =
                                            await APIServices.unblockUser(
                                                SharedPreference.getValue(
                                                    PrefConstants.MERA_USER_ID),
                                                listenerDisplayModel1!
                                                    .data![0].id
                                                    .toString());
                                        if (result!) {
                                          EasyLoading.dismiss();
                                          EasyLoading.showSuccess(
                                              'Unblocked Successfully'.tr);
                                          if (context.mounted) {
                                            Navigator.of(context).pop();
                                          }
                                        } else {
                                          EasyLoading.dismiss();
                                        }
                                      }
                                    } else {
                                      EasyLoading.dismiss();
                                      EasyLoading.showError(
                                          'Low balance - $amount. Please Recharge to Unblock');
                                    }
                                  } else if (blockcount == 2) {
                                    String? amount =
                                        await APIServices.getWalletAmount(
                                            SharedPreference.getValue(
                                                PrefConstants.MERA_USER_ID));
                                    if (double.parse(amount!) >= 299) {
                                      bool? result =
                                          await APIServices.unblockPenalty(
                                              SharedPreference.getValue(
                                                  PrefConstants.MERA_USER_ID),
                                              listenerDisplayModel1!
                                                  .data![0].id!
                                                  .toString(),
                                              "299");
                                      if (result!) {
                                        bool? result =
                                            await APIServices.unblockUser(
                                                SharedPreference.getValue(
                                                    PrefConstants.MERA_USER_ID),
                                                listenerDisplayModel1!
                                                    .data![0].id
                                                    .toString());
                                        if (result!) {
                                          EasyLoading.dismiss();
                                          EasyLoading.showSuccess(
                                              'Unblocked Successfully'.tr);
                                          if (context.mounted) {
                                            Navigator.of(context).pop();
                                          }
                                        } else {
                                          EasyLoading.dismiss();
                                        }
                                      }
                                    } else {
                                      EasyLoading.dismiss();
                                      EasyLoading.showError(
                                          'Low balance - $amount. Please Recharge to Unblock');
                                    }
                                  } else if (blockcount == 3) {
                                    EasyLoading.showInfo(
                                        'Your User Account for ${listenerDisplayModel1!.data![0].name} is blocked for 3 months');
                                  }
                                },
                                child: Column(
                                  children: [
                                    showIcon(
                                        24,
                                        colorWhite,
                                        Icons.block,
                                        30,
                                        ui_mode == "dark"
                                            ? Colors.green
                                            : primaryColor.withOpacity(0.95)),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'To Unblock'.tr,
                                      style: TextStyle(
                                        color: ui_mode == "dark"
                                            ? Colors.green
                                            : primaryColor.withOpacity(0.95),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (listenerDisplayModel1
                                              ?.data![0].onlineStatus ==
                                          1 &&
                                      listenerDisplayModel1
                                              ?.data![0].busyStatus ==
                                          0) ...{
                                    if (listenerDisplayModel1
                                                ?.data![0].availableOn ==
                                            'call' ||
                                        listenerDisplayModel1
                                                ?.data![0].availableOn ==
                                            'Call' ||
                                        listenerDisplayModel1
                                                ?.data![0].availableOn ==
                                            'call,chat' ||
                                        listenerDisplayModel1
                                                ?.data![0].availableOn ==
                                            'Chat & Cal' ||
                                        listenerDisplayModel1
                                                ?.data![0].availableOn ==
                                            'chat & cal' ||
                                        listenerDisplayModel1
                                                ?.data![0].availableOn ==
                                            'video & au' ||
                                        listenerDisplayModel1
                                                ?.data![0].availableOn ==
                                            'Video & Au' ||
                                        listenerDisplayModel1
                                                ?.data![0].availableOn ==
                                            'video,audi' ||
                                        listenerDisplayModel1
                                                ?.data![0].availableOn ==
                                            'all' ||
                                        listenerDisplayModel1
                                                ?.data![0].availableOn ==
                                            'All' ||
                                        listenerDisplayModel1
                                                ?.data![0].availableOn ==
                                            'chat,call' ||
                                        listenerDisplayModel1
                                                ?.data![0].availableOn ==
                                            'chat & call')
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            fixedSize:
                                                const Size.fromWidth(130),
                                            backgroundColor: ui_mode == "dark"
                                                ? Colors.green
                                                : primaryColor
                                                    .withOpacity(0.95),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10))),
                                        onPressed: () async {
                                          EasyLoading.show(
                                              status: 'Connecting...'.tr);
                                          ListnerDisplayModel? model =
                                              await APIServices
                                                  .getListnerDataById(
                                                      widget.listnerId!);
                                          setState(() {
                                            onlinestatus =
                                                model.data![0].onlineStatus!;
                                          });
                                          if (onlinestatus == 1 &&
                                              model.data![0].busyStatus == 0) {
                                            String? useramt = await APIServices
                                                .getWalletAmount(
                                                    SharedPreference.getValue(
                                                        PrefConstants
                                                            .MERA_USER_ID));
                                            if (double.tryParse(useramt!)! <=
                                                6.0) {
                                              EasyLoading.dismiss();
                                              if (context.mounted) {
                                                showLowBalanceBottomSheet(
                                                    context,
                                                    "To make a call to ${listenerDisplayModel1!.data![0].name ?? ''}, you should have at least ₹6");
                                              }
                                            } else {
                                              onCallPlaced();
                                            }
                                          } else {
                                            onlineStatus = false;
                                            EasyLoading.dismiss();
                                            if (context.mounted) {
                                              toastshowDefaultSnackbar(
                                                  context,
                                                  onlineStatus
                                                      ? "Listner is Currently Busy on Another Chat"
                                                          .tr
                                                      : "Listner Went Offline"
                                                          .tr,
                                                  true,
                                                  primaryColor);
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const HomeScreen()));
                                            }
                                          }
                                        }, //},
                                        child: Text(
                                          "CALL NOW".tr,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: colorWhite,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ),
                                    if (SharedPreference.getValue(
                                            PrefConstants.USER_TYPE) ==
                                        'user') ...{
                                      if (listenerDisplayModel1
                                                  ?.data![0].availableOn ==
                                              'Chat' ||
                                          listenerDisplayModel1
                                                  ?.data![0].availableOn ==
                                              'chat' ||
                                          listenerDisplayModel1
                                                  ?.data![0].availableOn ==
                                              'call,chat' ||
                                          listenerDisplayModel1
                                                  ?.data![0].availableOn ==
                                              'Chat & Cal' ||
                                          listenerDisplayModel1
                                                  ?.data![0].availableOn ==
                                              'chat & cal' ||
                                          listenerDisplayModel1
                                                  ?.data![0].availableOn ==
                                              'all' ||
                                          listenerDisplayModel1
                                                  ?.data![0].availableOn ==
                                              'All' ||
                                          listenerDisplayModel1
                                                  ?.data![0].availableOn ==
                                              'chat,call' ||
                                          listenerDisplayModel1
                                                  ?.data![0].availableOn ==
                                              'chat & call')
                                        Container(
                                          margin:
                                              const EdgeInsets.only(top: 10),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                fixedSize:
                                                    const Size.fromWidth(130),
                                                backgroundColor:
                                                    ui_mode == "dark"
                                                        ? Colors.green
                                                        : primaryColor
                                                            .withOpacity(0.95),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10))),
                                            onPressed: () async {
                                              String? useramt = await APIServices
                                                  .getWalletAmount(
                                                      SharedPreference.getValue(
                                                          PrefConstants
                                                              .MERA_USER_ID));
                                              if (double.tryParse(useramt!)! <=
                                                  6.0) {
                                                if (context.mounted) {
                                                  showLowBalanceBottomSheet(
                                                      context,
                                                      "To make a chat to ${listenerDisplayModel1!.data![0].name ?? ''}, you should have at least ₹6");
                                                }
                                              } else {
                                                ListnerDisplayModel? model =
                                                    await APIServices
                                                        .getListnerDataById(
                                                            widget.listnerId!);
                                                setState(() {
                                                  onlinestatus = model
                                                      .data![0].onlineStatus!;
                                                });
                                                if (onlinestatus == 1 &&
                                                    model.data![0].busyStatus ==
                                                        0) {
                                                  EasyLoading.show(
                                                      status: 'Please Wait...');
                                                  if (await registerqueryAgoraChatListener(
                                                          listenerDisplayModel1!) &&
                                                      await registerqueryAgoraChatUser()) {
                                                    EasyLoading.dismiss();
                                                    onChatPlaced();
                                                  } else {
                                                    EasyLoading.dismiss();
                                                  }
                                                  // if (context.mounted) {
                                                  //   showChatRequestDialog(
                                                  //       context,
                                                  //       SharedPreference.getValue(
                                                  //           PrefConstants
                                                  //               .MERA_USER_ID),
                                                  //       listenerDisplayModel1!
                                                  //           .data![0].id
                                                  //           .toString(),
                                                  //       listenerDisplayModel1!
                                                  //           .data![0].id
                                                  //           .toString(),
                                                  //       listenerDisplayModel1!
                                                  //           .data![0].name
                                                  //           .toString(),
                                                  //       listenerDisplayModel1!
                                                  //           .data![0].image
                                                  //           .toString(),
                                                  //       listenerDisplayModel1!
                                                  //           .data![0]);
                                                  // }
                                                } else {
                                                  onlineStatus = false;
                                                  if (context.mounted) {
                                                    toastshowDefaultSnackbar(
                                                        context,
                                                        onlineStatus
                                                            ? "Listner is Currently Busy on Another Chat"
                                                                .tr
                                                            : "Listner Went Offline"
                                                                .tr,
                                                        true,
                                                        primaryColor);
                                                    Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const HomeScreen()));
                                                  }
                                                }
                                              }
                                            },
                                            child: Text(
                                              "CHAT NOW".tr,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: colorWhite,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ),
                                        ),
                                    },
                                    if (listenerDisplayModel1
                                                ?.data![0].availableOn ==
                                            'video call' ||
                                        listenerDisplayModel1
                                                ?.data![0].availableOn ==
                                            'Video Call' ||
                                        listenerDisplayModel1
                                                ?.data![0].availableOn ==
                                            'all' ||
                                        listenerDisplayModel1
                                                ?.data![0].availableOn ==
                                            'All' ||
                                        listenerDisplayModel1
                                                ?.data![0].availableOn ==
                                            'video & au' ||
                                        listenerDisplayModel1
                                                ?.data![0].availableOn ==
                                            'Video & Au' ||
                                        listenerDisplayModel1
                                                ?.data![0].availableOn ==
                                            'video,audi')
                                      Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              fixedSize:
                                                  const Size.fromWidth(130),
                                              backgroundColor: ui_mode == "dark"
                                                  ? Colors.green
                                                  : primaryColor
                                                      .withOpacity(0.95),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                          onPressed: () async {
                                            EasyLoading.show(
                                                status: 'Connecting...'.tr);
                                            ListnerDisplayModel? model =
                                                await APIServices
                                                    .getListnerDataById(
                                                        widget.listnerId!);
                                            setState(() {
                                              onlinestatus =
                                                  model.data![0].onlineStatus!;
                                            });
                                            if (onlinestatus == 1 &&
                                                model.data![0].busyStatus ==
                                                    0) {
                                              String? useramt = await APIServices
                                                  .getWalletAmount(
                                                      SharedPreference.getValue(
                                                          PrefConstants
                                                              .MERA_USER_ID));
                                              if (double.tryParse(useramt!)! <=
                                                  18.0) {
                                                EasyLoading.dismiss();
                                                if (context.mounted) {
                                                  showLowBalanceBottomSheet(
                                                      context,
                                                      "To make a video call to ${listenerDisplayModel1!.data![0].name ?? ''}, you should have at least ₹18");
                                                }
                                              } else {
                                                onVideoCallPlaced();
                                              }
                                            } else {
                                              onlineStatus = false;
                                              EasyLoading.dismiss();
                                              if (context.mounted) {
                                                toastshowDefaultSnackbar(
                                                    context,
                                                    onlineStatus
                                                        ? "Listner is Currently Busy on Another Chat"
                                                            .tr
                                                        : "Listner Went Offline"
                                                            .tr,
                                                    true,
                                                    primaryColor);
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const HomeScreen()));
                                              }
                                            }
                                          },
                                          child: Text(
                                            "VIDEO CALL".tr,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: colorWhite,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      ),
                                  } else ...{
                                    InkWell(
                                      onTap: () async {
                                        EasyLoading.show(
                                            status: 'loading...'.tr);
                                        await APIServices.notifyUser(type: "user",deviceToken: listenerDisplayModel1!.data![0].deviceToken,name: SharedPreference.getValue(
                                            PrefConstants
                                                .LISTENER_NAME),imageDP: SharedPreference.getValue(
                                            PrefConstants
                                                .LISTENER_IMAGE));

                                        SendBellNotificationModel? bellNotify =
                                            await APIServices.sendBellNotify(
                                                listenerDisplayModel1!
                                                    .data![0].id!,
                                                SharedPreference.getValue(
                                                        PrefConstants
                                                            .USER_NAME) ??
                                                    'Anonymous',
                                                int.parse(
                                                    SharedPreference.getValue(
                                                        PrefConstants
                                                            .MERA_USER_ID)),
                                                SharedPreference.getValue(
                                                    PrefConstants.USER_IMAGE));

                                        if (bellNotify?.status == true) {
                                          EasyLoading.showSuccess(
                                              'If listener comes online,we will notify you!'
                                                  .tr);
                                          EasyLoading.dismiss();
                                        }
                                      },
                                      child: showIcon(30, colorWhite,
                                          Icons.notifications, 30, colorBlack),
                                    ),
                                  },
                                  const SizedBox(
                                    height: 30,
                                  ),
                                ],
                              )
                        : Container(),
                  ],
                ),
                body: isFetching
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : SafeArea(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15.0, 20, 15, 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SharedPreference.getValue(
                                                PrefConstants.USER_TYPE) ==
                                            'user'
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              CustomBackButton(
                                                  isfromLoginScreen: false,
                                                  isListner: isListener),
                                              if (listenerDisplayModel1
                                                      ?.data![0].busyStatus ==
                                                  1) ...{
                                                Text('Busy'.tr,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        letterSpacing: 0.3,
                                                        color: colorRed,
                                                        fontWeight:
                                                            FontWeight.bold))
                                              } else if (listenerDisplayModel1
                                                      ?.data![0].onlineStatus ==
                                                  1) ...{
                                                Text('Online'.tr,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.green,
                                                        letterSpacing: 0.3,
                                                        fontWeight:
                                                            FontWeight.bold))
                                              } else ...{
                                                isListener
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                            Text(
                                                                'Last seen: '
                                                                    .tr,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 12,
                                                                  letterSpacing:
                                                                      0.3,
                                                                  color: Colors
                                                                      .redAccent,
                                                                )),
                                                            Text(
                                                                GetTimeAgo
                                                                    .parse(
                                                                  DateTime.parse(
                                                                      lastActiveTime),
                                                                  pattern:
                                                                      "dd-MM-yyyy hh:mm aa",
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 12,
                                                                  letterSpacing:
                                                                      0.3,
                                                                  color: Colors
                                                                      .redAccent,
                                                                ))
                                                          ])
                                                    : Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                            Text(
                                                                'Last seen: '
                                                                    .tr,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 12,
                                                                  letterSpacing:
                                                                      0.3,
                                                                  color: Colors
                                                                      .redAccent,
                                                                )),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text(
                                                                GetTimeAgo
                                                                    .parse(
                                                                  DateTime.parse(
                                                                      lastActiveTime),
                                                                  pattern:
                                                                      "dd-MM-yyyy hh:mm aa",
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 12,
                                                                  letterSpacing:
                                                                      0.3,
                                                                  color: Colors
                                                                      .redAccent,
                                                                ))
                                                          ]),
                                              },
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              if (SharedPreference.getValue(
                                                      PrefConstants
                                                          .USER_TYPE) ==
                                                  'user') ...{
                                                Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        showReportDialog(
                                                            context);
                                                      },
                                                      child: SizedBox(
                                                        height: 48,
                                                        child: Center(
                                                          child: Text(
                                                            'Report'.tr,
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    textColor),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    const CustomShareButton(),
                                                    const WhatsappShareButton(), //test
                                                  ],
                                                ),
                                              },
                                            ],
                                          )
                                        : Row(
                                            children: [
                                              CustomBackButton(
                                                  isfromLoginScreen: false,
                                                  isListner: isListener),
                                              const Spacer(),
                                              if (listenerDisplayModel1
                                                      ?.data![0].busyStatus ==
                                                  1) ...{
                                                Text('Busy'.tr,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        letterSpacing: 0.3,
                                                        color: Colors.orange,
                                                        fontWeight:
                                                            FontWeight.bold))
                                              } else if (listenerDisplayModel1
                                                      ?.data![0].onlineStatus ==
                                                  1) ...{
                                                Text('Online'.tr,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.green,
                                                        letterSpacing: 0.3,
                                                        fontWeight:
                                                            FontWeight.bold))
                                              } else ...{
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text('Last seen: '.tr,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            letterSpacing: 0.3,
                                                            color: Colors
                                                                .redAccent,
                                                          )),
                                                      Text(
                                                          GetTimeAgo.parse(
                                                            DateTime.parse(
                                                                lastActiveTime),
                                                            pattern:
                                                                "dd-MM-yyyy hh:mm aa",
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            letterSpacing: 0.3,
                                                            color: Colors
                                                                .redAccent,
                                                          ))
                                                    ])
                                              },
                                              const SizedBox(width: 20),
                                            ],
                                          ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Center(
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              ClipRRect(
                                                  borderRadius:
                                                      listenerDisplayModel1
                                                                  ?.data?[0]
                                                                  .onlineStatus ==
                                                              1
                                                          ? BorderRadius
                                                              .circular(100)
                                                          : BorderRadius
                                                              .circular(
                                                                  100),
                                                  child: InkWell(
                                                    onTap: () {
                                                      width = MediaQuery.of(
                                                              context)
                                                          .size
                                                          .width;
                                                      height =
                                                          MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .height;
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => ListnerImage(
                                                                  image: getImage(
                                                                      height!,
                                                                      width!,
                                                                      "${APIConstants.BASE_URL}${listenerDisplayModel1?.data![0].image}",
                                                                      width!,
                                                                      "assets/logo.png",
                                                                      BoxShape
                                                                          .rectangle,
                                                                      context))));
                                                    },
                                                    child: image,
                                                  )),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                          ),
                                          Positioned(
                                            bottom: 5,
                                            right: 15,
                                            child: InkWell(
                                              onTap: () async {
                                                try {
                                                  if (listenerDisplayModel1!
                                                          .data![0].id !=
                                                      int.parse(SharedPreference
                                                          .getValue(PrefConstants
                                                              .MERA_USER_ID))) {
                                                    DocumentSnapshot doc =
                                                        await _firebase
                                                            .collection(
                                                                "listner-likes")
                                                            .doc(
                                                                listenerDisplayModel1!
                                                                    .data![0]
                                                                    .id!
                                                                    .toString())
                                                            .get();
                                                    if (doc.exists) {
                                                      List<dynamic> list =
                                                          doc['likes'];
                                                      List<int> likelist =
                                                          list.cast<int>();
                                                      if (likelist.contains(int
                                                          .parse(SharedPreference
                                                              .getValue(
                                                                  PrefConstants
                                                                      .MERA_USER_ID)))) {
                                                        likelist.remove(int.parse(
                                                            SharedPreference
                                                                .getValue(
                                                                    PrefConstants
                                                                        .MERA_USER_ID)));
                                                        setState(() {
                                                          isProfileLiked =
                                                              false;
                                                        });
                                                      } else {
                                                        likelist.add(int.parse(
                                                            SharedPreference
                                                                .getValue(
                                                                    PrefConstants
                                                                        .MERA_USER_ID)));
                                                        setState(() {
                                                          isProfileLiked = true;
                                                        });
                                                      }
                                                      if (likelist.isNotEmpty) {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'listner-likes')
                                                            .doc(
                                                                listenerDisplayModel1!
                                                                    .data![0]
                                                                    .id!
                                                                    .toString())
                                                            .update({
                                                          'likes': likelist
                                                        });
                                                      } else {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'listner-likes')
                                                            .doc(
                                                                listenerDisplayModel1!
                                                                    .data![0]
                                                                    .id!
                                                                    .toString())
                                                            .update(
                                                                {'likes': []});
                                                      }
                                                      setState(() {
                                                        profileLiked =
                                                            list.length;
                                                      });
                                                    } else {
                                                      List<int> list = [
                                                        int.parse(SharedPreference
                                                            .getValue(PrefConstants
                                                                .MERA_USER_ID))
                                                      ];
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'listner-likes')
                                                          .doc(
                                                              listenerDisplayModel1!
                                                                  .data![0].id!
                                                                  .toString())
                                                          .set({'likes': list});
                                                      setState(() {
                                                        profileLiked =
                                                            list.length;
                                                        isProfileLiked = true;
                                                      });
                                                    }
                                                  }
                                                } catch (e) {
                                                  debugPrint(
                                                      'Error liking story: $e');
                                                }
                                              },
                                              child: profileLiked != 0
                                                  ? isProfileLiked
                                                      ? SizedBox(
                                                          height: 48,
                                                          width: 48,
                                                          child: Icon(
                                                            Icons.favorite,
                                                            color: colorBlue,
                                                            size: 30,
                                                          ),
                                                        )
                                                      : SizedBox(
                                                          height: 48,
                                                          width: 48,
                                                          child: Icon(
                                                            Icons
                                                                .favorite_border,
                                                            color: colorBlue,
                                                            size: 30,
                                                          ),
                                                        )
                                                  : SizedBox(
                                                      height: 48,
                                                      width: 48,
                                                      child: Icon(
                                                        Icons.favorite_border,
                                                        color: colorBlue,
                                                        size: 30,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 15,
                                            right: 2,
                                            child: profileLiked != 0
                                                ? Text(
                                                    '$profileLiked',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: textColor,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                                  )
                                                : Container(),
                                          ),
                                          if(listenerDisplayModel1!.data![0].charge! == "1.00") ...{
                                            Positioned(
                                              right: 15,
                                              top: 10,
                                              child: showIcon(
                                                  20,
                                                  Colors
                                                      .yellow,
                                                  Icons
                                                      .star_purple500_sharp,
                                                  10,
                                                  colorBlue),
                                            ),
                                            },
                                        ],
                                      ),
                                    ),
                                    Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${listenerDisplayModel1?.data![0].name}, ${listenerDisplayModel1!.data![0].age}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: textColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          listenerDisplayModel1?.data![0].sex ==
                                                  'F'
                                              ? Icon(
                                                  Icons.female,
                                                  size: 24,
                                                  color: textColor,
                                                )
                                              : Icon(
                                                  Icons.male,
                                                  size: 24,
                                                  color: textColor,
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                child: TabBar(
                                  controller: tabController,
                                  tabs: [
                                    Tab(
                                      child: Text('ABOUT ME'.tr,
                                          style: TextStyle(
                                              color: tabController!.index == 0
                                                  ? colorBlue
                                                  : textColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                    ),
                                    Tab(
                                      child: Text('REELS'.tr,
                                          style: TextStyle(
                                              color: tabController!.index == 1
                                                  ? colorBlue
                                                  : textColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                    ),
                                    // Tab(
                                    //   child: Text('GIFTS',
                                    //       style: TextStyle(
                                    //           color: tabController!.index == 2
                                    //               ? colorBlue
                                    //               : textColor,
                                    //           fontWeight: FontWeight.bold,
                                    //           fontSize: 16)),
                                    // ),
                                  ],
                                ),
                              ),
                              // if (selectedIndex == 2)
                              //   giftsList.isNotEmpty
                              //       ? SizedBox(
                              //           width: 380,
                              //           child: ListView.builder(
                              //             shrinkWrap: true,
                              //             physics:
                              //                 const NeverScrollableScrollPhysics(),
                              //             itemCount: giftsList.length,
                              //             padding:
                              //                 const EdgeInsets.only(top: 10),
                              //             itemBuilder: (context, index) {
                              //               return reelGifts(
                              //                 thumbnails[index],
                              //                 giftsList[index]
                              //                     .toString()
                              //                     .replaceAll('{', '')
                              //                     .replaceAll('}', ''),
                              //               );
                              //             },
                              //           ))
                              //       : Container(
                              //           color: detailScreenBgColor,
                              //           height: 50,
                              //           alignment: Alignment.center,
                              //           child: Text(
                              //             'No Reels Found!!',
                              //             style: TextStyle(
                              //                 color: ui_mode == "dark"
                              //                     ? colorWhite
                              //                     : textColor,
                              //                 fontSize: 16,
                              //                 fontWeight: FontWeight.w700),
                              //           )),
                              if (selectedIndex == 1)
                                Container(
                                  color: detailScreenBgColor,
                                  padding: const EdgeInsets.all(5),
                                  width: 400,
                                  child: thumbnails.isNotEmpty
                                      ? GridView.builder(
                                          itemCount: thumbnails.length,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount:
                                                2, // Number of columns
                                            crossAxisSpacing:
                                                2.0, // Spacing between columns
                                            mainAxisSpacing:
                                                2.0, // Spacing between rows
                                          ),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return thumbnails[index] == ""
                                                ? const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  )
                                                : GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ReelScreen(
                                                            listenerId:
                                                                listenerDisplayModel1!
                                                                    .data![0].id
                                                                    .toString(),
                                                            selectedIndex:
                                                                index,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: SizedBox(
                                                      height: 200,
                                                      width: 200,
                                                      child: Image.file(
                                                          File(thumbnails[
                                                              index]),
                                                          fit: BoxFit.cover),
                                                    ),
                                                  );
                                          },
                                        )
                                      : Container(
                                          height: 50,
                                          alignment: Alignment.center,
                                          child: Text(
                                            'No Reels Found!!',
                                            style: TextStyle(
                                                color: ui_mode == "dark"
                                                    ? colorWhite
                                                    : textColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700),
                                          )),
                                ),
                              selectedIndex == 1 || selectedIndex == 2
                                  ? Container()
                                  : Container(
                                      decoration: BoxDecoration(
                                          color: detailScreenBgColor),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            15.0, 15, 15, 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: detailScreenBgColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        12.0, 5, 12, 12),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (!isListener &&
                                                        isBlocked) ...{
                                                      Text(
                                                        'To unblock,\n** Pay 199 for first block count.\n** Pay 299 for second block count.\n** You will be blocked for 3 months for third block count'
                                                            .tr,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: colorRed,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                    },
                                                    // Bio like
                                                    Text(
                                                      listenerDisplayModel1
                                                              ?.data![0]
                                                              .about ??
                                                          '',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: textColor,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        InkWell(
                                                          onTap: () async {
                                                            try {
                                                              if (listenerDisplayModel1!
                                                                      .data![0]
                                                                      .id !=
                                                                  int.parse(SharedPreference
                                                                      .getValue(
                                                                          PrefConstants
                                                                              .MERA_USER_ID))) {
                                                                DocumentSnapshot doc = await _firebase
                                                                    .collection(
                                                                        "bio-likes")
                                                                    .doc(listenerDisplayModel1!
                                                                        .data![
                                                                            0]
                                                                        .id!
                                                                        .toString())
                                                                    .get();
                                                                if (doc
                                                                    .exists) {
                                                                  List<dynamic>
                                                                      list =
                                                                      doc['likes'];
                                                                  List<int>
                                                                      likelist =
                                                                      list.cast<
                                                                          int>();
                                                                  if (likelist.contains(
                                                                      int.parse(
                                                                          SharedPreference.getValue(
                                                                              PrefConstants.MERA_USER_ID)))) {
                                                                    likelist.remove(
                                                                        int.parse(
                                                                            SharedPreference.getValue(PrefConstants.MERA_USER_ID)));
                                                                    setState(
                                                                        () {
                                                                      isBioLiked =
                                                                          false;
                                                                    });
                                                                  } else {
                                                                    likelist.add(
                                                                        int.parse(
                                                                            SharedPreference.getValue(PrefConstants.MERA_USER_ID)));
                                                                    setState(
                                                                        () {
                                                                      isBioLiked =
                                                                          true;
                                                                    });
                                                                  }
                                                                  if (likelist
                                                                      .isNotEmpty) {
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'bio-likes')
                                                                        .doc(listenerDisplayModel1!
                                                                            .data![
                                                                                0]
                                                                            .id!
                                                                            .toString())
                                                                        .update({
                                                                      'likes':
                                                                          likelist
                                                                    });
                                                                  } else {
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'bio-likes')
                                                                        .doc(listenerDisplayModel1!
                                                                            .data![
                                                                                0]
                                                                            .id!
                                                                            .toString())
                                                                        .update({
                                                                      'likes':
                                                                          []
                                                                    });
                                                                  }
                                                                  setState(() {
                                                                    bioLiked = list
                                                                        .length;
                                                                  });
                                                                } else {
                                                                  List<int>
                                                                      list = [
                                                                    int.parse(SharedPreference.getValue(
                                                                        PrefConstants
                                                                            .MERA_USER_ID))
                                                                  ];
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'bio-likes')
                                                                      .doc(listenerDisplayModel1!
                                                                          .data![
                                                                              0]
                                                                          .id!
                                                                          .toString())
                                                                      .set({
                                                                    'likes':
                                                                        list
                                                                  });
                                                                  setState(() {
                                                                    bioLiked = list
                                                                        .length;
                                                                    isBioLiked =
                                                                        true;
                                                                  });
                                                                }
                                                              }
                                                            } catch (e) {
                                                              debugPrint(
                                                                  'Error liking bio: $e');
                                                            }
                                                          },
                                                          child: bioLiked != 0
                                                              ? isBioLiked
                                                                  ? const Icon(
                                                                      Icons
                                                                          .favorite,
                                                                      color: Colors
                                                                          .blue,
                                                                      size: 30,
                                                                    )
                                                                  : const Icon(
                                                                      Icons
                                                                          .favorite_border,
                                                                      color: Colors
                                                                          .blue,
                                                                      size: 30,
                                                                    )
                                                              : const Icon(
                                                                  Icons
                                                                      .favorite_border,
                                                                  color: Colors
                                                                      .blue,
                                                                  size: 30,
                                                                ),
                                                        ),
                                                        isListener &&
                                                                bioLiked != 0
                                                            ? Container()
                                                            : const SizedBox(
                                                                width: 5),
                                                        bioLiked != 0
                                                            ? Text(
                                                                '$bioLiked',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 18,
                                                                  color:
                                                                      textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                ),
                                                              )
                                                            : Container(),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // const SizedBox(
                                            //   height: 5,
                                            // ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.10,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            detailScreenCardColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          const SizedBox(
                                                              width: 12),
                                                          Column(
                                                            children: [
                                                              const SizedBox(
                                                                  height: 8),
                                                              Icon(
                                                                Icons.interests,
                                                                size: 35,
                                                                color:
                                                                    textColor,
                                                              ),
                                                              Text(
                                                                'Interest'.tr,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 10,
                                                                  color:
                                                                      textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            width: 20,
                                                          ),
                                                          SizedBox(
                                                            height: 50,
                                                            child: Center(
                                                              // marquee text
                                                              child:
                                                                  MarqueeWidget(
                                                                direction: Axis
                                                                    .vertical,
                                                                child: Text(
                                                                  interest,
                                                                  style: TextStyle(
                                                                      color:
                                                                          textColor),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.10,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            detailScreenCardColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              const SizedBox(
                                                                  height: 8),
                                                              Icon(
                                                                Icons.language,
                                                                size: 30,
                                                                color:
                                                                    textColor,
                                                              ),
                                                              Text(
                                                                'Language'.tr,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 10,
                                                                  color:
                                                                      textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          SizedBox(
                                                            height: 50,
                                                            child: Center(
                                                              // marquee text
                                                              child:
                                                                  MarqueeWidget(
                                                                direction: Axis
                                                                    .vertical,
                                                                child: Text(
                                                                  language,
                                                                  style: TextStyle(
                                                                      color:
                                                                          textColor),
                                                                ),
                                                              ),
                                                            ), // Center
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Container(
                                              height: 166,
                                              padding: const EdgeInsets.only(
                                                left: 15,
                                                bottom: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                  color: detailScreenCardColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    right: 166 * 0.04,
                                                    top: 166 * 0.366,
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          avgRating.toString(),
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            color: textColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        RatingBar.builder(
                                                          ignoreGestures: true,
                                                          initialRating: double.tryParse(listenerDisplayModel1
                                                                      ?.data?[0]
                                                                      .ratingReviews!
                                                                      .averageRating
                                                                      ?.toString() ??
                                                                  '0.0') ??
                                                              0.0,
                                                          minRating: 1,
                                                          direction:
                                                              Axis.horizontal,
                                                          allowHalfRating: true,
                                                          itemCount: 5,
                                                          itemSize: 12,
                                                          itemPadding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      1.0),
                                                          itemBuilder:
                                                              (context, _) =>
                                                                  Icon(
                                                            Icons.star,
                                                            color: textColor,
                                                            size: 30,
                                                          ),
                                                          onRatingUpdate:
                                                              (rating) {
                                                            debugPrint(rating
                                                                .toString());
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Chart widget
                                                  SfCartesianChart(
                                                    margin:
                                                        const EdgeInsets.only(
                                                      left: 5,
                                                      right: 80,
                                                    ),
                                                    plotAreaBorderColor:
                                                        textColor
                                                            .withOpacity(0.1),
                                                    title: ChartTitle(
                                                      text:
                                                          'Listener\'s rating',
                                                      textStyle: TextStyle(
                                                        fontSize: 14,
                                                        color: textColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    series: <BarSeries>[
                                                      BarSeries<ReviewData,
                                                          String>(
                                                        name: 'Reviews',
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                          topRight:
                                                              Radius.circular(
                                                                  4),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  4),
                                                        ),
                                                        dataSource: reviewData,
                                                        xValueMapper:
                                                            (ReviewData data,
                                                                    _) =>
                                                                data.reviewStars,
                                                        yValueMapper:
                                                            (ReviewData data,
                                                                    _) =>
                                                                data.reviewCount,
                                                        dataLabelSettings:
                                                            DataLabelSettings(
                                                          isVisible: true,
                                                          textStyle: TextStyle(
                                                            color: textColor,
                                                          ),
                                                        ),
                                                        pointColorMapper:
                                                            (ReviewData data,
                                                                    _) =>
                                                                data.pointColor,
                                                      ),
                                                    ],
                                                    primaryXAxis: CategoryAxis(
                                                      labelStyle: TextStyle(
                                                        color: textColor,
                                                      ),
                                                      majorGridLines:
                                                          MajorGridLines(
                                                        color: textColor
                                                            .withOpacity(0.1),
                                                      ),
                                                    ),
                                                    primaryYAxis: NumericAxis(
                                                      isVisible: false,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      height: 80,
                                                      width: 110,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              detailScreenCardColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            'Chat Charges'.tr,
                                                            style: TextStyle(
                                                                color:
                                                                    textColor,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            listenerDisplayModel1!
                                                                        .data![
                                                                            0]
                                                                        .charge ==
                                                                    "1.00"
                                                                ? '₹ 8/min'.tr
                                                                : '₹ 6/min'.tr,
                                                            style: TextStyle(
                                                                color:
                                                                    textColor,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Spacer(),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      height: 80,
                                                      width: 110,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              detailScreenCardColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            'Call Charges'.tr,
                                                            style: TextStyle(
                                                                color:
                                                                    textColor,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            listenerDisplayModel1!
                                                                        .data![
                                                                            0]
                                                                        .charge ==
                                                                    "1.00"
                                                                ? '₹ 10/min'.tr
                                                                : '₹ 6/min'.tr,
                                                            style: TextStyle(
                                                                color:
                                                                    textColor,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Spacer(),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      height: 80,
                                                      width: 110,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              detailScreenCardColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            'Video Charges'.tr,
                                                            style: TextStyle(
                                                                color:
                                                                    textColor,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            listenerDisplayModel1!
                                                                        .data![
                                                                            0]
                                                                        .charge ==
                                                                    "1.00"
                                                                ? '₹ 20/min'.tr
                                                                : '₹ 18/min'.tr,
                                                            style: TextStyle(
                                                                color:
                                                                    textColor,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              selectedIndex == 1 || selectedIndex == 2
                                  ? Container()
                                  : Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        color: colorBlack,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            12.0, 10, 12, 10),
                                        child: Center(
                                          child: Text(
                                            'Reviews'.tr,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              color: colorWhite,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              selectedIndex == 1 || selectedIndex == 2
                                  ? Container()
                                  : Container(
                                      decoration: BoxDecoration(
                                        color: detailScreenBgColor,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            15.0, 15, 15, 110),
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: listenerDisplayModel1
                                                    ?.data?[0]
                                                    .ratingReviews
                                                    ?.allReviews
                                                    ?.length ??
                                                0,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return review[index] == true
                                                  ? Container()
                                                  : Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 180,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  RatingBar
                                                                      .builder(
                                                                    ignoreGestures:
                                                                        true,
                                                                    initialRating: double.tryParse(listenerDisplayModel1!
                                                                            .data![0]
                                                                            .ratingReviews!
                                                                            .allReviews![index]
                                                                            .rating
                                                                            .toString()) ??
                                                                        0.0,
                                                                    minRating:
                                                                        1,
                                                                    direction: Axis
                                                                        .horizontal,
                                                                    allowHalfRating:
                                                                        true,
                                                                    itemCount:
                                                                        5,
                                                                    itemSize:
                                                                        30,
                                                                    itemPadding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            1.0),
                                                                    itemBuilder:
                                                                        (context,
                                                                                _) =>
                                                                            Icon(
                                                                      Icons
                                                                          .star,
                                                                      color:
                                                                          textColor,
                                                                      size: 30,
                                                                    ),
                                                                    onRatingUpdate:
                                                                        (rating) {
                                                                      debugPrint(
                                                                          rating
                                                                              .toString());
                                                                    },
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 7,
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            1),
                                                                    child: Text(
                                                                      listenerDisplayModel1!
                                                                              .data![0]
                                                                              .ratingReviews!
                                                                              .allReviews?[index]
                                                                              .review ??
                                                                          '',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color:
                                                                            textColor,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const Spacer(),
                                                            Text(
                                                              listenerDisplayModel1!
                                                                      .data![0]
                                                                      .ratingReviews!
                                                                      .allReviews?[
                                                                          index]
                                                                      .createdAt
                                                                      .toString() ??
                                                                  '0',
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                color:
                                                                    textColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                            if (SharedPreference
                                                                    .getValue(
                                                                        PrefConstants
                                                                            .MERA_USER_ID) ==
                                                                listenerDisplayModel1!
                                                                    .data![0].id
                                                                    .toString()) ...{
                                                              const SizedBox(
                                                                width: 2,
                                                              ),
                                                              PopupMenuButton<
                                                                  String>(
                                                                icon: Icon(
                                                                    Icons
                                                                        .more_vert,
                                                                    color:
                                                                        textColor),
                                                                itemBuilder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return [
                                                                    PopupMenuItem<
                                                                        String>(
                                                                      value:
                                                                          'Report Review',
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () async {
                                                                          Navigator.pop(
                                                                              context,
                                                                              "Notify User");
                                                                          EasyLoading.show(
                                                                              status: 'loading...'.tr);
                                                                          DateTime
                                                                              date =
                                                                              DateTime.now();
                                                                          String
                                                                              currentdate =
                                                                              date.toString();
                                                                          FirebaseFirestore
                                                                              firestore =
                                                                              FirebaseFirestore.instance;
                                                                          DocumentReference doc = firestore.collection('reported_reviews').doc(listenerDisplayModel1!
                                                                              .data![0]
                                                                              .ratingReviews!
                                                                              .allReviews![index]
                                                                              .id!);
                                                                          doc.set({
                                                                            "id":
                                                                                listenerDisplayModel1!.data![0].ratingReviews!.allReviews![index].id!,
                                                                            "from_id":
                                                                                listenerDisplayModel1!.data![0].ratingReviews!.allReviews![index].fromId!,
                                                                            "to_id":
                                                                                listenerDisplayModel1!.data![0].ratingReviews!.allReviews![index].toId!,
                                                                            "rating":
                                                                                listenerDisplayModel1!.data![0].ratingReviews!.allReviews![index].rating!,
                                                                            "review":
                                                                                listenerDisplayModel1!.data![0].ratingReviews!.allReviews![index].review ?? "",
                                                                            "created_at":
                                                                                currentdate,
                                                                            "status":
                                                                                "pending"
                                                                          }).then(
                                                                              (value) {
                                                                            EasyLoading.dismiss();
                                                                          }).onError((error,
                                                                              stackTrace) {
                                                                            EasyLoading.dismiss();
                                                                            debugPrint(error.toString());
                                                                          });
                                                                        },
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            const Icon(Icons.report,
                                                                                color: Colors.blueAccent),
                                                                            const SizedBox(width: 8),
                                                                            Text(
                                                                              'Report Review'.tr,
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
                                                            },
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 10),
                                                        const Divider(),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                      ],
                                                    );
                                            }),
                                      ),
                                    )
                            ],
                          ),
                        ),
                      ),
              ),
            ),
    );
  }

  // Show Alert Dialog for Report

  showReportDialog(BuildContext context) {
    // set up the button
    Widget reportButton = TextButton(
      child: Text(
        "REPORT".tr,
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
      ),
      onPressed: () async {
        EasyLoading.show(status: 'loading...'.tr);
        ReportModel? reportModel = await APIServices.reportAPI(
            SharedPreference.getValue(PrefConstants.MERA_USER_ID),
            listenerDisplayModel1!.data![0].id.toString(),
            '""');

        if (reportModel?.status == true) {
          EasyLoading.showSuccess(reportModel?.message.toString() ?? '');
          EasyLoading.dismiss();

          if (context.mounted) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => const HomeScreen()));
          }
        } else {
          EasyLoading.dismiss();
          if (context.mounted) {
            toastshowDefaultSnackbar(
                context, 'Something went wrong'.tr, false, colorRed);
          }
        }
      },
    );
    Widget cancelButton = TextButton(
      child: Text(
        "CANCEL".tr,
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
      ),
      onPressed: () async {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: backgroundColor,
      buttonPadding: const EdgeInsets.symmetric(vertical: 0),
      title: Text(
        "Report ${listenerDisplayModel1?.data![0].name}".tr,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      content: Text(
        'The last session with ${listenerDisplayModel1?.data![0].name} was not good. Do you want to report this listner?'
            .tr,
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w400, color: textColor),
      ),
      actions: [
        reportButton,
        cancelButton,
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

  //show dialog

  showLowBalanceBottomSheet(BuildContext context, String amt) {
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Balance is Low".tr,
                  style: TextStyle(
                      color: ui_mode == "dark" ? colorWhite : textColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                Text(
                  amt.tr,
                  style: TextStyle(
                    color: ui_mode == "dark" ? colorWhite : textColor,
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: colorRed), // Add red border
                        borderRadius: BorderRadius.circular(
                            20.0), // Rounded rectangular border
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0), // Adjust padding
                        ),
                        child: Text(
                          "Cancel".tr,
                          style: const TextStyle(color: colorRed),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        // Add green border
                        borderRadius: BorderRadius.circular(
                            20.0), // Rounded rectangular border
                      ),
                      child: TextButton(
                        onPressed: () async {
                          if (!mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const WalletScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0), // Adjust padding
                        ),
                        child: Text(
                          "Add Money".tr,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showFeedBackDialog(BuildContext context) {
    Widget skipButton = TextButton(
        child: Text(
          "Skip".tr.length > 4 ? "Skip".tr.substring(0, 4) : "Skip".tr,
          style: TextStyle(color: ui_mode == "dark" ? colorWhite : colorBlack),
        ),
        onPressed: () async {
          if (!mounted) return;
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const HomeScreen()));
        });
    // set up the button
    Widget okButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: ui_mode == "dark" ? Colors.green : primaryColor,
        foregroundColor: colorWhite,
      ),
      child: Text("OK".tr),
      onPressed: () async {
        EasyLoading.show(status: 'loading...'.tr);
        FeedBackModel? feedBackModel = await APIServices.feedbackAPI(
            SharedPreference.getValue(PrefConstants.MERA_USER_ID),
            listenerDisplayModel1!.data![0].id.toString(),
            ratingStore.toString(),
            feedbackController.text);

        if (feedBackModel?.status == true) {
          // if(ratingStore == 5) {

          EasyLoading.dismiss();
          if (!mounted) return;
          toastshowDefaultSnackbar(
              context, 'Thank you for your feedback'.tr, false, primaryColor);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const HomeScreen()));
        } else {
          EasyLoading.dismiss();
          if (!mounted) return;
          toastshowDefaultSnackbar(
              context, 'Something went wrong'.tr, false, colorRed);
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                "Your Feedback".tr,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
              const Spacer(),
              skipButton,
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RatingBar.builder(
                initialRating: 5,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 30,
                itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star_outlined,
                  color: Colors.orange,
                  size: 30,
                ),
                onRatingUpdate: (rating) {
                  ratingStore = rating;
                  debugPrint(ratingStore.toString());
                },
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            "Would you like to add a comment ?".tr,
            style: TextStyle(fontSize: 13, color: textColor),
          ),
          const SizedBox(
            height: 8,
          ),
          TextField(
            style: TextStyle(fontSize: 14, color: textColor),
            minLines: 2,
            maxLines: 4,
            controller: feedbackController,
            decoration: InputDecoration(
              hintText: 'Your comments'.tr,
              contentPadding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              hintStyle: TextStyle(fontSize: 14, color: colorGrey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(child: okButton),
            ],
          ),
        ],
      ),
      // actions: [skipButton, okButton],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showPlayStoreRatingDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            backgroundColor: colorWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: Text(
              'Would you like to rate us on playstore'.tr,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {},
                  child: Text(
                    'Rate Now'.tr,
                    style: const TextStyle(fontSize: 14),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Skip'.tr,
                    style: const TextStyle(fontSize: 14),
                  )),
            ],
          );
        });
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('online_status', onlinestatus));
  }
}

// Chat now Request

showChatRequestDialog(
  BuildContext context,
  String fromId,
  String toId,
  String listnerId,
  String listnerName,
  String listenerImage,
  listner.Data listnerDisplayModel1,
) {
  Widget sendRequestButton = TextButton(
      child: Text(
        "Send Request".tr,
        style: const TextStyle(color: Colors.cyan),
      ),
      onPressed: () async {
        EasyLoading.show(status: 'loading...'.tr);

        ListnerDisplayModel model = await APIServices.getListnerDataById(
            listnerDisplayModel1.id!.toString());
        if (model.data![0].busyStatus == 0) {
          UserChatSendRequest? userChatSendRequest =
              await APIServices.userChatSendRequestAPI(fromId, toId);

          if (userChatSendRequest?.status == true) {
            EasyLoading.dismiss();
            if (userChatSendRequest?.busyStatus == true) {
              if (context.mounted) {
                Navigator.pop(context);
              }
              if (context.mounted) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          "${listnerDisplayModel1.name} is busy".tr,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () async {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen()),
                                    (Route<dynamic> route) => false);
                              },
                              child: Text("Ok".tr))
                        ],
                      );
                    });
              }
            } else {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String id = prefs.getString("userId")!;
              String name =
                  SharedPreference.getValue(PrefConstants.USER_NAME) ??
                      "Anonymous";

              if (listnerDisplayModel1.busyStatus == 0) {
                await APIServices.getBusyOnline(
                    true, listnerDisplayModel1.id!.toString());
                await APIServices.getBusyOnline(true,
                    SharedPreference.getValue(PrefConstants.MERA_USER_ID));
              }

              APIServices.sendChatNotification(
                  deviceToken: listnerDisplayModel1.deviceToken!,
                  senderName: listnerName);

              EasyLoading.dismiss();

              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => ChatRequestPending(
                              userChatSendRequest: userChatSendRequest,
                              listenerId: listnerId,
                              listenerName: listnerName,
                              listenerImage: listenerImage,
                              senderImageUrl: SharedPreference.getValue(
                                          PrefConstants.LISTENER_IMAGE)! !=
                                      null
                                  ? SharedPreference.getValue(
                                      PrefConstants.LISTENER_IMAGE)
                                  : 'https://laravel.supportletstalk.com/manage/images/avatar/user.png',
                              userId: id,
                              userName: name == "" ? 'Anonymous' : name,
                              listnerDisplayModel: listnerDisplayModel1,
                            )),
                    (Route<dynamic> route) => false);
              } else {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            }
          }
        } else {
          EasyLoading.dismiss();
          EasyLoading.showInfo('Listner is Busy'.tr);
        }
      });
  // set up the button
  Widget cancelButton = TextButton(
    child: Text(
      "Cancel".tr,
      style: const TextStyle(color: colorRed),
    ),
    onPressed: () async {
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    backgroundColor: cardColor,
    title: Column(
      children: [
        Text("You can Chat only after Listener Approve.".tr,
            style: TextStyle(fontSize: 16, color: textColor)),
        const SizedBox(height: 10),
      ],
    ),
    actions: [sendRequestButton, cancelButton],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
