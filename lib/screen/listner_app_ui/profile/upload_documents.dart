import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/color.dart';
import 'package:support/utils/reuasble_widget/toast_widget.dart';

class UploadDocuments extends StatefulWidget {
  const UploadDocuments({super.key});

  @override
  State<UploadDocuments> createState() => _UploadDocumentsState();
}

class _UploadDocumentsState extends State<UploadDocuments> {
  File? iddoc, qualificationdoc;
  String? proofDocName = "No File Selected",
      qualificationDocName = "No File Selected",
      idproofurl,
      qualificationurl;
  bool isAlreadyUploaded = false;
  String status = 'pending';

  checkAlreadyUploaded() async {
    DocumentSnapshot biodoc = await _firebase
        .collection("listner_documents")
        .doc(SharedPreference.getValue(PrefConstants.MERA_USER_ID))
        .get();
    if (biodoc.exists) {
      setState(() {
        isAlreadyUploaded = true;
        status = biodoc['status'];
        log(status);
      });
    }
  }

  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  final Reference storage = FirebaseStorage.instance.ref();
  Reference? updatestorage;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    checkAlreadyUploaded();
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
            'Documents'.tr,
            style: const TextStyle(color: colorWhite),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: status == "accepted"
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Your documents are successfully verified!!!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.green,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (status == "rejected") ...{
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        "Your documents are not verified. Please upload your documents again for verification",
                        style: TextStyle(
                            color: colorRed,
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                      ),
                    },
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      'Identity Proof',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorGrey,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: textColor, width: 1),
                        // color: detailScreenCardColor,
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: ['jpg', 'pdf', 'doc']);
                              if (result != null) {
                                iddoc = File(result.files.single.path!);
                                setState(() {
                                  proofDocName = result.files.single.name;
                                });
                              } else {
                                setState(() {
                                  proofDocName = "No File Selected";
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
                              proofDocName!,
                              style: TextStyle(color: textColor),
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Highest Qualification',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorGrey,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: textColor, width: 1),
                        // color: detailScreenCardColor,
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: ['jpg', 'pdf', 'doc']);
                              if (result != null) {
                                qualificationdoc =
                                    File(result.files.single.path!);
                                setState(() {
                                  qualificationDocName =
                                      result.files.single.name;
                                });
                              } else {
                                setState(() {
                                  qualificationDocName = "No File Selected";
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
                                qualificationDocName!,
                                style: TextStyle(color: textColor),
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              uploaddocs();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                'UPLOAD',
                                style: TextStyle(color: colorWhite),
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void uploaddocs() async {
    if (proofDocName == "No File Selected") {
      toastshowDefaultSnackbar(
          context, "Choose ID Proof Document", false, primaryColor);
    } else if (qualificationDocName == "No File Selected") {
      toastshowDefaultSnackbar(
          context, "Choose Qualification Document", false, primaryColor);
    } else {
      EasyLoading.show(status: "loading");
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child(
              'listner_profile_docs/id_proof_documents/${SharedPreference.getValue(PrefConstants.LISTENER_NAME)}_idproof_doc_${DateTime.now()}')
          .putFile(iddoc!, SettableMetadata(contentType: 'application/pdf'));
      TaskSnapshot snapshot = await task;
      String url = await snapshot.ref.getDownloadURL();
      setState(() {
        idproofurl = url;
      });

      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child(
              'listner_profile_docs/qualification_documents/${SharedPreference.getValue(PrefConstants.LISTENER_NAME)}_qualification_doc_${DateTime.now()}')
          .putFile(qualificationdoc!,
              SettableMetadata(contentType: 'application/pdf'));
      TaskSnapshot taskSnapshot = await uploadTask;
      String qurl = await taskSnapshot.ref.getDownloadURL();
      setState(() {
        qualificationurl = qurl;
      });

      if (isAlreadyUploaded) {
        await _firebase
            .collection('listner_documents')
            .doc(SharedPreference.getValue(PrefConstants.MERA_USER_ID))
            .update({
          "id_proof": idproofurl,
          "qualification": qualificationurl,
          "status": "pending"
        });
      } else {
        await _firebase
            .collection('listner_documents')
            .doc(SharedPreference.getValue(PrefConstants.MERA_USER_ID))
            .set({
          "id_proof": idproofurl,
          "qualification": qualificationurl,
          "status": "pending"
        });
      }
      setState(() {
        idproofurl = "";
        qualificationurl = "";
        proofDocName = "No File Selected";
        qualificationDocName = "No File Selected";
      });
      EasyLoading.dismiss();
      EasyLoading.showInfo('Documents Uploaded Successfully');
    }
  }
}
