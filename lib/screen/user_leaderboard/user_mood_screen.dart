import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:support/main.dart';
import 'package:support/model/listner_display_model.dart';
import 'package:support/model/mood_selection_model.dart';
import 'package:support/model/moods_model.dart';
import 'package:support/screen/home/helper_detail_screen.dart';
import 'package:support/screen/user_leaderboard/loyalty_points_screen.dart';

import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/color.dart';
import 'package:support/utils/reuasble_widget/image.dart';

class UserMoodScreen extends StatefulWidget {
  const UserMoodScreen({super.key});

  @override
  State<UserMoodScreen> createState() => _UserMoodScreenState();
}

class _UserMoodScreenState extends State<UserMoodScreen> {
  String selectedEmoji =
      'assets/mood/${SharedPreference.getValue(PrefConstants.INTEREST).toString().toLowerCase()}.png';
  String? currentRp = "0";
  MoodsModel? model;
  String selectedMood = '', todayMood = '';
  List<String>? names = [];
  List<String>? images = [];
  List<int>? ids = [];
  bool isLoading = false;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  String _getEmojiName(String path) {
    String mood = path.split('/').last.split('.').first;
    debugPrint("Selected Emoji: $path");
    debugPrint("Extracted Mood: $mood");
    return mood.substring(0, 1).toUpperCase() + mood.substring(1).toLowerCase();
  }

