import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:support/screen/auth/panda_animation_page.dart';
import 'package:support/utils/color.dart';
import 'package:support/utils/reuasble_widget/toast_widget.dart';
import 'package:support/utils/reuasble_widget/utils.dart';
import 'package:support/screen/auth/login_via_whatsapp_screen.dart';

class PermissionRequestScreen extends StatefulWidget {
  const PermissionRequestScreen({super.key});

  @override
  PermissionRequestScreenState createState() => PermissionRequestScreenState();
}

class PermissionRequestScreenState extends State<PermissionRequestScreen> {
  bool camerastatus = false,
      microphonestatus = false,
      notificationstatus = false;

  static const platform = MethodChannel('com.example.support/screen_control');

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

  Future<void> requestPermissions() async {
    await AppUtils.handleMic(Permission.microphone, context);
    if (await Permission.microphone.isGranted) {
      setState(() {
        microphonestatus = true;
      });
      if (context.mounted) {
        await AppUtils.handleCamera(Permission.camera, context);
        if (await Permission.camera.isGranted) {
          setState(() {
            camerastatus = true;
          });
          //Permissions that will not show dialog
          await AppUtils.handleBluetoothAndNotification(Permission.bluetooth);
          await AppUtils.handleBluetoothAndNotification(
              Permission.notification);

          if (await Permission.notification.isGranted) {
            setState(() {
              notificationstatus = true;
            });
            createChannel();
            if (context.mounted) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const LoginViaWhatsApp()));
            }
          } else if (await Permission.notification.isDenied) {
            if (context.mounted) {
              toastshowDefaultSnackbar(context,
                  "Notification Permission is Required".tr, true, primaryColor);
            }
            if (context.mounted) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const PandaAnimationScreen()));
            }
          } else if (await Permission.notification.isPermanentlyDenied) {
            if (context.mounted) {
              toastshowDefaultSnackbar(
                  context,
                  "Go to App Settings > Permissions > Enable Notification Permission"
                      .tr,
                  true,
                  primaryColor);
            }
            if (context.mounted) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const PandaAnimationScreen()));
            }
          }
        } else {
          if (context.mounted) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const PandaAnimationScreen()));
          }
        }
      }
    } else {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const PandaAnimationScreen()));
      }
    }
  }

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    super.initState();

    if(Platform.isAndroid) {
      secureApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const PandaAnimationScreen()));
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorWhite,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Your permissions are needed for the following:'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    permissionCard(
                      Icons.camera_alt,
                      'Camera',
                      'For video chat',
                      camerastatus,
                    ),
                    permissionCard(
                      Icons.mic,
                      'Mic',
                      'For voice calls',
                      microphonestatus,
                    ),
                    permissionCard(
                      Icons.notifications,
                      'Notification',
                      'For alerts and updates',
                      notificationstatus,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: colorWhite,
                          backgroundColor: colorBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          requestPermissions();
                        },
                        child: Text(
                          'Turn on'.tr,
                          style: const TextStyle(fontSize: 16),
                        ),
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

  Widget permissionCard(
      IconData icon, String title, String subtitle, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(subtitle.tr),
              ],
            ),
          ),
          Icon(
            status ? Icons.check : Icons.close,
            color: status ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}
