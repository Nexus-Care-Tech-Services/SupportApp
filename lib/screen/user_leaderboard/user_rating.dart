import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:support/api/api_services.dart';
import 'package:support/main.dart';

import 'package:support/screen/user_leaderboard/blur_list_tile.dart';
import 'package:support/utils/color.dart';
import 'package:support/utils/reuasble_widget/image.dart';

class UserRatingScreen extends StatefulWidget {
  const UserRatingScreen({super.key});

  @override
  State<UserRatingScreen> createState() => _UserRatingScreenState();
}

class _UserRatingScreenState extends State<UserRatingScreen> {
  late Future<Map<String, dynamic>> leaderBoardFuture;
  late List<Map<String, dynamic>> leaderBoardData;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    leaderBoardFuture = fetchLeaderBoardData();
  }

  Future<Map<String, dynamic>> fetchLeaderBoardData() async {
    try {
      Map<String, dynamic> response = await APIServices.getLeaderBoardData();
      return response;
    } catch (e) {
      debugPrint("Error fetching leader board data: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: detailScreenBgColor,
      body: Container(
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
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: colorBlue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Center(
                  child: Text(
                    'Current LeaderBoard'.tr,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorWhite,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            FutureBuilder<Map<String, dynamic>>(
              future: leaderBoardFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Expanded(
                    child: Center(
                      child: Text('Error loading data'.tr,
                          style: TextStyle(
                              color:
                                  ui_mode == "dark" ? colorWhite : colorBlack)),
                    ),
                  );
                } else {
                  leaderBoardData =
                      List<Map<String, dynamic>>.from(snapshot.data!['data']);
                  return _buildLeaderBoard();
                }
              },
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
              child: Text(
                'Top 10 users will get Rewards'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  color: colorWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderBoard() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: 140,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      _buildLeaderBoardItem(leaderBoardData[1], 25),
                      Image.asset(
                        'assets/two.png',
                        height: 25,
                        width: 25,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      _buildLeaderBoardItem(leaderBoardData[0], 35),
                      Image.asset(
                        'assets/one.png',
                        height: 25,
                        width: 25,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      _buildLeaderBoardItem(leaderBoardData[2], 25),
                      Image.asset(
                        'assets/three.png',
                        height: 25,
                        width: 25,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: leaderBoardData.length - 3,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return BlurredListTile(
                    rank: index + 4,
                    points: leaderBoardData[index + 3]['rp_points'] ?? "0.00",
                    name: leaderBoardData[index + 3]['name'] ?? "",
                    imageUrl: leaderBoardData[index + 3]['image'] ?? "",
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderBoardItem(Map<String, dynamic> data, double? radius) {
    return Column(
      children: [
        data['name'] != "Anonymous"
            ? showImage(radius ?? 25, NetworkImage(data['image'] ?? ''))
            : showIcon(0.0, colorWhite, Icons.person, 20, colorGrey),
        const SizedBox(
          height: 5,
        ),
        Text(
          data['name'] ?? "",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: ui_mode == "dark" ? colorWhite : const Color(0xff4F5357),
          ),
        ),
        Text(
          data['rp_points'] != null
              ? '${data['rp_points'].split(',').first.trim()} RP'
              : "0.00 RP",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ui_mode == "dark" ? colorWhite : const Color(0xff4F5357),
          ),
        ),
      ],
    );
  }
}
