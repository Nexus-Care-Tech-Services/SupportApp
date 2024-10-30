import 'dart:developer';
import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:support/api/api_constant.dart';

import 'package:support/api/api_services.dart';
import 'package:support/utils/color.dart';
import 'package:support/model/chat_notification.dart';
import 'package:support/model/read_notifications.dart';
import 'package:support/utils/reuasble_widget/shimmer_progress_widget.dart';

class OnlineListnerNotification extends StatefulWidget {
  const OnlineListnerNotification({Key? key}) : super(key: key);

  @override
  State<OnlineListnerNotification> createState() =>
      _OnlineListnerNotificationState();
}

class _OnlineListnerNotificationState extends State<OnlineListnerNotification> {
  bool isProgressRunning = false;
  ChatNotificationModel? chatNotificationModel;
  ReadNotificationModel? readNotificationModel;

  Future<void> apiNotifyListnerList() async {
    try {
      setState(() {
        isProgressRunning = true;
      });
      chatNotificationModel = await APIServices.getNotification();
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() {
        isProgressRunning = false;
      });
    }
  }

  Future<void> apiGetReadNotification() async {
    try {
      setState(() {
        isProgressRunning = true;
      });
      readNotificationModel = await APIServices.readNotificationApi();
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() {
        isProgressRunning = false;
      });
    }
  }

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    apiNotifyListnerList();
    apiGetReadNotification();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: textColor,
              )),
          title: Text(
            'Notification'.tr,
            style: TextStyle(fontSize: 18, color: textColor),
          ),
        ),
        body: isProgressRunning
            ? ShimmerProgressWidget(
                count: 8, isProgressRunning: isProgressRunning)
            : SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (chatNotificationModel?.allNotifications != null &&
                          chatNotificationModel!
                              .allNotifications!.isNotEmpty) ...{
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15.0, 15, 15, 8),
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: chatNotificationModel
                                      ?.allNotifications?.length ??
                                  0,
                              scrollDirection: Axis.vertical,
                              physics: const ScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Card(
                                        elevation: 3,
                                        color: cardColor,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: cardColor,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                12.0, 12, 12, 12),
                                            child: Column(
                                              children: [
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 40,
                                                            height: 40,
                                                            decoration:
                                                                BoxDecoration(
                                                                    border: Border.all(
                                                                        width:
                                                                            3,
                                                                        color:
                                                                            primaryColor),
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    image:
                                                                        DecorationImage(
                                                                      image: chatNotificationModel?.allNotifications?[index].dataImage !=
                                                                              null
                                                                          ? ExtendedNetworkImageProvider(
                                                                              "${APIConstants.BASE_URL}${chatNotificationModel?.allNotifications?[index].dataImage}",
                                                                              cache: true,
                                                                            )
                                                                          : const AssetImage('assets/logo.png')
                                                                              as ImageProvider,
                                                                    )),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Text(
                                                            chatNotificationModel
                                                                    ?.allNotifications?[
                                                                        index]
                                                                    .dataName ??
                                                                "",
                                                            style: TextStyle(
                                                                color:
                                                                    textColor,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16),
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        chatNotificationModel
                                                                ?.allNotifications?[
                                                                    index]
                                                                .dataMsg ??
                                                            "",
                                                        style: const TextStyle(
                                                            color: Colors.green,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16),
                                                      )
                                                    ]),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                );
                              }),
                        ),
                      } else ...{
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 80),
                            Center(
                              child: Text(
                                'No Notification yet'.tr,
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: 18, color: textColor),
                              ),
                            )
                          ],
                        )
                      }
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
