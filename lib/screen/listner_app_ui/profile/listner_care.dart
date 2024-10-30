// Home page widget for the Listener Care feature
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:support/main.dart';
import 'package:support/screen/listner_app_ui/Profile/leave_form.dart';
import 'package:support/screen/listner_app_ui/Profile/update_profile.dart';
import 'package:support/screen/listner_app_ui/profile/complaint_form.dart';
import 'package:support/screen/listner_app_ui/profile/manual.dart';
import 'package:support/screen/listner_app_ui/profile/missed_data_screen.dart';
import 'package:support/screen/listner_app_ui/profile/redeem_wallet.dart';
import 'package:support/screen/listner_app_ui/profile/resignation_form.dart';
import 'package:support/screen/listner_app_ui/profile/rules.dart';
import 'package:support/screen/listner_app_ui/profile/upload_documents.dart';
import 'package:support/utils/color.dart';

class ListenerCarePage extends StatelessWidget {
  const ListenerCarePage({super.key});

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  Widget build(BuildContext context) {
    if(Platform.isAndroid) {
      secureApp();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Listener Care', // Title displayed in the AppBar
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ui_mode == "dark"
                  ? colorWhite
                  : colorBlack), // White text color for title
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: ui_mode == "dark" ? colorWhite : colorBlack,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        // Transparent background for AppBar
        elevation: 0,
      ),
      extendBodyBehindAppBar: true, // Extend the body behind the AppBar
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: ui_mode == "dark"
                ? [
                    colorBlue,
                    colorBlack, // Light blue color
                  ]
                : [
                    colorWhite,
                    primaryColor,
                  ], // Gradient colors for background
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Padding around the content
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80), // Space below the AppBar
              Text(
                "Please choose a relevant category", // Instruction text
                style: TextStyle(
                  fontSize: 18,
                  // Smaller font size for instruction text
                  color: ui_mode == "dark" ? colorWhite : colorBlack,
                  // Slightly transparent white color
                  fontWeight: FontWeight.w500, // Light font weight
                ),
              ),
              const SizedBox(height: 50), // Space between instruction and grid
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ManualPage()));
                        },
                        child: SizedBox(
                          height: 80,
                          width: 80, // Set height to take full available space
                          child: categoryItem(
                              Icons.book_sharp, "Manual", Colors.orange),
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RulesPage()));
                        },
                        child: SizedBox(
                          height: 80,
                          width: 80, // Set height to take full available space
                          child:
                              categoryItem(Icons.gavel, "Rules", Colors.orange),
                        ),
                      ),
                      const SizedBox(width: 20), // Add space between icons
                      InkWell(
                        onTap: () {
                          log("pressed");
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const MissedDataScreen()));
                        },
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: categoryItem(Icons.reviews_rounded, "Requests",
                              Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // Add space between rows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const UpdateProfile()));
                        },
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: categoryItem(Icons.person_2_rounded,
                              "Edit Profile", Colors.blueAccent),
                        ),
                      ),
                      const SizedBox(width: 20), // Add space between icons
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const LeaveForm()));
                        },
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: categoryItem(Icons.calendar_today, "Leaves",
                              Colors.lightGreen),
                        ),
                      ),
                      const SizedBox(width: 20), // Add space between icons
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const ComplaintForm()));
                        },
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: categoryItem(Icons.report_problem, "Complaint",
                              Colors.purpleAccent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // Add space between rows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const ResignationForm()));
                        },
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: categoryItem(Icons.exit_to_app_rounded,
                              "Resignation", Colors.amber),
                        ),
                      ),
                      const SizedBox(width: 20), // Add space between icons
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const RedeemWallet()));
                        },
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: categoryItem(
                              Icons.wallet, "Redeem", Colors.deepOrangeAccent),
                        ),
                      ),
                      const SizedBox(width: 20), // Add space between icons
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const UploadDocuments()));
                        },
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: categoryItem(Icons.cloud_upload, "Document",
                              Colors.cyanAccent),
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 20), // Add space between rows
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     SizedBox(
                  //       height: 80,
                  //       width: 80,
                  //       child: categoryItem(Icons.question_answer, "Queries",
                  //           Colors.pinkAccent),
                  //     ),
                  //   ],
                  // )
                ],
              ),
              const SizedBox(height: 20), // Space below the grid
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create a category item
  Widget categoryItem(IconData icon, String label, Color iconColor) {
    return Container(
      width: 65, // Set width to take full available space
      height: 60, // Decreased height of the container
      decoration: BoxDecoration(
        color: Colors.grey[300], // Dark grey background color
        borderRadius: BorderRadius.circular(15), // Adjusted corner radius
        boxShadow: const [
          BoxShadow(
            color: Colors.black45, // Shadow color
            offset: Offset(2, 4), // Shadow offset
            blurRadius: 6, // Blur radius of the shadow
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Center content vertically
        children: [
          Icon(
            icon,
            size: 20, // Decreased size of the icon
            color: iconColor, // Color of the icon
          ),
          const SizedBox(height: 3), // Space between icon and text
          Text(
            label, // Label text for the category item
            style: const TextStyle(
              fontSize: 12, // Smaller font size for the label text
              color: colorBlack, // White text color
              fontWeight: FontWeight.w500, // Medium font weight
            ),
          ),
        ],
      ),
    );
  }
}
