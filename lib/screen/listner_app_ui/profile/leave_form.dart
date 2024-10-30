import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/main.dart';
import 'package:support/utils/color.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/reuasble_widget/toast_widget.dart';

class LeaveForm extends StatefulWidget {
  const LeaveForm({Key? key}) : super(key: key);

  @override
  State<LeaveForm> createState() => _LeaveFormState();
}

class _LeaveFormState extends State<LeaveForm> {
  final TextEditingController startdate = TextEditingController();
  final TextEditingController enddate = TextEditingController();
  final TextEditingController reason = TextEditingController();

  DateTime? startDate, endDate;
  int leavecount = 0;

  String? sdate, edate;

  File? filesdoc;
  String? docSelected = 'No File Selected', docurl;
  Reference? updatestorage;
  final Reference storage = FirebaseStorage.instance.ref();
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;

  getCurrentMonthLeaveCount() async {
    int currentmonth = DateTime.now().month;
    DocumentSnapshot doc = await _firebase
        .collection('listner_leave_count')
        .doc(SharedPreference.getValue(PrefConstants.MERA_USER_ID))
        .get();
    if (doc.exists) {
      if (currentmonth == 1) {
        if (jsonEncode(doc.data()).contains('January')) {
          setState(() {
            leavecount = doc['January'];
          });
        }
      } else if (currentmonth == 2) {
        if (jsonEncode(doc.data()).contains('February')) {
          setState(() {
            leavecount = doc['February'];
          });
        }
      } else if (currentmonth == 3) {
        if (jsonEncode(doc.data()).contains('March')) {
          setState(() {
            leavecount = doc['March'];
          });
        }
      } else if (currentmonth == 4) {
        if (jsonEncode(doc.data()).contains('April')) {
          setState(() {
            leavecount = doc['April'];
          });
        }
      } else if (currentmonth == 5) {
        if (jsonEncode(doc.data()).contains('May')) {
          setState(() {
            leavecount = doc['May'];
          });
        }
      } else if (currentmonth == 6) {
        if (jsonEncode(doc.data()).contains('June')) {
          setState(() {
            leavecount = doc['June'];
          });
        }
      } else if (currentmonth == 7) {
        if (jsonEncode(doc.data()).contains('July')) {
          setState(() {
            leavecount = doc['July'];
          });
        }
      } else if (currentmonth == 8) {
        if (jsonEncode(doc.data()).contains('August')) {
          setState(() {
            leavecount = doc['August'];
          });
        }
      } else if (currentmonth == 9) {
        if (jsonEncode(doc.data()).contains('September')) {
          setState(() {
            leavecount = doc['September'];
          });
        }
      } else if (currentmonth == 10) {
        if (jsonEncode(doc.data()).contains('October')) {
          setState(() {
            leavecount = doc['October'];
          });
        }
      } else if (currentmonth == 11) {
        if (jsonEncode(doc.data()).contains('November')) {
          setState(() {
            leavecount = doc['November'];
          });
        }
      } else if (currentmonth == 12) {
        if (jsonEncode(doc.data()).contains('December')) {
          setState(() {
            leavecount = doc['December'];
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
    getCurrentMonthLeaveCount();
  }

  showLeavesCount() async {
    if (leavecount != 0) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              backgroundColor: detailScreenCardColor,
              title: Text(
                'Leave Count'.tr,
                style: TextStyle(
                    fontSize: 18,
                    color: ui_mode == "dark" ? colorWhite : colorBlack),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Total Leave taken'.tr,
                        style: TextStyle(
                            fontSize: 14,
                            color: ui_mode == "dark" ? colorWhite : colorBlack),
                      ),
                      const Spacer(),
                      Text(
                        leavecount.toString(),
                        style: TextStyle(
                            fontSize: 14,
                            color: ui_mode == "dark" ? colorWhite : colorBlack),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Remaining Leave'.tr,
                        style: TextStyle(
                            fontSize: 14,
                            color: ui_mode == "dark" ? colorWhite : colorBlack),
                      ),
                      const Spacer(),
                      Text(
                        "${6 - leavecount}",
                        style: TextStyle(
                            fontSize: 14,
                            color: ui_mode == "dark" ? colorWhite : colorBlack),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(
                          fontSize: 15,
                          color: ui_mode == "dark" ? colorWhite : colorBlack),
                    )),
              ],
            );
          });
    }
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
          title: const Text(
            'Leave Form',
            style: TextStyle(color: colorWhite),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                onTap: () {
                  showLeavesCount();
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorWhite, width: 1),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    leavecount.toString(),
                    style: const TextStyle(
                      color: colorWhite,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Note:'.tr,
                    style: const TextStyle(
                        color: Colors.teal,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 5,
                ),
                Text(
                    'There will be 6 Leaves free in each month.\nIf you take more than 6 Leaves, we will charge Rs 40 per day.'
                        .tr,
                    style: TextStyle(
                        color: colorBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
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
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: textColor, width: 1),
                    // color: detailScreenCardColor,
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: TextFormField(
                    controller: reason,
                    style: TextStyle(
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Reason',
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
                        controller: startdate,
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
                              initialDate: startDate != null
                                  ? startDate!
                                  : DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2026),
                              builder: (context, child) {
                                return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(),
                                    ),
                                    child: child!);
                              });
                          if (pickedDate != null) {
                            String birthdate =
                                DateFormat('dd-MM-yyyy').format(pickedDate);
                            setState(() {
                              sdate =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
                              startdate.text = birthdate.toString();
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
                              initialDate:
                                  endDate != null ? endDate! : DateTime(2024),
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2026),
                              builder: (context, child) {
                                return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(),
                                    ),
                                    child: child!);
                              });
                          if (pickedDate != null) {
                            String birthdate =
                                DateFormat('dd-MM-yyyy').format(pickedDate);
                            setState(() {
                              edate =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['jpg', 'pdf', 'doc']);
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
                          applyLeave();
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

  void applyLeave() {
    DateTime stdate = DateTime.parse(sdate!);
    DateTime eddate = DateTime.parse(edate!);
    if (reason.text.isEmpty) {
      toastshowDefaultSnackbar(
          context, "Please Provide Reason For Leave", false, primaryColor);
    } else if (startdate.text.isEmpty) {
      toastshowDefaultSnackbar(
          context, "Please Select Start Date For Leave", false, primaryColor);
    } else if (enddate.text.isEmpty) {
      toastshowDefaultSnackbar(
          context, "Please Select End Date For Leave", false, primaryColor);
    } else if (eddate.isBefore(stdate)) {
      toastshowDefaultSnackbar(
          context, "End Date must be after Start Date", false, primaryColor);
    } else {
      DocumentReference doc =
          _firebase.collection('listner_leave_details').doc();
      EasyLoading.show(status: "loading");
      if (docSelected != 'No File Selected') {
        updatestorage = storage.child(
            'listner_profile_docs/listner_leave_documents/${SharedPreference.getValue(PrefConstants.MERA_USER_ID)}_leavedoc_${DateTime.now()}');
        updatestorage!.putFile(filesdoc!).then((value) async {
          String url = await value.ref.getDownloadURL();
          debugPrint("success $url");
          setState(() {
            docurl = url;
          });
          doc.set({
            "id": SharedPreference.getValue(PrefConstants.MERA_USER_ID),
            "name": SharedPreference.getValue(PrefConstants.LISTENER_NAME),
            "reason": reason.text.toString(),
            "leave_doc_url": docurl,
            "start_date": startdate.text.toString(),
            "end_date": enddate.text.toString(),
            "apply_date": DateTime.now().toString(),
            "status": "pending",
          }).then((value) {
            EasyLoading.dismiss();
            EasyLoading.showSuccess('Leave Form Submitted Successfully!');
            reason.clear();
            startdate.clear();
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
          "name": SharedPreference.getValue(PrefConstants.LISTENER_NAME),
          "reason": reason.text.toString(),
          "start_date": startdate.text.toString(),
          "end_date": enddate.text.toString(),
          "apply_date": DateTime.now().toString(),
          "status": "pending",
        }).then((value) {
          EasyLoading.dismiss();
          EasyLoading.showSuccess('Leave Form Submitted Successfully!');
          reason.clear();
          startdate.clear();
          enddate.clear();
          setState(() {
            docSelected = 'No File Selected';
          });
          debugPrint("success");
        }, onError: (e) {
          debugPrint("Error $e");
        });
      }
    }
  }
}
