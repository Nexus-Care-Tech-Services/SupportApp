import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support/api/api_services.dart';
import 'package:support/utils/color.dart';
import 'package:support/main.dart';
import 'package:support/model/listner_display_model.dart';
import 'package:support/model/recent_listners_model.dart';
import 'package:support/screen/home/helper_detail_screen.dart';
import 'package:support/screen/home/helper_screen.dart';
import 'package:support/sharedpreference/sharedpreference.dart';

import 'package:support/api/api_constant.dart';
import 'package:support/model/listner_display_model.dart' as listner;
import 'package:support/utils/reuasble_widget/image.dart';
import 'package:support/utils/reuasble_widget/toast_widget.dart';

class TrendingSearches {
  String searchData;

  TrendingSearches({
    required this.searchData,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool isFetching = false;

  List<listner.ListnerDisplayModel?> listenerDisplayModels = [];
  List<String> listenerIds = ["13538", "17463", "28702", "2077", "6099"];

  List<String> recentlistenerImages = [];
  List<String> recentlistenerItems = [];
  List<String> recentlistenerNames = [];
  List<String> recentlistenerStatus = [];

  List<String> languages = [
    'English',
    'Hindi',
    'Assamese',
    'Telugu',
    'Gujarati',
    'Kannada',
    'Malayalam',
    'Marathi',
    'Odia',
    'Punjabi',
    'Tamil',
    'Bengali',
    'Konkani',
    'Kashmiri',
    'Bhojpuri',
    'Dogri',
    'Urdu',
    'Manipuri',
    'Sindhi',
    'Bodo',
    'Sanskrit'
  ];
  Map map = {};
  bool isLanguageOnly = false;

  bool isListener = false;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    fetchListnerData();
    checkListener();
  }

  Future<int?> getListenerStatus(String id) async {
    try {
      ListnerDisplayModel model = await APIServices.getListnerDataById(id);
      return model.data![0].onlineStatus!;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<String?> getListenerImage(String id) async {
    try {
      ListnerDisplayModel displayModel =
          await APIServices.getListnerDataById(id);
      return displayModel.data![0].image;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<void> fetchListnerData() async {
    try {
      setState(() {
        isFetching = true;
      });
      for (String listenerId in listenerIds) {
        listner.ListnerDisplayModel? listenerDisplayModel =
            await APIServices.getListnerDataById(listenerId);
        listenerDisplayModels.add(listenerDisplayModel);
      }

      //Recent Listners
      if (SharedPreference.getValue(PrefConstants.USER_TYPE) == 'user') {
        RecentListnersModel? model = await APIServices.getRecentListners(
            SharedPreference.getValue(PrefConstants.MERA_USER_ID));
        for (int i = 0; i < model!.listeners!.length; i++) {
          setState(() {
            recentlistenerItems.add(model.listeners![i].id!.toString());
            recentlistenerNames.add(model.listeners![i].name!);
          });
        }

        for (int i = 0; i < recentlistenerItems.length; i++) {
          String? image = await getListenerImage(recentlistenerItems[i]);
          int? status = await getListenerStatus(recentlistenerItems[i]);
          String onlinestatus = status == 0 ? "Offline" : "Online";
          setState(() {
            recentlistenerImages.add(image!);
            recentlistenerStatus.add(onlinestatus);
          });
        }
      }
    } catch (e) {
      log(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          isFetching = false;
        });
      }
    }
  }

  checkListener() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isListener = prefs.getBool("isListener")!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: detailScreenBgColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back, color: textColor)),
        title: Text(
          "Support Search".tr,
          style: TextStyle(color: textColor),
        ),
      ),
      body: isFetching
          ? Center(
              child: CircularProgressIndicator(
              color: textColor,
            ))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22.0, 16, 22, 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Trending Searches".tr,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: textColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Top 5 Listeners of Support App".tr,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          //test
                          scrollDirection: Axis.horizontal,
                          itemCount: listenerDisplayModels.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            var listenerDisplayModel =
                                listenerDisplayModels[index];

