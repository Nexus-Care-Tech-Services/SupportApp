import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/screen/listner_app_ui/listner_homescreen.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/color.dart';
import 'package:support/utils/reuasble_widget/image.dart';

class ListnerStatusDetail extends StatefulWidget {
  const ListnerStatusDetail({Key? key}) : super(key: key);

  @override
  State<ListnerStatusDetail> createState() => _ListnerStatusDetailState();
}

class _ListnerStatusDetailState extends State<ListnerStatusDetail> {
  List<int> views = [];
  List<String> urls = [];
  List<String> ids = [];
  List<String> thumbnails = [];
  bool isLoading = false;

  void fetchDetails() async {
    try {
      setState(() {
        isLoading = true;
      });
      ids.clear();
      views.clear();
      urls.clear();

      var response = await APIServices.getStoryDetailsByListnerId(
          int.parse(SharedPreference.getValue(PrefConstants.MERA_USER_ID)));

      List<dynamic> stories = jsonDecode(response);

      if (stories.isEmpty) {
        Get.to(() => const ListnerHomeScreen(
              index: 0,
            ));
      }

      for (var story in stories) {
        setState(() {
          views.add((story['views'] as List).length);
          urls.add(story['image_url'].toString());
          thumbnails.add(story['thumbnail'].toString());
        });
      }

      List<String>? id = await APIServices.getStoryByListenerId(
          int.parse(SharedPreference.getValue(PrefConstants.MERA_USER_ID)));
      setState(() {
        ids = id!;
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(Platform.isAndroid) {
      secureApp();
    }
    fetchDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: detailScreenBgColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.arrow_back,
            color: textColor,
            size: 30,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: ids.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ListTile(
                    leading: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorBlue,
                            width: 2,
                          ),
                        ),
                        child: urls[index].contains('.mp4')
                            ? showImage(27, NetworkImage(thumbnails[index]))
                            : showImage(27, NetworkImage(urls[index]))),
                    title: Text(
                      '${views[index]} Views',
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                    trailing: InkWell(
                      onTap: () async {
                        EasyLoading.show(status: 'loading');
                        await APIServices.deleteStory(ids[index]);
                        await FirebaseStorage.instance
                            .refFromURL(urls[index])
                            .delete()
                            .whenComplete(() {
                          debugPrint("deleted successfully");
                        }).onError((error, stackTrace) {
                          debugPrint("$error $stackTrace");
                        });
                        if (urls[index].contains(".mp4")) {
                          thumbnails.removeAt(index);
                        }
                        EasyLoading.dismiss();
                        fetchDetails();
                      },
                      child: Icon(
                        Icons.delete,
                        color: textColor,
                        size: 30,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
