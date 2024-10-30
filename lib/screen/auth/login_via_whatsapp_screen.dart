import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/utils/all_images.dart';
import 'package:support/utils/color.dart';
import 'package:support/model/register_model.dart';
import 'package:support/screen/auth/login_screen.dart';
import 'package:support/screen/home/home_screen.dart';
import 'package:support/screen/listner_app_ui/listner_homescreen.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/reuasble_widget/toast_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginViaWhatsApp extends StatefulWidget {
  const LoginViaWhatsApp({Key? key}) : super(key: key);

  @override
  State<LoginViaWhatsApp> createState() => _LoginViaWhatsAppState();
}

class _LoginViaWhatsAppState extends State<LoginViaWhatsApp> {
  GlobalKey<FormState> formKey = GlobalKey();
  FocusNode mobileNumberFocusNode = FocusNode();
  final TextEditingController mobileNumberController = TextEditingController();
  String mobileNumber = "";
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  signInWithGoogle() async {
    try {
      EasyLoading.show(status: 'loading'.tr);
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      EasyLoading.dismiss();
      if (userCredential.user != null) {
        EasyLoading.show(status: 'loading...'.tr);
        String? token = await FirebaseMessaging.instance.getToken();
        // bool? result = await APIServices.validateToken(deviceToken: token!);
        //
        // if (result!) {
          RegistrationModel registerModel =
              await APIServices.registerwithEmailAPI(googleUser!.email, token!);

          if (registerModel.status == true) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("userId", registerModel.data!.id.toString());
            prefs.setString("userName", registerModel.data!.name!);
            SharedPreference.setValue(
                PrefConstants.USER_NAME, registerModel.data!.name!);
            SharedPreference.setValue(PrefConstants.EMAIL, googleUser.email);
            SharedPreference.setValue(
                PrefConstants.USER_IMAGE, registerModel.data?.image.toString());
            SharedPreference.setValue(PrefConstants.MOBILE_NUMBER,
                registerModel.data?.mobileNo.toString());
            SharedPreference.setValue(
                PrefConstants.LAST_UPDATE_TIMESTAMP, DateTime.now().toString());
            SharedPreference.setValue(
                PrefConstants.MERA_USER_ID, registerModel.data?.id.toString());
            SharedPreference.setValue(PrefConstants.LANGUAGE,
                registerModel.data?.language.toString());
            SharedPreference.setValue(
                PrefConstants.CHARGE, registerModel.data?.charge.toString());
            SharedPreference.setValue(PrefConstants.USER_TYPE,
                registerModel.data?.userType.toString());
            SharedPreference.setValue(PrefConstants.LISTENER_NAME,
                registerModel.data?.name.toString());
            SharedPreference.setValue(
                PrefConstants.LISTENER_IMAGE,
                registerModel.data?.image?.toString() != null
                    ? registerModel.data?.image.toString()
                    : 'https://laravel.supportletstalk.com/manage/images/avatar/user.png');
            SharedPreference.setValue(PrefConstants.ONLINE,
                registerModel.data?.onlineStatus == 1 ? true : false);
            SharedPreference.setValue(PrefConstants.INTEREST,
                registerModel.data?.interest == '' ? "happy" :  registerModel.data?.interest.toString());

            logUserSignInEvent(
                SharedPreference.getValue(PrefConstants.LISTENER_NAME),
                SharedPreference.getValue(PrefConstants.MERA_USER_ID));

            EasyLoading.dismiss();

            if (registerModel.data?.userType == 'user') {
              // if (!isListener) {

              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool("isListener", false);

              if (context.mounted) {
                FirebaseAnalytics.instance.logEvent(
                    name: 'User_Logged_In_${registerModel.data!.id!}');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              }
            } else {
              SharedPreference.setValue(PrefConstants.LISTNER_AVAILABILITY,
                  registerModel.data!.availableOn!);

              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool("isListener", true);

              if (context.mounted) {
                FirebaseAnalytics.instance.logEvent(
                    name: 'User_Logged_In_${registerModel.data!.id!}');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListnerHomeScreen(index: 0),
                  ),
                );
              }
            }
          }
        // } else {
        //   EasyLoading.dismiss();
        //   EasyLoading.showInfo('Validation Failed. Login again'.tr);
        //   await GoogleSignIn().signOut();
        //   await FirebaseAuth.instance.signOut();
        //   if (context.mounted) {
        //     Navigator.of(context).pushReplacement(MaterialPageRoute(
        //         builder: (context) => const LoginViaWhatsApp()));
        //   }
        // }
      } else {
        EasyLoading.dismiss();
        log("Register API failed");
      }
    } catch (e) {
     toastshowDefaultSnackbar(context, 'signinWithGoogle $e', true, primaryColor);
    }
  }

  void logUserSignInEvent(String userName, String userid) async {
    // Log user sign-in event
    await analytics.logEvent(
      name: 'user_sign_in',
      parameters: <String, dynamic>{'user_name': userName, 'user_id': userid},
    );
    debugPrint('User signed in with Google');
  }

  @override
  void initState() {
    analytics.setAnalyticsCollectionEnabled(true);
    if (Platform.isAndroid) {
      secureApp();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: ListView(
              children: [
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      appLogoTransparent,
                      height: 48,
                      width: MediaQuery.of(context).size.width * 0.35,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 80,
                ),
                InkWell(
                  onTap: () {
                    signInWithGoogle();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 15, right: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black38, width: 1),
                    ),
                    height: 48,
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/google_signin_icon.png',
                          width: 22,
                          height: 22,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Sign in with Google".tr,
                          style: const TextStyle(
                            //color: Color(0xFF333333),
                            color: colorBlack,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Center(
                  child: Text(
                    'OR'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: colorBlack,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Center(
                  child: Container(
                    alignment: Alignment.center,
                    height: 48,
                    // width: MediaQuery.of(context).size.width * 0.65,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                      },
                      child: Text(
                        "Continue with Mobile".tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: colorBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: Container(
                    alignment: Alignment.center,
                    height: 48,
                    child: RichText(
                      textScaleFactor: 1,
                      text: TextSpan(
                        text: 'By clicking, I accept the '.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          color: colorBlack,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'T&C'.tr,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrl(Uri.parse(
                                    "https://supportletstalk.com/Terms-and-Condition.html"));
                              },
                            style: TextStyle(
                                fontSize: 16,
                                color: colorBlue,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: ' and '.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              color: colorBlack,
                            ),
                          ),
                          TextSpan(
                            text: 'Privacy Policy'.tr,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrl(Uri.parse(
                                    "https://supportletstalk.com/privacy-policy.html"));
                              },
                            style: TextStyle(
                                fontSize: 16,
                                color: colorBlue,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
