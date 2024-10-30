import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/utils/color.dart';
import 'package:support/model/listner_display_model.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/reuasble_widget/image.dart';
import 'package:support/utils/reuasble_widget/toast_widget.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({Key? key}) : super(key: key);

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  double height = 200, width = 200;
  File? image;
  String? profileimage, interestselect, age, languageselect;
  ListnerDisplayModel? model;
  DateTime? birthDate;

  final TextEditingController dob = TextEditingController();
  final TextEditingController bio = TextEditingController();
  bool isFetching = false;
  List<Map<String, dynamic>> interestlist = [
    {"title": "Career", "isSelect": false},
    {"title": "Stress", "isSelect": false},
    {"title": "Relationship", "isSelect": false},
    {"title": "Loneliness", "isSelect": false},
    {"title": "Breakup", "isSelect": false},
    {"title": "Studies", "isSelect": false},
    {"title": "Friendship", "isSelect": false},
  ];

  List<Map<String, dynamic>> languagelist = [
    {"lang": "English", "isSelect": false},
    {"lang": "Hindi", "isSelect": false},
    {"lang": "Gujarati", "isSelect": false},
    {"lang": "Telugu", "isSelect": false},
    {"lang": "Assamese", "isSelect": false},
    {"lang": "Kannada", "isSelect": false},
    {"lang": "Malayalam", "isSelect": false},
    {"lang": "Marathi", "isSelect": false},
    {"lang": "Odia", "isSelect": false},
    {"lang": "Punjabi", "isSelect": false},
    {"lang": "Tamil", "isSelect": false},
    {"lang": "Bengali", "isSelect": false},
  ];
  List<String> selectedinterest = [], selectedlanguage = [];

  final FirebaseFirestore _firebase = FirebaseFirestore.instance;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  Future getListnerData() async {
    try {
      setState(() {
        isFetching = true;
      });
      ListnerDisplayModel listnermodel = await APIServices.getListnerDataById(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID));
      setState(() {
        model = listnermodel;
        interestselect = listnermodel.data![0].interest;
        age = listnermodel.data![0].age;
        languageselect = listnermodel.data![0].language;
        bio.text = listnermodel.data![0].about!;
      });

      //interest
      var interest = interestselect!.split(",");
      for (int j = 0; j < interestlist.length; j++) {
        for (int i = 0; i < interest.length; i++) {
          if (interest[i] == interestlist[j]["title"]) {
            setState(() {
              interestlist[j]["isSelect"] = true;
            });
          }
        }
      }

      //language
      var language = languageselect!.split(" ");
      for (int j = 0; j < languagelist.length; j++) {
        for (int i = 0; i < language.length; i++) {
          if (language[i] == languagelist[j]["lang"]) {
            setState(() {
              languagelist[j]["isSelect"] = true;
            });
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          isFetching = false;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    getListnerData();
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
            'Update Profile'.tr,
            style: const TextStyle(color: colorWhite),
          ),
        ),
        body: isFetching
            ? const Center(child: CircularProgressIndicator())
            : Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Stack(
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: profileimage != null
                                      ? Image.file(
                                          image!,
                                          width: width,
                                          height: height,
                                          fit: BoxFit.cover,
                                        )
                                      : getImage(
                                          height,
                                          width,
                                          "${APIConstants.BASE_URL}${SharedPreference.getValue(PrefConstants.LISTENER_IMAGE)}",
                                          width,
                                          "assets/logo.png",
                                          BoxShape.circle,
                                          context)),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: InkWell(
                                  onTap: () async {
                                    XFile? img = await ImagePicker()
                                        .pickImage(source: ImageSource.gallery);
                                    if (img != null) {
                                      EasyLoading.show(status: 'loading'.tr);
                                      setState(() {
                                        image = File(img.path);
                                        debugPrint(image!.path);
                                        profileimage = image!.path;
                                      });
                                      String? url =
                                          await APIServices.updateProfileImg(
                                              image);
                                      await _firebase
                                          .collection(
                                              "listner_profile_requests")
                                          .doc()
                                          .set({
                                        "id": SharedPreference.getValue(
                                            PrefConstants.MERA_USER_ID),
                                        "name": SharedPreference.getValue(
                                            PrefConstants.LISTENER_NAME),
                                        "image_url": url!,
                                        "status": "pending",
                                        "created_at": DateFormat("dd-MM-yyyy HH:mm:ss").format(DateTime.now()),
                                      });
                                      EasyLoading.dismiss();
                                      EasyLoading.showInfo(
                                          'Profile Request Submitted');
                                      setState(() {
                                        profileimage = '';
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: primaryColor,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: colorWhite,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
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
                        child: Text(
                          model!.data![0].name!,
                          style: TextStyle(
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Mobile Number',
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
                        child: Text(
                          model!.data![0].mobileNo!,
                          style: TextStyle(
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Age',
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
                        child: Text(
                          age!,
                          style: TextStyle(
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Date of Birth',
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
                            vertical: 10, horizontal: 10),
                        child: TextFormField(
                          controller: dob,
                          readOnly: true,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Birth Date",
                            hintStyle: TextStyle(color: textColor),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: birthDate != null
                                    ? birthDate!
                                    : DateTime(1990),
                                firstDate: DateTime(1950),
                                lastDate: DateTime(2005),
                                builder: (context, child) {
                                  return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(),
                                      ),
                                      child: child!);
                                });
                            if (pickedDate != null) {
                              String birthdate =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
                              calculateage(pickedDate.year);
                              setState(() {
                                birthDate = pickedDate;
                                dob.text = birthdate.toString();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Sex',
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
                        child: Text(
                          model!.data![0].sex!,
                          style: TextStyle(
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Interest',
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
                        child: ListView.builder(
                          itemCount: interestlist.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              side: BorderSide(color: textColor),
                              value: interestlist[index]["isSelect"],
                              onChanged: (value) {
                                setState(() {
                                  interestlist[index]["isSelect"] = value;
                                });
                              },
                              title: Text(
                                interestlist[index]["title"],
                                style: TextStyle(color: textColor),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Language',
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
                        child: ListView.builder(
                          itemCount: languagelist.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              side: BorderSide(color: textColor),
                              value: languagelist[index]["isSelect"],
                              onChanged: (value) {
                                setState(() {
                                  languagelist[index]["isSelect"] = value;
                                });
                              },
                              title: Text(
                                languagelist[index]["lang"],
                                style: TextStyle(color: textColor),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Your Emotional Journey',
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
                        child: TextFormField(
                          controller: bio,
                          style: TextStyle(
                            color: textColor,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          minLines: 1,
                          maxLines: 7,
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
                                updateProfile();
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
                                  'SAVE',
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

  void calculateage(int birthyear) {
    int currentyear = DateTime.now().year;
    setState(() {
      age = (currentyear - birthyear).toString();
    });
  }

  void updateProfile() async {
    selectedinterest.clear();
    selectedlanguage.clear();
    int cntinterest = 0;
    for (int i = 0; i < interestlist.length; i++) {
      if (interestlist[i]["isSelect"] == true) {
        cntinterest = cntinterest + 1;
      }
    }

    if (cntinterest > 3) {
      toastshowDefaultSnackbar(context,
          "More than 3 Interest Selection not allowed", false, primaryColor);
    } else {
      for (int i = 0; i < interestlist.length; i++) {
        if (interestlist[i]["isSelect"] == true) {
          selectedinterest.add(interestlist[i]["title"]);
        }
      }

      for (int i = 0; i < languagelist.length; i++) {
        if (languagelist[i]["isSelect"] == true) {
          selectedlanguage.add(languagelist[i]["lang"]);
        }
      }
      if (dob.text.isEmpty) {
        toastshowDefaultSnackbar(
            context, "Please Select Your Birth Date", false, primaryColor);
      } else if (selectedinterest.isEmpty) {
        toastshowDefaultSnackbar(
            context, "Please Select Your Interests", false, primaryColor);
      } else if (selectedlanguage.isEmpty) {
        toastshowDefaultSnackbar(
            context, "Please Select Your Languages", false, primaryColor);
      } else if (bio.text.isEmpty) {
        toastshowDefaultSnackbar(
            context, "Please Enter Your Bio Data", false, primaryColor);
      } else {
        EasyLoading.show(status: "loading");
        bool result = await APIServices.profileUpdateRequest(
            int.parse(age!), selectedlanguage, selectedinterest, bio.text);
        if (result) {
          EasyLoading.dismiss();
          EasyLoading.showSuccess("Update Request Submitted");
          dob.clear();
          bio.clear();
          if (context.mounted) {
            Navigator.pop(context);
          }
        } else {
          EasyLoading.dismiss();
          EasyLoading.showInfo(
              "Can't send more than one update request per month!");
          dob.clear();
          bio.clear();
        }
      }
    }
  }
}
