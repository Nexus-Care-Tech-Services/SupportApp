import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scratcher/widgets.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/main.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

import 'package:support/api/api_services.dart';
import 'package:support/screen/home/home_screen.dart';
import 'package:support/utils/color.dart';

class ScratchCardList extends StatefulWidget {
  const ScratchCardList({super.key});

  @override
  State<ScratchCardList> createState() => _ScratchCardListState();
}

class _ScratchCardListState extends State<ScratchCardList> {
  bool isScratched = false;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: cardColor,
      body: FutureBuilder<QuerySnapshot>(
        future: firestore
            .collection("scratch_card_stored")
            .where("card_user_id",
                isEqualTo:
                    SharedPreference.getValue(PrefConstants.MERA_USER_ID))
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No Cards found.'.tr,
                style: TextStyle(
                  color: ui_mode == "dark" ? colorWhite : colorBlack,
                ),
              ),
            );
          } else {
            List<QueryDocumentSnapshot> scratchCard = snapshot.data!.docs;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 1,
              ),
              padding: const EdgeInsets.all(8.0),
              itemCount: scratchCard.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: colorBlue,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: const Offset(3, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: scratchCard[index]['card_status'] == 'unused'
                        ? InkWell(
                            onTap: () => showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                contentPadding: EdgeInsets.zero,
                                backgroundColor: Colors.transparent,
                                content: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Stack(
                                      children: [
                                        TapRegion(
                                          onTapOutside: (event) =>
                                              Navigator.of(context)
                                                  .pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const HomeScreen(),
                                            ),
                                          ),
                                          child: StatefulBuilder(
                                            builder: (context, setState) =>
                                                Scratcher(
                                              brushSize: 50,
                                              threshold: 50,
                                              accuracy: ScratchAccuracy.high,
                                              color: colorWhite,
                                              image: Image.asset(
                                                'assets/scretchlogo.png',
                                                fit: BoxFit.fill,
                                                height: 30,
                                                // width: 150,
                                              ),
                                              onChange: (value) {},
                                              onThreshold: () {
                                                setState(() {
                                                  isScratched = true;
                                                  scratchCard[index]
                                                      .reference
                                                      .update({
                                                    'card_status': 'used'
                                                  });
                                                });
                                              },
                                              child: Container(
                                                height: double.infinity,
                                                width: double.infinity,
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xffF5FAFF),
                                                      Color(0xff128AF8),
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 150,
                                                      height: 150,
                                                      decoration:
                                                          const BoxDecoration(
                                                        image: DecorationImage(
                                                          image: AssetImage(
                                                            'assets/logo2.png',
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    isScratched
                                                        ? RichText(
                                                            textAlign: TextAlign
                                                                .center,
                                                            text: TextSpan(
                                                              text:
                                                                  'Congratulations\n',
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 24,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              children: [
                                                                const TextSpan(
                                                                  text:
                                                                      'You win\n',
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        24,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text: getReward(
                                                                      scratchCard[index]
                                                                              [
                                                                              'card_amount']
                                                                          .toString(),
                                                                      scratchCard[
                                                                              index]
                                                                          [
                                                                          'card_type']),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        18,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            child: const Image(
                              image: AssetImage(
                                'assets/scretchlogo.png',
                              ),
                              fit: BoxFit.contain,
                            ),
                          )
                        : ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              colorGrey,
                              BlendMode.saturation,
                            ),
                            child: Container(
                              height: 300,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xffF5FAFF),
                                    Color(0xff128AF8),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/logo2.png',
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'Congratulations',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                      color: colorBlack,
                                    ),
                                  ),
                                  const Text(
                                    'You win',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                      color: colorBlack,
                                    ),
                                  ),
                                  Text(
                                    getRewardText(
                                      scratchCard[index]['card_amount']
                                          .toString(),
                                      scratchCard[index]['card_type'],
                                    ),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                      color: colorWhite,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  String getRewardText(String amount, String type) {
    switch (type) {
      case 'Money':
        return '$amount ₹';
      case 'LP':
        return '$amount LP';
      case 'RP':
        return '$amount RP';
      default:
        return 'Better luck next time!';
    }
  }

  String getReward(String amount, String type) {
    switch (type) {
      case 'Money':
        debugPrint(amount);
        addMoneyReward(int.parse(amount));
        return '$amount ₹';
      case 'LP':
        addLpReward(int.parse(amount));
        debugPrint(amount);
        return '$amount LP';
      case 'RP':
        addLpReward(int.parse(amount));
        debugPrint(amount);
        return '$amount RP';
      default:
        return 'Better luck next time!';
    }
  }

  void addMoneyReward(int amount) async {
    await APIServices.addMoney(
      SharedPreference.getValue(PrefConstants.MERA_USER_ID),
      amount,
    );
    debugPrint('money added successfully, amount of rp: $amount');
  }

  void addRpReward(int rpPoints) async {
    await APIServices.setUserRate(
      int.parse(SharedPreference.getValue(PrefConstants.MERA_USER_ID)),
      rpPoints,
    );
    debugPrint('Rp added successfully, amount of rp: $rpPoints');
  }

  void addLpReward(int lpPoints) async {
    await APIServices.setUserLp(
      int.parse(SharedPreference.getValue(PrefConstants.MERA_USER_ID)),
      lpPoints,
    );
    debugPrint('Lp added successfully, amount of lp: $lpPoints');
  }
}
