// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:story_view/story_view.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/color.dart';
import 'package:support/utils/reuasble_widget/image.dart';

class Status extends StatefulWidget {
  const Status({
    Key? key,
    required this.urls,
    required this.views,
    required this.statusImageIds,
    required this.onStoryDeleted,
    required this.durations,
    required this.captions,
  }) : super(key: key);

  final List<String> urls;
  final List<int> views;
  final List<String> statusImageIds;
  final List<String> captions;
  final VoidCallback onStoryDeleted;
  final List<int> durations;

  @override
  State<Status> createState() => _StatusState();
}

class _StatusState extends State<Status> {
  int currentPage = 0;
  String currentStoryId = '';
  final controller = StoryController();
  bool isLoading = false;
  String currentStoryUrl = '';

  late List<StoryItem?> storyItems = [];
  late Timer timer;
  List<int> views = [];

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  void loadData() async {
    storyItems.clear();
    for (int i = 0; i < widget.urls.length; i++) {
      if (widget.urls[i].contains('.mp4')) {
        setState(() {
          storyItems.add(StoryItem.pageVideo(widget.urls[i],
              controller: controller,
              caption: widget.captions[i],
              duration: Duration(seconds: widget.durations[i])));
        });
      } else {
        setState(() {
          storyItems.add(StoryItem.pageImage(
              url: widget.urls[i],
              controller: controller,
              caption: widget.captions[i],
              duration: Duration(seconds: widget.durations[i])));
        });
      }
      views.add(widget.views[i]);
    }
    debugPrint(widget.durations[2].toString());
  }

  @override
  void initState() {
    super.initState();
    if(Platform.isAndroid) {
      secureApp();
    }
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBlack,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: colorBlue),
            )
          : Material(
              type: MaterialType.transparency,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child:
                              const Icon(Icons.arrow_back, color: colorWhite),
                        ),
                        const SizedBox(width: 8),
                        showImage(
                          24,
                          NetworkImage(
                            APIConstants.BASE_URL +
                                SharedPreference.getValue(
                                  PrefConstants.LISTENER_IMAGE,
                                ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                SharedPreference.getValue(
                                    PrefConstants.LISTENER_NAME),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          StatefulBuilder(
                            builder: (context, index) => StoryView(
                              storyItems: storyItems,
                              controller: controller,
                              onStoryShow: (
                                value,
                              ) async {
                                int? currentStoryIndex =
                                    storyItems.indexOf(value);
                                setState(() {
                                  currentPage = currentStoryIndex;
                                });
                                debugPrint('current page: $currentPage');
                                currentStoryId =
                                    widget.statusImageIds[currentStoryIndex];
                                await APIServices().viewStory(
                                    currentStoryId,
                                    int.parse(SharedPreference.getValue(
                                        PrefConstants.MERA_USER_ID)));
                              },
                              repeat: true,
                              onComplete: () async {
                                Navigator.of(context).pop();
                                for (String storyId in widget.statusImageIds) {
                                  await APIServices().viewStory(
                                    storyId,
                                    int.parse(
                                      SharedPreference.getValue(
                                          PrefConstants.MERA_USER_ID),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          SharedPreference.getValue(PrefConstants.USER_TYPE) !=
                                  'user'
                              ? Positioned(
                                  bottom: 60,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.remove_red_eye,
                                          color: colorWhite),
                                      const SizedBox(width: 5),
                                      Text(
                                        "${widget.views[currentPage]}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: colorWhite,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
