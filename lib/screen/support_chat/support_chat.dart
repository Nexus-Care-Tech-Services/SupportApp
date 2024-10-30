import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:support/main.dart';
import 'package:support/utils/color.dart';
import 'package:support/utils/reuasble_widget/image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:support/api/api_services.dart';
import 'package:support/model/support_chat_model.dart';
import 'package:support/utils/reuasble_widget/listner_image.dart';

class SupportChat extends StatefulWidget {
  final SupportChatModel? supportChatModel;

  const SupportChat({super.key, this.supportChatModel});

  @override
  State<SupportChat> createState() => _SupportChatState();
}

class _SupportChatState extends State<SupportChat> {
  bool isProgressRunning = false;

  late final Uri url;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  Future<void> readMessage() async {
    if (widget.supportChatModel!.allMessages!.isNotEmpty &&
        widget.supportChatModel?.allMessages?[0].id != null) {
      for (int i = 0; i < widget.supportChatModel!.allMessages!.length; i++) {
        if (widget.supportChatModel?.allMessages?[i].id != null) {
          await apiMessageRead(widget.supportChatModel?.allMessages?[i].id);
        }
      }
    }
  }

  // Message Read
  Future<void> apiMessageRead(int? messageId) async {
    try {
      setState(() {
        isProgressRunning = true;
      });

      await APIServices.getSupportMessageReadAPI(messageId ?? 1);
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() {
        isProgressRunning = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    readMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              color: colorWhite,
            )),
        title: Text('Support'.tr, style: const TextStyle(color: colorWhite)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 20, 15, 30),
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.supportChatModel?.allMessages?.length ?? 0,
                scrollDirection: Axis.vertical,
                physics: const ScrollPhysics(),
                itemBuilder: (context, index) {
                  widget.supportChatModel?.allMessages?[index].link != null &&
                      widget.supportChatModel!.allMessages![index].link!
                          .isNotEmpty;
                  final Uri url = Uri.parse(
                      widget.supportChatModel?.allMessages?[index].link ?? '');

                  Future<void> launchUrlInApp() async {
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          width: 250,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.shade300,
                                    spreadRadius: 5,
                                    blurRadius: 5)
                              ],
                              color: cardColor),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ListnerImage(
                                              image: getImage(
                                                  MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  double.infinity,
                                                  widget
                                                          .supportChatModel
                                                          ?.allMessages?[index]
                                                          .image ??
                                                      '',
                                                  60,
                                                  "assets/images/logo.png",
                                                  BoxShape.rectangle,
                                                  context))));
                                },
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: getImage(
                                        MediaQuery.of(context).size.height *
                                            0.2,
                                        250,
                                        widget.supportChatModel
                                                ?.allMessages?[index].image ??
                                            '',
                                        60,
                                        "assets/images/logo.png",
                                        BoxShape.rectangle,
                                        context)),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                  widget.supportChatModel?.allMessages?[index]
                                          .title ??
                                      '',
                                  style: TextStyle(color: textColor)),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.supportChatModel
                                              ?.allMessages?[index].message ??
                                          '',
                                      style: TextStyle(
                                        color: ui_mode == "dark"
                                            ? colorWhite
                                            : colorGrey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (widget.supportChatModel
                                                ?.allMessages?[index].link !=
                                            null &&
                                        widget
                                            .supportChatModel!
                                            .allMessages![index]
                                            .link!
                                            .isNotEmpty) ...{
                                      const SizedBox(height: 6),
                                      InkWell(
                                        onTap: () {
                                          launchUrlInApp();
                                        },
                                        child: Text(
                                          widget.supportChatModel
                                                  ?.allMessages?[index].link ??
                                              '',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color: colorBlue,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    }
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }
}
