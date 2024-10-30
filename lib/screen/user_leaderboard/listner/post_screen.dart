import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/main.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/color.dart';
import 'package:support/utils/reuasble_widget/toast_widget.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => PostScreenState();
}

class PostScreenState extends State<PostScreen> {
  final postController = TextEditingController();
  final _focusNode = FocusNode();

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }

    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    postController.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: detailScreenBgColor,
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              ui_mode == "dark" ? colorBlack : const Color(0xffF5FAFF),
              const Color(0xff128AF8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => Share.share(
                      'https://play.google.com/store/apps/details?id=com.support2heal.app',
                      subject: 'Share your emotional stories with others.',
                    ),
                    child: Icon(Icons.share,
                        color: ui_mode == "dark" ? colorWhite : colorBlack),
                  ),
                ],
              ),
              //! Title
              RichText(
                text: TextSpan(
                  text: 'Your\'s\n'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: ui_mode == "dark" ? colorWhite : colorBlack,
                  ),
                  children: [
                    TextSpan(
                      text: 'Emotional Journey\n'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: ui_mode == "dark" ? colorWhite : colorBlack,
                      ),
                    ),
                    TextSpan(
                      text: '20 Rs bonus if your story gets verified'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: ui_mode == "dark" ? colorWhite : colorGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              //! Use name and image
              Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: Image(
                      image: NetworkImage(
                        SharedPreference.getValue(
                          PrefConstants.USER_IMAGE,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    SharedPreference.getValue(
                      PrefConstants.USER_NAME,
                    ),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: ui_mode == "dark" ? colorWhite : colorBlack,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: postController,
                style: TextStyle(
                  color: ui_mode == "dark" ? colorWhite : colorBlack,
                ),
                maxLength: 500,
                maxLines: 8,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Write your\'s emotional journey...'.tr,
                  hintStyle: TextStyle(
                    color: ui_mode == "dark" ? colorWhite : colorBlack,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorGrey.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorBlue,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onEditingComplete: () {},
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      String userId =
                          SharedPreference.getValue(PrefConstants.MERA_USER_ID);
                      String content = postController.text.trim();

                      if (userId.isNotEmpty && content.isNotEmpty) {
                        String? result = await APIServices.createEmotionalStory(
                          int.parse(userId),
                          content,
                          "happy",
                          "wow",
                        );

                        debugPrint('Create Story Result: $result');

                        if (result != null) {
                          if (context.mounted) {
                            toastshowDefaultSnackbar(
                                context,
                                'Post created successfully!'.tr,
                                false,
                                primaryColor);
                          }
                          postController.clear();
                        } else {
                          if (context.mounted) {
                            toastshowDefaultSnackbar(
                                context,
                                'Something went wrong in the server!'.tr,
                                false,
                                colorRed);
                          }
                          postController.clear();
                        }
                      } else {
                        debugPrint('User ID or content is empty');
                      }
                    } catch (e) {
                      debugPrint('Error: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Submit'.tr,
                    style: const TextStyle(
                      color: colorWhite,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
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
