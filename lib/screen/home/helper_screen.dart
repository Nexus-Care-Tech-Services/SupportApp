import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:support/model/listner_display_model.dart';
import 'package:support/model/listner_list_model.dart';
import 'package:support/utils/color.dart';
import 'package:support/screen/home/helper_detail_screen.dart';
import 'package:support/screen/search/search_screen.dart';
import 'package:support/utils/reuasble_widget/image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/main.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/reuasble_widget/shimmer_progress_widget.dart';

class HelperScreen extends StatefulWidget {
  final ListnerDisplayModel? listnerDisplayModel;
  final bool isNavigatedFromSearchScreen;

  const HelperScreen(
      {this.listnerDisplayModel,
      this.isNavigatedFromSearchScreen = false,
      Key? key})
      : super(key: key);

  @override
  State<HelperScreen> createState() => _HelperScreenState();
}

class _HelperScreenState extends State<HelperScreen> {
  ListnerListModel? model;
  int currentpage = 1, limit = 30;
  ScrollController controller = ScrollController();

  bool isProgressRunning = false;
  bool isLoading = false;
  String walletAmount = "0.0";
  int totalRating = 0;
  String dataFromSecondScreen = '';
  bool isListener = false;

  List<String> interests = [
    'Interests',
    'All',
    'Relationship',
    'Breakup',
    'Studies',
    'Friendship',
    'Career',
    'Stress',
    'Loneliness'
  ];
  List<String> languages = [
    'Languages',
    'All',
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

  String? selectedfilter = 'All',
      selectedinterest = 'Interests',
      selectedlanguage = 'Languages',
      queryfilter = '';
  Map map = {};

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  checkListener() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isListener = prefs.getBool("isListener")!;
    setState(() {});
  }

  checkUIMode() async {
    ui_mode = SharedPreference.getValue(PrefConstants.UI_MODE) ?? "light";
    log(ui_mode);
  }

