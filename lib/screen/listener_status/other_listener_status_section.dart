// ignore_for_file: public_member_api_docs, sort_constructors_first, unnecessary_type_check
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:story_view/story_view.dart';
import 'package:support/sharedpreference/sharedpreference.dart';

import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/model/story_model.dart';
import 'package:support/utils/color.dart';
import 'package:support/utils/reuasble_widget/image.dart';

class OthersListenerStatusSection extends StatefulWidget {
  final StoryModel model;
  final List<StoryModel> list;

  const OthersListenerStatusSection(
      {Key? key, required this.model, required this.list})
      : super(key: key);

  @override
  State<OthersListenerStatusSection> createState() =>
      _OthersListenerStatusSectionState();
}

class _OthersListenerStatusSectionState
    extends State<OthersListenerStatusSection> {
  PageController? controller;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(Platform.isAndroid) {
      secureApp();
    }

    final initialPage = widget.list.indexOf(widget.model);
    controller = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: controller,
      children: widget.list
          .map((e) => OtherListenerStatus(
                storyModel: e,
                pageController: controller!,
                list: widget.list,
              ))
          .toList(),
    );
  }
}

class OtherListenerStatus extends StatefulWidget {
  const OtherListenerStatus({
    Key? key,
    required this.storyModel,
    required this.pageController,
    required this.list,
  }) : super(key: key);
  final StoryModel storyModel;
  final PageController pageController;
  final List<StoryModel> list;

  @override
  State<OtherListenerStatus> createState() => _OtherListenerStatusState();
}

class _OtherListenerStatusState extends State<OtherListenerStatus> {
  List<StoryItem?> storyItems = [];
  final controller = StoryController();

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    super.initState();
    secureApp();
    storyItems.clear();
    if (widget.storyModel.listenerId !=
        int.parse(SharedPreference.getValue(PrefConstants.MERA_USER_ID))) {
      for (int i = 0; i < widget.storyModel.imageURLs.length; i++) {
        if (widget.storyModel.imageURLs[i].contains(".mp4")) {
          setState(() {
            storyItems.add(StoryItem.pageVideo(widget.storyModel.imageURLs[i],
                controller: controller,
                caption: widget.storyModel.captions[i],
                duration: Duration(seconds: widget.storyModel.duration[i])));
          });
        } else {
          setState(() {
            storyItems.add(StoryItem.pageImage(
                url: widget.storyModel.imageURLs[i],
                controller: controller,
                caption: widget.storyModel.captions[i],
                duration: Duration(seconds: widget.storyModel.duration[i])));
          });
        }
      }

      fetchStoryIds();
    }
  }

  List<String> imageIds = [];

  //! Fetch story ids
  Future<void> fetchStoryIds() async {
    try {
      var response = await APIServices.getStoryByListenerId(
        widget.storyModel.listenerId,
      );

      if (response is List<String>) {
        setState(() {
          imageIds = response;
        });
      } else {
        debugPrint("Unexpected response format: $response");
      }
    } catch (e) {
      debugPrint("Error fetching story IDs: $e");
    }
  }

  void handleCompleted() {
    widget.pageController
        .nextPage(duration: const Duration(seconds: 1), curve: Curves.easeIn);

    final current = widget.list.indexOf(widget.storyModel);
    final isLast = widget.list.length - 1 == current;
    if (isLast) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBlack,
      body: Material(
        color: colorBlack,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, color: colorWhite),
                  ),
                  const SizedBox(width: 8),
                  showImage(
                    24,
                    NetworkImage(
                      APIConstants.BASE_URL + widget.storyModel.listenerImage,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.storyModel.listenerName,
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
                child: StatefulBuilder(
                  builder: (context, setState) => StoryView(
                    storyItems: storyItems,
                    controller: controller,
                    onVerticalSwipeComplete: (direction) {
                      if (direction == Direction.down) {
                        Navigator.of(context).pop();
                      }
                    },
                    onStoryShow: (value) async {},
                    repeat: false,
                    onComplete: () async {
                      // Navigator.of(context).pop();
                      for (String storyId in imageIds) {
                        await APIServices().viewStory(
                          storyId,
                          int.parse(
                            SharedPreference.getValue(
                                PrefConstants.MERA_USER_ID),
                          ),
                        );
                        handleCompleted();
                      }
                    },
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
