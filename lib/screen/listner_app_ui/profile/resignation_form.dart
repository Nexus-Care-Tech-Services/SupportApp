import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/utils/color.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/reuasble_widget/toast_widget.dart';

class ResignationForm extends StatefulWidget {
  const ResignationForm({Key? key}) : super(key: key);

  @override
  State<ResignationForm> createState() => _ResignationFormState();
}

class _ResignationFormState extends State<ResignationForm> {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController resigndate = TextEditingController();
  final TextEditingController enddate = TextEditingController();
  final TextEditingController reason = TextEditingController();

  DateTime? resignDate, endDate, rdate, edate;
  File? filesdoc;
  String? docSelected = 'No File Selected', docurl;
  Reference? updatestorage;
  final Reference storage = FirebaseStorage.instance.ref();
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  bool isResigned = false;
  String? fname, fenddate, fresigndate, freason, fstatus;

  getResignStatus() async {
    var doc = await _firebase.collection("listner_resign_section").get();
    if (doc.docs.isNotEmpty) {
      for (int i = 0; i < doc.docs.length; i++) {
        if (doc.docs[i].data()['id'] ==
            SharedPreference.getValue(PrefConstants.MERA_USER_ID)) {
          setState(() {
            isResigned = true;
            fname = doc.docs[i].data()['name'];
            fresigndate = doc.docs[i].data()['resign_date'];
            fenddate = doc.docs[i].data()['end_date'];
            freason = doc.docs[i].data()['reason'];
            fstatus = doc.docs[i].data()['status'];
          });
        }
      }
    }
  }

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(Platform.isAndroid) {
      secureApp();
    }
    getResignStatus();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
          backgroundColor: primaryColor,
          centerTitle: true,
          title: Text(
            'Resignation Form'.tr,
            style: const TextStyle(color: colorWhite),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: SingleChildScrollView(
            child: isResigned && fstatus != "rejected"
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Name:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorBlack,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            fname!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: colorBlack,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Reason:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorBlack,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        freason!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: colorBlack,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'RESIGN NOTICE PERIOD:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorBlack,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "$fresigndate - $fenddate",
                        style: const TextStyle(
                          fontSize: 16,
                          color: colorBlack,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Text(
                            'Status:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorBlack,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            fstatus!,
                            style: TextStyle(
                                fontSize: 16,
                                color: fstatus == "accepted"
                                    ? Colors.green
                                    : colorBlack,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('*** Process To Resign'.tr,
                          style: const TextStyle(
                              color: Colors.teal,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                          'Once you resign, you need to serve a notice period of 30 days without taking any leaves. You have the option to revoke your resignation in the notice period.\n\nIf you resign and do not revoke your resignation in the notice period and would like to join Support again as a listener after some time then a rejoining fee of ₹10,000 will be charged.'
                              .tr,
                          style: const TextStyle(
                              color: colorRed,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Name',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorGrey,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: textColor, width: 1),
                          // color: detailScreenCardColor,
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        child: TextFormField(
                          controller: name,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(
                            color: textColor,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Name',
                            hintStyle: TextStyle(
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Email ID',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorGrey,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: textColor, width: 1),
                          // color: detailScreenCardColor,
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        child: TextFormField(
                          controller: email,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(
                            color: textColor,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Email',
                            hintStyle: TextStyle(
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Phone Number',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorGrey,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: textColor, width: 1),
                          // color: detailScreenCardColor,
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        child: TextFormField(
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.phone,
                          controller: phone,
                          style: TextStyle(
                            color: textColor,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Phone Number',
                            hintStyle: TextStyle(
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Reason',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorGrey,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: textColor, width: 1),
                          // color: detailScreenCardColor,
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        child: TextFormField(
                          controller: reason,
                          style: TextStyle(
                            color: textColor,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter Your Reason for Resignation Here',
                            hintStyle: TextStyle(
                              color: textColor,
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          minLines: 1,
                          maxLines: 5,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'NOTICE PERIOD DURATION',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorGrey,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(
                            'Start Date',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colorGrey,
                            ),
                          ),
                          const SizedBox(width: 115),
                          Text(
                            'End Date',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colorGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 170,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: textColor, width: 1),
                              // color: detailScreenCardColor,
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: TextFormField(
                              controller: resigndate,
                              textInputAction: TextInputAction.next,
                              readOnly: true,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Start Date",
                                hintStyle: TextStyle(color: textColor),
                              ),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: resignDate != null
                                        ? resignDate!
                                        : DateTime.now(),
                                    firstDate: DateTime(2024),
                                    lastDate: DateTime(2026),
                                    builder: (context, child) {
                                      return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme:
                                                const ColorScheme.light(),
                                          ),
                                          child: child!);
                                    });
                                if (pickedDate != null) {
                                  String birthdate = DateFormat('dd-MM-yyyy')
                                      .format(pickedDate);
                                  setState(() {
                                    rdate = pickedDate;
                                    resigndate.text = birthdate.toString();
                                  });
                                }
                              },
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 170,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: textColor, width: 1),
                              // color: detailScreenCardColor,
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: TextFormField(
                              controller: enddate,
                              textInputAction: TextInputAction.next,
                              readOnly: true,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "End Date",
                                hintStyle: TextStyle(color: textColor),
                              ),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: endDate != null
                                        ? endDate!
                                        : DateTime.now(),
                                    firstDate: DateTime(2024),
                                    lastDate: DateTime(2026),
                                    builder: (context, child) {
                                      return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme:
                                                const ColorScheme.light(),
                                          ),
                                          child: child!);
                                    });
                                if (pickedDate != null) {
                                  String birthdate = DateFormat('dd-MM-yyyy')
                                      .format(pickedDate);
                                  setState(() {
                                    edate = pickedDate;
                                    enddate.text = birthdate.toString();
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Upload Files (Optional)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorGrey,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: textColor, width: 1),
                          // color: detailScreenCardColor,
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        child: Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: [
                                      'jpg',
                                      'pdf',
                                      'doc'
                                    ]);
                                if (result != null) {
                                  filesdoc = File(result.files.single.path!);
                                  setState(() {
                                    docSelected = result.files.single.name;
                                  });
                                } else {
                                  setState(() {
                                    docSelected = "No File Selected";
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text(
                                "Select File",
                                style: TextStyle(color: colorWhite),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            SizedBox(
                                width: 170,
                                child: Text(
                                  docSelected!,
                                  style: TextStyle(color: textColor),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                applyResign();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'SUBMIT',
                                  style: TextStyle(color: colorWhite),
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void applyResign() async {
    RegExp pattern = RegExp(
        r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

    if (name.text.isEmpty) {
      toastshowDefaultSnackbar(
          context, "Please Enter Your Name", false, primaryColor);
    } else if (email.text.isEmpty) {
      toastshowDefaultSnackbar(
          context, "Please Enter Your Email ID", false, primaryColor);
    } else if (!pattern.hasMatch(email.text)) {
      toastshowDefaultSnackbar(
          context, "Please Enter Valid Email ID", false, primaryColor);
    } else if (phone.text.isEmpty) {
      toastshowDefaultSnackbar(
          context, "Please Enter Your Phone Number", false, primaryColor);
    } else if (phone.text.length != 10) {
      toastshowDefaultSnackbar(
          context, "Enter Your Valid Phone Number", false, primaryColor);
    } else if (reason.text.isEmpty) {
      toastshowDefaultSnackbar(
          context, "Please Enter Your Complain", false, primaryColor);
    } else if (resigndate.text.isEmpty) {
      toastshowDefaultSnackbar(
          context, "Please Select Date", false, primaryColor);
    } else if (enddate.text.isEmpty) {
      toastshowDefaultSnackbar(context,
          "Please Select End Date for Notice Period", false, primaryColor);
    } else {
      int days = edate!.difference(rdate!).inDays;
      log(days.toString());
      if (days == 30 || days == 31) {
        DocumentReference doc =
            _firebase.collection('listner_resign_section').doc();
        EasyLoading.show(status: "loading");
        if (docSelected != 'No File Selected') {
          updatestorage = storage.child(
              'listner_profile_docs/resign_documents/${SharedPreference.getValue(PrefConstants.MERA_USER_ID)}_resigndoc_${DateTime.now()}');
          updatestorage!.putFile(filesdoc!).then((value) async {
            String url = await value.ref.getDownloadURL();
            debugPrint("success $url");
            setState(() {
              docurl = url;
            });
            doc.set({
              "id": SharedPreference.getValue(PrefConstants.MERA_USER_ID),
              "name": name.text.toString(),
              "email": email.text.toString(),
              "phone": phone.text.toString(),
              "reason": reason.text.toString(),
              "resign_doc": docurl,
              "resign_date": resigndate.text.toString(),
              "end_date": enddate.text.toString(),
              "status": "pending",
            }).then((value) {
              EasyLoading.dismiss();
              EasyLoading.showSuccess(
                  'Resignation Form Submitted Successfully!');
              name.clear();
              email.clear();
              phone.clear();
              reason.clear();
              resigndate.clear();
              enddate.clear();
              setState(() {
                docSelected = 'No File Selected';
              });
              debugPrint("success");
            }, onError: (e) {
              debugPrint("Error $e");
            });
          }, onError: (e) {
            EasyLoading.dismiss();
            debugPrint("error $e");
          });
        } else {
          doc.set({
            "id": SharedPreference.getValue(PrefConstants.MERA_USER_ID),
            "name": name.text.toString(),
            "email": email.text.toString(),
            "phone": phone.text.toString(),
            "reason": reason.text.toString(),
            "resign_date": resigndate.text.toString(),
            "end_date": enddate.text.toString(),
            "status": "pending",
          }).then((value) {
            EasyLoading.dismiss();
            EasyLoading.showSuccess('Resignation Form Submitted Successfully!');
            name.clear();
            email.clear();
            phone.clear();
            reason.clear();
            resigndate.clear();
            enddate.clear();
            setState(() {
              docSelected = 'No File Selected';
            });
            debugPrint("success");
          }, onError: (e) {
            debugPrint("Error $e");
          });
        }
      } else {
        toastshowDefaultSnackbar(
            context, "Notice Period must be of one month", false, primaryColor);
      }
    }
  }
}
