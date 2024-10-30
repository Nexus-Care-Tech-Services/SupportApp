import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/screen/user_leaderboard/listner/post_screen.dart';
import 'package:support/screen/user_leaderboard/user_mood_screen.dart';
import 'package:support/screen/user_leaderboard/user_posts_screen.dart';
import 'package:support/screen/user_leaderboard/user_rating.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/color.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  bool isUploaded = false;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  getStoryDetails() {
    _firebase.collection('emotional_stories').get().then((value) {
      if (value.docs.isNotEmpty) {
        for (int i = 0; i < value.docs.length; i++) {
          Map<String, dynamic> map = value.docs[i].data();
          if (map['user_id'].toString() ==
              SharedPreference.getValue(PrefConstants.MERA_USER_ID)) {
            debugPrint(map['user_id'].toString());
            setState(() {
              isUploaded = true;
            });
          }
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    getStoryDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: detailScreenBgColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 5),
          child: CarouselSlider(
            items: isUploaded
                ? [
                    const UserPostScreen(),
                    const UserRatingScreen(),
                    const UserMoodScreen(),
                  ]
                : [
                    const UserPostScreen(),
                    const UserRatingScreen(),
                    const UserMoodScreen(),
                    const PostScreen(),
                  ],
            options: CarouselOptions(
              height: 620,
              aspectRatio: 16 / 9,
              viewportFraction: 0.8,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: false,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              enlargeFactor: 0.3,
              onPageChanged: (index, reason) {},
              scrollDirection: Axis.horizontal,
            ),
          ),
        ),
      ),
    );
  }
}
