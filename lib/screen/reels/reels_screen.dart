import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support/api/api_services.dart';
import 'package:support/model/reel_model.dart';
import 'package:support/screen/reels/video_recorder_screen.dart';
import 'package:support/screen/reels/video_tile.dart';
import 'package:support/utils/color.dart';

class ReelScreen extends StatefulWidget {
  final String? listenerId;
  final int? selectedIndex;

  const ReelScreen({super.key, this.listenerId, this.selectedIndex});

  @override
  State<ReelScreen> createState() => _ReelScreenState();
}

class _ReelScreenState extends State<ReelScreen> {
  final List<String> videos = [];
  bool isListener = false;
  ReelModel? reelData;
  bool isFetching = true;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    super.initState();
    if(Platform.isAndroid) {
      secureApp();
    }
    checkListener();
    setReelData();
  }

  setReelData() async {
    var reels = await APIServices.fetchReelData(
      listnerId: widget.listenerId,
      filterReel: widget.listenerId == null ? false : true,
    );
    debugPrint('##$reels');
    debugPrint('##${widget.selectedIndex}');
    setState(() {
      reelData = reels;
      isFetching = false;
    });
  }

  checkListener() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isListener = prefs.getBool("isListener")!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBlack,
      body: isFetching
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Stack(
                children: [
                  //We need swiper for every content
                  reelData!.data!.isEmpty
                      ? Center(
                          child: Text(
                            'No Reels Present'.tr,
                            style: const TextStyle(
                              color: colorWhite,
                            ),
                          ),
                        )
                      : Swiper(
                          scrollDirection: Axis.vertical,
                          itemCount: reelData!.data!.length,
                          itemBuilder: (context, index) {
                            return VideoTile(
                              video: reelData!.data![index].reelUrl.toString(),
                              data: reelData!,
                              currentIndex: index,
                            );
                          }),
                  Positioned(
                    top: -15,
                    left: 5,
                    child: Image.asset('assets/images/Image.png',height: 80,width: 80,),),
                  Positioned(
                    top: -5,
                    right: -5,
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        color: colorWhite,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                const VideoRecorderScreen()));
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
