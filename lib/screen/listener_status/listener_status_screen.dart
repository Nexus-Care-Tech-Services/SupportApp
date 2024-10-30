// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously, unnecessary_type_check

import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/main.dart';
import 'package:support/utils/color.dart';
import 'package:support/screen/listener_status/listner_status_detail_screen.dart';
import 'package:support/screen/listener_status/other_listener_status_section.dart';
import 'package:support/screen/listener_status/status.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/reuasble_widget/image.dart';
import 'package:support/utils/reuasble_widget/toast_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:support/model/story_model.dart';

class ListenerStatusScreen extends StatefulWidget {
  const ListenerStatusScreen({super.key});

  @override
  State<ListenerStatusScreen> createState() => _ListenerStatusScreenState();
}

class _ListenerStatusScreenState extends State<ListenerStatusScreen> {
  // List<String> stories = [];
  bool isReload = false;

  File? selectedImage;
  String? imageUrl;
  String? uploadedImageUrl = "", thumbnailUrl = "", thumbnailPath = "";
  int duration = 0;
  TextEditingController captionController = TextEditingController();

  Future<void> _pickImageFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image!.path != "") {
      debugPrint("image ${image.path}");
      setState(() {
        isVideoSelected = false;
        selectedImage = File(image.path);
        debugPrint(image.path);
        duration = 5;
      });
    }
  }

  bool isVideoSelected = false;

  Future<void> _pickVideoFromGallery() async {
    try {
      final video = await ImagePicker().pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(seconds: 60));
      if (video!.path != "") {
        VideoPlayerController player =
            VideoPlayerController.file(File(video.path));
        await player.initialize();
        thumbnailPath = await VideoThumbnail.thumbnailFile(
            video: video.path, imageFormat: ImageFormat.JPEG, quality: 75);
        setState(() {
          isVideoSelected = true;
          selectedImage = File(video.path);
          debugPrint('Video path: ${video.path}');
          duration = player.value.duration.inSeconds;
          thumbnailUrl = thumbnailPath;
        });
        await player.dispose();
      }
    } catch (e) {
      debugPrint("video picked $e");
    }
  }

  //! Create story
  Future<void> createStory(BuildContext context) async {
    setState(() {
      isLoading = true;
      uploadedImageUrl = "";
    });
    try {
      if (isVideoSelected) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        fileName = "${fileName}Thumbnail.png";
        Reference ref =
            FirebaseStorage.instance.ref().child('stories').child(fileName);

        UploadTask uploadTask = ref.putFile(File(thumbnailUrl!));
        TaskSnapshot taskSnapshot = await uploadTask;
        String videothumbnail = await taskSnapshot.ref.getDownloadURL();
        setState(() {
          thumbnailUrl = videothumbnail;
        });
      }

      String? userId = SharedPreference.getValue(PrefConstants.MERA_USER_ID);
      if (userId == null) {
        throw Exception("User ID is not available!");
      }
      int listenerId = int.parse(userId);

      if (selectedImage == null) {
        throw Exception("No image selected!");
      }

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      fileName = isVideoSelected ? "$fileName.mp4" : "$fileName.png";
      UploadTask task2 = FirebaseStorage.instance
          .ref()
          .child('stories/$fileName')
          .putFile(File(selectedImage!.path));
      TaskSnapshot snapshot = await task2;
      String imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        uploadedImageUrl = imageUrl;
      });

      debugPrint(uploadedImageUrl);
      if (uploadedImageUrl != "") {
        if (captionController.text != "") {
          thumbnailUrl != ""
              ? await APIServices.createStory(listenerId, uploadedImageUrl,
                  duration, captionController.text, thumbnailUrl)
              : await APIServices.createStory(listenerId, uploadedImageUrl,
                  duration, captionController.text, "");
        } else {
          thumbnailUrl != ""
              ? await APIServices.createStory(listenerId, uploadedImageUrl,
                  duration, captionController.text, thumbnailUrl)
              : await APIServices.createStory(listenerId, uploadedImageUrl,
                  duration, captionController.text, "");
        }

        toastshowDefaultSnackbar(
            context, 'Story created successfully!'.tr, false, primaryColor);
      }
      setState(() {
        selectedImage = null;
        thumbnailUrl = "";
        thumbnailPath = "";
        uploadedImageUrl = "";
        captionController.text = "";
      });
      fetchStoryDetails();
    } catch (e) {
      debugPrint("Story $e");
      toastshowDefaultSnackbar(
          context, 'Failed to create story: $e'.tr, false, colorRed);
    }
    setState(() {
      isLoading = false;
    });
  }

  List<String> imageURLs = [];
  List<int> views = [];
  List<int> durations = [];
  List<String> captions = [];

  //! Fetch story details
  Future<void> fetchStoryDetails() async {
    setState(() {
      isLoading = true;
    });
    try {
      var response = await APIServices.getStoryDetailsByListnerId(
        int.parse(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID),
        ),
      );
      List<dynamic> stories = jsonDecode(response);
      List<String> urls = [];
      List<int> viewCounts = [];

      for (var story in stories) {
        urls.add(story['image_url'].toString());
        viewCounts.add((story['views'] as List).length);
        durations.add(story['duration']);
        captions.add(story['caption'].toString());
      }

      setState(() {
        imageURLs = urls;
        views = viewCounts;
      });
    } catch (e) {
      debugPrint("Error fetching story details: $e");
    }
    setState(() {
      isLoading = false;
    });
  }

  List<String> imageId = [];

  //! Fetch story ids
  Future<void> fetchStoryIds() async {
    try {
      var response = await APIServices.getStoryByListenerId(
        int.parse(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID),
        ),
      );

      if (response is List<String>) {
        setState(() {
          imageId = response;
        });
      } else {
        debugPrint("Unexpected response format: $response");
      }
    } catch (e) {
      debugPrint("Error fetching story IDs: $e");
    }
  }

  List<StoryModel> storyModels = [];

  Future<void> fetchStoryModels() async {
    try {
      List<StoryModel>? fetchedStoryModels = await APIServices.getAllStory();
      setState(() {
        storyModels = fetchedStoryModels!;
      });
    } catch (e) {
      debugPrint("Error fetching story models: $e");
    }
  }

  bool isLoading = true;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    super.initState();
    if(Platform.isAndroid) {
      secureApp();
    }
    Future.delayed(const Duration(seconds: 1), () {
      fetchStoryDetails();
      fetchStoryIds();
      fetchStoryModels();
    });
  }

  // Show modal bottom sheet with options
  void _showAddStatusOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Add Image Status'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Add Video Status'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideoFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      // floatingActionButton: Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     selectedImage == null
      //         ? FloatingActionButton(
      //             heroTag: 'video',
      //             backgroundColor:
      //                 ui_mode == "dark" ? Colors.green : primaryColor,
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(50),
      //             ),
      //             onPressed: () async {
      //               await _pickVideoFromGallery();
      //             },
      //             child: const Icon(Icons.video_camera_back,
      //                 size: 32, color: colorWhite),
      //           )
      //         : Container(),
      //     const SizedBox(height: 8),
      //     selectedImage == null
      //         ? FloatingActionButton(
      //             heroTag: 'image',
      //             backgroundColor:
      //                 ui_mode == "dark" ? Colors.green : primaryColor,
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(50),
      //             ),
      //             onPressed: () async {
      //               await _pickImageFromGallery();
      //             },
      //             child: const Icon(Icons.image, size: 32, color: Colors.white),
      //           )
      //         : Container(),
      //   ],
      // ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: colorBlue),
            )
          : selectedImage != null
              ? isVideoSelected
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 300,
                          margin: const EdgeInsets.fromLTRB(20, 60, 20, 80),
                          child: Image.file(File(thumbnailPath!)),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedImage = null;
                                    thumbnailPath = "";
                                    thumbnailUrl = "";
                                    captionController.text = "";
                                  });
                                },
                                child: Icon(Icons.cancel_outlined,
                                    color: textColor, size: 30)),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            children: [
                              Expanded(
                                  child: Container(
                                margin:
                                    const EdgeInsets.only(left: 10, bottom: 10),
                                padding: const EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                  color: detailScreenBgColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: TextFormField(
                                  controller: captionController,
                                  style:
                                      TextStyle(color: textColor, fontSize: 16),
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Add a caption...".tr,
                                      hintStyle: TextStyle(
                                        fontSize: 16,
                                        color: colorGrey,
                                      )),
                                ),
                              )),
                              const SizedBox(
                                width: 5,
                              ),
                              InkWell(
                                onTap: () async {
                                  if (selectedImage != null) {
                                    try {
                                      await createStory(
                                        context,
                                      );
                                    } catch (e) {
                                      debugPrint("Error creating story: $e");
                                      toastshowDefaultSnackbar(
                                          context,
                                          'Failed to create story: $e'.tr,
                                          false,
                                          colorRed);
                                    }
                                  }
                                  setState(() {
                                    selectedImage = null;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 5, bottom: 10),
                                  child: showIcon(
                                      20,
                                      colorWhite,
                                      Icons.send,
                                      25,
                                      ui_mode == "dark"
                                          ? Colors.green
                                          : primaryColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 60, 20, 60),
                          child: Image.file(File(selectedImage!.path)),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: InkWell(
                              onTap: () {
                                _cropImage();
                              },
                              child: showIcon(
                                  20,
                                  colorWhite,
                                  Icons.crop,
                                  25,
                                  ui_mode == "dark"
                                      ? Colors.green
                                      : primaryColor),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedImage = null;
                                    captionController.text = "";
                                  });
                                },
                                child: Icon(Icons.cancel_outlined,
                                    color: textColor, size: 30)),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            children: [
                              Expanded(
                                  child: Container(
                                margin:
                                    const EdgeInsets.only(left: 10, bottom: 10),
                                padding: const EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                  color: detailScreenBgColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: TextFormField(
                                  controller: captionController,
                                  style:
                                      TextStyle(color: textColor, fontSize: 16),
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Add a caption...".tr,
                                      hintStyle: TextStyle(
                                        fontSize: 16,
                                        color: colorGrey,
                                      )),
                                ),
                              )),
                              const SizedBox(
                                width: 5,
                              ),
                              InkWell(
                                onTap: () async {
                                  if (selectedImage != null) {
                                    try {
                                      await createStory(
                                        context,
                                      );
                                    } catch (e) {
                                      debugPrint("Error creating story: $e");
                                      toastshowDefaultSnackbar(
                                          context,
                                          'Failed to create story: $e'.tr,
                                          false,
                                          colorRed);
                                    }
                                  }
                                  setState(() {
                                    selectedImage = null;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 5, bottom: 10),
                                  child: showIcon(
                                      20,
                                      colorWhite,
                                      Icons.send,
                                      25,
                                      ui_mode == "dark"
                                          ? Colors.green
                                          : primaryColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => imageURLs.isNotEmpty
                            ? Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Status(
                                      captions: captions,
                                      urls: imageURLs,
                                      durations: durations,
                                      statusImageIds: imageId,
                                      views: views,
                                      onStoryDeleted: () {
                                        fetchStoryDetails();
                                        fetchStoryIds();
                                        setState(() {});
                                      },
                                    )))
                            : _showAddStatusOptions(),
                        child: imageURLs.isNotEmpty
                            ? ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: colorBlue,
                                          width: 2,
                                        ),
                                      ),
                                      child: showImage(
                                        27,
                                        NetworkImage(
                                          APIConstants.BASE_URL +
                                              SharedPreference.getValue(
                                                PrefConstants.LISTENER_IMAGE,
                                              ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: imageURLs.isNotEmpty
                                          ? Container()
                                          : showIcon(
                                              20,
                                              colorWhite,
                                              Icons.add,
                                              10,
                                              ui_mode == "dark"
                                                  ? Colors.green
                                                  : colorBlue),
                                    ),
                                  ],
                                ),
                                title: Text(
                                  'My Status'.tr,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                subtitle: Text(
                                  imageURLs.isNotEmpty
                                      ? 'Tap to view status'.tr
                                      : 'Tap to add status'.tr,
                                  style: TextStyle(
                                    color: colorGrey,
                                  ),
                                ),
                                trailing: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ListnerStatusDetail()));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.more_horiz,
                                      color: textColor,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              )
                            : ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: colorBlue,
                                          width: 2,
                                        ),
                                      ),
                                      child: showImage(
                                        27,
                                        NetworkImage(
                                          APIConstants.BASE_URL +
                                              SharedPreference.getValue(
                                                PrefConstants.LISTENER_IMAGE,
                                              ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: imageURLs.isNotEmpty
                                          ? Container()
                                          : showIcon(
                                              20,
                                              colorWhite,
                                              Icons.add,
                                              10,
                                              ui_mode == "dark"
                                                  ? Colors.green
                                                  : colorBlue),
                                    ),
                                  ],
                                ),
                                title: Text(
                                  'My Status'.tr,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                subtitle: Text(
                                  imageURLs.isNotEmpty
                                      ? 'Tap to view status'.tr
                                      : 'Tap to add status'.tr,
                                  style: TextStyle(
                                    color: colorGrey,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Recent updates'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: storyModels.length,
                          itemBuilder: (context, index) {
                            return Visibility(
                              visible: storyModels[index].listenerId !=
                                  int.parse(SharedPreference.getValue(
                                      PrefConstants.MERA_USER_ID)),
                              child: InkWell(
                                onTap: () {
                                  storyModels.removeWhere((element) =>
                                      element.listenerId ==
                                      int.parse(SharedPreference.getValue(
                                          PrefConstants.MERA_USER_ID)));
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          OthersListenerStatusSection(
                                              model: storyModels[index],
                                              list: storyModels)));
                                },
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
                                      color: colorGrey,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Future _cropImage() async {
    if (selectedImage != null) {
      CroppedFile? cropped = await ImageCropper()
          .cropImage(sourcePath: selectedImage!.path, aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ], uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop',
            cropGridColor: colorBlack,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(title: 'Crop')
      ]);

      if (cropped != null) {
        setState(() {
          selectedImage = File(cropped.path);
        });
      }
    }
  }
}
