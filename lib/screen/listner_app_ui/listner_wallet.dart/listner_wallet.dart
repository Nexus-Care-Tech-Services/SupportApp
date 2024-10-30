import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:support/api/api_services.dart';
import 'package:support/utils/color.dart';
import 'package:support/screen/wallet/transaction_screen.dart';

import 'package:support/api/api_constant.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/screen/wallet/withdrawal_page_listner.dart';

class ListnerWalletScreen extends StatefulWidget {
  const ListnerWalletScreen({Key? key}) : super(key: key);

  @override
  State<ListnerWalletScreen> createState() => _ListnerWalletScreenState();
}

class _ListnerWalletScreenState extends State<ListnerWalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String walletAmount = "0.0";
  Timer? _timer;
  bool isFirstCall = true;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
    _timer?.cancel();
  }

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
      });
    });
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: backgroundColor,
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back, color: textColor)),
          bottom: TabBar(
            padding: const EdgeInsets.only(left: 40, right: 40),
            controller: _tabController,
            tabs: [
              Tab(
                  icon: FittedBox(
                    fit: BoxFit.fitWidth,
                    child:
                    Text("Transactions".tr, style: TextStyle(color: textColor)),
                  )),
              Tab(
                  icon: FittedBox(
                fit: BoxFit.fitWidth,
                child:
                    Text("Withdrawal".tr, style: TextStyle(color: textColor)),
              )),
            ],
          ),
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
          child: TabBarView(
            controller: _tabController,
            children: const [
              TransactionScreen(),
              WithdrawPage(),
            ],
          ),
        ));
  }
}
