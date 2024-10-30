import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/utils/color.dart';
import 'package:support/model/missed_data_model.dart';
import 'package:support/screen/listner_app_ui/profile/missed_details_screen.dart';
import 'package:support/sharedpreference/sharedpreference.dart';

class MissedDataScreen extends StatefulWidget {
  const MissedDataScreen({Key? key}) : super(key: key);

  @override
  State<MissedDataScreen> createState() => _MissedDataScreenState();
}

class _MissedDataScreenState extends State<MissedDataScreen> {
  String? missedcall = "0", missedchats = "0", missedvideocall = "0";
  int chat = 0, call = 0, vc = 0;

  Future getMissedData() async {
    try {
      List<MissedDataModel> data = await APIServices.getListnerMissedData(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID));
      for (int i = 0; i < data.length; i++) {
        if (data[i].type == "chat") {
          chat += 1;
        }
        if (data[i].type == "call") {
          call += 1;
        }
        if (data[i].type == "video") {
          vc += 1;
        }
      }
      setState(() {
        missedcall = call.toString();
        missedchats = chat.toString();
        missedvideocall = vc.toString();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(Platform.isAndroid) {
      secureApp();
    }
    getMissedData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: cardColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: colorWhite,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: primaryColor,
          centerTitle: true,
          title: Text(
            'Missed Data'.tr,
            style: const TextStyle(color: colorWhite),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Column(
            children: [
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const MissedDetailScreen(type: 'call')));
                        },
                        child: Text(
                          'Missed Calls'.tr,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 65,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const MissedDetailScreen(type: 'chat')));
                        },
                        child: Text(
                          'Missed Chats'.tr,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 65,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const MissedDetailScreen(type: 'video')));
                        },
                        child: Text(
                          'Missed Video Calls'.tr,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const MissedDetailScreen(type: 'call')));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: textColor, width: 1),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.center,
                          child: Text(
                            missedcall!,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const MissedDetailScreen(type: 'chat')));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: textColor, width: 1),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.center,
                          child: Text(
                            missedchats!,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const MissedDetailScreen(type: 'video')));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: textColor, width: 1),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.center,
                          child: Text(
                            missedvideocall!,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
