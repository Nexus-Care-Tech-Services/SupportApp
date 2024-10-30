import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:support/model/withdrawal_model.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/utils/color.dart';
import 'package:support/screen/listner_app_ui/listner_homescreen.dart';

import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/utils/reuasble_widget/progress_indicator/progress_container_view.dart';
import 'package:support/utils/reuasble_widget/toast_widget.dart';

class WithdrawPage extends StatefulWidget {
  final String? bankNumber;
  final String? bankName;

  const WithdrawPage({Key? key, this.bankNumber, this.bankName})
      : super(key: key);

  @override
  WithdrawPageState createState() => WithdrawPageState();
}

class WithdrawPageState extends State<WithdrawPage> {
  final TextEditingController _amountController = TextEditingController();
  bool upiID = true, bank = false;
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isProgressRunning = false;

  TextEditingController upiIDController = TextEditingController();
  String upiId = '', accountno = '', ifsccode = '', bankname = '';

  TextEditingController bankAccountController = TextEditingController();
  TextEditingController ifsccodeController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();

  String walletAmount = "0.0";

  // WithDrawalModel commonResponseModel;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      secureApp();
    }
    Future.delayed(Duration.zero, () async {
      String amount = await APIServices.getWalletAmount(
              SharedPreference.getValue(PrefConstants.MERA_USER_ID)) ??
          "0.0";
      setState(() {
        walletAmount = amount;
        SharedPreference.setValue(PrefConstants.WALLET_AMOUNT, walletAmount);
      });
    });
    getWithdrawalDetails();
  }

  getWithdrawalDetails() async {
    DocumentSnapshot doc = await _firebase
        .collection("listner_withdrawl_details")
        .doc(SharedPreference.getValue(PrefConstants.MERA_USER_ID))
        .get();

    if (doc.exists) {
      if (upiID && jsonEncode(doc.data()).contains('upi_id')) {
        setState(() {
          upiId = doc['upi_id'].toString();
          upiIDController.text = upiId;
        });
      } else if (bank == true && jsonEncode(doc.data()).contains('bank_name')) {
        setState(() {
          bankname = doc['bank_name'].toString();
          ifsccode = doc['ifsc_code'].toString();
          accountno = doc['account_no'].toString();

          bankNameController.text = bankname;
          ifsccodeController.text = ifsccode;
          bankAccountController.text = accountno;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: cardColor,
      body: ProgressContainerView(
        isProgressRunning: isProgressRunning,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [_otherDetailsCard()],
            ),
          ),
        ),
      ),
      bottomNavigationBar: InkWell(
        onTap: () async {
          DateTime today = DateTime.now();
          if (_amountController.text.isEmpty) {
            toastshowDefaultSnackbar(
                context, 'Please enter amount'.tr, false, primaryColor);
            return;
          }
          if (bank == true) {
            if (bankname == '' && ifsccode == '' && accountno == '') {
              toastshowDefaultSnackbar(
                  context, 'Please fill data'.tr, false, primaryColor);
              return;
            }
          }
          if (upiID == true && upiId.isEmpty) {
            toastshowDefaultSnackbar(
                context, 'Please fill upi id'.tr, false, primaryColor);
            return;
          }
          if ((today.day == 30) ||
              (today.day == 29) ||
              (today.day == 28) ||
              (today.day == 27)) {
            // double withdrawalAmount = double.parse(_amountController.text);

            EasyLoading.show(status: 'loading...'.tr);
            log('upiIDController.text: ${upiIDController.text}');

            if (double.parse(_amountController.text) == 1000) {
              EasyLoading.dismiss();
              toastshowDefaultSnackbar(
                  context,
                  'Maintain min 1000 in your wallet. You can\'t redeem it'.tr,
                  false,
                  primaryColor);
            }
            // else if(double.parse(_amountController.text) < 1500 && upiID == true) {
            //   EasyLoading.dismiss();
            //   toastshowDefaultSnackbar(
            //       context,
            //       'Minimum withdrawal amount is 1500 '.tr,
            //       false,
            //       primaryColor);
            // }
            // else if(double.parse(_amountController.text) < 10000 && bank == true) {
            //   EasyLoading.dismiss();
            //   toastshowDefaultSnackbar(
            //       context,
            //       'Minimum withdrawal amount is 10000 '.tr,
            //       false,
            //       primaryColor);
            // }
            // else if(double.parse(_amountController.text) > 99000 && bank == true) {
            //   EasyLoading.dismiss();
            //   toastshowDefaultSnackbar(
            //       context,
            //       'Maximum withdrawal amount is 99000 '.tr,
            //       false,
            //       primaryColor);
            // }
            else {
              if (_amountController.text == walletAmount) {
                EasyLoading.dismiss();
                toastshowDefaultSnackbar(
                    context,
                    'Maintain min 1000 in your wallet. You can\'t redeem it'.tr,
                    false,
                    primaryColor);
              }
              else {
                WithdrawalModel? withdrawPage =
                await APIServices.withdrawalWalletApi(
                    upiIDController.text,
                    _amountController.text,
                    bankAccountController.text,
                    ifsccodeController.text,
                    bankNameController.text);

                EasyLoading.dismiss();
                if (mounted) {
                  toastshowDefaultSnackbar(
                      context, withdrawPage?.message, false, primaryColor);
                }

                log('withdrawPage: ${withdrawPage?.toJson()}',
                    name: 'withdrawPage');

                if (withdrawPage?.status == true) {
                  EasyLoading.dismiss();

                  if (!mounted) return;
                  toastshowDefaultSnackbar(
                      context, withdrawPage?.message, false, primaryColor);
                } else if (withdrawPage?.status == true &&
                    withdrawPage?.message == 'withdrawal request send'.tr) {
                  EasyLoading.dismiss();
                  if (!mounted) return;
                  showWithdrawalDialog(context, withdrawPage?.message ?? '');
                }
              }
            }
          }
          else {
            upiIDController.clear();
            _amountController.clear();
            setState(() {
              upiId = "";
            });
            toastshowDefaultSnackbar(
                context,
                'Withdrawal request can be sent from 27th to 30th of every month'
                    .tr,
                false,
                primaryColor);
            return;
          }
        },
        child: Card(
          elevation: 0.0,
          child: Container(
            height: 50.0,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: primaryColor,
            ),
            child: Center(
              child: Text(
                'WITHDRAWAL'.tr,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _otherDetailsCard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Your Current Amount'.tr,
                  maxLines: 2,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "₹ ${SharedPreference.getValue(PrefConstants.WALLET_AMOUNT) ?? 10}",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          TextFormField(
            controller: _amountController,
            maxLength: 10,
            keyboardType: const TextInputType.numberWithOptions(
                signed: true, decimal: true),
            decoration: InputDecoration(
              filled: true,
              counterText: "",
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: colorBlack, width: 1.2),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: colorBlack, width: 1.2),
              ),
              disabledBorder: InputBorder.none,
              hintText: "₹ 0.0",
              hintStyle: TextStyle(
                  color: colorGrey,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600),
              fillColor: detailScreenCardColor,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            upiID ? "Min Withdrawal ₹1500".tr : "Min Withdrawal ₹10000".tr,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8.0),
          Container(
            width: double.infinity,
            color: detailScreenCardColor,
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () async {
                      setState(() {
                        upiID = true;
                      });
                    },
                    child: Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: upiID,
                      activeColor: colorBlack,
                      onChanged: (bool? value) {
                        setState(() {
                          upiID = value!;
                          bank = false;
                          bankAccountController.clear();
                          bankNameController.clear();
                          ifsccodeController.clear();

                          //  bank = false;
                        });
                        getWithdrawalDetails();
                      },
                    ),
                  ),
                  Text(
                    "UPI ID",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 30.0),
                  InkWell(
                    onTap: () async {
                      setState(() {
                        bank = true;
                      });
                    },
                    child: Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: bank,
                      activeColor: colorBlack,
                      onChanged: (bool? value) {
                        setState(() {
                          bank = value!;
                          upiID = false;
                          upiIDController.clear();
                        });
                        getWithdrawalDetails();
                      },
                    ),
                  ),
                  Text(
                    "Bank".tr,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Visibility(
                    visible: bank,
                    child: InkWell(
                      onTap: () {
                        showBankAlertDialog(context);
                      },
                      child: Icon(
                        Icons.edit,
                        color: textColor,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14.0),

          // Paytm Click Visibility

          Visibility(
              visible: upiID == true,
              child: Container(
                width: double.infinity,
                color: detailScreenCardColor,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 5, left: 5),
                  child: Row(
                    children: [
                      Text(
                        "UPI ID: ",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (upiId != '')
                        Text(
                          upiId,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        const Text(""),
                      const SizedBox(width: 14.0),
                      InkWell(
                        onTap: () {
                          showPaytmAlertDialog(context);
                        },
                        child: Icon(
                          Icons.edit,
                          color: textColor,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              )),

          // Bank Click Visibility

          Visibility(
            visible: bank == true,
            child: Container(
              width: double.infinity,
              color: detailScreenCardColor,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 10, bottom: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Account no:".tr,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          accountno,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "IFSC Code:".tr,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        if (ifsccode != '') ...{
                          Text(
                            ifsccode,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        } else ...{
                          Text(
                            "",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        },
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Bank Name:".tr,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        if (bankname != '') ...{
                          Text(
                            bankname,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        } else ...{
                          Text(
                            "",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        },
                      ],
                    ),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 14.0),
          Container(
            decoration: BoxDecoration(
              color: detailScreenCardColor,
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 8, top: 5.0, bottom: 1, right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: primaryColor,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        top: 8.0,
                        bottom: 8,
                      ),
                      child: Text(
                        "NOTE:".tr,
                        style: TextStyle(
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.w800,
                          fontSize: 14.0,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    width: double.infinity,
                    color: detailScreenCardColor,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "[1]".tr,
                            style: TextStyle(
                                letterSpacing: 0.2,
                                fontWeight: FontWeight.w400,
                                fontSize: 14.0,
                                color: textColor),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Expanded(
                            child: Text(
                              "UPI Minimum : 1500 & Maximum : 50,000".tr
                                  .tr,
                              maxLines: 2,
                              style: TextStyle(
                                  letterSpacing: 0.2,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.0,
                                  color: textColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "[2]".tr,
                        style: TextStyle(
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.w400,
                            fontSize: 14.0,
                            color: textColor),
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      Expanded(
                        child: Text(
                          "Bank Minimum: 10000 & Maximum : 99,000".tr
                              .tr,
                          maxLines: 2,
                          style: TextStyle(
                              letterSpacing: 0.2,
                              fontWeight: FontWeight.w400,
                              fontSize: 14.0,
                              color: textColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    color: detailScreenCardColor,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "[3]".tr,
                            style: TextStyle(
                                letterSpacing: 0.2,
                                fontWeight: FontWeight.w400,
                                fontSize: 14.0,
                                color: textColor),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Expanded(
                            child: Text(
                              "Listener can send withdrawal request only after one month completion of work.".tr,
                              maxLines: 2,
                              style: TextStyle(
                                  letterSpacing: 0.2,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.0,
                                  color: textColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "[4]".tr,
                        style: TextStyle(
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.w400,
                            fontSize: 14.0,
                            color: textColor),
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      Expanded(
                        child: Text(
                          "1000 will be locked in your wallet, you can redeem it after resignation accepted.".tr,
                          maxLines: 2,
                          style: TextStyle(
                              letterSpacing: 0.2,
                              fontWeight: FontWeight.w400,
                              fontSize: 14.0,
                              color: textColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "[5]".tr,
                        style: TextStyle(
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.w400,
                            fontSize: 14.0,
                            color: textColor),
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      Expanded(
                        child: Text(
                          "Listener can send withdrawal request from 27th to 30th of every month & you will get your wallet money between 1st to 10th of the coming month."
                              .tr,
                          maxLines: 4,
                          style: TextStyle(
                              letterSpacing: 0.2,
                              fontWeight: FontWeight.w400,
                              fontSize: 14.0,
                              color: textColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    color: detailScreenCardColor,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "[6]".tr,
                            style: TextStyle(
                                letterSpacing: 0.2,
                                fontWeight: FontWeight.w400,
                                fontSize: 14.0,
                                color: textColor),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Expanded(
                            child: Text(
                              "Check bank details and UPI ID before submitting the request."
                                  .tr,
                              maxLines: 2,
                              style: TextStyle(
                                  letterSpacing: 0.2,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.0,
                                  color: textColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Text(
                  //       "[7]".tr,
                  //       style: TextStyle(
                  //           letterSpacing: 0.2,
                  //           fontWeight: FontWeight.w400,
                  //           fontSize: 14.0,
                  //           color: textColor),
                  //     ),
                  //     const SizedBox(
                  //       width: 2,
                  //     ),
                  //     Expanded(
                  //       child: Text(
                  //         "You will get a withdrawal amount in your account between 1st to 10th of every month."
                  //             .tr,
                  //         maxLines: 2,
                  //         style: TextStyle(
                  //             letterSpacing: 0.2,
                  //             fontWeight: FontWeight.w400,
                  //             fontSize: 14.0,
                  //             color: textColor),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 5.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getBankDetailsCard() {
    return const Card(
      elevation: 2.0,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: [
            SizedBox(width: 20.0),
          ],
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context, String message) {
    //  set up the button
    Widget okButton = TextButton(
      child: Text("OK".tr),
      onPressed: () {},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: colorWhite,
      // title: Text("My title"),
      content: Text(message),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  showPaytmAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        "Cancel".tr,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget okButton = TextButton(
        child: Text(
          "OK".tr,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        onPressed: () async {
          RegExp upipattern = RegExp("^[0-9A-Za-z.-]{2,256}@[A-Za-z]{2,64}\$");
          if (upiIDController.text.isEmpty) {
            Navigator.pop(context);
            toastshowDefaultSnackbar(
                context, "Please enter your UPI ID".tr, false, primaryColor);
          } else if (upiIDController.text.isNotEmpty &&
              upipattern.hasMatch(upiIDController.text)) {
            var collection = _firebase.collection("listner_withdrawl_details");
            var doc = await collection
                .doc(SharedPreference.getValue(PrefConstants.MERA_USER_ID))
                .get();
            if (doc.exists) {
              _firebase
                  .collection("listner_withdrawl_details")
                  .doc(SharedPreference.getValue(PrefConstants.MERA_USER_ID))
                  .update({"upi_id": upiIDController.text}).then((value) {
                debugPrint("success");
              }, onError: (e) {
                debugPrint("Error $e");
              });
            } else {
              _firebase
                  .collection("listner_withdrawl_details")
                  .doc(SharedPreference.getValue(PrefConstants.MERA_USER_ID))
                  .set({"upi_id": upiIDController.text}).then((value) {
                debugPrint("success");
              }, onError: (e) {
                debugPrint("Error $e");
              });
            }
            getWithdrawalDetails();
            if (context.mounted) {
              Navigator.pop(context);
            }
          } else {
            toastshowDefaultSnackbar(
                context, "Please enter valid UPI ID".tr, false, primaryColor);
          }
          {}
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: colorWhite,
      contentPadding: const EdgeInsets.only(left: 10.0),
      titlePadding: const EdgeInsets.all(0.0),
      // insetPadding: EdgeInsets.all(0.0),
      title: Padding(
        padding: const EdgeInsets.only(left: 15.0, top: 15),
        child: Text(
          "Enter UPI ID".tr,
          style: const TextStyle(
            color: colorBlack,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      content: SizedBox(
        width: double.infinity,
        child: TextField(
          controller: upiIDController,
          decoration: InputDecoration(
            // border: OutlineInputBorder(),
            hintText: 'Enter your UPI ID'.tr,
            hintStyle: TextStyle(
              color: colorGrey,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showBankAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        "Cancel".tr,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget okButton = TextButton(
        child: Text(
          "OK".tr,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        onPressed: () async {
          RegExp ifscpattern = RegExp("^[A-Za-z]{4}0[A-Z0-9a-z]{6}\$");
          if (bankAccountController.text.isNotEmpty &&
              bankNameController.text.isNotEmpty &&
              ifsccodeController.text.isNotEmpty) {
            var collection = _firebase.collection("listner_withdrawl_details");
            var doc = await collection
                .doc(SharedPreference.getValue(PrefConstants.MERA_USER_ID))
                .get();
            if (doc.exists) {
              _firebase
                  .collection("listner_withdrawl_details")
                  .doc(SharedPreference.getValue(PrefConstants.MERA_USER_ID))
                  .update({
                "account_no": bankAccountController.text,
                "bank_name": bankNameController.text,
                "ifsc_code": ifsccodeController.text
              }).then((value) {
                debugPrint("success");
              }, onError: (e) {
                debugPrint("Error $e");
              });
            } else {
              _firebase
                  .collection("listner_withdrawl_details")
                  .doc(SharedPreference.getValue(PrefConstants.MERA_USER_ID))
                  .set({
                "account_no": bankAccountController.text,
                "bank_name": bankNameController.text,
                "ifsc_code": ifsccodeController.text
              }).then((value) {
                debugPrint("success");
              }, onError: (e) {
                debugPrint("Error $e");
              });
            }
            getWithdrawalDetails();
            if (context.mounted) {
              Navigator.pop(context);
            }
          } else if (bankAccountController.text.isNotEmpty &&
              (bankAccountController.text.length < 9 ||
                  bankAccountController.text.length > 18)) {
            Navigator.pop(context);
            toastshowDefaultSnackbar(
                context,
                "Please enter valid Bank Account Number".tr,
                false,
                primaryColor);
          } else if (ifsccodeController.text.isNotEmpty &&
              ifsccodeController.text.length != 11 &&
              !ifscpattern.hasMatch(ifsccodeController.text)) {
            Navigator.pop(context);
            toastshowDefaultSnackbar(context, "Please enter valid IFSC Code".tr,
                false, primaryColor);
          } else {
            Navigator.pop(context);
            toastshowDefaultSnackbar(
                context, "Please fill data".tr, false, primaryColor);
          }
          {}
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: colorWhite,
      contentPadding: const EdgeInsets.only(left: 10.0, right: 10),
      titlePadding: const EdgeInsets.all(0.0),
      // insetPadding: EdgeInsets.all(0.0),
      title: Padding(
        padding: const EdgeInsets.only(left: 15.0, top: 15),
        child: Text(
          "Enter Bank Details".tr,
          style: const TextStyle(
            color: colorBlack,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: bankAccountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                hintText: 'Please enter Account no.'.tr,
                hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorGrey)),
          ),
          TextField(
            controller: ifsccodeController,
            decoration: InputDecoration(
                hintText: 'Please enter IFSC Code'.tr,
                hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorGrey)),
          ),
          TextField(
            controller: bankNameController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                hintText: 'Please enter bank name'.tr,
                hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorGrey)),
          ),
        ],
      ),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // Withdrawal alert

  showWithdrawalDialog(BuildContext context, String message) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK".tr),
      onPressed: () {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => const ListnerHomeScreen(index: 0)),
            (Route<dynamic> route) => false);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: colorWhite,
      title: Text("Successfully".tr),
      content: Text(message),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
