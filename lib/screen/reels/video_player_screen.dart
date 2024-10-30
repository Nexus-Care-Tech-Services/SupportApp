import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support/main.dart';
import 'package:support/screen/home/home_screen.dart';
import 'package:support/screen/listner_app_ui/listner_homescreen.dart';
import 'package:support/utils/color.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/model/listner_display_model.dart';
import 'package:support/sharedpreference/sharedpreference.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeControllerFuture;
  final Reference storage = FirebaseStorage.instance.ref();
  Reference? updatestorage;
  bool isFetching = true;
  String? name, url, profilePic;
  int? id, duration;
  String caption = '';
  bool isListener = false;
  bool isLoading = false;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    super.initState();
    if(Platform.isAndroid) {
      secureApp();
    }
    updatestorage =
        storage.child('Reels/${DateTime.now().millisecondsSinceEpoch}.mp4');
    initializeVideo();
    getListnerData();
    setReelUrl();
  }

  void initializeVideo() {
    _controller = VideoPlayerController.file(File(widget.videoPath));
    _initializeControllerFuture = _controller.initialize();
    _controller.setLooping(true);
  }

  Future<void> setReelUrl() async {
    File video = File(widget.videoPath);
    updatestorage!.putFile(video).then((value) async {
      String url1 = await value.ref.getDownloadURL();
      setState(() {
        url = url1;
        isFetching = false;
      });
      debugPrint("success $url");
    }, onError: (e) {
      throw (e);
    });
  }

  Future getListnerData() async {
    try {
      setState(() {
        isFetching = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      isListener = prefs.getBool("isListener")!;
      if (isListener == true) {
        ListnerDisplayModel listenermodel =
            await APIServices.getListnerDataById(
                SharedPreference.getValue(PrefConstants.MERA_USER_ID));
        name = listenermodel.data![0].name;
        id = listenermodel.data![0].id;
        profilePic = listenermodel.data![0].image;
      } else {
        ListnerDisplayModel usermodel = await APIServices.getUserDataById(
            SharedPreference.getValue(PrefConstants.MERA_USER_ID));
        name = usermodel.data![0].name;
        id = usermodel.data![0].id;
        profilePic = usermodel.data![0].image;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back, color: textColor)),
        backgroundColor: primaryColor,
        title: Text(
          'Review Reel'.tr,
          style: TextStyle(color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              setState(() {
                isFetching = true;
              });
              if (caption != "") {
                await APIServices.sendReelData(
                    id!, profilePic!, name!, url!, 15, caption);
                if (mounted) {
                  if (isListener == true) {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) =>
                              const ListnerHomeScreen(index: 0),
                        ),
                        (route) => false);
                  } else {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false);
                  }
                }
              } else {
                await APIServices.sendReelData(
                    id!, profilePic!, name!, url!, 15, "");
                if (mounted) {
                  if (isListener == true) {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) =>
                              const ListnerHomeScreen(index: 0),
                        ),
                        (route) => false);
                  } else {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false);
                  }
                }
              }
              setState(() {
                isFetching = false;
              });
            },
            child: Text(
              'POST'.tr,
              style: GoogleFonts.rakkas(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
          )
        ],
      ),
      body: isFetching
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: FutureBuilder(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          caption =
                              value; // Update the caption when text changes
                        });
                      },
                      decoration: InputDecoration(
                        fillColor: colorWhite,
                        filled: true,
                        hintText: 'Enter Caption'.tr,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: Column(
        children: [
          const Spacer(),
          FloatingActionButton(
            backgroundColor: ui_mode == "dark" ? Colors.green : primaryColor,
            onPressed: () {
              setState(() {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
              });
            },
            child: Icon(
              color: ui_mode == "dark" ? colorWhite : textColor,
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          ),
          const SizedBox(
            height: 70,
          ),
        ],
      ),
    );
  }
}
