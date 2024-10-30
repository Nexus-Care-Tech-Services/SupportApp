import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:support/main.dart';
import 'package:support/utils/color.dart';

class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

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
        title: const Text(
          'Rules and Regulations',
          style: TextStyle(color: colorWhite),
        ),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Text(
              "Rules and Regulations for Listeners",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ui_mode == "dark" ? colorWhite : colorBlack),
            ),
            const SizedBox(height: 10),
            _buildRuleSection(
                "1. Daily Availability",
                "● Listeners are required to be available for a minimum of 3 hours each day across all communication modes: chat, call, and video call.\n"
                    "● These 3 hours must reflect strong connectivity and engagement with users. If you wish to contribute more than 3 hours, you are welcome to do so.\n"
                    "● The 3-hour window is flexible. You can distribute the time across the day, splitting it as per your availability (morning, afternoon, etc.), but the total must add up to 3 hours within 24 hours."),
            _buildRuleSection(
                "2. Active Status",
                "● While using the app, ensure you are active only when fully available. You are expected to respond to user requests within 5 to 10 seconds of receiving them.\n"
                    "● If you are unable to respond immediately, turn your status offline by using the toggle button. The toggle button indicates your availability. Green: You are online.\n"
                    "● When turning your status online or offline, refresh the listener list to update your current availability."),
            _buildRuleSection("3. Missed Requests",
                "A penalty of ₹25 will be applied for every missed chat, call, or video call request. This amount will be deducted from your account for each missed request."),
            _buildRuleSection("4. Leave Policy",
                "You are allowed 6 free leave days per month. Any additional leave beyond this will incur a penalty of ₹40 per day. Leaves cannot be carried over to the next month, and all leave requests must be submitted through the app."),
            _buildRuleSection("5. Inactivity Penalty",
                "Inactive listeners will face a deduction of ₹25 per day of inactivity. If a listener remains inactive for 3 consecutive days, their profile will be deleted on the 4th day."),
            _buildRuleSection("6. Notice Period",
                "If you wish to discontinue your services on the platform, you are required to serve a 1-month notice period. After completing the notice period, you may exit the platform."),
            _buildRuleSection("7. Platform Exclusivity",
                "Listeners on the Support app are prohibited from providing similar services on any other platform. A zero-tolerance policy is enforced, and if it is discovered that you are offering services elsewhere, the company reserves the right to ban your account and impose a penalty of ₹15,000."),
            _buildRuleSection("8. Conduct and Communication",
                "Do not engage in any obscene conversations or violate any user policies. Such behavior will result in immediate banning and the seizure of valid funds. Always provide a positive and supportive response to users. Do not end chats, calls, or video calls unnecessarily."),
            _buildRuleSection(
                "9. Confidentiality",
                "● Do not share personal details such as your name, phone number, social media handles, UPI, or bank details with users.\n"
                    "● Maintain confidentiality about company information, including details about HR, training sessions, rules, and regulations.\n"
                    "● Never share the details of other listeners with users."),
            _buildRuleSection("10. Meetings for Listeners",
                "We are scheduling meetings for listeners to address various issues such as: App-related problems, User concerns, Payment or valid funds issues, and other relevant concerns. You can have a one-on-one conversation with the team on Saturday or Sunday. Meeting links and timings will be provided in your inbox of Support App and Whatsapp."),
            _buildRuleSection("11. Mandatory Meetings",
                "We are scheduling mandatory meetings for all listeners. If you do not attend these meetings, a penalty may be applied. These meetings are essential as important information will be shared with all listeners."),
            const SizedBox(height: 20),
            const Text(
              "Failure to comply with these rules may result in penalties, suspension, or removal from the platform.",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build each rule section
  Widget _buildRuleSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ui_mode == "dark" ? colorWhite : colorBlack),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: TextStyle(
                fontSize: 14,
                color: ui_mode == "dark" ? colorWhite : colorBlack),
          ),
        ],
      ),
    );
  }
}
