import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:support/main.dart';
import 'package:support/utils/color.dart';

class ManualPage extends StatelessWidget {
  const ManualPage({super.key});

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
        title: const Text('Listener Manual',
            style:
                TextStyle(color: colorWhite)),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "In this Listener Manual, you'll find all the essential information about the Support app and the role of a listener.",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
            const SizedBox(height: 10),
            Text(
              "This guide will walk you through the application’s features, listener responsibilities, and best practices to ensure a positive experience for both you and the users.",
              style: TextStyle(
                  fontSize: 14,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
            const SizedBox(height: 20),
            Text(
              "Introduction to the Support App",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
            const SizedBox(height: 10),
            Text(
              "Support is a comprehensive emotional wellness platform, designed to provide an open and non-judgmental space for people who are navigating personal challenges. Whether it's stress, anxiety, relationship issues, career dilemmas, or academic pressures, our listeners are here 24/7 to offer a compassionate ear.",
              style: TextStyle(
                  fontSize: 14,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
            const SizedBox(height: 10),
            Text(
              "Our mission is simple: Take care of emotional well-being in the digital age.",
              style: TextStyle(
                  fontSize: 14,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
            const SizedBox(height: 20),
            Text(
              "How the Support App Works",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
            const SizedBox(height: 10),
            Text(
              "1. User-Listener Connection: Users can connect with listeners based on their preferences, selecting someone they feel comfortable talking to.",
              style: TextStyle(
                  fontSize: 14,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
            const SizedBox(height: 5),
            Text(
              "2. Anonymity and Open Sharing: Users can freely share their feelings, emotions, and concerns while remaining anonymous.",
              style: TextStyle(
                  fontSize: 14,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
            const SizedBox(height: 5),
            Text(
              "3. Immediate Response from Listeners: Listeners provide an immediate response, focusing on the emotional well-being of the user.",
              style: TextStyle(
                  fontSize: 14,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
            const SizedBox(height: 5),
            Text(
              "4. Pricing Structure: Users pay Rs. 6 per minute for chat, Rs. 6 per minute for audio calls, and Rs. 18 per minute for video calls. Listeners earn Rs. 2.5 per minute for chat, Rs. 3 per minute for audio calls, and Rs. 18 per minute for video calls.",
              style: TextStyle(
                  fontSize: 14,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
            const SizedBox(height: 20),
            Text(
              "Points to Remember as a Listener",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
            const SizedBox(height: 10),
            Text(
              "1. Keep the App Active: Ensure the Support app is running in the background by keeping it in your recent tabs.",
              style: TextStyle(
                  fontSize: 14,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
            const SizedBox(height: 5),
            Text(
              "2. Grant Necessary Permissions: In the app settings, enable permissions for microphone, camera, and phone access.",
              style: TextStyle(
                  fontSize: 14,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
            const SizedBox(height: 5),
            Text(
              "3. Allow Notifications: Make sure all notifications are enabled so you don’t miss any updates or user requests.",
              style: TextStyle(
                  fontSize: 14,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
            const SizedBox(height: 5),
            Text(
              "4. Be Available When Free: Only log in when you are fully available. Once you're online, users may request your support.",
              style: TextStyle(
                  fontSize: 14,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
            const SizedBox(height: 5),
            Text(
              "5. Engage and Build Connections: Try to keep conversations going and establish a strong connection with the user.",
              style: TextStyle(
                  fontSize: 14,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
            const SizedBox(height: 5),
            Text(
              "6. Politeness is Key: Always remain polite and understanding, as it’s essential to creating a comforting environment for the user.",
              style: TextStyle(
                  fontSize: 14,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
            const SizedBox(height: 5),
            Text(
              "7. Keep Track of Valid Funds: While engaging in conversations with users, ensure you are tracking your valid funds.",
              style: TextStyle(
                  fontSize: 14,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
            const SizedBox(height: 5),
            Text(
              "8. Avoid Unnecessary Blocking: Never block any user without a valid reason.",
              style: TextStyle(
                  fontSize: 14,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
            const SizedBox(height: 5),
            Text(
              "9. Toggle Availability: If you are unavailable to take requests, remember to turn your availability toggle off.",
              style: TextStyle(
                  fontSize: 14,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
            const SizedBox(height: 20),
            Text(
              "Thank you for being part of the Support community! Together, we can help foster emotional wellness and provide the support people truly need in today’s world.",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
          ],
        ),
      ),
    );
  }
}
