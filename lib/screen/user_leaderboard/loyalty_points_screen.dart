import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:support/api/api_services.dart';
import 'package:support/main.dart';
import 'package:support/utils/color.dart';
import 'package:support/model/listner_display_model.dart';

import 'package:support/api/api_constant.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/reuasble_widget/toast_widget.dart';

class LoyaltyPointsScreen extends StatefulWidget {
  const LoyaltyPointsScreen({super.key});

  @override
  State<LoyaltyPointsScreen> createState() => _LoyaltyPointsScreenState();
}

class _LoyaltyPointsScreenState extends State<LoyaltyPointsScreen> {
  final lpController = TextEditingController();
  String? userLp = "0";

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  int calculateMoneyFromLoyaltyPoints() {
    const conversionRate = 5;

    try {
      // Attempt to parse the input as an integer
      int loyaltyPoints = int.parse(lpController.text);

      // Calculate money and round down to the nearest integer
      return (loyaltyPoints / conversionRate).floor();
    } catch (e) {
      // Handle the case when lpController.text is not a valid integer
      // You can display an error message or perform any other appropriate action
      debugPrint('Error: $e');
      return 0; // Or any default value
    }
  }

  getUserLp() async {
    ListnerDisplayModel user = await APIServices.getUserDataById(
        SharedPreference.getValue(PrefConstants.MERA_USER_ID));
    if (user.data != null) {
      setState(() {
        userLp = user.data![0].charge!.trim();
      });
    } else {
      setState(() {
        userLp = "User data not available";
      });
    }
  }

  void showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text("Sorry".tr,
              style: TextStyle(
                  color: ui_mode == "dark" ? colorWhite : colorBlack)),
          content: Text("You have not enough loyalty points.".tr,
              style: TextStyle(
                  color: ui_mode == "dark" ? colorWhite : colorBlack)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK".tr,
                  style: TextStyle(
                      color: ui_mode == "dark" ? colorWhite : colorBlack)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    lpController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserLp();
    if (Platform.isAndroid) {
      secureApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: detailScreenBgColor,
      appBar: AppBar(
        backgroundColor: colorBlue,
        iconTheme: const IconThemeData(color: colorWhite),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Convert\n'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 28,
                        color: ui_mode == "dark" ? colorWhite : Colors.black54,
                      ),
                      children: [
                        TextSpan(
                          text: 'Your Loyalty Points'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 28,
                            color: ui_mode == "dark" ? colorWhite : colorBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colorGrey, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        userLp!.replaceAll(".00", ""),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color:
                              ui_mode == "dark" ? colorWhite : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              //! LP
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      offset: const Offset(3, 3),
                      blurRadius: 2,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: lpController,
                        style: TextStyle(
                          color:
                              ui_mode == "dark" ? colorWhite : Colors.black54,
                        ),
                        keyboardType: TextInputType.number,
                        maxLines: 1,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          filled: true,
                          alignLabelWithHint: true,
                          hintText: 'Enter loyalty points'.tr,
                          fillColor: inboxCardColor,
                          labelText: 'Loyalty Points'.tr,
                          hintStyle: TextStyle(
                            color:
                                ui_mode == "dark" ? colorWhite : Colors.black54,
                          ),
                          labelStyle: TextStyle(
                            color:
                                ui_mode == "dark" ? colorWhite : Colors.black54,
                            fontSize: 18,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: colorBlue,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(18),
                          errorMaxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Center(
                child: Image(
                  height: 50,
                  width: 50,
                  image: AssetImage('assets/down.png'),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              //! Convert money
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: inboxCardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      offset: const Offset(3, 3),
                      blurRadius: 2,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          'Money'.tr,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color:
                                ui_mode == "dark" ? colorWhite : Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Text(
                          "₹ ${calculateMoneyFromLoyaltyPoints()}",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            color: ui_mode == "dark" ? colorWhite : colorBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: colorBlue,
                  ),
                  onPressed: () => int.parse(lpController.text) >= 200
                      ? () async {
                          int amt = calculateMoneyFromLoyaltyPoints();
                          bool? result =
                              await APIServices.addLPMoney(amt.toString());
                          if (result!) {
                            if (mounted) {
                              toastshowDefaultSnackbar(
                                  context,
                                  'Money added successfully',
                                  false,
                                  primaryColor);
                            }
                            setState(() {
                              lpController.clear();
                            });
                          }
                        }
                      : showAlertDialog(),
                  child: Text(
                    'Proceed'.tr,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: ui_mode == "dark" ? colorWhite : colorBlack,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
