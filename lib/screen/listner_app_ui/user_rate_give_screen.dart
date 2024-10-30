import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:support/api/api_services.dart';
import 'package:support/main.dart';
import 'package:support/model/listner_display_model.dart';
import 'package:support/screen/listner_app_ui/listner_homescreen.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:support/utils/color.dart';
import 'package:support/utils/reuasble_widget/image.dart';

class UserRateGiveScreen extends StatefulWidget {
  final String userId;

  const UserRateGiveScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<UserRateGiveScreen> createState() => _UserRateGiveScreenState();
}

class _UserRateGiveScreenState extends State<UserRateGiveScreen> {
  ListnerDisplayModel listnerDisplayModel = ListnerDisplayModel();
  String imageUrl = "";
  String name = "";

  int selectedRating = 0;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  Future<void> getData(String id) async {
    listnerDisplayModel = await APIServices.getUserDataById(id);

    if (listnerDisplayModel.data != null) {
      imageUrl = listnerDisplayModel.data![0].image ?? "";
      name = listnerDisplayModel.data![0].name ?? "";
    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    getData(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      appBar: AppBar(
        backgroundColor: detailScreenCardColor,
        title: Text(
          'Feedback'.tr,
          style: TextStyle(
            color: ui_mode == "dark" ? colorWhite : colorBlack,
          ),
        ),
        iconTheme: IconThemeData(color: ui_mode == "dark" ? colorWhite : colorBlack),
        actions: [
          showImage(
            25,
            const AssetImage('assets/logo.png'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<void>(
              future: getData(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: colorWhite,
                          shape: BoxShape.circle,
                        ),
                        child: showImage(
                          60,
                          NetworkImage(imageUrl),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        name,
                        style: TextStyle(fontSize: 32,color: textColor),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Respect points to the User'.tr,
              style: TextStyle(fontSize: 20,color: textColor),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildRatingButton(0),
                buildRatingButton(1),
                buildRatingButton(2),
                buildRatingButton(3),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ui_mode == "dark" ? colorWhite : colorBlack
              ),
              onPressed: () async {
                if (selectedRating != -1) {
                  String? result = await APIServices.setUserRate(
                    int.parse(widget.userId),
                    selectedRating,
                  );
                  if (result != null) {
                    debugPrint('Rating submitted successfully: $result');
                    debugPrint('$selectedRating');
                    debugPrint('response $result');
                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const ListnerHomeScreen(index: 0),
                        ),
                      );
                    }
                  } else {
                    debugPrint('Error submitting rating.');
                  }
                } else {
                  debugPrint('Please select a rating before submitting.');
                }
              },
              child: Text('Submit'.tr,style: TextStyle(color: ui_mode == "dark" ? colorBlack : colorWhite)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRatingButton(int rating) {
    return ElevatedButton(
      onPressed: () async {
        setState(() {
          selectedRating = rating;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedRating == rating ? Colors.green : ui_mode == "dark" ? colorBlack : colorBlue,
      ),
      child: Text('$rating',style: TextStyle(color: textColor)),
    );
  }
}
