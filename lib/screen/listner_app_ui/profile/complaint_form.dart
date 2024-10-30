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
import 'package:support/utils/color.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/reuasble_widget/toast_widget.dart';

class ComplaintForm extends StatefulWidget {
  const ComplaintForm({Key? key}) : super(key: key);

  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final TextEditingController complainsection = TextEditingController();

  File? filesdoc;
  String? docSelected = 'No File Selected', docurl;
  Reference? updatestorage;
  final Reference storage = FirebaseStorage.instance.ref();
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  DateFormat format = DateFormat("dd-MM-yyyy");

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(Platform.isAndroid) {
      secureApp();
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
          title: Text(
            'Complaint Form'.tr,
            style: const TextStyle(color: colorWhite),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complaint Section',
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
                    controller: complainsection,
                    style: TextStyle(
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter Your Complain Here',
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
                          submitComplain();
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

  void submitComplain() async {
    if (complainsection.text.isEmpty) {
      toastshowDefaultSnackbar(
          context, "Please Enter Your Complain", false, primaryColor);
    } else {
      DocumentReference doc = _firebase.collection('complain_section').doc();
      EasyLoading.show(status: "loading");
      if (docSelected != 'No File Selected') {
        updatestorage = storage.child(
            'listner_profile_docs/complain_documents/${SharedPreference.getValue(PrefConstants.MERA_USER_ID)}_complaindoc_${DateTime.now()}');
        updatestorage!.putFile(filesdoc!).then((value) async {
          String url = await value.ref.getDownloadURL();
          debugPrint("success $url");
          setState(() {
            docurl = url;
          });
          doc.set({
            "id": SharedPreference.getValue(PrefConstants.MERA_USER_ID),
            "name": SharedPreference.getValue(PrefConstants.LISTENER_NAME),
            "complain": complainsection.text.toString(),
            "complain_doc": docurl,
            "complain_date": format.format(DateTime.now()),
          }).then((value) {
            EasyLoading.dismiss();
            EasyLoading.showSuccess('Complain Submitted Successfully!');
            complainsection.clear();
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
          "complain_date": format.format(DateTime.now()),
          "complain": complainsection.text.toString(),
        }).then((value) {
          EasyLoading.dismiss();
          EasyLoading.showSuccess('Complain Submitted Successfully!');
          complainsection.clear();
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
