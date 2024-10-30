// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support/api/api_services.dart';
import 'package:support/screen/auth/panda_animation_page.dart';
import 'package:support/screen/drawer/about_us_screen.dart';
import 'package:support/screen/listner_app_ui/profile/listner_care.dart';
import 'package:support/screen/listner_app_ui/profile/view_profile.dart';
import 'package:support/utils/color.dart';
import 'package:support/model/delete_model.dart';
import 'package:support/screen/auth/login_via_whatsapp_screen.dart';
import 'package:support/screen/drawer/online_notification.dart';
import 'package:support/utils/reuasble_widget/image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:support/api/api_constant.dart';
import 'package:support/main.dart';
import 'package:support/model/chat_notification.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/screen/home/home_screen.dart';
import 'package:support/screen/listner_app_ui/listner_homescreen.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({Key? key}) : super(key: key);

  @override
  DrawerScreenState createState() => DrawerScreenState();
}

class DrawerScreenState extends State<DrawerScreen> {
  bool isProgressRunning = false;
  ChatNotificationModel? chatNotificationModel;
  String dataFromSecondScreen = '';
  bool? isListener = true;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool isDark = false;
  bool isProcessRunning = false;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  final List locale = [
    {'name': 'English', 'locale': const Locale('en', 'US')},
    {'name': 'हिंदी', 'locale': const Locale('hi', 'IN')},
    {'name': 'ગુજરાતી', 'locale': const Locale('gu', 'IN')},
    {'name': 'தமிழ்', 'locale': const Locale('ta', 'IN')},
    {'name': 'తెలుగు', 'locale': const Locale('te', 'IN')},
    {'name': 'മലയാളം', 'locale': const Locale('ml', 'IN')},
    {'name': 'বাংলা', 'locale': const Locale('bn', 'IN')},
  ];

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  updateLanguage(Locale locale) {
    Get.back();
    Get.updateLocale(locale);
  }

