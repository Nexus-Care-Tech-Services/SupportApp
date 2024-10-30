import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:support/utils/color.dart';
import 'package:support/screen/reels/reels_screen.dart';
import 'package:support/screen/in_app_update/in_app_update.dart';
import 'package:support/screen/listener_status/user_status_screen.dart';
import 'package:support/screen/search/search_screen.dart';
import 'package:support/screen/user_leaderboard/profile_screen.dart';
import 'package:support/screen/wallet/recharge_screen.dart';

import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/main.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/screen/drawer/drawer.dart';
import 'package:support/screen/wallet/wallet_screen.dart';
import 'package:support/screen/home/helper_screen.dart';
import 'package:support/utils/reuasble_widget/toast_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int currentindex = 0;
  int backButtonPressCount = 0;
  late DateTime currentBackPressTime;
  bool isInboxVisible = true, today = false;
  final GlobalKey<ScaffoldState> _scaffoldStateKey = GlobalKey<ScaffoldState>();
  String walletAmount = "0.0";
  String name = "";
  String dataFromSecondScreen = "";
  DateTime backPressedTime = DateTime.now();
  final InAppReview inAppReview = InAppReview.instance;
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;

  List<Widget> buildScreens() {
    return [
      const HelperScreen(),
      const ProfileScreen(),
      const ReelScreen(),
      const UserStatusScreen(),
    ];
  }

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  void checkWalletAmount() {
    if (double.parse(walletAmount) <= 10) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: detailScreenCardColor,
              iconColor: colorRed,
              title: Text(
                'Low Balance'.tr,
                style: TextStyle(
                    fontSize: 18,
                    color: ui_mode == "dark" ? colorWhite : colorBlack),
              ),
              icon: const Icon(Icons.warning),
              content: Text(
                'Press \'Recharge Now\' to top up your balance'.tr,
                style: TextStyle(
                    fontSize: 14,
                    color: ui_mode == "dark" ? colorWhite : colorBlack),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const RechargeScreen()));
                        },
                        child: Text(
                          'RECHARGE NOW'.tr,
                          style: TextStyle(
                              fontSize: 15,
                              color:
                                  ui_mode == "dark" ? colorWhite : colorBlack),
                        )),
                    const Spacer(),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                              fontSize: 15,
                              color:
                                  ui_mode == "dark" ? colorWhite : colorBlack),
                        )),
                  ],
                ),
              ],
            );
          });
    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    checkListener();
    if (kDebugMode) {
      print("UI MODE: $ui_mode");
    }
    UpdateChecker.checkForUpdate();
    _tabController = TabController(length: 4, vsync: this);
    log(SharedPreference.getValue(PrefConstants.MOBILE_NUMBER),
        name: 'Mobile Number');
    log(SharedPreference.getValue(PrefConstants.MERA_USER_ID), name: 'User Id');
    log(name);
    // log(SharedPreference.getValue(PrefConstants.USER_NAME), name: 'User Name');
    Future.delayed(Duration.zero, () async {
      String amount = await APIServices.getWalletAmount(
              SharedPreference.getValue(PrefConstants.MERA_USER_ID)) ??
          "0.0";
      setState(() {
        walletAmount = amount;
        SharedPreference.setValue(PrefConstants.WALLET_AMOUNT, walletAmount);
      });
      checkWalletAmount();
    });
  }

  Future<void> _checkDayDiff() async {
    String? storedTimestampString =
        await SharedPreference.getValue(PrefConstants.LAST_UPDATE_TIMESTAMP);

    DateTime storedTimestamp = DateTime.parse(storedTimestampString!);

    Duration difference = DateTime.now().difference(storedTimestamp);
    int daysDifference = difference.inDays;

    if (daysDifference == 1) {
      debugPrint("Difference is 1 day. Updating mood and calling API...");
      SharedPreference.setValue(
        PrefConstants.LAST_UPDATE_TIMESTAMP,
        DateTime.now().toIso8601String(),
      );
      setState(() {
        today = false;
      });
    } else {
      setState(() {
        today = true;
      });
    }
  }

  checkListener() async {
    name = SharedPreference.getValue(PrefConstants.USER_NAME) ?? "Anonymous";
    log(name);
    setState(() {});
  }

  void goToSecondScreen() {
    _scaffoldStateKey.currentState?.openDrawer();
  }

  checkUIMode() async {
    ui_mode = SharedPreference.getValue(PrefConstants.UI_MODE) ?? "light";
    log(ui_mode);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  Future<void> _showRatingDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: detailScreenCardColor,
          title: Text('Rate the App'.tr,
              style: TextStyle(
                  color: ui_mode == "dark" ? colorWhite : colorBlack)),
          content: Text(
            'Would you like to rate the app on Play Store?'.tr,
            style: TextStyle(
                fontSize: 14,
                color: ui_mode == "dark" ? colorWhite : colorBlack),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: Text('Yes'.tr,
                  style: TextStyle(
                      color: ui_mode == "dark" ? colorWhite : colorBlack)),
              onPressed: () {
                inAppReview.openStoreListing(
                    appStoreId: "com.support2heal.app");
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Rated'.tr,
                  style: TextStyle(
                      color: ui_mode == "dark" ? colorWhite : colorBlack)),
              onPressed: () async {
                _firebase
                    .collection("app_rating")
                    .doc(SharedPreference.getValue(PrefConstants.MERA_USER_ID))
                    .set({"already_rated": true}).then((value) {
                  debugPrint("success");
                }, onError: (e) {
                  debugPrint("error $e");
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'.tr,
                  style: TextStyle(
                      color: ui_mode == "dark" ? colorWhite : colorBlack)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    checkUIMode();
    return WillPopScope(
      onWillPop: () async {
        final timegap = DateTime.now().difference(backPressedTime);

        final canExit = timegap >= const Duration(seconds: 2);

        backPressedTime = DateTime.now();
        _checkDayDiff();

        if (canExit) {
          var collection = _firebase.collection("app_rating");
          var doc = await collection
              .doc(SharedPreference.getValue(PrefConstants.MERA_USER_ID))
              .get();
          if (!doc.exists) {
            if (!today) {
              _showRatingDialog();
              if (await inAppReview.isAvailable()) {
                inAppReview.requestReview();
              }
            }
          }
          if (context.mounted) {
            toastshowDefaultSnackbar(context,
                "Press Back Button Again To Exit".tr, true, primaryColor);
          }
          return false;
        } else {
          return true;
        }
      },
      child: Semantics(
        child: Scaffold(
          key: _scaffoldStateKey,
          drawer: const DrawerScreen(),
          appBar: AppBar(
            backgroundColor: primaryColor,
            leading: InkWell(
              onTap: () {
                goToSecondScreen();
              },
              child: Icon(
                Icons.menu,
                color: ui_mode == "dark" ? colorWhite : colorWhite,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SearchScreen()));
                      },
                      child: const SizedBox(
                          height: 48,
                          width: 48,
                          child:
                              Icon(Icons.search, color: colorWhite, size: 35)),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const WalletScreen()));
                      },
                      // child: const Icon(
                      //   Icons.wallet,
                      //   size: 26,
                      // ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 7, bottom: 7, right: 3, left: 3),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: colorWhite, width: 2),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: Text(
                              '\u{20B9}$walletAmount',
                              style: const TextStyle(
                                  color: colorWhite,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 14,
              )
            ],
          ),
          body: SafeArea(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: buildScreens(),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: tabColor,
            iconSize: 25,
            selectedItemColor:
                ui_mode == "dark" ? Colors.lightBlue : primaryColor,
            unselectedItemColor: textColor,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 14,
            unselectedFontSize: 14,
            type: BottomNavigationBarType.fixed,
            currentIndex: currentindex,
            elevation: 0,
            onTap: (index) {
              setState(() {
                currentindex = index;
                _tabController.index = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                  icon: _tabController.index == 0
                      ? const Icon(Icons.groups)
                      : const Icon(Icons.groups_3_outlined),
                  label: 'All'.tr),
              BottomNavigationBarItem(
                  icon: _tabController.index == 1
                      ? const Icon(Icons.dashboard_rounded)
                      : const Icon(Icons.dashboard_outlined),
                  label: 'Dashboard'.tr),
              BottomNavigationBarItem(
                  icon: _tabController.index == 2
                      ? const Icon(Icons.video_collection)
                      : const Icon(Icons.video_collection_outlined),
                  label: 'Reels'.tr),
              BottomNavigationBarItem(
                  icon: _tabController.index == 3
                      ? const Icon(Icons.image_sharp)
                      : const Icon(Icons.image_outlined),
                  label: 'Status'.tr),
            ],
          ),
        ),
      ),
    );
  }
}
