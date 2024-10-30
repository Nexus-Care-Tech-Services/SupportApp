// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/main.dart';
import 'package:support/utils/color.dart';
import 'package:support/model/post_model.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:support/model/listner_display_model.dart';
import 'package:support/utils/reuasble_widget/image.dart';

class CommentScreen extends StatefulWidget {
  final String postId;
  final UserPost post;

  const CommentScreen({
    Key? key,
    required this.postId,
    required this.post,
  }) : super(key: key);

  @override
  CommentScreenState createState() => CommentScreenState();
}

class CommentScreenState extends State<CommentScreen> {
  UserPost? post;
  List<String> imageurls = [];
  bool isLoading = false, isAleardyCommented = false;
  List<String> comments = [
    "Heartfelt ❤️",
    "Powerful 💥",
    "Touching 💓",
    "Inspiring 🌟",
    "Moving 😌",
    "Poignant 🌹",
    "Beautiful ✨",
    "Profound 🌊",
    "Captivating 💫",
    "Resonant 🎶"
  ];

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  Future<void> _commentPost(int userId, String postId, String content) async {
    try {
      EasyLoading.show(status: 'loading'.tr);
      await APIServices.commentOnStory(userId, postId, content);
      _fetchPosts();
      setImageUrls();
    } catch (e) {
      debugPrint('Error like post');
    }
    EasyLoading.dismiss();
    EasyLoading.showSuccess('Comment Added'.tr);
  }

  final _commentController = TextEditingController();

  Future<void> _fetchPosts() async {
    try {
      List<UserPost> postlist = await APIServices.getEmotionalStories() ?? [];
      for (int i = 0; i < postlist.length; i++) {
        if (widget.postId == postlist[i].id) {
          setState(() {
            debugPrint(postlist[i].id);
            post = postlist[i];
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
    }
  }

  void setImageUrls() async {
    setState(() {
      isLoading = true;
    });
    imageurls.clear();
    for (int j = 0; j < post!.comments.length; j++) {
      if (post!.comments[j]["type"] == "user") {
        ListnerDisplayModel model = await APIServices.getUserDataById(
            post!.comments[j]['id'].toString());
        setState(() {
          imageurls.add(model.data![0].image!);
        });
        if (post!.comments[j]['id'] ==
            int.parse(SharedPreference.getValue(PrefConstants.MERA_USER_ID))) {
          setState(() {
            isAleardyCommented = true;
          });
        }
        debugPrint(imageurls.length.toString());
      } else {
        ListnerDisplayModel model = await APIServices.getListnerDataById(
            post!.comments[j]['id'].toString());
        setState(() {
          imageurls.add(model.data![0].image!);
        });
        if (post!.comments[j]['id'] ==
            int.parse(SharedPreference.getValue(PrefConstants.MERA_USER_ID))) {
          setState(() {
            isAleardyCommented = true;
          });
        }
        debugPrint(imageurls.length.toString());
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    setState(() {
      post = widget.post;
      _commentController.text = "Write something here...";
    });
    setImageUrls();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: detailScreenCardColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: ui_mode == "dark" ? colorWhite : colorBlack,
                    size: 25,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 100,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: colorBlue,
                  ),
                ),
                const Spacer(),
              ],
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      itemCount: post!.comments.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  imageurls.isNotEmpty
                                      ? post!.comments[index]['type'] ==
                                              'listner'
                                          ? showImage(
                                              20,
                                              NetworkImage(
                                                  APIConstants.BASE_URL +
                                                      imageurls[index]),
                                            )
                                          : showImage(
                                              20,
                                              NetworkImage(
                                                imageurls[index],
                                              ),
                                            )
                                      : showIcon(0.0, colorWhite, Icons.person,
                                          20, Colors.lightBlueAccent),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${post!.comments[index]['name']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: ui_mode == "dark"
                                          ? colorWhite
                                          : colorBlack,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateFormat('dd-MM-yyyy')
                                        .format(DateTime.parse(post!.comments[index]['created_at'])),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: ui_mode == "dark"
                                          ? colorWhite
                                          : colorGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Text('${post!.comments[index]['content']}',
                                  style: TextStyle(
                                    color: ui_mode == "dark"
                                        ? colorWhite
                                        : colorBlack,
                                  )),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            isAleardyCommented
                ? Container()
                : SizedBox(
                    height: 50,
                    child: ListView.builder(
                        itemCount: comments.length,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _commentController.text = comments[index];
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: ui_mode == "dark"
                                          ? colorWhite
                                          : colorBlack)),
                              padding: const EdgeInsets.all(8),
                              alignment: Alignment.center,
                              child: Text(
                                comments[index],
                                style: TextStyle(
                                  color: ui_mode == "dark"
                                      ? colorWhite
                                      : colorBlack,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
            const SizedBox(
              height: 10,
            ),
            isAleardyCommented
                ? Container()
                : Row(
                    children: [
                      SharedPreference.getValue(PrefConstants.USER_TYPE) ==
                              "user"
                          ? showImage(
                              0.0,
                              NetworkImage(
                                SharedPreference.getValue(
                                    PrefConstants.LISTENER_IMAGE),
                              ),
                            )
                          : showImage(
                              0.0,
                              NetworkImage(
                                APIConstants.BASE_URL +
                                    SharedPreference.getValue(
                                        PrefConstants.LISTENER_IMAGE),
                              ),
                            ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color:
                                    ui_mode == "dark" ? colorWhite : colorBlue),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _commentController.text,
                            style: TextStyle(
                                color: ui_mode == "dark"
                                    ? colorWhite
                                    : colorBlack),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.send,
                          color: ui_mode == "dark" ? colorWhite : colorBlack,
                        ),
                        onPressed: () {
                          _commentPost(
                            int.parse(
                              SharedPreference.getValue(
                                  PrefConstants.MERA_USER_ID),
                            ),
                            widget.postId,
                            _commentController.text.trim(),
                          );
                          _commentController.clear();
                          setState(() {
                            isAleardyCommented = true;
                          });
                        },
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