  Future<void> apiGetListnerList() async {
    try {
      setState(() {
        isProgressRunning = true;
      });
      ListnerListModel listners = await APIServices.getListnerList(map);
      setState(() {
        model = listners;
      });
    } catch (e) {
      APIServices.updateErrorLogs(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID),
          'apiGetListnerList()');
      debugPrint("Listner List Screen ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          isProgressRunning = false;
        });
      }
    }
  }

  // Future<void> loadMoreData() async {
  //   if (controller.offset == controller.position.maxScrollExtent) {
  //         setState(() {
  //           currentpage = currentpage + 1;
  //         });
  //         ListnerPaginationModel listners =
  //             await APIServices.getListnerList("?page=$currentpage&limit=$limit$queryfilter");
  //         log("?page=$currentpage&limit=$limit$queryfilter");
  //         setState(() {
  //           model!.data!.addAll(listners.data!);
  //         });
  //   }
  // }

  @override
  void initState() {
    // setState(() {
    //   queryfilter = '';
    // });
    // controller.addListener(() {
    //   loadMoreData();
    // });
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    if (kDebugMode) {
      print("UI_MODE: $ui_mode");
    }
    checkUIMode();
    checkListener();

    apiGetListnerList();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void goToSecondScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Drawer()),
    );

    if (result != null) {
      setState(() {
        dataFromSecondScreen = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: widget.isNavigatedFromSearchScreen
            ? AppBar(
                backgroundColor: primaryColor,
                leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back, color: colorWhite)),
                title: Text(
                  "Search Results".tr,
                  style: TextStyle(fontSize: 22, color: textColor),
                ),
              )
            : null,
        floatingActionButton: widget.isNavigatedFromSearchScreen
            ? null
            : isListener
                ? FloatingActionButton(
                    backgroundColor:
                        ui_mode == "dark" ? Colors.green : primaryColor,
                    onPressed: () async {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const SearchScreen()));
                    },
                    child: const Icon(
                      Icons.search,
                      color: colorWhite,
                    ),
                  )
                : FloatingActionButton(
                    backgroundColor:
                        ui_mode == "dark" ? Colors.green : primaryColor,
                    onPressed: () async {
                      await launchUrl(Uri.parse("https://wa.me/+919310351710"),
                          mode: LaunchMode.externalApplication);
                    },
                    child: const Text(
                      "Help",
                      style: TextStyle(
                        color: colorWhite,
                      ),
                    ),
                  ),
        body: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                if (!widget.isNavigatedFromSearchScreen) ...{
                  /*** Listner List Filter UI***/
                  if (SharedPreference.getValue(PrefConstants.USER_TYPE) ==
                      "user") ...{
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      height: 35,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectedfilter = "All";
                                selectedinterest = "Interests";
                                selectedlanguage = "Languages";
                                queryfilter = "";
                                currentpage = 1;
                                map = {};
                                apiGetListnerList();
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              height: 35,
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: selectedfilter == 'All'
                                      ? colorBlue
                                      : Colors.transparent,
                                  border: Border.all(
                                      color: selectedfilter == 'All'
                                          ? colorBlue
                                          : ui_mode == "dark"
                                              ? colorWhite
                                              : colorBlack)),
                              alignment: Alignment.center,
                              child: Text(
                                'All',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: selectedfilter == 'All'
                                      ? colorWhite
                                      : ui_mode == "dark"
                                          ? colorWhite
                                          : colorBlack,
                                  fontWeight: selectedfilter == 'All'
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 35,
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: selectedfilter == 'Interests'
                                    ? colorBlue
                                    : Colors.transparent,
                                border: Border.all(
                                    color: selectedfilter == 'Interests'
                                        ? colorBlue
                                        : ui_mode == "dark"
                                            ? colorWhite
                                            : colorBlack)),
                            alignment: Alignment.center,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<String>(
                                dropdownColor: primaryColor,
                                icon: const SizedBox(),
                                isExpanded: true,
                                padding: const EdgeInsets.only(top: 0),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                items: interests.map((e) {
                                  return DropdownMenuItem(
                                    alignment: AlignmentDirectional.center,
                                    value: e,
                                    child: Text(e,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: selectedfilter == 'Interests'
                                              ? colorWhite
                                              : ui_mode == "dark"
                                                  ? colorWhite
                                                  : colorBlack,
                                          fontWeight:
                                              selectedfilter == 'Interests'
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                        ),
                                        textAlign: TextAlign.center),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    currentpage = 1;
                                    if (value == "All" ||
                                        value == "Interests") {
                                      selectedfilter = 'All';
                                      selectedinterest = 'Interests';
                                      selectedlanguage = 'Languages';
                                      queryfilter = '';
                                      map = {};
                                      apiGetListnerList();
                                    } else {
                                      selectedfilter = 'Interests';
                                      selectedinterest = value!;
                                      selectedlanguage = "Languages";
                                      queryfilter =
                                          '&interests=${selectedinterest!.toLowerCase()}';
                                      map = {
                                        "interest": selectedinterest,
                                      };
                                      apiGetListnerList();
                                    }
                                  });
                                },
                                hint: const Text('Interests'),
                                value: selectedinterest,
                              ),
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 35,
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: selectedfilter == 'Languages'
                                    ? colorBlue
                                    : Colors.transparent,
                                border: Border.all(
                                    color: selectedfilter == 'Languages'
                                        ? colorBlue
                                        : ui_mode == "dark"
                                            ? colorWhite
                                            : colorBlack)),
                            alignment: Alignment.center,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                dropdownColor: primaryColor,
                                icon: const SizedBox(),
                                padding: const EdgeInsets.only(top: 0),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                items: languages.map((e) {
                                  return DropdownMenuItem(
                                    alignment: AlignmentDirectional.center,
                                    value: e,
                                    child: Text(e,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: selectedfilter == 'Languages'
                                              ? colorWhite
                                              : ui_mode == "dark"
                                                  ? colorWhite
                                                  : colorBlack,
                                          fontWeight:
                                              selectedfilter == 'Languages'
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                        ),
                                        textAlign: TextAlign.center),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    currentpage = 1;
                                    if (value == "All" ||
                                        value == "Languages") {
                                      selectedfilter = 'All';
                                      selectedinterest = 'Interests';
                                      selectedlanguage = 'Languages';
                                      queryfilter = '';
                                      map = {};
                                      apiGetListnerList();
                                    } else {
                                      selectedfilter = 'Languages';
                                      selectedinterest = 'Interests';
                                      selectedlanguage = value!;
                                      queryfilter =
                                          '&language=${selectedlanguage!.toLowerCase()}';
                                      map = {"language": selectedlanguage};
                                      apiGetListnerList();
                                    }
                                  });
                                },
                                hint: const Text('Languages'),
                                value: selectedlanguage,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectedfilter = "Star Listner";
                                selectedinterest = "Interests";
                                selectedlanguage = "Languages";
                                queryfilter = "&verified=true";
                                currentpage = 1;
                                map = {"verified": 1};
                                apiGetListnerList();
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              height: 35,
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: selectedfilter == 'Star Listner'
                                      ? colorBlue
                                      : Colors.transparent,
                                  border: Border.all(
                                      color: selectedfilter == 'Star Listner'
                                          ? colorBlue
                                          : ui_mode == "dark"
                                              ? colorWhite
                                              : colorBlack)),
                              alignment: Alignment.center,
                              child: Text(
                                'Star Listner',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: selectedfilter == 'Star Listner'
                                      ? colorWhite
                                      : ui_mode == "dark"
                                          ? colorWhite
                                          : colorBlack,
                                  fontWeight: selectedfilter == 'Star Listner'
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  },
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      GestureDetector(
                          child:
                              Icon(Icons.refresh, color: textColor, size: 25),
                          onTap: () async {
                            setState(() {
                              currentpage = 1;
                              selectedfilter = 'All';
                              selectedlanguage = 'Languages';
                              selectedinterest = 'Interests';
                              queryfilter = "";
                              map = {};
                              apiGetListnerList();
                            });
                          }),
                      const SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                },
                isProgressRunning
                    ? Expanded(
                        child: ShimmerProgressWidget(
                            count: 8, isProgressRunning: isProgressRunning),
                      )
                    : widget.isNavigatedFromSearchScreen
                        ? Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 10, 12, 5),
                              child: ListView.builder(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  shrinkWrap: true,
                                  itemCount: widget
                                          .listnerDisplayModel?.data?.length ??
                                      0,
                                  scrollDirection: Axis.vertical,
                                  physics: const ScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: cardColor,
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
                                              if (mounted) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            HelperDetailScreen(
                                                              listnerId: widget
                                                                  .listnerDisplayModel!
                                                                  .data![index]
                                                                  .id!
                                                                  .toString(),
                                                              showFeedbackForm:
                                                                  false,
                                                            )));
                                                await apiGetListnerList();
                                              }
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      6.0, 6, 6, 6),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: cardColor,
                                                ),
                                                child: Column(
                                                  children: [
                                                    Row(children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Stack(
                                                          children: [
                                                            if (widget
                                                                    .listnerDisplayModel
                                                                    ?.data?[
                                                                        index]
                                                                    .image !=
                                                                null) ...{
                                                              getImage(
                                                                  80,
                                                                  80,
                                                                  "${APIConstants.BASE_URL}${widget.listnerDisplayModel?.data?[index].image}",
                                                                  30,
                                                                  "assets/logo.png",
                                                                  BoxShape
                                                                      .circle,
                                                                  context),
                                                            } else ...{
                                                              Container(
                                                                width: 80,
                                                                height: 80,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        width:
                                                                            3,
                                                                        color:
                                                                            primaryColor),
                                                                    shape: BoxShape
                                                                        .circle),
                                                                child:
                                                                    Image.asset(
                                                                  "assets/logo.png",
                                                                  width: 30,
                                                                  height: 30,
                                                                ),
                                                              ),
                                                            },
                                                            Positioned(
                                                                right: 4,
                                                                bottom: 3,
                                                                child:
                                                                    Container(
                                                                  height: 15,
                                                                  width: 15,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border: Border.all(
                                                                        width:
                                                                            2,
                                                                        color:
                                                                            backgroundColor),
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: widget.listnerDisplayModel?.data?[index].onlineStatus ==
                                                                            1
                                                                        ? widget.listnerDisplayModel!.data![index].busyStatus ==
                                                                                1
                                                                            ? Colors
                                                                                .yellow
                                                                            : Colors
                                                                                .green
                                                                        : Colors
                                                                            .red,
                                                                  ),
                                                                )),
                                                            if (widget
                                                                    .listnerDisplayModel!
                                                                    .data![0]
                                                                    .charge ==
                                                                "1.00") ...{
                                                              Positioned(
                                                                right: 2,
                                                                top: 2,
                                                                child: showIcon(
                                                                    15,
                                                                    Colors
                                                                        .yellow,
                                                                    Icons
                                                                        .star_purple500_sharp,
                                                                    8,
                                                                    colorBlue),
                                                              ),
                                                            },
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      Expanded(
                                                        flex: 7,
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              flex: 6,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              "${widget.listnerDisplayModel?.data?[index].name!}, ${widget.listnerDisplayModel?.data?[index].age!}",
                                                                              style: TextStyle(color: textColor, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.bold, fontSize: 16),
                                                                            ),
                                                                            if (widget.listnerDisplayModel?.data?[index].busyStatus ==
                                                                                1)
                                                                              Text(
                                                                                widget.listnerDisplayModel?.data?[index].busyStatus == 1 ? "Busy" : "",
                                                                                style: TextStyle(color: textColor, fontSize: 12.0),
                                                                              )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      if (widget.listnerDisplayModel!.data![index].availableOn == "all" ||
                                                                          widget.listnerDisplayModel!.data![index].availableOn ==
                                                                              "All") ...{
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(right: 5),
                                                                          child: Icon(
                                                                              Icons.call,
                                                                              size: 16,
                                                                              color: ui_mode == "dark" ? colorWhite : colorBlue),
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(right: 5),
                                                                          child: Icon(
                                                                              Icons.chat_outlined,
                                                                              size: 16,
                                                                              color: ui_mode == "dark" ? colorWhite : colorBlue),
                                                                        ),
                                                                        Icon(
                                                                            Icons
                                                                                .videocam,
                                                                            size:
                                                                                16,
                                                                            color: ui_mode == "dark"
                                                                                ? colorWhite
                                                                                : colorBlue),
                                                                      } else if (widget.listnerDisplayModel!.data![index].availableOn == "chat & cal" ||
                                                                          widget.listnerDisplayModel!.data![index].availableOn ==
                                                                              "chat,call" ||
                                                                          widget.listnerDisplayModel!.data![index].availableOn ==
                                                                              "call,chat" ||
                                                                          widget.listnerDisplayModel!.data![index].availableOn ==
                                                                              "chat & call") ...{
                                                                        Icon(
                                                                            Icons
                                                                                .call,
                                                                            size:
                                                                                16,
                                                                            color: ui_mode == "dark"
                                                                                ? colorWhite
                                                                                : colorBlue),
                                                                        const SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Icon(
                                                                            Icons
                                                                                .chat_outlined,
                                                                            size:
                                                                                16,
                                                                            color: ui_mode == "dark"
                                                                                ? colorWhite
                                                                                : colorBlue),
                                                                      } else if (widget
                                                                              .listnerDisplayModel!
                                                                              .data![
                                                                                  index]
                                                                              .availableOn ==
                                                                          "video & au") ...{
                                                                        Icon(
                                                                            Icons
                                                                                .call,
                                                                            size:
                                                                                16,
                                                                            color: ui_mode == "dark"
                                                                                ? colorWhite
                                                                                : colorBlue),
                                                                        const SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Icon(
                                                                            Icons
                                                                                .videocam,
                                                                            size:
                                                                                16,
                                                                            color: ui_mode == "dark"
                                                                                ? colorWhite
                                                                                : colorBlue),
                                                                      } else if (widget
                                                                              .listnerDisplayModel!
                                                                              .data![
                                                                                  index]
                                                                              .availableOn ==
                                                                          "video call") ...{
                                                                        Icon(
                                                                            Icons
                                                                                .videocam,
                                                                            size:
                                                                                16,
                                                                            color: ui_mode == "dark"
                                                                                ? colorWhite
                                                                                : colorBlue),
                                                                      } else if (widget
                                                                              .listnerDisplayModel!
                                                                              .data![
                                                                                  index]
                                                                              .availableOn ==
                                                                          "call") ...{
                                                                        Icon(
                                                                            Icons
                                                                                .call,
                                                                            size:
                                                                                16,
                                                                            color: ui_mode == "dark"
                                                                                ? colorWhite
                                                                                : colorBlue),
                                                                      } else if (widget
                                                                              .listnerDisplayModel!
                                                                              .data![index]
                                                                              .availableOn ==
                                                                          "chat") ...{
                                                                        Icon(
                                                                            Icons
                                                                                .chat_outlined,
                                                                            size:
                                                                                16,
                                                                            color: ui_mode == "dark"
                                                                                ? colorWhite
                                                                                : colorBlue),
                                                                      }
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 4,
                                                                  ),
                                                                  Text(
                                                                    widget
                                                                            .listnerDisplayModel
                                                                            ?.data?[index]
                                                                            .about ??
                                                                        "",
                                                                    maxLines: 2,
                                                                    style: TextStyle(
                                                                        color:
                                                                            textColor,
                                                                        fontSize:
                                                                            12),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            const SizedBox(
                                                                height: 90,
                                                                child:
                                                                    VerticalDivider()),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Expanded(
                                                              flex: 2,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    widget
                                                                            .listnerDisplayModel
                                                                            ?.data?[index]
                                                                            .avgRating
                                                                            ?.toString() ??
                                                                        '0',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color:
                                                                            listnerRatingColor,
                                                                        fontWeight:
                                                                            FontWeight.w900),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      RatingBar
                                                                          .builder(
                                                                        ignoreGestures:
                                                                            true,
                                                                        initialRating:
                                                                            double.tryParse(widget.listnerDisplayModel?.data?[index].avgRating?.toString() ?? '0.0') ??
                                                                                0.0,
                                                                        minRating:
                                                                            1,
                                                                        direction:
                                                                            Axis.horizontal,
                                                                        allowHalfRating:
                                                                            true,
                                                                        itemCount:
                                                                            5,
                                                                        itemSize:
                                                                            8,
                                                                        itemPadding:
                                                                            const EdgeInsets.symmetric(horizontal: 1.0),
                                                                        itemBuilder:
                                                                            (context, _) =>
                                                                                Icon(
                                                                          Icons
                                                                              .star,
                                                                          color: ui_mode == "dark"
                                                                              ? colorWhite
                                                                              : colorDarkBlue,
                                                                          size:
                                                                              2,
                                                                        ),
                                                                        onRatingUpdate:
                                                                            (rating) {},
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Text(
                                                                    widget
                                                                            .listnerDisplayModel
                                                                            ?.data?[index]
                                                                            .totalReviewCount
                                                                            .toString() ??
                                                                        "0",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          textColor,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ]),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    );
                                  }),
                            ),
                          )
                        : Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 10, 12, 5),
                              child: ListView.builder(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 10),
                                  shrinkWrap: true,
                                  itemCount: model!.data!.length,
                                  scrollDirection: Axis.vertical,
                                  physics: const ScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: cardColor,
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
                                              String id = model!
                                                  .data![index].id!
                                                  .toString();
                                              if (mounted) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            HelperDetailScreen(
                                                              listnerId: id,
                                                              showFeedbackForm:
                                                                  false,
                                                            )));
                                                await apiGetListnerList();
                                              }
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      6.0, 6, 6, 6),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: cardColor,
                                                ),
                                                child: Column(
                                                  children: [
                                                    Row(children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Stack(
                                                          children: [
                                                            if (model!
                                                                    .data![
                                                                        index]
                                                                    .image !=
                                                                null) ...{
                                                              getImage(
                                                                  80,
                                                                  80,
                                                                  "${APIConstants.BASE_URL}${model!.data![index].image}",
                                                                  30,
                                                                  "assets/logo.png",
                                                                  BoxShape
                                                                      .circle,
                                                                  context),
                                                            } else ...{
                                                              Container(
                                                                width: 80,
                                                                height: 80,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        width:
                                                                            3,
                                                                        color:
                                                                            primaryColor),
                                                                    shape: BoxShape
                                                                        .circle),
                                                                child:
                                                                    Image.asset(
                                                                  "assets/logo.png",
                                                                  width: 30,
                                                                  height: 30,
                                                                ),
                                                              ),
                                                            },
                                                            Positioned(
                                                                right: 4,
                                                                bottom: 3,
                                                                child:
                                                                    Container(
                                                                  height: 15,
                                                                  width: 15,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border: Border.all(
                                                                        width:
                                                                            2,
                                                                        color:
                                                                            backgroundColor),
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: model!.data![index].onlineStatus ==
                                                                            1
                                                                        ? model!.data![index].busyStatus ==
                                                                                1
                                                                            ? Colors
                                                                                .yellow
                                                                            : Colors
                                                                                .green
                                                                        : Colors
                                                                            .red,
                                                                  ),
                                                                )),
                                                            if (model!
                                                                    .data![
                                                                        index]
                                                                    .charge ==
                                                                "1.00") ...{
                                                              Positioned(
                                                                right: 2,
                                                                top: 2,
                                                                child: showIcon(
                                                                    15,
                                                                    Colors
                                                                        .yellow,
                                                                    Icons
                                                                        .star_purple500_sharp,
                                                                    8,
                                                                    colorBlue),
                                                              ),
                                                            },
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      Expanded(
                                                        flex: 7,
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              flex: 6,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              "${model!.data![index].name!}, ${model!.data![index].age!}",
                                                                              style: TextStyle(color: textColor, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.bold, fontSize: 16),
                                                                            ),
                                                                            if (model!.data![index].busyStatus ==
                                                                                1)
                                                                              Text(
                                                                                model!.data![index].busyStatus == 1 ? "Busy" : "",
                                                                                style: TextStyle(color: textColor, fontSize: 12.0),
                                                                              )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      if (model!.data![index].availableOn == "all" ||
                                                                          model!.data![index].availableOn ==
                                                                              "All") ...{
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(right: 5),
                                                                          child: Icon(
                                                                              Icons.call,
                                                                              size: 16,
                                                                              color: ui_mode == "dark" ? colorWhite : colorBlue),
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(right: 5),
                                                                          child: Icon(
                                                                              Icons.chat_outlined,
                                                                              size: 16,
                                                                              color: ui_mode == "dark" ? colorWhite : colorBlue),
                                                                        ),
                                                                        Icon(
                                                                            Icons
                                                                                .videocam,
                                                                            size:
                                                                                16,
                                                                            color: ui_mode == "dark"
                                                                                ? colorWhite
                                                                                : colorBlue),
                                                                      } else if (model!.data![index].availableOn == "chat & cal" ||
                                                                          model!.data![index].availableOn ==
                                                                              "chat,call" ||
                                                                          model!.data![index].availableOn ==
                                                                              "call,chat" ||
                                                                          model!.data![index].availableOn ==
                                                                              "chat & call") ...{
                                                                        Icon(
                                                                            Icons
                                                                                .call,
                                                                            size:
                                                                                16,
                                                                            color: ui_mode == "dark"
                                                                                ? colorWhite
                                                                                : colorBlue),
                                                                        const SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Icon(
                                                                            Icons
                                                                                .chat_outlined,
                                                                            size:
                                                                                16,
                                                                            color: ui_mode == "dark"
                                                                                ? colorWhite
                                                                                : colorBlue),
                                                                      } else if (model!
                                                                              .data![
                                                                                  index]
                                                                              .availableOn ==
                                                                          "video & au") ...{
                                                                        Icon(
                                                                            Icons
                                                                                .call,
                                                                            size:
                                                                                16,
                                                                            color: ui_mode == "dark"
                                                                                ? colorWhite
                                                                                : colorBlue),
                                                                        const SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Icon(
                                                                            Icons
                                                                                .videocam,
                                                                            size:
                                                                                16,
                                                                            color: ui_mode == "dark"
                                                                                ? colorWhite
                                                                                : colorBlue),
                                                                      } else if (model!
                                                                              .data![
                                                                                  index]
                                                                              .availableOn ==
                                                                          "video call") ...{
                                                                        Icon(
                                                                            Icons
                                                                                .videocam,
                                                                            size:
                                                                                16,
                                                                            color: ui_mode == "dark"
                                                                                ? colorWhite
                                                                                : colorBlue),
                                                                      } else if (model!
                                                                              .data![
                                                                                  index]
                                                                              .availableOn ==
                                                                          "call") ...{
                                                                        Icon(
                                                                            Icons
                                                                                .call,
                                                                            size:
                                                                                16,
                                                                            color: ui_mode == "dark"
                                                                                ? colorWhite
                                                                                : colorBlue),
                                                                      } else if (model!
                                                                              .data![index]
                                                                              .availableOn ==
                                                                          "chat") ...{
                                                                        Icon(
                                                                            Icons
                                                                                .chat_outlined,
                                                                            size:
                                                                                16,
                                                                            color: ui_mode == "dark"
                                                                                ? colorWhite
                                                                                : colorBlue),
                                                                      }
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 4,
                                                                  ),
                                                                  Text(
                                                                    model!.data![index]
                                                                            .about ??
                                                                        "",
                                                                    maxLines: 2,
                                                                    style: TextStyle(
                                                                        color:
                                                                            textColor,
                                                                        fontSize:
                                                                            12),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            const SizedBox(
                                                                height: 90,
                                                                child:
                                                                    VerticalDivider()),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Expanded(
                                                              flex: 2,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    model!.data![index]
                                                                            .avgRating
                                                                            ?.toString() ??
                                                                        '0',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color:
                                                                            listnerRatingColor,
                                                                        fontWeight:
                                                                            FontWeight.w900),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      RatingBar
                                                                          .builder(
                                                                        ignoreGestures:
                                                                            true,
                                                                        initialRating:
                                                                            double.tryParse(model!.data![index].avgRating?.toString() ?? '0.0') ??
                                                                                0.0,
                                                                        minRating:
                                                                            1,
                                                                        direction:
                                                                            Axis.horizontal,
                                                                        allowHalfRating:
                                                                            true,
                                                                        itemCount:
                                                                            5,
                                                                        itemSize:
                                                                            8,
                                                                        itemPadding:
                                                                            const EdgeInsets.symmetric(horizontal: 1.0),
                                                                        itemBuilder:
                                                                            (context, _) =>
                                                                                Icon(
                                                                          Icons
                                                                              .star,
                                                                          color: ui_mode == "dark"
                                                                              ? colorWhite
                                                                              : colorDarkBlue,
                                                                          size:
                                                                              2,
                                                                        ),
                                                                        onRatingUpdate:
                                                                            (rating) {},
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Text(
                                                                    model!
                                                                        .data![
                                                                            index]
                                                                        .ratingCount
                                                                        .toString(),
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          textColor,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ]),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    );
                                  }),
                            ),
                          ),
              ],
            ),
          ),
        ));
  }
}
