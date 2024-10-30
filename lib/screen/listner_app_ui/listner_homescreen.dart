import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support/api/api_services.dart';
import 'package:support/utils/color.dart';
import 'package:support/utils/reuasble_widget/notification.dart';
import 'package:support/utils/reuasble_widget/toast_widget.dart';
import 'package:support/utils/reuasble_widget/utils.dart';
import 'package:support/main.dart';
import 'package:support/model/listner_display_model.dart';
import 'package:support/screen/reels/reels_screen.dart';
import 'package:support/screen/in_app_update/in_app_update.dart';
import 'package:support/screen/listener_status/listener_status_screen.dart';
import 'package:support/screen/user_leaderboard/user_posts_screen.dart';

import 'package:support/api/api_constant.dart';
import 'package:support/controller/listener_home_screen_controller.dart';
import 'package:support/model/listner/listner_availability_model.dart';
import 'package:support/model/listner/listner_chat_request_model.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/screen/drawer/drawer.dart';
import 'package:support/screen/home/helper_screen.dart';
import 'package:support/screen/wallet/wallet_screen.dart';
import 'package:support/screen/listner_app_ui/listner_chat_request_screen.dart';
import 'package:support/screen/listner_app_ui/listner_inbox.dart';
import 'package:support/screen/listner_app_ui/listner_wallet.dart/listner_wallet.dart';

class ListnerHomeScreen extends StatefulWidget {
  final int index;

  const ListnerHomeScreen({Key? key, required this.index}) : super(key: key);

  @override
  State<ListnerHomeScreen> createState() => _ListnerHomeScreenState();
}

