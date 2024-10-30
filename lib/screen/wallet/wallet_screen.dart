import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:support/api/api_services.dart';
import 'package:support/screen/home/home_screen.dart';
import 'package:support/utils/color.dart';
import 'package:support/screen/wallet/recharge_screen.dart';
import 'package:support/screen/wallet/scratch_card_list.dart';
import 'package:support/screen/wallet/transaction_screen.dart';

import 'package:support/api/api_constant.dart';
import 'package:support/sharedpreference/sharedpreference.dart';

class WalletScreen extends StatefulWidget {
  final bool isFromReels;

  const WalletScreen({Key? key, this.isFromReels = false}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String walletAmount = "0.0";

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    Future.delayed(Duration.zero, () async {
      String amount = await APIServices.getWalletAmount(
              SharedPreference.getValue(PrefConstants.MERA_USER_ID)) ??
          "0.0";
      setState(() {
        walletAmount = amount;
        SharedPreference.setValue(PrefConstants.WALLET_AMOUNT, walletAmount);
      });
    });
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        // backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          leading: InkWell(
              onTap: () {
                if (widget.isFromReels) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()));
                } else {
                  Navigator.pop(context);
                }
              },
              child: Icon(Icons.arrow_back, color: textColor)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0, top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹ $walletAmount /-",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    "Current Balance".tr,
                    style: TextStyle(fontSize: 12, color: textColor),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                        icon: SizedBox(
                      height: 50,
                      child: Text("Recharge".tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textColor, fontSize: 13)),
                    )),
                    Tab(
                        icon: SizedBox(
                      height: 50,
                      child: Text("Transaction".tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textColor, fontSize: 13)),
                    )),
                    Tab(
                        icon: SizedBox(
                      height: 50,
                      child: Text("Scratch Cards".tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textColor, fontSize: 13)),
                    )),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    RechargeScreen(),
                    TransactionScreen(),
                    ScratchCardList(),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
