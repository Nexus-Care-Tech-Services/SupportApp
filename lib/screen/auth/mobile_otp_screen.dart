//
// OTP SCREEN
//

import 'dart:async';
import 'dart:developer';
import 'dart:io';

// import 'package:alt_sms_autofill/alt_sms_autofill.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/screen/auth/login_via_whatsapp_screen.dart';
import 'package:support/utils/color.dart';
import 'package:support/model/register_model.dart';
import 'package:support/utils/reuasble_widget/appbar.dart';
import 'package:support/screen/home/home_screen.dart';
import 'package:support/screen/listner_app_ui/listner_homescreen.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/reuasble_widget/toast_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:support/api/api_services.dart';
import 'package:support/utils/all_images.dart';

class OTPScreen extends StatefulWidget {
  final String mobileNumber;
  final String verificationId;
  final int? resendToken;

  const OTPScreen({
    required this.mobileNumber,
    required this.verificationId,
    required this.resendToken,
    Key? key,
  }) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController otpController = TextEditingController();

  // String _comingSms = 'Unknown';
  FocusNode _focusNode = FocusNode();
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countDown,
    presetMillisecond: StopWatchTimer.getMilliSecFromSecond(150),
  );
  String? selectedTopic;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  verifyOtp() async {
    String otp = otpController.text.trim();
    EasyLoading.show(status: 'loading...'.tr);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId, smsCode: otp);
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user != null) {
        if (kDebugMode) {
          print("OTP verification succeeded");
        }

        EasyLoading.show(status: 'loading...'.tr);
        String? token = await FirebaseMessaging.instance.getToken();

          RegistrationModel registerModel = await APIServices.registerAPI(
            widget.mobileNumber.toString(),
            // selectedTopic.toString(),
            token.toString(),
          );

          if (registerModel.status == true) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("userId", registerModel.data!.id.toString());
            prefs.setString("userName", registerModel.data!.name!);
            SharedPreference.setValue(
                PrefConstants.USER_NAME, registerModel.data!.name!);
            SharedPreference.setValue(
                PrefConstants.USER_IMAGE, registerModel.data?.image.toString());
            SharedPreference.setValue(PrefConstants.MOBILE_NUMBER,
                registerModel.data?.mobileNo.toString());
            SharedPreference.setValue(
                PrefConstants.MERA_USER_ID, registerModel.data?.id.toString());
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

            logUserSignInEvent(
                SharedPreference.getValue(PrefConstants.LISTENER_NAME),
                SharedPreference.getValue(PrefConstants.MERA_USER_ID));

            EasyLoading.dismiss();

            if (registerModel.data?.userType == 'user') {
              // if (!isListener) {

              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool("isListener", false);

              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              }
            } else {
              SharedPreference.setValue(PrefConstants.LISTNER_AVAILABILITY,
                  registerModel.data?.availableOn!.capitalizeFirst);
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool("isListener", true);

              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListnerHomeScreen(index: 0),
                  ),
                );
              }
            }
          } else {
            EasyLoading.dismiss();
            log("Register API failed");
            APIServices.updateErrorLogs(
                widget.mobileNumber.toString(), "Register API failed");
            // _focusNode.dispose();
          }
      }
    } on FirebaseAuthException catch (e) {
      APIServices.updateErrorLogs(
          widget.mobileNumber.toString(), "Invalid OTP. Please try again");
      EasyLoading.dismiss();
      otpController.clear();
      _focusNode.requestFocus();
      toastshowDefaultSnackbar(
          context, "Invalid OTP. Please try again.".tr, false, colorRed);
      log("$e");
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

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    super.initState();
    analytics.setAnalyticsCollectionEnabled(true);
    if (Platform.isAndroid) {
      secureApp();
    }
    _stopWatchTimer.onStartTimer();
    // initSmsListener();
    // sendFirebaseOTP();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    // AltSmsAutofill().unregisterListener();
    _stopWatchTimer.dispose();
    try {
      otpController.dispose();
    } catch (e) {
      // (e);
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 4.0, 15.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const CustomBackButton(
                            isfromLoginScreen: true, isListner: false),
                        const Spacer(),
                        Image.asset(
                          appLogoTransparent,
                          // height: 80,
                          width: MediaQuery.of(context).size.width * 0.35,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(
                          width: 35,
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25.0, top: 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enter code sent\nto your phone'.tr,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: colorBlack,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                'we send it to the number'.tr,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: colorGrey,
                                ),
                              ),
                              Text(
                                ' ${widget.mobileNumber}'.tr,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: colorGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 50),
                  child: PinCodeTextField(
                    // autoFocus: true,
                    focusNode: _focusNode,
                    appContext: context,
                    pastedTextStyle: TextStyle(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                    length: 6,
                    obscureText: false,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.underline,
                      // borderRadius: BorderRadius.circular(10),
                      fieldHeight: 33,
                      fieldWidth: 20,
                      inactiveFillColor: const Color(0xffF9FAFC),
                      inactiveColor: colorBlack,
                      selectedColor: colorBlack,
                      selectedFillColor: const Color(0xffF9FAFC),
                      activeFillColor: const Color(0xffF9FAFC),
                      activeColor: colorBlack,
                    ),
                    cursorColor: colorBlack,
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    enablePinAutofill: true,
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    // boxShadows: const [],
                    onCompleted: (v) {
                      //do something or move to next screen when code complete
                    },
                    onChanged: (value) {
                      log(value);
                      if (mounted) {
                        setState(() {
                          log(value);
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  StreamBuilder<int>(
                    stream: _stopWatchTimer.rawTime,
                    initialData: _stopWatchTimer.rawTime.value,
                    builder: (context, snap) {
                      final value = snap.data!;
                      final displayTime = StopWatchTimer.getDisplayTime(value,
                          hours: false, milliSecond: false);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _stopWatchTimer.rawTime.value != 0
                              ? Text(
                                  "Resend code in".tr,
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: 16, color: colorGrey),
                                )
                              : InkWell(
                                  onTap: () {
                                    _stopWatchTimer.setPresetSecondTime(150);
                                    _stopWatchTimer.onStartTimer();
                                    sendFirebaseOTP();
                                  },
                                  child: Text(
                                    "RESEND CODE".tr,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: colorBlack,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                          _stopWatchTimer.rawTime.value != 0
                              ? Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    displayTime,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: colorGrey,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      onPressed: () async {
                        verifyOtp(); // uncoment this
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 14.0, bottom: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.verified_user,
                                size: 24,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Verify Code".tr,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: colorWhite,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Center(
                child: InkWell(
                  onTap: () {
                    launchUrl(Uri.parse(
                        "https://supportletstalk.com/privacy-policy.html"));
                  },
                  child: RichText(
                    textScaleFactor: 1,
                    text: TextSpan(
                      text: 'By clicking, I accept the '.tr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: colorBlack,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'T&C'.tr,
                          style: TextStyle(
                              fontSize: 12,
                              color: colorBlue,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' and '.tr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: colorBlack,
                          ),
                        ),
                        TextSpan(
                          text: 'Privacy Policy'.tr,
                          style: TextStyle(
                              fontSize: 12,
                              color: colorBlue,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  sendFirebaseOTP() async {
    try {
      EasyLoading.show(status: 'loading...'.tr);
      await FirebaseAuth.instance.signOut();
      await Future.delayed(const Duration(seconds: 1));
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.mobileNumber,
        timeout: const Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential credential) async {},
        verificationFailed: (FirebaseAuthException e) async {},
        forceResendingToken: widget.resendToken,
        codeSent: (String verificationId, int? resendToken) async {
          // Update the UI - wait for the user to enter the SMS code
          EasyLoading.dismiss();

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => OTPScreen(
                        mobileNumber: widget.mobileNumber,
                        verificationId: verificationId,
                        resendToken: widget.resendToken,
                      )));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          EasyLoading.dismiss();
        },
      );
    } catch (e) {
      APIServices.updateErrorLogs(widget.mobileNumber, 'err while sending OTP');
      EasyLoading.dismiss();
      log("$e");
    }
  }
}
