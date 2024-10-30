import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:support/utils/color.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      secureApp();
    }
    return Scaffold(
      backgroundColor: cardColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        title: Text(
          'About us'.tr,
          style: TextStyle(color: textColor),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
            children: [
              Text(
                "Welcome to **Support: Let’s Talk** – a safe space for your emotional well-being, brought to you by **NexusXcare Tech Services Private Limited**. Our mission is simple yet profound: to provide a platform where everyone can find compassionate support, a listening ear, and the comfort they need during life's ups and downs.",
                style: TextStyle(color: textColor),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "In today's fast-paced world, mental health challenges have become more prevalent, but the stigma surrounding them often keeps people from seeking the help they need. We believe that no one should ever feel alone in their struggles. That’s why we created Support: Let’s Talk, a confidential, non-judgmental platform that offers real-time emotional support through chat, voice, and video calls with trained listeners and mental health professionals.",
                style: TextStyle(color: textColor),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Our app is designed to be accessible, easy to use, and discreet. Whether you’re facing stress, anxiety, relationship issues, or simply need someone to talk to, we are here for you. Our listeners are trained to provide empathetic support, and our platform ensures that your conversations remain completely private and secure.",
                style: TextStyle(color: textColor),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "At Support: Let’s Talk, we understand that everyone’s journey is different. Our services are tailored to meet you where you are, offering the flexibility to choose how you want to connect – whether through a quick chat, an in-depth conversation, or a supportive video call.",
                style: TextStyle(color: textColor),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Join our growing community of users who have found solace, understanding, and connection through our app. We are committed to making mental health support accessible to everyone, anytime, anywhere.",
                style: TextStyle(color: textColor),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "**Support: Let’s Talk** – Because your mental health matters.",
                style: TextStyle(color: textColor),
              ),
            ],
        ),
      ),
          )),
    );
  }
}
