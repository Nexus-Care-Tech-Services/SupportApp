import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/screen/auth/login_via_whatsapp_screen.dart';
import 'package:support/screen/auth/permission_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:support/utils/color.dart';
import 'package:support/utils/reuasble_widget/logo.dart';

class SecondPage extends StatelessWidget {
  SecondPage({super.key});

  final List locale = [
    {'name': 'English', 'locale': const Locale('en', 'US')},
    {'name': 'हिंदी', 'locale': const Locale('hi', 'IN')},
    {'name': 'ગુજરાતી', 'locale': const Locale('gu', 'IN')},
    {'name': 'தமிழ்', 'locale': const Locale('ta', 'IN')},
    {'name': 'తెలుగు', 'locale': const Locale('te', 'US')},
    {'name': 'മലയാളം', 'locale': const Locale('ml', 'US')},
    {'name': 'বাংলা', 'locale': const Locale('bn', 'IN')},
  ];

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  updateLanguage(Locale locale) {
    Get.back();
    Get.updateLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    if(Platform.isAndroid) {
      secureApp();
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Logo(
            height: 150,
            width: 300,
          ),
          Column(
            children: [
              Center(
                child: Text(
                  "Attentive Ears, Caring Hearts",
                  style: GoogleFonts.openSans(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  "We’re Here for You",
                  style: GoogleFonts.openSans(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                          width: 4,
                        ),
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage("assets/images/l1.png"),
                        ),
                      ),
                      height: 100,
                      width: 100,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                          width: 4,
                        ),
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage("assets/images/l2.png"),
                        ),
                      ),
                      height: 100,
                      width: 100,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                          width: 4,
                        ),
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage("assets/images/l3.png"),
                        ),
                      ),
                      height: 100,
                      width: 100,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                          width: 4,
                        ),
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage("assets/images/l4.png"),
                        ),
                      ),
                      height: 100,
                      width: 100,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                          width: 4,
                        ),
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage("assets/images/l5.png"),
                        ),
                      ),
                      height: 100,
                      width: 100,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                          width: 4,
                        ),
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage("assets/images/l6.png"),
                        ),
                      ),
                      height: 100,
                      width: 100,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                          width: 4,
                        ),
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage("assets/images/l7.png"),
                        ),
                      ),
                      height: 100,
                      width: 100,
                    ),
                    const SizedBox(width: 15,),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                          width: 4,
                        ),
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage("assets/images/l8.png"),
                        ),
                      ),
                      height: 100,
                      width: 100,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              Center(
                child: Text(
                  "Anonymous",
                  style: GoogleFonts.openSans(
                      color: const Color.fromARGB(255, 0, 106, 196),
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  "Chat | Call | V Call",
                  style: GoogleFonts.openSans(
                      color: const Color.fromARGB(255, 0, 106, 196),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          InkWell(
            onTap: () {
              showLanguageChangeDialog(context);
            },
            child: Container(
              width: 100,
              height: 50,
              margin: const EdgeInsets.only(top: 20,bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.lightBlueAccent,
              ),
              alignment: Alignment.center,
              child: const Text(
                'NEXT',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  showLanguageChangeDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (builder) {
          return Semantics(
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9)),
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

                          if (await Permission.microphone.isGranted) {
                            if (await Permission.camera.isGranted) {
                              if (await Permission.notification.isGranted) {
                                if (context.mounted) {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginViaWhatsApp()));
                                }
                              } else {
                                if (context.mounted) {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const PermissionRequestScreen()));
                                }
                              }
                            } else {
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const PermissionRequestScreen()));
                              }
                            }
                          } else {
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PermissionRequestScreen()));
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          child: Text(locale[index]['name']),
                        ),
                      );
                    },
                    itemCount: locale.length),
              ),
            ),
          );
        });
  }
}
