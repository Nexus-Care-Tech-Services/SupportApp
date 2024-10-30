import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/main.dart';
import 'package:support/model/busy_online.dart';
import 'package:support/model/listner_display_model.dart' as listner;
import 'package:support/model/listner_display_model.dart';
import 'package:support/model/reel_model.dart';
import 'package:support/screen/reels/reels_screen.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/color.dart';
import 'package:support/utils/reuasble_widget/appbar.dart';
import 'package:support/utils/reuasble_widget/image.dart';
import 'package:support/utils/reuasble_widget/marquee_widget.dart';
import 'package:support/utils/reuasble_widget/review_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({super.key});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile>
    with SingleTickerProviderStateMixin {
  num? percent5, percent4, percent3, percent2, percent1;

  double ratingStore = 5;
  String walletAmount = "0.0";
  bool isListener = false;
  BusyOnlineModel? busyOnlineModel;

  bool isProgressRunning = false;
  bool isFirstCall = true;
  String name = '';
  bool onlineStatus = true;
  Widget? image;
  double? width = 150;
  double? height = 150;
  dynamic response;
  late int onlinestatus;
  late dynamic lastActiveTime;
  bool isFetching = false;
  bool isBlocked = false;
  listner.ListnerDisplayModel? listenerDisplayModel1;

  int bioLiked = 0, profileLiked = 0;
  bool isBioLiked = false, isProfileLiked = false;
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;

  //List of ReviewData
  List<ReviewData> reviewData = [];
  List<bool> review = [];

// variable to calculate total no. of reviews
  int totalReviews = 0;

// variable to calculate average rating
  double avgRating = 0.0;
  String interest = '';
  String language = '';

  TabController? tabController;
  int selectedIndex = 0;
  ReelModel? listenerReels;
  List<String> thumbnails = [];
  List<Map<String, dynamic>> giftsList = [];

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  imagedata(width, height) {
    return getImage(
        height,
        width,
        "${APIConstants.BASE_URL}${listenerDisplayModel1?.data![0].image}",
        width,
        "assets/logo.png",
        BoxShape.circle,
        context);
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    tabController = TabController(length: 2, vsync: this);
    tabController!.addListener(() {
      setState(() {
        selectedIndex = tabController!.index;
      });
    });
    setReels();
    getLikesCount();
    fetchListnerData();
    checkListener();
    Future.delayed(Duration.zero, () async {
      String amount = await APIServices.getWalletAmount(
              SharedPreference.getValue(PrefConstants.MERA_USER_ID)) ??
          "0.0";
      setState(() {
        walletAmount = amount;
        SharedPreference.setValue(PrefConstants.WALLET_AMOUNT, walletAmount);
      });
    });
    Future.delayed(const Duration(seconds: 5), () async {
      setTotalAndAvgRatings();
      setLangAndInterest();
      getReportedReviews();
    });
  }

  Future<void> setReels() async {
    listenerReels = await APIServices.fetchReelData(
        filterReel: true,
        listnerId: SharedPreference.getValue(PrefConstants.MERA_USER_ID));
    if (listenerReels!.data!.isNotEmpty) {
      for (int i = 0; i < listenerReels!.data!.length; i++) {
        debugPrint('##${listenerReels!.data![i]}');
        if (listenerReels!.data![i].listnerId.toString() ==
            SharedPreference.getValue(PrefConstants.MERA_USER_ID)) {
          thumbnails.add("");
          final gifts = await APIServices.fetchGifts(
              listenerReels!.data![i].listnerId.toString(),
              listenerReels!.data![i].reelId!);
          giftsList.add(gifts);
        }
      } //var data in listenerReels)
      debugPrint('##$giftsList');
      for (int i = 0; i < listenerReels!.data!.length; i++) {
        if (listenerReels!.data![i].listnerId.toString() ==
            SharedPreference.getValue(PrefConstants.MERA_USER_ID)) {
          String? videoUrl = listenerReels!.data![i].reelUrl!;
          try {
            final thumbnailPath = await VideoThumbnail.thumbnailFile(
              video: videoUrl,
              thumbnailPath: (await getTemporaryDirectory()).path,
              imageFormat: ImageFormat.JPEG,
              maxWidth: 500,
              // Adjust thumbnail size as needed
              maxHeight: 500,

              quality: 100, // Adjust thumbnail quality as needed
            );

            if (thumbnailPath != null) {
              setState(() {
                thumbnails[i] = thumbnailPath;
              });
            }
          } catch (e) {
            rethrow;
          }
        }
      }
    }
  }

  Widget reelGifts(Image? image, String text) {
    List<String> items = text.split(', ');
    return SizedBox(
      height: 160,
      child: Card(
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 80,
                  width: 80,
                  child: image ?? Container(),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              SizedBox(
                height: 140,
                width: 260,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  // Disable scrolling
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Number of items per row
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 6,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Text(
                      items[index],
                      style: TextStyle(
                          fontSize: 16,
                          color: ui_mode == "dark" ? colorWhite : colorBlack),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getLikesCount() async {
    DocumentSnapshot biodoc = await _firebase
        .collection("bio-likes")
        .doc(SharedPreference.getValue(PrefConstants.MERA_USER_ID))
        .get();
    if (biodoc.exists) {
      List<dynamic> list = biodoc['likes'];
      if (list.contains(
          int.parse(SharedPreference.getValue(PrefConstants.MERA_USER_ID)))) {
        setState(() {
          isBioLiked = true;
        });
      }
      setState(() {
        bioLiked = list.length;
      });
    }

    DocumentSnapshot doc = await _firebase
        .collection("listner-likes")
        .doc(SharedPreference.getValue(PrefConstants.MERA_USER_ID))
        .get();
    if (doc.exists) {
      List<dynamic> list = doc['likes'];
      if (list.contains(
          int.parse(SharedPreference.getValue(PrefConstants.MERA_USER_ID)))) {
        setState(() {
          isProfileLiked = true;
        });
      }
      setState(() {
        profileLiked = list.length;
      });
    }
  }

  void getReportedReviews() async {
    if (listenerDisplayModel1 != null) {
      FirebaseFirestore firebase = FirebaseFirestore.instance;
      var collection = firebase.collection("reported_reviews");
      for (int i = 0;
          i < listenerDisplayModel1!.data![0].ratingReviews!.allReviews!.length;
          i++) {
        var doc = await collection
            .doc(listenerDisplayModel1!
                .data![0].ratingReviews!.allReviews![i].id!)
            .get();
        setState(() {
          if (doc.exists) {
            review[i] = true;
          } else {
            review[i] = false;
          }
        });
      }
    }
  }

  Future<void> fetchListnerData() async {
    try {
      setState(() {
        isFetching = true;
      });

      ListnerDisplayModel listnerDisplayModel =
          await APIServices.getListnerDataById(
              SharedPreference.getValue(PrefConstants.MERA_USER_ID));
      setState(() {
        listenerDisplayModel1 = listnerDisplayModel;
      });
      lastActiveTime = listenerDisplayModel1!.data![0].updatedAt;
      image = CachedNetworkImage(
        imageUrl:
            "${APIConstants.BASE_URL}${listenerDisplayModel1!.data![0].image}",
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Image.asset(
          "assets/logo.png",
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
        placeholder: (context, url) => Image.asset(
          "assets/logo.png",
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      );

      for (int i = 0;
          i < listnerDisplayModel.data![0].ratingReviews!.allReviews!.length;
          i++) {
        review.add(false);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          // initializing the reviewData variable with the listener's ratings
          reviewData = [
            ReviewData(
              '1★',
              listenerDisplayModel1!.data![0].ratingReviews!.rating1 ?? 0,
              ui_mode == 'dark'
                  ? const Color.fromRGBO(250, 141, 125, 1)
                  : const Color.fromRGBO(255, 105, 97, 1),
            ),
            ReviewData(
              '2★',
              listenerDisplayModel1!.data![0].ratingReviews!.rating2 ?? 0,
              ui_mode == 'dark'
                  ? const Color.fromRGBO(255, 207, 61, 1)
                  : const Color.fromARGB(255, 163, 170, 255),
            ),
            ReviewData(
              '3★',
              listenerDisplayModel1!.data![0].ratingReviews!.rating3 ?? 0,
              ui_mode == 'dark'
                  ? const Color.fromRGBO(185, 159, 229, 1)
                  : const Color.fromRGBO(233, 236, 107, 1),
            ),
            ReviewData(
              '4★',
              listenerDisplayModel1!.data![0].ratingReviews!.rating4 ?? 0,
              ui_mode == 'dark'
                  ? const Color.fromRGBO(129, 176, 217, 1)
                  : const Color.fromRGBO(137, 207, 240, 1),
            ),
            ReviewData(
              '5★',
              listenerDisplayModel1!.data![0].ratingReviews!.rating5 ?? 0,
              ui_mode == 'dark'
                  ? const Color.fromRGBO(88, 161, 81, 1)
                  : const Color.fromRGBO(119, 221, 119, 1),
            ),
          ];
          isFetching = false;
        });
      }
    }
  }

  // function to calculate total no. of ratings and average rating
  void setTotalAndAvgRatings() async {
    if (listenerDisplayModel1 != null) {
      setState(() {
        final review = listenerDisplayModel1!.data![0].ratingReviews!;
        totalReviews = review.rating1! +
            review.rating2! +
            review.rating3! +
            review.rating4! +
            review.rating5!;
        avgRating = review.averageRating!.toDouble();
      });
    }
  }

  void setLangAndInterest() {
    if (listenerDisplayModel1 != null) {
      setState(() {
        // replacing ',' and ' ' with new line(\n)
        interest =
            (listenerDisplayModel1?.data![0].interest ?? '').replaceAllMapped(
          RegExp(r'(,|\s)+'),
          (match) {
            return '\n';
          },
        );

        // replacing ',' and ' ' with new line(\n)
        language =
            (listenerDisplayModel1?.data![0].language ?? '').replaceAllMapped(
          RegExp(r'(,|\s)+'),
          (match) {
            return '\n';
          },
        );
      });
    }
  }

  checkListener() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isListener = prefs.getBool("isListener")!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return WillPopScope(
      onWillPop: () async {
        // if (isListener) {
        //   Navigator.pushReplacement(
        //       context,
        //       MaterialPageRoute(
        //           builder: (context) => const ListnerHomeScreen(index: 0)));
        // } else {
        //   Navigator.pushReplacement(context,
        //       MaterialPageRoute(builder: (context) => const HomeScreen()));
        // }
        Navigator.pop(context);
        return true;
      },
      child: isFetching
          ? SafeArea(
              child: Container(
                color: backgroundColor,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.fromLTRB(15.0, 20, 15, 10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CustomBackButton(
                                        isfromLoginScreen: false,
                                        isListner: isListener),
                                  ],
                                )
                              ])),
                      SizedBox(
                        height: mediaQuery.size.height * 0.350,
                      ),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
              ),
            )
          : DefaultTabController(
              length: 2,
              initialIndex: 0,
              child: Scaffold(
                backgroundColor: detailScreenCardColor,
                body: isFetching
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : SafeArea(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15.0, 20, 15, 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CustomBackButton(
                                            isfromLoginScreen: false,
                                            isListner: isListener),
                                        const Spacer(),
                                        if (listenerDisplayModel1
                                                ?.data![0].busyStatus ==
                                            1) ...{
                                          Text('Busy'.tr,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  letterSpacing: 0.3,
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.bold))
                                        } else if (listenerDisplayModel1
                                                ?.data![0].onlineStatus ==
                                            1) ...{
                                          Text('Online'.tr,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.green,
                                                  letterSpacing: 0.3,
                                                  fontWeight: FontWeight.bold))
                                        } else ...{
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text('Last seen: '.tr,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      letterSpacing: 0.3,
                                                      color: Colors.redAccent,
                                                    )),
                                                Text(
                                                    GetTimeAgo.parse(
                                                      DateTime.parse(
                                                          lastActiveTime),
                                                      pattern:
                                                          "dd-MM-yyyy hh:mm aa",
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      letterSpacing: 0.3,
                                                      color: Colors.redAccent,
                                                    ))
                                              ])
                                        },
                                        const SizedBox(width: 20),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Center(
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ClipRRect(
                                                      borderRadius:
                                                          listenerDisplayModel1
                                                                      ?.data?[0]
                                                                      .onlineStatus ==
                                                                  1
                                                              ? BorderRadius
                                                                  .circular(100)
                                                              : BorderRadius
                                                                  .circular(
                                                                      100),
                                                      child: InkWell(
                                                        onTap: () {
                                                          width = MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width;
                                                          height =
                                                              MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height;
                                                        },
                                                        child: image,
                                                      )),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                          ),
                                          Positioned(
                                            bottom: 15,
                                            right: 110,
                                            child: InkWell(
                                              onTap: () async {
                                                try {
                                                  if (listenerDisplayModel1!
                                                          .data![0].id !=
                                                      int.parse(SharedPreference
                                                          .getValue(PrefConstants
                                                              .MERA_USER_ID))) {
                                                    DocumentSnapshot doc =
                                                        await _firebase
                                                            .collection(
                                                                "listner-likes")
                                                            .doc(
                                                                listenerDisplayModel1!
                                                                    .data![0]
                                                                    .id!
                                                                    .toString())
                                                            .get();
                                                    if (doc.exists) {
                                                      List<dynamic> list =
                                                          doc['likes'];
                                                      List<int> likelist =
                                                          list.cast<int>();
                                                      if (likelist.contains(int
                                                          .parse(SharedPreference
                                                              .getValue(
                                                                  PrefConstants
                                                                      .MERA_USER_ID)))) {
                                                        likelist.remove(int.parse(
                                                            SharedPreference
                                                                .getValue(
                                                                    PrefConstants
                                                                        .MERA_USER_ID)));
                                                        setState(() {
                                                          isProfileLiked =
                                                              false;
                                                        });
                                                      } else {
                                                        likelist.add(int.parse(
                                                            SharedPreference
                                                                .getValue(
                                                                    PrefConstants
                                                                        .MERA_USER_ID)));
                                                        setState(() {
                                                          isProfileLiked = true;
                                                        });
                                                      }
                                                      if (likelist.isNotEmpty) {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'listner-likes')
                                                            .doc(
                                                                listenerDisplayModel1!
                                                                    .data![0]
                                                                    .id!
                                                                    .toString())
                                                            .update({
                                                          'likes': likelist
                                                        });
                                                      } else {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'listner-likes')
                                                            .doc(
                                                                listenerDisplayModel1!
                                                                    .data![0]
                                                                    .id!
                                                                    .toString())
                                                            .update(
                                                                {'likes': []});
                                                      }
                                                      setState(() {
                                                        profileLiked =
                                                            list.length;
                                                      });
                                                    } else {
                                                      List<int> list = [
                                                        int.parse(SharedPreference
                                                            .getValue(PrefConstants
                                                                .MERA_USER_ID))
                                                      ];
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'listner-likes')
                                                          .doc(
                                                              listenerDisplayModel1!
                                                                  .data![0].id!
                                                                  .toString())
                                                          .set({'likes': list});
                                                      setState(() {
                                                        profileLiked =
                                                            list.length;
                                                        isProfileLiked = true;
                                                      });
                                                    }
                                                  }
                                                } catch (e) {
                                                  debugPrint(
                                                      'Error liking story: $e');
                                                }
                                              },
                                              child: profileLiked != 0
                                                  ? isProfileLiked
                                                      ? SizedBox(
                                                          height: 48,
                                                          width: 48,
                                                          child: Icon(
                                                            Icons.favorite,
                                                            color: colorBlue,
                                                            size: 30,
                                                          ),
                                                        )
                                                      : SizedBox(
                                                          height: 48,
                                                          width: 48,
                                                          child: Icon(
                                                            Icons
                                                                .favorite_border,
                                                            color: colorBlue,
                                                            size: 30,
                                                          ),
                                                        )
                                                  : SizedBox(
                                                      height: 48,
                                                      width: 48,
                                                      child: Icon(
                                                        Icons.favorite_border,
                                                        color: colorBlue,
                                                        size: 30,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 25,
                                            right: 95,
                                            child: profileLiked != 0
                                                ? Text(
                                                    '$profileLiked',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: textColor,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                                  )
                                                : Container(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${listenerDisplayModel1?.data![0].name}, ${listenerDisplayModel1!.data![0].age}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: textColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          listenerDisplayModel1?.data![0].sex ==
                                                  'F'
                                              ? Icon(
                                                  Icons.female,
                                                  size: 24,
                                                  color: textColor,
                                                )
                                              : Icon(
                                                  Icons.male,
                                                  size: 24,
                                                  color: textColor,
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                child: TabBar(
                                  controller: tabController,
                                  tabs: [
                                    Tab(
                                      child: Text('ABOUT ME'.tr,
                                          style: TextStyle(
                                              color: tabController!.index == 0
                                                  ? colorBlue
                                                  : textColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                    ),
                                    Tab(
                                      child: Text('REELS'.tr,
                                          style: TextStyle(
                                              color: tabController!.index == 1
                                                  ? colorBlue
                                                  : textColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                    ),
                                    // Tab(
                                    //   child: Text('GIFTS',
                                    //       style: TextStyle(
                                    //           color: tabController!.index == 2
                                    //               ? colorBlue
                                    //               : textColor,
                                    //           fontWeight: FontWeight.bold,
                                    //           fontSize: 16)),
                                    // ),
                                  ],
                                ),
                              ),
                              // if (selectedIndex == 2)
                              //   giftsList.isNotEmpty
                              //       ? SizedBox(
                              //           width: 380,
                              //           child: ListView.builder(
                              //             shrinkWrap: true,
                              //             physics:
                              //                 const NeverScrollableScrollPhysics(),
                              //             itemCount: giftsList.length,
                              //             padding:
                              //                 const EdgeInsets.only(top: 10),
                              //             itemBuilder: (context, index) {
                              //               return reelGifts(
                              //                 thumbnails[index],
                              //                 giftsList[index]
                              //                     .toString()
                              //                     .replaceAll('{', '')
                              //                     .replaceAll('}', ''),
                              //               );
                              //             },
                              //           ))
                              //       : Container(
                              //           color: detailScreenBgColor,
                              //           height: 50,
                              //           alignment: Alignment.center,
                              //           child: Text(
                              //             'No Reels Found!!',
                              //             style: TextStyle(
                              //                 color: ui_mode == "dark"
                              //                     ? colorWhite
                              //                     : textColor,
                              //                 fontSize: 16,
                              //                 fontWeight: FontWeight.w700),
                              //           )),
                              if (selectedIndex == 1)
                                Container(
                                  color: detailScreenBgColor,
                                  padding: const EdgeInsets.all(5),
                                  width: 400,
                                  child: thumbnails.length > 0
                                      ? GridView.builder(
                                    itemCount: thumbnails.length,
                                    shrinkWrap: true,
                                    physics:
                                    const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                      2, // Number of columns
                                      crossAxisSpacing:
                                      2.0, // Spacing between columns
                                      mainAxisSpacing:
                                      2.0, // Spacing between rows
                                    ),
                                    itemBuilder: (BuildContext context,
                                        int index) {
                                      return thumbnails[index] == ""
                                          ? const Center(
                                        child:
                                        CircularProgressIndicator(),
                                      )
                                          : GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ReelScreen(
                                                    listenerId:
                                                    listenerDisplayModel1!
                                                        .data![0].id
                                                        .toString(),
                                                    selectedIndex:
                                                    index,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: SizedBox(
                                          height: 200,
                                          width: 200,
                                          child: Image.file(
                                              File(thumbnails[
                                              index]),
                                              fit: BoxFit.cover),
                                        ),
                                      );
                                    },
                                  ) : Container(
                                          height: 50,
                                          alignment: Alignment.center,
                                          child: Text(
                                            'No Reels Found!!',
                                            style: TextStyle(
                                                color: ui_mode == "dark"
                                                    ? colorWhite
                                                    : textColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700),
                                          )),
                                ),
                              selectedIndex == 1 || selectedIndex == 2
                                  ? Container()
                                  : Container(
                                      decoration: BoxDecoration(
                                          color: detailScreenBgColor),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            15.0, 15, 15, 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: detailScreenBgColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        12.0, 5, 12, 12),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (!isListener &&
                                                        isBlocked) ...{
                                                      Text(
                                                        'To unblock,\n** Pay 199 for first block count.\n** Pay 299 for second block count.\n** You will be blocked for 3 months for third block count'
                                                            .tr,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: colorRed,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                    },
                                                    // Bio like
                                                    Text(
                                                      listenerDisplayModel1
                                                              ?.data![0]
                                                              .about ??
                                                          '',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: textColor,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        InkWell(
                                                          onTap: () async {
                                                            try {
                                                              if (listenerDisplayModel1!
                                                                      .data![0]
                                                                      .id !=
                                                                  int.parse(SharedPreference
                                                                      .getValue(
                                                                          PrefConstants
                                                                              .MERA_USER_ID))) {
                                                                DocumentSnapshot doc = await _firebase
                                                                    .collection(
                                                                        "bio-likes")
                                                                    .doc(listenerDisplayModel1!
                                                                        .data![
                                                                            0]
                                                                        .id!
                                                                        .toString())
                                                                    .get();
                                                                if (doc
                                                                    .exists) {
                                                                  List<dynamic>
                                                                      list =
                                                                      doc['likes'];
                                                                  List<int>
                                                                      likelist =
                                                                      list.cast<
                                                                          int>();
                                                                  if (likelist.contains(
                                                                      int.parse(
                                                                          SharedPreference.getValue(
                                                                              PrefConstants.MERA_USER_ID)))) {
                                                                    likelist.remove(
                                                                        int.parse(
                                                                            SharedPreference.getValue(PrefConstants.MERA_USER_ID)));
                                                                    setState(
                                                                        () {
                                                                      isBioLiked =
                                                                          false;
                                                                    });
                                                                  } else {
                                                                    likelist.add(
                                                                        int.parse(
                                                                            SharedPreference.getValue(PrefConstants.MERA_USER_ID)));
                                                                    setState(
                                                                        () {
                                                                      isBioLiked =
                                                                          true;
                                                                    });
                                                                  }
                                                                  if (likelist
                                                                      .isNotEmpty) {
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'bio-likes')
                                                                        .doc(listenerDisplayModel1!
                                                                            .data![
                                                                                0]
                                                                            .id!
                                                                            .toString())
                                                                        .update({
                                                                      'likes':
                                                                          likelist
                                                                    });
                                                                  } else {
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'bio-likes')
                                                                        .doc(listenerDisplayModel1!
                                                                            .data![
                                                                                0]
                                                                            .id!
                                                                            .toString())
                                                                        .update({
                                                                      'likes':
                                                                          []
                                                                    });
                                                                  }
                                                                  setState(() {
                                                                    bioLiked = list
                                                                        .length;
                                                                  });
                                                                } else {
                                                                  List<int>
                                                                      list = [
                                                                    int.parse(SharedPreference.getValue(
                                                                        PrefConstants
                                                                            .MERA_USER_ID))
                                                                  ];
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'bio-likes')
                                                                      .doc(listenerDisplayModel1!
                                                                          .data![
                                                                              0]
                                                                          .id!
                                                                          .toString())
                                                                      .set({
                                                                    'likes':
                                                                        list
                                                                  });
                                                                  setState(() {
                                                                    bioLiked = list
                                                                        .length;
                                                                    isBioLiked =
                                                                        true;
                                                                  });
                                                                }
                                                              }
                                                            } catch (e) {
                                                              debugPrint(
                                                                  'Error liking bio: $e');
                                                            }
                                                          },
                                                          child: bioLiked != 0
                                                              ? isBioLiked
                                                                  ? const Icon(
                                                                      Icons
                                                                          .favorite,
                                                                      color: Colors
                                                                          .blue,
                                                                      size: 30,
                                                                    )
                                                                  : const Icon(
                                                                      Icons
                                                                          .favorite_border,
                                                                      color: Colors
                                                                          .blue,
                                                                      size: 30,
                                                                    )
                                                              : const Icon(
                                                                  Icons
                                                                      .favorite_border,
                                                                  color: Colors
                                                                      .blue,
                                                                  size: 30,
                                                                ),
                                                        ),
                                                        isListener &&
                                                                bioLiked != 0
                                                            ? Container()
                                                            : const SizedBox(
                                                                width: 5),
                                                        bioLiked != 0
                                                            ? Text(
                                                                '$bioLiked',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 18,
                                                                  color:
                                                                      textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                ),
                                                              )
                                                            : Container(),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.10,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            detailScreenCardColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          const SizedBox(
                                                              width: 12),
                                                          Column(
                                                            children: [
                                                              const SizedBox(
                                                                  height: 8),
                                                              Icon(
                                                                Icons.interests,
                                                                size: 35,
                                                                color:
                                                                    textColor,
                                                              ),
                                                              Text(
                                                                'Interest'.tr,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 10,
                                                                  color:
                                                                      textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            width: 20,
                                                          ),
                                                          SizedBox(
                                                            height: 50,
                                                            child: Center(
                                                              // marquee text
                                                              child:
                                                                  MarqueeWidget(
                                                                direction: Axis
                                                                    .vertical,
                                                                child: Text(
                                                                  interest,
                                                                  style: TextStyle(
                                                                      color:
                                                                          textColor),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.10,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            detailScreenCardColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              const SizedBox(
                                                                  height: 8),
                                                              Icon(
                                                                Icons.language,
                                                                size: 30,
                                                                color:
                                                                    textColor,
                                                              ),
                                                              Text(
                                                                'Language'.tr,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 10,
                                                                  color:
                                                                      textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          SizedBox(
                                                            height: 50,
                                                            child: Center(
                                                              // marquee text
                                                              child:
                                                                  MarqueeWidget(
                                                                direction: Axis
                                                                    .vertical,
                                                                child: Text(
                                                                  language,
                                                                  style: TextStyle(
                                                                      color:
                                                                          textColor),
                                                                ),
                                                              ),
                                                            ), // Center
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Container(
                                              height: 166,
                                              padding: const EdgeInsets.only(
                                                left: 15,
                                                bottom: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                  color: detailScreenCardColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    right: 166 * 0.04,
                                                    top: 166 * 0.366,
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          avgRating.toString(),
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            color: textColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        RatingBar.builder(
                                                          ignoreGestures: true,
                                                          initialRating: double.tryParse(listenerDisplayModel1
                                                                      ?.data?[0]
                                                                      .ratingReviews!
                                                                      .averageRating
                                                                      ?.toString() ??
                                                                  '0.0') ??
                                                              0.0,
                                                          minRating: 1,
                                                          direction:
                                                              Axis.horizontal,
                                                          allowHalfRating: true,
                                                          itemCount: 5,
                                                          itemSize: 12,
                                                          itemPadding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      1.0),
                                                          itemBuilder:
                                                              (context, _) =>
                                                                  Icon(
                                                            Icons.star,
                                                            color: textColor,
                                                            size: 30,
                                                          ),
                                                          onRatingUpdate:
                                                              (rating) {
                                                            debugPrint(rating
                                                                .toString());
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Chart widget
                                                  SfCartesianChart(
                                                    margin:
                                                        const EdgeInsets.only(
                                                      left: 5,
                                                      right: 80,
                                                    ),
                                                    plotAreaBorderColor:
                                                        textColor
                                                            .withOpacity(0.1),
                                                    title: ChartTitle(
                                                      text:
                                                          'Listener\'s rating',
                                                      textStyle: TextStyle(
                                                        fontSize: 14,
                                                        color: textColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    series: <BarSeries>[
                                                      BarSeries<ReviewData,
                                                          String>(
                                                        name: 'Reviews',
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                          topRight:
                                                              Radius.circular(
                                                                  4),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  4),
                                                        ),
                                                        dataSource: reviewData,
                                                        xValueMapper:
                                                            (ReviewData data,
                                                                    _) =>
                                                                data.reviewStars,
                                                        yValueMapper:
                                                            (ReviewData data,
                                                                    _) =>
                                                                data.reviewCount,
                                                        dataLabelSettings:
                                                            DataLabelSettings(
                                                          isVisible: true,
                                                          textStyle: TextStyle(
                                                            color: textColor,
                                                          ),
                                                        ),
                                                        pointColorMapper:
                                                            (ReviewData data,
                                                                    _) =>
                                                                data.pointColor,
                                                      ),
                                                    ],
                                                    primaryXAxis: CategoryAxis(
                                                      labelStyle: TextStyle(
                                                        color: textColor,
                                                      ),
                                                      majorGridLines:
                                                          MajorGridLines(
                                                        color: textColor
                                                            .withOpacity(0.1),
                                                      ),
                                                    ),
                                                    primaryYAxis: NumericAxis(
                                                      isVisible: false,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Row(
                                              children: [
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      height: 110,
                                                      width: 110,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              detailScreenCardColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            'Chat Charges'.tr,
                                                            style: TextStyle(
                                                                color:
                                                                    textColor,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            listenerDisplayModel1!
                                                                        .data![
                                                                            0]
                                                                        .charge ==
                                                                    "1.00"
                                                                ? '₹ 8/min'.tr
                                                                : '₹ 6/min'.tr,
                                                            style: TextStyle(
                                                                color:
                                                                    textColor,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      height: 110,
                                                      width: 110,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              detailScreenCardColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            'Call Charges'.tr,
                                                            style: TextStyle(
                                                                color:
                                                                    textColor,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            listenerDisplayModel1!
                                                                        .data![
                                                                            0]
                                                                        .charge ==
                                                                    "1.00"
                                                                ? '₹ 10/min'.tr
                                                                : '₹ 6/min'.tr,
                                                            style: TextStyle(
                                                                color:
                                                                    textColor,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      height: 110,
                                                      width: 110,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              detailScreenCardColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            'Video Charges'.tr,
                                                            style: TextStyle(
                                                                color:
                                                                    textColor,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            listenerDisplayModel1!
                                                                        .data![
                                                                            0]
                                                                        .charge ==
                                                                    "1.00"
                                                                ? '₹ 20/min'.tr
                                                                : '₹ 18/min'.tr,
                                                            style: TextStyle(
                                                                color:
                                                                    textColor,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              selectedIndex == 1 || selectedIndex == 2
                                  ? Container()
                                  : Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        color: colorBlack,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            12.0, 10, 12, 10),
                                        child: Center(
                                          child: Text(
                                            'Reviews'.tr,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              color: colorWhite,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              selectedIndex == 1 || selectedIndex == 2
                                  ? Container()
                                  : Container(
                                      decoration: BoxDecoration(
                                        color: detailScreenBgColor,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            15.0, 15, 15, 110),
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: listenerDisplayModel1
                                                    ?.data?[0]
                                                    .ratingReviews
                                                    ?.allReviews
                                                    ?.length ??
                                                0,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return review[index] == true
                                                  ? Container()
                                                  : Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 180,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  RatingBar
                                                                      .builder(
                                                                    ignoreGestures:
                                                                        true,
                                                                    initialRating: double.tryParse(listenerDisplayModel1!
                                                                            .data![0]
                                                                            .ratingReviews!
                                                                            .allReviews![index]
                                                                            .rating
                                                                            .toString()) ??
                                                                        0.0,
                                                                    minRating:
                                                                        1,
                                                                    direction: Axis
                                                                        .horizontal,
                                                                    allowHalfRating:
                                                                        true,
                                                                    itemCount:
                                                                        5,
                                                                    itemSize:
                                                                        30,
                                                                    itemPadding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            1.0),
                                                                    itemBuilder:
                                                                        (context,
                                                                                _) =>
                                                                            Icon(
                                                                      Icons
                                                                          .star,
                                                                      color:
                                                                          textColor,
                                                                      size: 30,
                                                                    ),
                                                                    onRatingUpdate:
                                                                        (rating) {
                                                                      debugPrint(
                                                                          rating
                                                                              .toString());
                                                                    },
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 7,
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            1),
                                                                    child: Text(
                                                                      listenerDisplayModel1!
                                                                              .data![0]
                                                                              .ratingReviews!
                                                                              .allReviews?[index]
                                                                              .review ??
                                                                          '',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color:
                                                                            textColor,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const Spacer(),
                                                            Text(
                                                              listenerDisplayModel1!
                                                                      .data![0]
                                                                      .ratingReviews!
                                                                      .allReviews?[
                                                                          index]
                                                                      .createdAt
                                                                      .toString() ??
                                                                  '0',
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                color:
                                                                    textColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                            if (SharedPreference
                                                                    .getValue(
                                                                        PrefConstants
                                                                            .MERA_USER_ID) ==
                                                                listenerDisplayModel1!
                                                                    .data![0].id
                                                                    .toString()) ...{
                                                              const SizedBox(
                                                                width: 2,
                                                              ),
                                                              PopupMenuButton<
                                                                  String>(
                                                                icon: Icon(
                                                                    Icons
                                                                        .more_vert,
                                                                    color:
                                                                        textColor),
                                                                itemBuilder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return [
                                                                    PopupMenuItem<
                                                                        String>(
                                                                      value:
                                                                          'Report Review',
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () async {
                                                                          Navigator.pop(
                                                                              context,
                                                                              "Notify User");
                                                                          EasyLoading.show(
                                                                              status: 'loading...'.tr);
                                                                          DateTime
                                                                              date =
                                                                              DateTime.now();
                                                                          String
                                                                              currentdate =
                                                                              date.toString();
                                                                          FirebaseFirestore
                                                                              firestore =
                                                                              FirebaseFirestore.instance;
                                                                          DocumentReference doc = firestore.collection('reported_reviews').doc(listenerDisplayModel1!
                                                                              .data![0]
                                                                              .ratingReviews!
                                                                              .allReviews![index]
                                                                              .id!);
                                                                          doc.set({
                                                                            "id":
                                                                                listenerDisplayModel1!.data![0].ratingReviews!.allReviews![index].id!,
                                                                            "from_id":
                                                                                listenerDisplayModel1!.data![0].ratingReviews!.allReviews![index].fromId!,
                                                                            "to_id":
                                                                                listenerDisplayModel1!.data![0].ratingReviews!.allReviews![index].toId!,
                                                                            "rating":
                                                                                listenerDisplayModel1!.data![0].ratingReviews!.allReviews![index].rating!,
                                                                            "review":
                                                                                listenerDisplayModel1!.data![0].ratingReviews!.allReviews![index].review ?? "",
                                                                            "created_at":
                                                                                currentdate,
                                                                            "status":
                                                                                "pending"
                                                                          }).then(
                                                                              (value) {
                                                                            EasyLoading.dismiss();
                                                                          }).onError((error,
                                                                              stackTrace) {
                                                                            EasyLoading.dismiss();
                                                                            debugPrint(error.toString());
                                                                          });
                                                                        },
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            const Icon(Icons.report,
                                                                                color: Colors.blueAccent),
                                                                            const SizedBox(width: 8),
                                                                            Text(
                                                                              'Report Review'.tr,
                                                                              style: const TextStyle(
                                                                                color: Colors.blueAccent,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ];
                                                                },
                                                              ),
                                                            },
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 10),
                                                        const Divider(),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                      ],
                                                    );
                                            }),
                                      ),
                                    )
                            ],
                          ),
                        ),
                      ),
              ),
            ),
    );
  }
}
