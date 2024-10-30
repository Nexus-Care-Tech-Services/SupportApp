import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart';
import 'package:support/screen/auth/second_page.dart';
import 'package:support/utils/reuasble_widget/logo.dart';

class PandaAnimationScreen extends StatefulWidget {
  const PandaAnimationScreen({super.key});

  @override
  State<PandaAnimationScreen> createState() => _PandaAnimationScreenState();
}

class _PandaAnimationScreenState extends State<PandaAnimationScreen> {
  late RiveAnimationController _controller;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      secureApp();
    }

    _controller = OneShotAnimation(
      'Move', // Replace with the correct animation name from your Rive file
      autoplay: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Logo(
            height: 170,
            width: 300,
          ),
          Center(
            child: Text(
              "Make New Friends",
              style: GoogleFonts.openSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: Text(
              "Nurture your Well-being",
              style: GoogleFonts.openSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Panda Animation
          SizedBox(
            height: 320,
            width: 500,
            child: RiveAnimation.asset(
              'assets/images/playing_panda.riv',
              fit: BoxFit.cover,
              controllers: [_controller],
            ),
          ),
          Center(
            child: Text(
              "Anonymous",
              style: GoogleFonts.openSans(
                fontSize: 25,
                color: const Color.fromARGB(255, 0, 106, 196),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: Text(
              "Chat | Call | V Call",
              style: GoogleFonts.openSans(
                fontSize: 20,
                color: const Color.fromARGB(255, 0, 106, 196),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SecondPage()));
            },
            child: Container(
              width: 100,
              height: 50,
              margin: const EdgeInsets.only(top: 20, bottom: 15),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.lightBlueAccent,
              ),
              alignment: Alignment.center,
              child: const Text(
                'NEXT',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
