import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:support/main.dart';
import 'package:support/screen/wallet/wallet_screen.dart';
import 'package:support/utils/reuasble_widget/toast_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:support/utils/color.dart';

class AppUtils {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<double> fetchListenerAvailability(
      String date, String listenerId) async {
    double availableTime = 0;
    try {
      CollectionReference availabilityCollection =
          _firestore.collection('listner_availability');

      DocumentReference dateDocument = availabilityCollection.doc(date);

      CollectionReference dataCollection = dateDocument.collection('data');

      DocumentSnapshot listenerDoc = await dataCollection.doc(listenerId).get();

      if (listenerDoc.exists) {
        availableTime = double.parse(listenerDoc['available_time'].toString());

        debugPrint(
            'Listener $listenerId is available for $availableTime minutes on $date.');
      } else {
        debugPrint('Listener $listenerId not found on $date.');
      }
    } catch (e) {
      debugPrint('Error fetching listener availability: $e');
    }
    return availableTime;
  }

  static launchURL(String url) async => await canLaunchUrl(Uri.parse(url))
      ? await launchUrl(Uri.parse(url))
      : throw 'Could not launch $url';

  static showLowBalanceBottomSheet(BuildContext context, String amt) {
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
                  style: TextStyle(color: ui_mode == "dark" ? colorWhite : textColor),
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

  //Microphone Permissions
  static Future<void> handleMic(
      Permission permission, BuildContext context) async {
    final status = await permission.request();
    if (status == PermissionStatus.denied) {
      if (context.mounted) {
        toastshowDefaultSnackbar(
            context, "Microphone Permission is Required".tr, true, primaryColor);
      }
    }

    if (status == PermissionStatus.permanentlyDenied) {
      if (context.mounted) {
        toastshowDefaultSnackbar(
            context,
            "Go to App Settings > Permissions > Enable Microphone Permission".tr,
            true,
            primaryColor);
      }
    }
    debugPrint(status.toString());
  }

  //Camera Permissions
  static Future<void> handleCamera(
      Permission permission, BuildContext context) async {
    final status = await permission.request();

    if (status == PermissionStatus.denied) {
      if (context.mounted) {
        toastshowDefaultSnackbar(
            context, "Camera Permission is Required".tr, true, primaryColor);
      }
    }

    if (status == PermissionStatus.permanentlyDenied) {
      if (context.mounted) {
        toastshowDefaultSnackbar(
            context,
            "Go to App Settings > Permissions > Enable Camera Permission".tr,
            true,
            primaryColor);
      }
    }
    debugPrint(status.toString());
  }

  //Bluetooth and Notification Permissions
  static Future<void> handleBluetoothAndNotification(
      Permission permission) async {
    final status = await permission.request();
    debugPrint(status.toString());
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
final Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