  final Uri _listnerurl = Uri.parse(
      'https://docs.google.com/forms/d/1GY8QI53xzPnR5pWLnWJmWHxYEWEZYvULE09EKDjUZG0/edit');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_listnerurl)) {
      throw 'Could not launch $_listnerurl';
    }
  }

  void logSignOutEvent(String userName, String userid) async {
    await analytics.logEvent(
      name: 'user_sign_out',
      parameters: <String, dynamic>{'user_name': userName, 'user_id': userid},
    );
  }

  Future<void> apiNotifyListnerList() async {
    try {
      setState(() {
        isProgressRunning = true;
      });
      chatNotificationModel = await APIServices.getNotification();
    } catch (e) {
      log(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          isProgressRunning = false;
        });
      }
    }
  }

  void restartApp() {
    if (Platform.isAndroid || Platform.isIOS) {
      // Use platform-specific method to restart the app
      Process.run('flutter', ['restart']).then((ProcessResult results) {
        if (results.exitCode == 0) {
          if (kDebugMode) {
            print('App restarted successfully.');
          }
        } else {
          if (kDebugMode) {
            print('Failed to restart app.');
          }
        }
      });
    } else {
      if (kDebugMode) {
        print('Restart is not supported on this platform.');
      }
    }
  }

  void getUIMode() async {
    ui_mode = SharedPreference.getValue(PrefConstants.UI_MODE) ?? "light";
  }

  Future<void> changeColors() async {
    try {
      setState(() {
        isProcessRunning = true;
      });
      if (ui_mode == "dark") {
        isDark = true;
        SharedPreference.setValue(PrefConstants.UI_MODE, "light");
        if (kDebugMode) {
          print("UI Set to LIght");
        }
        primaryColor = const Color(0xff006BC5);
        cardColor = const Color(0xffF9FAFC);
        tabColor = const Color(0xffF9FAFC);
        textColor = const Color(0xff181818);
        listnerRatingColor = const Color(0xff0157ca);
        // backgroundColor = Color
        backgroundColor = const Color(0xffF9FAFC);
        tabUnderLineColor = const Color(0xff181818);
        detailScreenCardColor = const Color(0xffe8ecf7);
        detailScreenBgColor = const Color(0xfff7f8fc);
        inboxCardColor = const Color(0xffF9FAFC);
        setState(() {});
      } else {
        isDark = false;
        SharedPreference.setValue(PrefConstants.UI_MODE, "dark");
        if (kDebugMode) {
          print("UI Set to Dark");
        }
        primaryColor = const Color(0xff181818);
        cardColor = const Color(0xff282828);
        tabColor = const Color(0xff282828);
        textColor = const Color(0xffF9FAFC);
        listnerRatingColor = const Color(0xffF9FAFC);
        backgroundColor = const Color(0xff181818);
        tabUnderLineColor = const Color(0xffF9FAFC);
        detailScreenCardColor = const Color(0xff393E46);
        detailScreenBgColor = const Color(0xff222831);
        inboxCardColor = const Color(0xff1A1A1B);
        setState(() {});
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessRunning = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    analytics.setAnalyticsCollectionEnabled(true);
    if (Platform.isAndroid) {
      secureApp();
    }
    apiNotifyListnerList();
    getUIMode();
  }

  @override
  Widget build(BuildContext context) {
    return isProcessRunning
        ? SafeArea(
            child: Container(
                color: backgroundColor,
                child: const Center(
                  child: CircularProgressIndicator(),
                )),
          )
        : Drawer(
            backgroundColor: tabColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: colorRed,
                ),
                Expanded(
                  child: Container(
                    color: tabColor,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 13, right: 13, bottom: 10, top: 30),
                              child: Row(
                                children: [
                                  Column(children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: textColor),
                                        shape: BoxShape.circle,
                                      ),
                                      child: SharedPreference.getValue(
                                                  PrefConstants.USER_TYPE) ==
                                              'user'
                                          ? SharedPreference.getValue(
                                                      PrefConstants
                                                          .USER_IMAGE) ==
                                                  null
                                              ? Icon(
                                                  Icons.person,
                                                  size: 50,
                                                  color: textColor,
                                                )
                                              : showImage(
                                                  0.0,
                                                  NetworkImage(
                                                      SharedPreference.getValue(
                                                          PrefConstants
                                                              .USER_IMAGE)))
                                          : showImage(
                                              0.0,
                                              NetworkImage(
                                                  APIConstants.BASE_URL +
                                                      SharedPreference.getValue(
                                                          PrefConstants
                                                              .LISTENER_IMAGE)),
                                            ),
                                    ),
                                  ]),
                                  const SizedBox(
                                    width: 13,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        SharedPreference.getValue(
                                                    PrefConstants.USER_TYPE) ==
                                                'user'
                                            ? SharedPreference.getValue(
                                                        PrefConstants
                                                            .LISTENER_NAME) ==
                                                    null
                                                ? 'Anonymous'
                                                : SharedPreference.getValue(
                                                        PrefConstants
                                                            .LISTENER_NAME)
                                                    .toString()
                                            : SharedPreference.getValue(
                                                PrefConstants.LISTENER_NAME),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: textColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        SharedPreference.getValue(
                                                    PrefConstants.EMAIL) ==
                                                null
                                            ? SharedPreference.getValue(
                                                    PrefConstants
                                                        .MOBILE_NUMBER) ??
                                                ''
                                            : SharedPreference.getValue(
                                                            PrefConstants.EMAIL)
                                                        .toString()
                                                        .length >
                                                    22
                                                ? "${SharedPreference.getValue(PrefConstants.EMAIL).toString().substring(0, 19)}..."
                                                : SharedPreference.getValue(
                                                    PrefConstants.EMAIL),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              color: textColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  InkWell(
                                    onTap: () {
                                      isProcessRunning = true;
                                      changeColors();
                                      if (SharedPreference.getValue(
                                              PrefConstants.USER_TYPE) !=
                                          'user') {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const ListnerHomeScreen(
                                                      index: 0,
                                                    )));
                                      } else {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const HomeScreen()));
                                      }
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: textColor),
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        child: Icon(
                                          ui_mode == "dark"
                                              ? Icons.dark_mode
                                              : Icons.light_mode,
                                          color: textColor,
                                          size: 25,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: SharedPreference.getValue(
                                      PrefConstants.USER_TYPE) ==
                                  'user',
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 13, right: 13),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const OnlineListnerNotification(),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: colorGrey,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(6),
                                              child: Icon(
                                                  Icons.notification_add,
                                                  color: textColor),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Chat Notification".tr,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: textColor,
                                                ),
                                              ),

                                              const SizedBox(width: 8),
                                              // isProgressRunning
                                              //     ?
                                              if (chatNotificationModel !=
                                                      null &&
                                                  chatNotificationModel!
                                                          .unreadNotifications! >
                                                      0)
                                                Visibility(
                                                  visible: chatNotificationModel !=
                                                          null &&
                                                      chatNotificationModel!
                                                              .unreadNotifications! >
                                                          0,
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color:
                                                                Colors.green),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      child: Text(
                                                        '${chatNotificationModel?.unreadNotifications ?? ''}',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: textColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: SharedPreference.getValue(
                                      PrefConstants.USER_TYPE) ==
                                  'user',
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  customRow(
                                    "Be a Listner".tr,
                                    Icon(Icons.interpreter_mode,
                                        color: textColor),
                                    _launchUrl,
                                  ),
                                ],
                              ),
                            ),
                            if (SharedPreference.getValue(
                                    PrefConstants.USER_TYPE) ==
                                'user') ...{
                              const SizedBox(
                                height: 15,
                              ),
                            },
                            if (SharedPreference.getValue(
                                    PrefConstants.USER_TYPE) ==
                                'user') ...{
                              customRow("Change Language".tr,
                                  Icon(Icons.translate, color: textColor), () {
                                showLanguageChangeDialog(context);
                              }),
                              const SizedBox(
                                height: 15,
                              ),
                            },
                            Visibility(
                              visible: SharedPreference.getValue(
                                      PrefConstants.USER_TYPE) !=
                                  'user',
                              child: Column(
                                children: [
                                  customRow('My Profile',
                                      Icon(Icons.person, color: textColor), () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ViewProfile()));
                                  }),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: SharedPreference.getValue(
                                      PrefConstants.USER_TYPE) !=
                                  'user',
                              child: customRow(
                                  'Listner Care',
                                  Icon(
                                    Icons.favorite_sharp,
                                    color: textColor,
                                  ), () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ListenerCarePage()));
                              }),
                            ),
                            Visibility(
                              visible: SharedPreference.getValue(
                                      PrefConstants.USER_TYPE) !=
                                  'user',
                              child: const SizedBox(
                                height: 15,
                              ),
                            ),
                            customRow(
                              "About us".tr,
                              Icon(Icons.info, color: textColor),
                              () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AboutUsScreen()));
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            customRow(
                              "Privacy Policy".tr,
                              Icon(Icons.privacy_tip, color: textColor),
                              () async {
                                launchUrl(Uri.parse(
                                    "https://supportletstalk.com/privacy-policy.html"));
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            customRow(
                              "Terms and Conditions".tr,
                              Icon(Icons.article, color: textColor),
                              () async {
                                launchUrl(Uri.parse(
                                    "https://supportletstalk.com/Terms-and-Condition.html"));
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            customRow(
                              "Refund Policy".tr,
                              Icon(Icons.policy, color: textColor),
                              () => launchUrl(
                                Uri.parse(
                                    "https://supportletstalk.com/RefundPolicy.html"),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            if (SharedPreference.getValue(
                                    PrefConstants.USER_TYPE) !=
                                'user') ...{
                              customRow("Change Language".tr,
                                  Icon(Icons.translate, color: textColor), () {
                                showLanguageChangeDialog(context);
                              }),
                              const SizedBox(
                                height: 15,
                              ),
                            },
                            customRow(
                              "Logout".tr,
                              Icon(Icons.logout, color: textColor),
                              () async {
                                logSignOutEvent(
                                    SharedPreference.getValue(
                                        PrefConstants.LISTENER_NAME),
                                    SharedPreference.getValue(
                                        PrefConstants.MERA_USER_ID));
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.clear();
                                await googleSignIn.signOut();
                                await FirebaseAuth.instance.signOut();
                                if (mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginViaWhatsApp()),
                                      (Route<dynamic> route) => false);
                                }
                              },
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 20),
                                InkWell(
                                  child: SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: Image.asset(
                                          'assets/images/youtube.png')),
                                  onTap: () {
                                    launchUrl(Uri.parse(
                                        'https://www.youtube.com/@Supportletstalk'));
                                  },
                                ),
                                const SizedBox(width: 10),
                                InkWell(
                                  child: SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: Image.asset(
                                        'assets/images/instagram.png'),
                                  ),
                                  onTap: () {
                                    launchUrl(Uri.parse(
                                        'https://www.instagram.com/support2heal/'));
                                  },
                                ),
                                const SizedBox(width: 15),
                                InkWell(
                                  child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: Image.asset(
                                          'assets/images/facebook.png')),
                                  onTap: () {
                                    launchUrl(Uri.parse(
                                        'https://www.facebook.com/support2heal'));
                                  },
                                ),
                                const SizedBox(width: 25),
                                InkWell(
                                  child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: Image.asset(
                                          'assets/whatsapp-fill.png')),
                                  onTap: () {
                                    launchUrl(Uri.parse(
                                        'https://whatsapp.com/channel/0029VaCatVzGpLHTqYNbRT1J'));
                                  },
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: tabColor,
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
                  child: Text(
                    'NexusCare Tech Services Pvt Ltd.',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget customRow(String txt, Icon icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 13, right: 13),
      child: InkWell(
        onTap: () {
          onTap();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorGrey,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: icon,
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Text(
                txt,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showDeleteAccountAlertDialog(BuildContext context) {
    // set up the button

    Widget yesButton = TextButton(
      child: Container(
          color: primaryColor,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25.0, 5, 25, 5),
            child: Text(
              "Yes".tr,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          )),
      onPressed: () async {
        EasyLoading.show(status: 'loading...'.tr);
        DeleteModel? data = await APIServices.getDeleteAccount(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID.toString()) ??
              '',
        );
        if (data?.status == true) {
          log(SharedPreference.getValue(PrefConstants.MERA_USER_ID) ?? '',
              name: 'Delete Account Success');

          EasyLoading.dismiss();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.clear();
          await googleSignIn.signOut();
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const PandaAnimationScreen()),
                (Route<dynamic> route) => false);
          }
        }
      },
    );

    Widget noButton = TextButton(
      child: Container(
          color: primaryColor,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25.0, 5, 25, 5),
            child: Text(
              "No".tr,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          )),
      onPressed: () async {
        Navigator.pop(context);
        Scaffold.of(context).openEndDrawer();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: colorWhite,
      titlePadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.all(0),
      insetPadding: const EdgeInsets.all(0),
      actionsPadding: const EdgeInsets.all(0),
      buttonPadding: const EdgeInsets.all(5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Delete Account".tr,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 22,
                  ),
                ),
              )),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.fromLTRB(14.0, 18, 14, 20),
        child: Text(
          "Are you sure you want to delete account ?".tr,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ),
      actions: [
        noButton,
        yesButton,
      ],
    );

    // show the dialog

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showLanguageChangeDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (builder) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            backgroundColor: colorWhite,
            title: Text('Choose a Language'.tr),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        updateLanguage(locale[index]['locale']);
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setString(PrefConstants.LANGUAGE,
                            locale[index]['locale'].languageCode);
                        if (kDebugMode) {
                          print(prefs.getString(PrefConstants.LANGUAGE));
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        child: Text(locale[index]['name']),
                      ),
                    );
                  },
                  itemCount: locale.length),
            ),
          );
        });
  }
}
