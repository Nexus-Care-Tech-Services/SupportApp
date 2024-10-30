import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/utils/color.dart';
import 'package:support/main.dart';
import 'package:support/model/support_chat_model.dart';
import 'package:support/screen/listener_status/other_listener_status_section.dart';
import 'package:support/screen/support_chat/support_chat.dart';
import 'package:support/sharedpreference/sharedpreference.dart';

import 'package:support/api/api_services.dart';
import 'package:support/model/story_model.dart';
import 'package:support/utils/reuasble_widget/image.dart';

class UserStatusScreen extends StatefulWidget {
  const UserStatusScreen({super.key});

  @override
  State<UserStatusScreen> createState() => _UserStatusScreenState();
}

class _UserStatusScreenState extends State<UserStatusScreen> {
  List<StoryModel> storyModels = [];
  bool isLoading = true;
  SupportChatModel? supportChatModel;

  Future<void> fetchStoryModels() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<StoryModel>? fetchedStoryModels = await APIServices.getAllStory();
      setState(() {
        storyModels = fetchedStoryModels!;
      });
    } catch (e) {
      debugPrint("Error fetching story models: $e");
    }
    setState(() {
      isLoading = false;
    });
  }

  // Support Chat
  Future<void> apiSupportChat() async {
    try {
      setState(() {
        isLoading = true;
      });

      supportChatModel = await APIServices.getSupportChatAPI(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID));
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
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
    apiSupportChat();
    Future.delayed(const Duration(seconds: 1), () {
      fetchStoryModels();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: colorBlue),
            )
          : Column(
              children: [
                if (supportChatModel != null) ...{
                  if (supportChatModel!.allMessages!.isNotEmpty) ...{
                    const SizedBox(height: 25),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: ui_mode == "dark"
                                ? Colors.transparent
                                : const Color.fromARGB(255, 49, 49, 49)
                                    .withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SupportChat(
                                    supportChatModel: supportChatModel,
                                  )));
                        },
                        title: Text(
                          'Support'.tr,
                          style: TextStyle(color: textColor),
                        ),
                        subtitle: Text(
                          supportChatModel?.allMessages?[0].title ?? "",
                          style: TextStyle(
                            color: colorGrey,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        leading: Image.asset(
                          "assets/logo.png",
                          // width: 100,
                          height: 80,
                        ),
                        trailing: Visibility(
                          visible: supportChatModel?.unreadMessages != 0
                              ? true
                              : false,
                          child: Container(
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                  color: ui_mode == "dark"
                                      ? Colors.transparent
                                      : Colors.grey.shade300,
                                  blurRadius: 10.0,
                                  spreadRadius: 5.0),
                            ], shape: BoxShape.circle, color: Colors.green),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                supportChatModel?.unreadMessages.toString() ??
                                    "0",
                                style: TextStyle(color: textColor),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  },
                },
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: storyModels.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      OthersListenerStatusSection(
                                          model: storyModels[index],
                                          list: storyModels))),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: DottedBorder(
                              borderType: BorderType.Circle,
                              radius: const Radius.circular(12),
                              color: colorBlue,
                              strokeCap: StrokeCap.round,
                              strokeWidth: 3,
                              dashPattern: const [1, 0],
                              child: showImage(
                                27,
                                NetworkImage(
                                  APIConstants.BASE_URL +
                                      storyModels[index].listenerImage,
                                ),
                              ),
                            ),
                            title: Text(
                              storyModels[index].listenerName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            subtitle: Text(
                              '${storyModels[index].count} stories',
                              style: TextStyle(
                                color:
                                    ui_mode == "dark" ? colorWhite : colorGrey,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
