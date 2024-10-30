import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:fcm_channels_manager/fcm_channels_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support/api/api_services.dart';
import 'package:support/screen/auth/loader_screen.dart';
import 'package:support/screen/auth/panda_animation_page.dart';
import 'package:support/utils/localestring.dart';
import 'package:support/screen/home/home_screen.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/stripe_payments/constants.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/bindings/global_bindings.dart';
import 'package:support/firebase_options.dart';
import 'package:support/utils/color.dart';
import 'package:support/utils/theme.dart';
import 'package:support/push_notification/firebase_messaging.dart';

import 'package:support/screen/listner_app_ui/listner_homescreen.dart';

String ui_mode = "";

Future<void> backgroundHandler(RemoteMessage message) async {}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  Stripe.publishableKey = STRIPE_PUBLISHABLE_KEY;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SharedPreference.init();
  if (Platform.isAndroid) {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  HttpOverrides.global = MyHttpOverrides();

  runApp(
    const MyApp(),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late TextEditingController controller;
  Widget? home = const PandaAnimationScreen();
  bool isLoading = true;
  late List<Object?> result;
  final fcmManager = FcmChannelsManager();
  List<NotificationChannel> channels = [];
  static const platform = MethodChannel('com.example.support/screen_control');

  checkUIMode() async {
    ui_mode = SharedPreference.getValue(PrefConstants.UI_MODE) ?? "light";

    if (ui_mode == "dark") {
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
    } else {
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
    }
    log(ui_mode);
  }

  getChannels() async {
    channels = await fcmManager.getChannels();
    for (int i = 0; i < channels.length; i++) {
      log("${channels[i].name} ${channels[i].id}");
      if (channels[i].id == "your channel id") {
        fcmManager.unregisterChannel("your channel id");
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = TextEditingController();
    Messaging.showMessage();
    checkLogin();
    checkUIMode();
    getChannels();
    createChannel();
  }

  checkPermission() async {
    if (await Permission.microphone.isGranted) {
      if (await Permission.camera.isGranted) {
        if (await Permission.notification.isGranted) {
          createChannel();
        } else {
          clearData();
        }
      } else {
        clearData();
      }
    } else {
      clearData();
    }
  }

  clearData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const PandaAnimationScreen()));
    }
  }

  createChannel() async {
    try {
      if (await Permission.notification.isGranted) {
        await platform.invokeMethod('createnotifychannel');
        await platform.invokeMethod('createconstantnotifychannel');
      }
    } catch (e) {
      log("createChannel $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // The application is exited or closed
      if (kDebugMode) {
        print('Application exited or closed');
      }
    }
  }

  void checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    if (FirebaseAuth.instance.currentUser != null) {
      String? token = await FirebaseMessaging.instance.getToken();
        bool? result = await APIServices.updateDeviceToken(token!);
        debugPrint(result.toString());
        bool? isListener = prefs.getBool("isListener");
        if (!isListener!) {
          home = const HomeScreen();
        } else {
          home = const ListnerHomeScreen(
            index: 0,
          );
        }
    } else {
      prefs.setString(PrefConstants.LANGUAGE, 'en');
      home = const PandaAnimationScreen();
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: const Locale('en', 'US'),
      translations: LocaleString(),
      initialBinding: GlobalBinding(),
      color: primaryColor,
      debugShowCheckedModeBanner: false,
      title: 'Support',
      theme: MyTheme.lightTheme,
      home: isLoading ? const LoaderScreen() : home,
      builder: EasyLoading.init(),
    );
  }
}
