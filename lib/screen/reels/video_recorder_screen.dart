import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/main.dart';
import 'package:support/screen/home/home_screen.dart';
import 'package:support/screen/listner_app_ui/listner_homescreen.dart';
import 'package:support/screen/reels/video_player_screen.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/color.dart';
import 'package:video_player/video_player.dart';

class VideoRecorderScreen extends StatefulWidget {
  const VideoRecorderScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VideoRecorderScreenState createState() => _VideoRecorderScreenState();
}

class _VideoRecorderScreenState extends State<VideoRecorderScreen> {
  CameraController? _controller;
  List<CameraDescription> cameras = [];
  bool isRecording = false;
  late String videoPath = '';
  bool isFrontCamera = false;
  bool isLoading = true;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    super.initState();
    if(Platform.isAndroid) {
      secureApp();
    }
    setupCamera();
  }

  Future<void> setupCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    await _controller!.initialize();
    isLoading = false;
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> switchCamera() async {
    if (cameras.length < 2) {
      return;
    }
    CameraDescription newCameraDescription =
        isFrontCamera ? cameras[0] : cameras[1];
    if (_controller != null) {
      await _controller!.dispose();
    }
    _controller = CameraController(newCameraDescription, ResolutionPreset.high);
    await _controller!.initialize();
    setState(() {
      isFrontCamera = !isFrontCamera;
    });
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  Future<void> startVideoRecording() async {
    if (!_controller!.value.isInitialized) {
      return;
    }

    try {
      await _controller!.startVideoRecording();
      setState(() {
        isRecording = true;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> stopVideoRecording() async {
    try {
      var filePath = await _controller!.stopVideoRecording();
      videoPath = filePath.path;
      if (!_controller!.value.isRecordingVideo) {
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Video Recorded'.tr),
              content: Text('Video Captured, Click Next to upload!'.tr),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'.tr),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              VideoPlayerScreen(videoPath: videoPath),
                        ));
                  },
                  child: Text('Next'.tr),
                ),
              ],
            );
          },
        );
      }

      setState(() {
        isRecording = false;
      });
      return;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _onRecordButtonPressed() {
    if (isRecording) {
      stopVideoRecording();
    } else {
      startVideoRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (SharedPreference.getValue(PrefConstants.USER_TYPE) == "user") {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomeScreen()));
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const ListnerHomeScreen(index: 2)));
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: cardColor,
        appBar: AppBar(
          leading: InkWell(
              onTap: () {
                if (SharedPreference.getValue(PrefConstants.USER_TYPE) ==
                    "user") {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()));
                } else {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const ListnerHomeScreen(index: 2)));
                }
              },
              child: Icon(Icons.arrow_back, color: textColor)),
          backgroundColor: primaryColor,
          title: Text('Video Recorder'.tr, style: TextStyle(color: textColor)),
        ),
        body: _controller == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: <Widget>[
                  Expanded(
                    child: CameraPreview(_controller!),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FloatingActionButton(
                        backgroundColor:
                            ui_mode == "dark" ? Colors.green : primaryColor,
                        onPressed: _onRecordButtonPressed,
                        child: Icon(
                          color: ui_mode == "dark" ? colorWhite : textColor,
                          isRecording ? Icons.stop : Icons.fiber_manual_record,
                        ),
                      ),
                      IconButton(
                        onPressed: switchCamera,
                        icon: const Icon(Icons.switch_camera),
                        color: ui_mode == "dark" ? colorWhite : colorBlack,
                      ),
                      IconButton(
                          onPressed: () async {
                            final video = await ImagePicker().pickVideo(
                                source: ImageSource.gallery,
                                maxDuration: const Duration(seconds: 60));
                            setState(() {
                              videoPath = video!.path;
                              isRecording = false;
                            });
                            if (videoPath != '') {
                              if (context.mounted) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VideoPlayerScreen(
                                          videoPath: videoPath),
                                    ));
                              }
                            }
                            return;
                          },
                          icon: Icon(
                            Icons.video_camera_back,
                            color: ui_mode == "dark" ? colorWhite : colorBlack,
                          ))
                    ],
                  ),
                  const SizedBox(height: 20),
                  // ignore: unnecessary_null_comparison
                  if (videoPath != null)
                    VideoPlayer(
                      VideoPlayerController.file(File(videoPath)),
                    ),
                ],
              ),
      ),
    );
  }
}
