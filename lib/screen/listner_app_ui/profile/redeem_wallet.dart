import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:support/main.dart';
import 'package:support/utils/color.dart';

class RedeemWallet extends StatelessWidget {
  const RedeemWallet({super.key});

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  Widget build(BuildContext context) {
    if(Platform.isAndroid) {
      secureApp();
    }
    return Scaffold(
      backgroundColor: cardColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: colorWhite,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: const Text(
          'Redeem Wallet',
          style: TextStyle(color: colorWhite),
        ),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10,),
            rulesSection("1. ", "UPI Minimum : 1500 & Maximum : 50,000"),
            rulesSection("2.", "Bank Minimum: 10000 & Maximum : 99,000"),
            rulesSection("3.",
                "Listener can send withdrawal request only after one month completion of work."),
            rulesSection("4.",
                "1000 will be locked in your wallet, you can redeem it after resignation accepted"),
            rulesSection("5.",
                "Listener can send withdrawal request from 27th to 30th of every month & you will get your wallet money between 1st to 10th of the coming month."),
            rulesSection("6.",
                "Check bank details and UPI ID before submitting the request."),
          ],
        ),
      ),
    );
  }

  Widget rulesSection(String num, String content) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            num,
            style: TextStyle(
              fontWeight: FontWeight.w500,
                fontSize: 14,
                color: ui_mode == "dark" ? colorWhite : colorBlack),
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: Text(
              content,
              maxLines: 4,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
          ),
        ],
      ),
    );
  }
}