  Future<void> _showInfoDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text('Loyalty Points (LP)'.tr,
              style: TextStyle(
                  color: ui_mode == "dark" ? colorWhite : colorBlack)),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                  '♦️You will get 2 LP on a Single day'.tr,
                  style: TextStyle(
                    color: ui_mode == "dark" ? colorWhite : colorGrey,
                  ),
                ),
                Text(
                  '♦5 LP will be equal to 1 Rs'.tr,
                  style: TextStyle(
                    color: ui_mode == "dark" ? colorWhite : colorGrey,
                  ),
                ),
                Text(
                  '♦Failed to use one day will reduce 2 LP from your total points'
                      .tr,
                  style: TextStyle(
                    color: ui_mode == "dark" ? colorWhite : colorGrey,
                  ),
                ),
                Text(
                  '♦200 LP will be the minimum point for initiating to wallet conversion'
                      .tr,
                  style: TextStyle(
                    color: ui_mode == "dark" ? colorWhite : colorGrey,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Ok'.tr,
                  style: TextStyle(
                      color: ui_mode == "dark" ? colorWhite : colorBlack)),
            ),
          ],
        );
      },
    );
  }

  void _showMoodSelectionModal(BuildContext context) async {
    showModalBottomSheet(
      backgroundColor: detailScreenCardColor,
      context: context,
      builder: (BuildContext context) {
        return MoodSelectionModal(
          onEmojiSelected: (String emoji) async {
            debugPrint('Selected Emoji: $emoji');
            setState(() {
              selectedEmoji = emoji;
            });
            Navigator.pop(context);
            String? message = await APIServices.setUserMood(
              SharedPreference.getValue(PrefConstants.MERA_USER_ID),
              _getEmojiName(emoji),
            );

            if (message != null) {
              SharedPreference.setValue(
                  PrefConstants.INTEREST, _getEmojiName(emoji));
              debugPrint("Mood set successfully: $message");
              setState(() {
                selectedMood = selectedEmoji.split('/').last.split('.').first;
                todayMood = selectedMood.substring(0, 1).toUpperCase() +
                    selectedMood.substring(1).toLowerCase();
                fetchData();
              });
            } else {
              debugPrint("Error setting mood: Unknown error");
            }
          },
        );
      },
    );
  }

  void fetchData() async {
    setState(() {
      isLoading = true;
    });
    ids!.clear();
    names!.clear();
    images!.clear();
    if (model != null) {
      if (selectedMood == "happy") {
        for (int i = 0; i < model!.modes!.happy!.length; i++) {
          ids!.add(model!.modes!.happy![i]);
        }
      } else if (selectedMood == "angry") {
        for (int i = 0; i < model!.modes!.angry!.length; i++) {
          ids!.add(model!.modes!.angry![i]);
        }
      } else if (selectedMood == "bored") {
        for (int i = 0; i < model!.modes!.bored!.length; i++) {
          ids!.add(model!.modes!.bored![i]);
        }
      } else if (selectedMood == "disappointed") {
        for (int i = 0; i < model!.modes!.disappointed!.length; i++) {
          ids!.add(model!.modes!.disappointed![i]);
        }
      } else if (selectedMood == "embarassed") {
        for (int i = 0; i < model!.modes!.embarassed!.length; i++) {
          ids!.add(model!.modes!.embarassed![i]);
        }
      } else if (selectedMood == "excited") {
        for (int i = 0; i < model!.modes!.excited!.length; i++) {
          ids!.add(model!.modes!.excited![i]);
        }
      } else if (selectedMood == "hungry") {
        for (int i = 0; i < model!.modes!.hungry!.length; i++) {
          ids!.add(model!.modes!.hungry![i]);
        }
      } else if (selectedMood == "lonely") {
        for (int i = 0; i < model!.modes!.lonely!.length; i++) {
          ids!.add(model!.modes!.lonely![i]);
        }
      } else if (selectedMood == "hurt") {
        for (int i = 0; i < model!.modes!.hurt!.length; i++) {
          ids!.add(model!.modes!.hurt![i]);
        }
      } else if (selectedMood == "nervous") {
        for (int i = 0; i < model!.modes!.nervous!.length; i++) {
          ids!.add(model!.modes!.nervous![i]);
        }
      } else if (selectedMood == "proud") {
        for (int i = 0; i < model!.modes!.proud!.length; i++) {
          ids!.add(model!.modes!.proud![i]);
        }
      } else if (selectedMood == "relaxed") {
        for (int i = 0; i < model!.modes!.relaxed!.length; i++) {
          ids!.add(model!.modes!.relaxed![i]);
        }
      } else if (selectedMood == "scared") {
        for (int i = 0; i < model!.modes!.scared!.length; i++) {
          ids!.add(model!.modes!.scared![i]);
        }
      } else if (selectedMood == "sick") {
        for (int i = 0; i < model!.modes!.sick!.length; i++) {
          ids!.add(model!.modes!.sick![i]);
        }
      } else if (selectedMood == "silly") {
        for (int i = 0; i < model!.modes!.silly!.length; i++) {
          ids!.add(model!.modes!.silly![i]);
        }
      } else if (selectedMood == "stressed") {
        for (int i = 0; i < model!.modes!.stressed!.length; i++) {
          ids!.add(model!.modes!.stressed![i]);
        }
      } else if (selectedMood == "surprised") {
        for (int i = 0; i < model!.modes!.surprised!.length; i++) {
          ids!.add(model!.modes!.surprised![i]);
        }
      } else if (selectedMood == "tired") {
        for (int i = 0; i < model!.modes!.tired!.length; i++) {
          ids!.add(model!.modes!.tired![i]);
        }
      } else if (selectedMood == "upset") {
        for (int i = 0; i < model!.modes!.upset!.length; i++) {
          ids!.add(model!.modes!.upset![i]);
        }
      } else if (selectedMood == "worried") {
        for (int i = 0; i < model!.modes!.worried!.length; i++) {
          ids!.add(model!.modes!.worried![i]);
        }
      }
      for (int i = 0; i < ids!.length; i++) {
        ListnerDisplayModel listnerDisplayModel =
            await APIServices.getListnerDataById(ids![i].toString());
        if (ids!.isNotEmpty) {
          names!.add(listnerDisplayModel.data![0].name!);
          images!.add(listnerDisplayModel.data![0].image!);
          setState(() {});
        }
      }
      debugPrint("${names!.length} ${ids!.length} ${images!.length}");
    }
    setState(() {
      isLoading = false;
    });
  }

  void fetchAPIData() async {
    MoodsModel? moodmodel = await APIServices.getListnersMoods();
    setState(() {
      model = moodmodel;
    });
    if (model != null) {
      fetchData();
    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    setState(() {
      selectedMood = selectedEmoji.split('/').last.split('.').first;
      todayMood = selectedMood.substring(0, 1).toUpperCase() +
          selectedMood.substring(1).toLowerCase();
    });
    _checkAndUpdateMood();
    fetchAPIData();
  }

  Future<void> _checkAndUpdateMood() async {
    String? id = SharedPreference.getValue(PrefConstants.MERA_USER_ID);

    String? storedTimestampString =
        SharedPreference.getValue(PrefConstants.LAST_UPDATE_TIMESTAMP);

    DateTime storedTimestamp = DateTime.parse(storedTimestampString!);

    Duration difference = DateTime.now().difference(storedTimestamp);
    int daysDifference = difference.inDays;

    if (daysDifference == 1) {
      debugPrint("Difference is 1 day. Updating mood and calling API...");
      SharedPreference.setValue(
        PrefConstants.LAST_UPDATE_TIMESTAMP,
        DateTime.now().toIso8601String(),
      );

      _callYourApi(int.parse(id!), 2);
    } else if (daysDifference >= 2) {
      _callYourApi(int.parse(id!), -2);
    } else {
      debugPrint("No need to update the mood today.");
    }
  }

  void _callYourApi(int id, int lp) async {
    String? message = await APIServices.setUserLp(id, lp);

    if (message != null) {
      debugPrint("API call successful: $message");
    } else {
      debugPrint("Error calling API: Unknown error");
    }
  }

  Future<String> getUserRp(String id) async {
    ListnerDisplayModel user = await APIServices.getUserDataById(id);

    if (user.data != null) {
      String? userRp = user.data![0].language!.split(',').first.trim();
      return userRp;
    } else {
      return "User data not available";
    }
  }

  Future<String> getUserLp(String id) async {
    ListnerDisplayModel user = await APIServices.getUserDataById(id);
    if (user.data != null) {
      String? userLp = user.data![0].charge!.trim();
      return userLp;
    } else {
      return "User data not available";
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Today mood $todayMood');
    return Scaffold(
      backgroundColor: detailScreenBgColor,
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
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              height: 60,
              decoration: BoxDecoration(
                color: colorBlue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  showImage(
                    25,
                    NetworkImage(
                      SharedPreference.getValue(
                        PrefConstants.USER_IMAGE,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        SharedPreference.getValue(
                          PrefConstants.USER_NAME,
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colorWhite,
                        ),
                      ),
                      FutureBuilder<String>(
                        future: getUserRp(SharedPreference.getValue(
                            PrefConstants.MERA_USER_ID)),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text('Loading...'.tr);
                          } else if (snapshot.hasError) {
                            return Container();
                          } else {
                            String userRp = snapshot.data ?? '';
                            return Text(
                              '$userRp RP',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: colorWhite,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoyaltyPointsScreen())),
                    child: FutureBuilder<String>(
                      future: getUserLp(SharedPreference.getValue(
                          PrefConstants.MERA_USER_ID)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            'Loading...'.tr,
                          );
                        } else if (snapshot.hasError) {
                          return Container();
                        } else {
                          String userLp = snapshot.data ?? '';
                          return Row(
                            children: [
                              Text(
                                '${userLp.replaceAll('.00', '')} LP',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: colorWhite,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _showInfoDialog(),
                                icon: const Icon(
                                  Icons.info_outline_rounded,
                                  color: colorWhite,
                                ),
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                  // const SizedBox(width: 2),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.transparent,
                    ),
                    child: Image.asset(
                      selectedEmoji,
                      height: 85,
                    ),
                  ),
                  Text(
                    todayMood,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ui_mode == "dark"
                          ? colorWhite
                          : const Color(0xff4F5357),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Matched Listeners'.tr,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: colorBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SizedBox(
                      height: 260,
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : ListView.builder(
                              itemCount: ids!.length,
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    ListnerDisplayModel? model =
                                        await APIServices.getListnerDataById(
                                            ids![index].toString());
                                    if (context.mounted) {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HelperDetailScreen(
                                                    showFeedbackForm: false,
                                                    listnerId: model
                                                        .data![0].id!
                                                        .toString(),
                                                  )));
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: ListTile(
                                      title: Text(
                                        names![index],
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20,
                                          color: ui_mode == "dark"
                                              ? colorWhite
                                              : colorBlack,
                                        ),
                                      ),
                                      leading: showImage(
                                        40,
                                        NetworkImage(
                                          APIConstants.BASE_URL +
                                              images![index],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.only(bottom: 5),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        shadowColor: colorWhite,
                      ),
                      onPressed: () {
                        debugPrint('Current Mood $todayMood');
                        _showMoodSelectionModal(context);
                      },
                      child: Text(
                        "Set mood".tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: colorWhite,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