class _ListnerHomeScreenState extends State<ListnerHomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  int currentindex = 0;
  bool isInboxVisible = true;
  final GlobalKey<ScaffoldState> _scaffoldStateKey = GlobalKey<ScaffoldState>();
  bool isListener = false, isProgressRunning = false;
  ListnerAvaiabilityModel? listnerAvaiabilityModel;
  ListnerDisplayModel? listnerDisplayModel;

  static const platform = MethodChannel('com.example.support/screen_control');

  ListnerChatRequest? getListnerRequest = ListnerChatRequest();

  Timer? _timer;
  bool isFirstCall = true;
  bool loading = true;
  DateTime backPressedTime = DateTime.now();

  final cont = Get.find<ListenerHomeScreenController>();

  // Listner Chat Request

  Future<ListnerChatRequest?> apigetListnerRequest() async {
    try {
      getListnerRequest = await APIServices.listnerChatRequestAPI();

      if (getListnerRequest?.requestedCount != null &&
          (getListnerRequest?.requestedCount)! > 0) {
        _timer?.cancel();
        if (mounted) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => ListnerChatRequestScreen(
                        requestid: getListnerRequest?.requests?[0].id ?? 0,
                        fromid: getListnerRequest?.requests?[0].fromId ?? '0',
                      )));
        }
      }
    } catch (e) {
      log(e.toString());
    }

    return null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
    _timer?.cancel();
  }

  Future<void> apiGetListnerList() async {
    try {
      // listnerDisplayModel = await APIServices.getListnerData();
    } catch (e) {
      APIServices.updateErrorLogs(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID),
          'apiGetListnerList()');
      log(e.toString());
    }
  }

  void firstCall() {
    loading = true;
    _timer = Timer.periodic(
        const Duration(seconds: 5), (Timer t) => apigetListnerRequest());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      checkStatus();
    } else if (state == AppLifecycleState.paused) {
      checkStatus();
    }
  }

  List<Widget> buildScreens() {
    return [
      const HelperScreen(),
      const ListnerInboxScreen(),
      const ReelScreen(),
      const ListenerStatusScreen(),
      const UserPostScreen(),
    ];
  }

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    super.initState();
    fetchAvailability();
    if (Platform.isAndroid) {
      secureApp();
    }
    _tabController = TabController(length: 5, vsync: this);
    setState(() {
      currentindex = widget.index;
      _tabController.index = widget.index;
    });
    UpdateChecker.checkForUpdate();
    WidgetsBinding.instance.addObserver(this);
    firstCall();
    checkOnlineStatus();
    checkListener();
  }

  String getCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(now);
  }

  double availableTime = 0;
  String listenerId = SharedPreference.getValue(PrefConstants.MERA_USER_ID);

  Future<void> fetchAvailability() async {
    try {
      String date = getCurrentDate();
      double fetchedTime =
          await AppUtils().fetchListenerAvailability(date, listenerId);
      setState(() {
        availableTime = fetchedTime;
      });
    } catch (e) {
      debugPrint('Error fetching availability: $e');
    }
  }

  String formatDuration(double minutes) {
    Duration duration = Duration(minutes: minutes.toInt());
    int hours = duration.inHours;
    int remainingMinutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours h $remainingMinutes min';
    } else {
      return '$remainingMinutes min';
    }
  }

  late bool isOnline = false;

  Future<void> checkOnlineStatus() async {
    int res = await fetchStatus(
        SharedPreference.getValue(PrefConstants.MERA_USER_ID));
    if (kDebugMode) {
      print(res);
    }
    if (res == 0) {
      showNotification(0);
      setState(() {
        isOnline = false;
      });
    } else {
      showNotification(1);
      setState(() {
        isOnline = true;
      });
    }
  }

  Future<void> checkStatus() async {
    int res = await fetchStatus(
        SharedPreference.getValue(PrefConstants.MERA_USER_ID));
    if (kDebugMode) {
      print(res);
    }
    if (res == 0) {
      setState(() {
        isOnline = false;
      });
    } else {
      setState(() {
        isOnline = true;
      });
    }
  }

  checkListener() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isListener = prefs.getBool("isListener")!;
    setState(() {});
  }

  List<String> listnerAvailablility = [
    'Chat & Call',
    'Chat, Call, VCall',
  ];
  String? dropdownValue = 'Chat, Call, VCall';

  // Listner Availability API

  Future<void> apiListnerAvailability(String selectAvailability) async {
    try {
      setState(() {
        isProgressRunning = true;
      });

      listnerAvaiabilityModel =
          await APIServices.listnerAvaiabilityModel(selectAvailability);
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() {
        isProgressRunning = false;
      });
    }
  }

  final bool _iconBool = false;

  void goToSecondScreen() {
    _scaffoldStateKey.currentState?.openDrawer();
  }

  checkUIMode() async {
    ui_mode = SharedPreference.getValue(PrefConstants.UI_MODE) ?? "light";
    log(ui_mode);
  }

  @override
  Widget build(BuildContext context) {
    checkUIMode();
    return WillPopScope(
      onWillPop: () async {
        final timegap = DateTime.now().difference(backPressedTime);

        final canExit = timegap >= const Duration(seconds: 2);

        backPressedTime = DateTime.now();

        if (canExit) {
          const snack = SnackBar(
            content: Text("Press Back Button Again To Exit"),
            duration: Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).showSnackBar(snack);
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        key: _scaffoldStateKey,
        drawer: const DrawerScreen(),
        appBar: AppBar(
          backgroundColor: primaryColor,
          iconTheme: const IconThemeData(color: colorWhite),
          leading: IconButton(
            icon: const Icon(Icons.menu, color: colorWhite),
            onPressed: () {
              goToSecondScreen();
            },
          ),
          centerTitle: false,
          title: Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  // Toggle user status
                  setState(() {
                    if (_iconBool) {
                      switchUpdateFunction();
                    } else {
                      switchUpdateFunction();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOnline ? Colors.green : colorGrey,
                ),
                child: Text(
                  isOnline ? 'Online'.tr : 'Offline'.tr,
                  style: const TextStyle(color: colorWhite),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: DropdownButtonFormField<String>(
                  iconEnabledColor: colorWhite,
                  isDense: true,
                  icon: const SizedBox(),
                  // isExpanded: false,
                  selectedItemBuilder: (context) {
                    return listnerAvailablility.map((String value) {
                      String val = SharedPreference.getValue(
                                  PrefConstants.LISTNER_AVAILABILITY) ==
                              'All'
                          ? 'Chat, Call, VCall'
                          : SharedPreference.getValue(
                                  PrefConstants.LISTNER_AVAILABILITY) ??
                              value;
                      return Row(
                        children: [
                          Text(
                            val.tr,
                            style: const TextStyle(
                                color: colorWhite,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: colorWhite,
                          )
                        ],
                      );
                    }).toList();
                  },
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      labelStyle: TextStyle(color: primaryColor)),
                  style: TextStyle(color: textColor),
                  value: dropdownValue,
                  items: listnerAvailablility.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value.tr,
                        style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (SharedPreference.getValue(
                            PrefConstants.LISTNER_AVAILABILITY) ==
                        value) {
                      return;
                    }
                    value == "Chat, Call, VCall"
                        ? apiListnerAvailability('All')
                        : apiListnerAvailability(value!);
                    log(value!, name: 'selection');
                    SharedPreference.setValue(
                        PrefConstants.LISTNER_AVAILABILITY,
                        value == "Chat, Call, VCall" ? 'All' : value);
                    setState(() {
                      dropdownValue = value;
                    });
                  },
                  dropdownColor: primaryColor,
                ),
              )
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: InkWell(
                onTap: () {
                  isListener
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ListnerWalletScreen()))
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WalletScreen()));
                },
                child: const Row(
                  children: [
                    Icon(
                      Icons.wallet,
                      size: 26,
                      color: colorWhite,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 14,
            )
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 45,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.timer_outlined,
                            color: ui_mode == "dark" ? colorWhite : colorBlack),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: Text(
                              formatDuration(availableTime),
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: ui_mode == "dark"
                                      ? colorWhite
                                      : colorBlack),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0, right: 40),
                      child: LinearProgressIndicator(
                        value: availableTime / (3 * 60),
                        backgroundColor: colorGrey,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: buildScreens(),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
          backgroundColor: tabColor,
          iconSize: 25,
          selectedItemColor:
              ui_mode == "dark" ? Colors.lightBlue : primaryColor,
          unselectedItemColor: textColor,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 14,
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
                    ? const Icon(Icons.inbox)
                    : const Icon(Icons.inbox_outlined),
                label: 'Inbox'.tr),
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
            BottomNavigationBarItem(
                icon: _tabController.index == 4
                    ? const Icon(Icons.comment)
                    : const Icon(Icons.comment_outlined),
                label: 'Story'.tr),
          ],
        ),
      ),
    );
    // : Center(child: Text('Notification, Audio, Video and Storage Permissions are required for app to run'));
  }

  Future<int> getListnerStatus() async {
    await APIServices.toggleButtonONOFFModel(
      SharedPreference.getValue(PrefConstants.MERA_USER_ID),
    );

    return await fetchStatus(
        SharedPreference.getValue(PrefConstants.MERA_USER_ID).toString());
  }

  Future<void> switchUpdateFunction() async {
    toastshowDefaultSnackbar(context, 'Loading'.tr, false, primaryColor);

    if (isOnline == true) {
      var currStatus = await APIServices.toggleButtonONOFFModel(
        SharedPreference.getValue(PrefConstants.MERA_USER_ID),
      );

      if (currStatus?.status == true) {
        if (currStatus?.message == 'User offline successfull') {
          showNotification(0);
          if (context.mounted) {
            toastshowDefaultSnackbar(
                context, 'Offline'.tr, false, primaryColor);
          }
          setState(() {
            isOnline = false;
          });
        } else if (currStatus?.message == 'User online successfull') {
          showNotification(1);
          if (context.mounted) {
            toastshowDefaultSnackbar(context, 'Online'.tr, false, primaryColor);
          }
          setState(() {
            isOnline = true;
          });
        } else {
          showNotification(0);
          if (context.mounted) {
            toastshowDefaultSnackbar(
                context, 'Offline'.tr, false, primaryColor);
          }
          setState(() {
            isOnline = false;
          });
        }
      } else {
        showNotification(0);
        if (context.mounted) {
          toastshowDefaultSnackbar(context, 'Offline'.tr, false, primaryColor);
        }
        setState(() {
          isOnline = false;
        });
      }
    } else {
      var currStatus = await APIServices.toggleButtonONOFFModel(
        SharedPreference.getValue(PrefConstants.MERA_USER_ID),
      );

      if (currStatus?.status == true) {
        if (currStatus?.message == 'User offline successfull') {
          showNotification(0);
          if (context.mounted) {
            toastshowDefaultSnackbar(
                context, 'Offline'.tr, false, primaryColor);
          }
          setState(() {
            isOnline = false;
          });
        } else if (currStatus?.message == 'User online successfull') {
          showNotification(1);
          if (context.mounted) {
            toastshowDefaultSnackbar(context, 'Online'.tr, false, primaryColor);
          }
          setState(() {
            isOnline = true;
          });
        } else {
          showNotification(0);
          if (context.mounted) {
            toastshowDefaultSnackbar(
                context, 'Offline'.tr, false, primaryColor);
          }
          setState(() {
            isOnline = false;
          });
        }
      } else {
        showNotification(0);
        if (context.mounted) {
          toastshowDefaultSnackbar(context, 'Offline'.tr, false, primaryColor);
        }
        setState(() {
          isOnline = false;
        });
      }
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

  void setStatusOnline(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnline', value);
  }
}
