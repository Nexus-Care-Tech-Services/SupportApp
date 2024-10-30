import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:support/api/api_services.dart';
import 'package:support/utils/color.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:support/utils/all_images.dart';
import 'package:support/utils/reuasble_widget/appbar.dart';
import 'mobile_otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> formKey = GlobalKey();
  FocusNode mobileNumberFocusNode = FocusNode();
  final TextEditingController mobileNumberController = TextEditingController();
  String mobileNumber = "";
  int? resendTokens;

  sendFirebaseOTP() async {
    try {
      EasyLoading.show(status: 'Sending OTP...'.tr);
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: mobileNumber,
        timeout: const Duration(seconds: 30),
        verificationCompleted: (PhoneAuthCredential credential) async {},
        verificationFailed: (FirebaseAuthException e) {
          APIServices.updateErrorLogs(mobileNumber, "verification failed");
          log("verification failed", error: e);
          EasyLoading.dismiss();
        },
        codeSent: (String verificationId, int? resendToken) async {
          resendTokens = resendToken;
          // Update the UI - wait for the user to enter the SMS code
          EasyLoading.dismiss();

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OTPScreen(
                        mobileNumber: mobileNumber,
                        verificationId: verificationId,
                        resendToken: resendTokens,
                      )));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          EasyLoading.dismiss();
        },
      );
    } catch (e) {
      APIServices.updateErrorLogs(mobileNumber, 'err while sending OTP');
      EasyLoading.dismiss();
      log("$e");
    }
  }

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    if (Platform.isAndroid) {
      secureApp();
    }
    super.initState();
  }

  @override
  void dispose() {
    mobileNumberController.dispose();
    mobileNumberFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 4.0, 15.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const CustomBackButton(
                          isfromLoginScreen: true,
                          isListner: false,
                        ),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0, top: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Enter your \nmobile number".tr,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: colorBlack,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(
                            'we will send you confirmation code'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colorGrey,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(6, 30.0, 6, 35),
                            child: Material(
                              surfaceTintColor: colorWhite,
                              shadowColor: primaryColor,
                              elevation: 1,
                              borderRadius: BorderRadius.circular(9),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: IntlPhoneField(
                                  controller: mobileNumberController,
                                  autofocus: true,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: colorBlack,
                                  ),
                                  focusNode: mobileNumberFocusNode,
                                  dropdownIconPosition: IconPosition.trailing,
                                  disableLengthCheck: true,
                                  initialCountryCode: "IN",
                                  decoration: InputDecoration(
                                    fillColor: colorWhite,
                                    focusColor: colorWhite,
                                    hoverColor: colorWhite,
                                    suffixIcon: InkWell(
                                      onTap: () {
                                        mobileNumberController.text = "";
                                        mobileNumberFocusNode.unfocus();
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: colorRed,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (phone) {
                                    mobileNumber = phone.completeNumber;
                                  },
                                  onCountryChanged: (country) {},
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: SizedBox(
                              // width: MediaQuery.of(context).size.width * 0.65,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                  ),
                                  onPressed: () {
                                    sendFirebaseOTP();
                                  },
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 14.0, bottom: 14),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.verified_user,
                                            size: 25,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Proceed Securly".tr,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            style: const TextStyle(
                                              color: colorWhite,
                                              fontSize: 19,
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
                            child: Container(
                              alignment: Alignment.center,
                              height: 48,
                              child: RichText(
                                textScaleFactor: 1,
                                text: TextSpan(
                                  text: 'By clicking, I accept the '.tr,
                                  style: const TextStyle(
                                    fontSize: 16,
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
                                          fontSize: 14,
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