                            return InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => HelperDetailScreen(
                                          listnerId: listenerDisplayModel
                                              ?.data![0].id!
                                              .toString(),
                                          showFeedbackForm: false,
                                        )));
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: ui_mode == "dark"
                                                      ? colorWhite
                                                      : colorBlack,
                                                  width: 2)),
                                          child: getImage(
                                              50,
                                              50,
                                              "${APIConstants.BASE_URL}${listenerDisplayModel?.data![0].image}",
                                              30,
                                              "assets/logo2.png",
                                              BoxShape.circle,
                                              context),
                                        ),
                                        Positioned(
                                          right: 0,
                                          bottom: 5,
                                          child: Container(
                                            height: 12,
                                            width: 12,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 2, color: colorWhite),
                                              shape: BoxShape.circle,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Text(
                                        listenerDisplayModel?.data![0].name ??
                                            "",
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10.0, right: 10),
                              child: TextFormField(
                                style: TextStyle(color: textColor),
                                onFieldSubmitted: (value) {
                                  search();
                                },
                                keyboardType: TextInputType.text,
                                controller: _searchController,
                                decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Search Listners, Language'.tr,
                                    hintStyle: TextStyle(
                                        color: ui_mode == "dark"
                                            ? colorWhite
                                            : colorBlack),
                                    suffixIcon: InkWell(
                                      onTap: () {
                                        search();
                                      },
                                      child: Icon(
                                        Icons.search,
                                        size: 20,
                                        color: textColor,
                                      ),
                                    ),
                                    contentPadding:
                                        const EdgeInsets.only(left: 15),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide:
                                            BorderSide(color: textColor)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide:
                                            BorderSide(color: textColor)),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide:
                                            BorderSide(color: textColor))),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          !isListener
                              ? Text('Recently Contacted Listeners'.tr,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textColor))
                              : Container(),
                          const SizedBox(
                            height: 20,
                          ),
                          isListener
                              ? Container()
                              : SizedBox(
                                  height: 300,
                                  width: MediaQuery.of(context).size.width,
                                  child: recentlistenerItems.isNotEmpty
                                      ? ListView.builder(
                                          padding: const EdgeInsets.only(
                                              left: 5, right: 5, top: 5),
                                          scrollDirection: Axis.vertical,
                                          itemCount: recentlistenerItems.length,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 10),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  50,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: detailScreenCardColor,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: ui_mode == "dark"
                                                        ? Colors.transparent
                                                        : const Color.fromARGB(
                                                                255, 49, 49, 49)
                                                            .withOpacity(0.3),
                                                    spreadRadius: 1,
                                                    blurRadius: 7,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: InkWell(
                                                onTap: () async {
                                                  ListnerDisplayModel?
                                                      listenerModel =
                                                      await APIServices
                                                          .getListnerDataById(
                                                              recentlistenerItems[
                                                                  index]);
                                                  if (context.mounted) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            HelperDetailScreen(
                                                          listnerId:
                                                              listenerModel
                                                                  .data![0].id!
                                                                  .toString(),
                                                          showFeedbackForm:
                                                              false,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      // Image
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            width: 2,
                                                            color: textColor,
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: getImage(
                                                            60,
                                                            60,
                                                            "${APIConstants.BASE_URL}${recentlistenerImages[index]}",
                                                            30,
                                                            "assets/logo2.png",
                                                            BoxShape.circle,
                                                            context),
                                                      ),
                                                      const SizedBox(width: 20),
                                                      // Name and Status
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            recentlistenerNames[
                                                                index],
                                                            style: TextStyle(
                                                              color: textColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                            recentlistenerStatus[
                                                                        index] ==
                                                                    'Online'
                                                                ? "Online"
                                                                : "Offline",
                                                            style: TextStyle(
                                                              color: recentlistenerStatus[
                                                                          index] ==
                                                                      'Online'
                                                                  ? Colors.green
                                                                  : colorRed,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : Center(
                                          child: Text(
                                              "No Recent Listners Found!".tr),
                                        ),
                                ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void search() async {
    var val = _searchController.text.trim();
    if (val.contains(',')) {
      var result = val.split(',');
      setState(() {
        map = {
          "search_keywords": result[0],
          "language": result[1],
        };
      });
    } else {
      for (int i = 0; i < languages.length; i++) {
        if (val == languages[i]) {
          setState(() {
            map = {
              "language": languages[i],
            };
            isLanguageOnly = true;
          });
        }
      }
      if (!isLanguageOnly) {
        setState(() {
          map = {
            "search_keywords": val,
          };
        });
      }
    }
    // toastshowDefaultSnackbar(context, "${map.toString()} $val", false, primaryColor);
    ListnerDisplayModel? listenerModel =
        await APIServices.searchListener(map: map);
    if (!mounted) return;
    if (listenerModel?.status == true) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HelperScreen(
                    listnerDisplayModel: listenerModel,
                    isNavigatedFromSearchScreen: true,
                  )));
    } else {
      toastshowDefaultSnackbar(
          context, "No Listener Found".tr, false, primaryColor);
    }
    setState(() {
      isLanguageOnly = false;
    });
  }
}
