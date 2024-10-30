import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:scratcher/scratcher.dart';
import 'package:http/http.dart' as http;

import 'package:support/utils/color.dart';
import 'package:support/model/addmoneyinwallet.dart';
import 'package:support/screen/home/home_screen.dart';
import 'package:support/utils/reuasble_widget/toast_widget.dart';

import 'package:support/api/api_constant.dart';
import 'package:support/api/api_services.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/stripe_payments/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class RechargeAmountData {
  String amount;
  bool isSelected;

  RechargeAmountData({required this.amount, required this.isSelected});
}

class RechargeScreen extends StatefulWidget {
  const RechargeScreen({Key? key}) : super(key: key);

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  Map<String, dynamic>? paymentIntent;

  String accessToken = "48bbb510-064b-11ee-b777-fd331606248c";
  String? result;
  bool isScratched = false;
  int gst = 0, totalAmt = 0;

  List<RechargeAmountData> rechargeAmountData = [
    // RechargeAmountData(amount: "1", isSelected: false),
    RechargeAmountData(amount: "99", isSelected: false),
    RechargeAmountData(amount: "199", isSelected: false),
    RechargeAmountData(amount: "299", isSelected: false),
    RechargeAmountData(amount: "499", isSelected: true),
    RechargeAmountData(amount: "999", isSelected: false),
    RechargeAmountData(amount: "2499", isSelected: false),
    RechargeAmountData(amount: "4999", isSelected: false),
  ];

  String amount = "499";
  String scratchAmount = "";
  bool isProgressRunning = false;

  // Razorpay? _razorPayGateWay;
  String? orderId, paymentId, signature;
  String? digit6OrderId = "";
  int amounytController = 100;

  var cfPaymentGatewayService = CFPaymentGatewayService();
  String? cforderId, paymentsessionId, orderStatus;

  secureApp() async =>
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  void createOrder() async {
    try {
      var response =
          await http.post(Uri.parse("https://api.cashfree.com/pg/orders"),
              body: jsonEncode({
                "order_amount": totalAmt.toString(),
                "order_currency": "INR",
                "customer_details": {
                  "customer_id":
                      SharedPreference.getValue(PrefConstants.MERA_USER_ID),
                  "customer_name":
                      SharedPreference.getValue(PrefConstants.LISTENER_NAME),
                  "customer_email":
                      SharedPreference.getValue(PrefConstants.EMAIL),
                  "customer_phone":
                      SharedPreference.getValue(PrefConstants.MOBILE_NUMBER),
                },
                "order_meta": {
                  "return_url": "",
                }
              }),
              headers: {
            'X-Client-Secret': CASHFREE_SECRET_KEY,
            'X-Client-Id': CASHFREE_API_KEY,
            'x-api-version': "2023-08-01",
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          });
      // if (context.mounted) {
      //   toastshowDefaultSnackbar(
      //       context, "response: ${response.body}", false, primaryColor);
      // }
      if (response.statusCode == 200) {
        var map = jsonDecode(response.body);
        setState(() {
          orderId = map['order_id'];
          cforderId = map['cf_order_id'];
          paymentsessionId = map['payment_session_id'];
          orderStatus = map['order_status'];
        });
        webCheckOut();
      }
    } catch (e) {
      log("createOrder $e");
    }
  }

  CFSession? createSession() {
    try {
      CFSession? session = CFSessionBuilder()
          .setEnvironment(CFEnvironment.PRODUCTION)
          .setOrderId(orderId!)
          .setPaymentSessionId(paymentsessionId!)
          .build();
      return session;
    } on CFException catch (e) {
      log("createSession $e");
    }
    return null;
  }

  webCheckOut() async {
    try {
      var session = createSession();
      var cfWebCheckout =
          CFWebCheckoutPaymentBuilder().setSession(session!).build();
      cfPaymentGatewayService.doPayment(cfWebCheckout);
    } on CFException catch (e) {
      log("webCheckOut $e");
    }
  }

  void verifyPayment(String orderId) async {
    AddMoneyIntoWalletModel? addMoneyIntoWalletModel =
        await APIServices.addMoneyintoWallet(
      userId: SharedPreference.getValue(PrefConstants.MERA_USER_ID),
      amount: amount,
      mobileNumber: SharedPreference.getValue(PrefConstants.MOBILE_NUMBER),
      orderId: orderId,
      paymentId: cforderId!,
      signatureId: "done",
    );
    if (addMoneyIntoWalletModel != null) {
      if (mounted) {
        toastshowDefaultSnackbar(
            context, 'Your money added successfully'.tr, false, primaryColor);
        getWalletData();
        _showScratchCard();
        // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    }
    log("Verify Payment");
  }

  void onError(CFErrorResponse errorResponse, String orderId) {
    toastshowDefaultSnackbar(
        context, 'Transaction Failed'.tr, true, primaryColor);
    log("Error while making payment ${errorResponse.getCode()} ${errorResponse.getMessage()}");
  }

  @override
  void initState() {
    if (Platform.isAndroid) {
      secureApp();
    }
    super.initState();
    cfPaymentGatewayService.setCallback(verifyPayment, onError);
    setState(() {
      int amt = int.parse(amount);
      double val = amt * 3 / 99;
      gst = val.round();
      totalAmt = gst + amt;
    });
  }

  void _handlePaymentSuccessStripe(
      String txnId, String orderId, String signId) async {
    AddMoneyIntoWalletModel? addMoneyIntoWalletModel =
        await APIServices.addMoneyintoWallet(
      userId: SharedPreference.getValue(PrefConstants.MERA_USER_ID),
      amount: amount,
      mobileNumber: SharedPreference.getValue(PrefConstants.MOBILE_NUMBER),
      orderId: orderId,
      paymentId: txnId,
      signatureId: signId,
    );

    debugPrint(SharedPreference.getValue(PrefConstants.MERA_USER_ID));
    debugPrint(SharedPreference.getValue(PrefConstants.MOBILE_NUMBER));
    if (addMoneyIntoWalletModel != null) {
      if (mounted) {
        toastshowDefaultSnackbar(
            context, 'Your money added successfully'.tr, false, primaryColor);
        getWalletData();
        _showScratchCard();
      }
    }
    paymentId = txnId;
    debugPrint("PAYMENT ID :: $txnId");
  }

  Future<void> _createNewOrder() async {
    try {
      setState(() {
        isProgressRunning = true;
      });
      // RazorPayOrderIdModel myOrderDetails =
      //     await APIServices.get6digitOrderId(amounytController * 100);
      // if (myOrderDetails.status == true) {
      //   debugPrint("${myOrderDetails.data} $orderId");
      //   orderId = myOrderDetails.data.toString();
      //   await openPaymentOption(myOrderDetails.data ?? 0);
      // }

      //Stripe Integration
      makeStripePayment();

      //OpenPayment Integration
      // makeOpenPayment();
    } catch (e) {
      APIServices.updateErrorLogs(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID),
          '_createNewOrder()');
      debugPrint(e.toString());
      // showErrorDialog(context, e);
    } finally {
      setState(() {
        isProgressRunning = false;
      });
    }
  }

  void _showScratchCard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width * 0.4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                TapRegion(
                  onTapOutside: (event) async {
                    if (!isScratched) {
                      debugPrint('Tap outside!');
                      String reward = getRandomReward();
                      if (reward.contains('LP')) {
                        await APIServices.storeScratchCard(
                          DateTime.now().millisecondsSinceEpoch.toString(),
                          SharedPreference.getValue(PrefConstants.MERA_USER_ID),
                          int.parse(
                              reward.substring(0, reward.length - 2).trim()),
                          'LP',
                          'unused',
                        );
                      } else if (reward.contains('RP')) {
                        await APIServices.storeScratchCard(
                          DateTime.now().millisecondsSinceEpoch.toString(),
                          SharedPreference.getValue(PrefConstants.MERA_USER_ID),
                          int.parse(
                              reward.substring(0, reward.length - 2).trim()),
                          'RP',
                          'unused',
                        );
                      } else if (reward.contains('₹')) {
                        await APIServices.storeScratchCard(
                          DateTime.now().millisecondsSinceEpoch.toString(),
                          SharedPreference.getValue(PrefConstants.MERA_USER_ID),
                          int.parse(
                              reward.substring(0, reward.length - 2).trim()),
                          'Money',
                          'unused',
                        );
                      }
                    }
                    Get.to(() => const HomeScreen());
                  },
                  child: StatefulBuilder(
                    builder: (context, setState) => Scratcher(
                      brushSize: 50,
                      threshold: 50,
                      accuracy: ScratchAccuracy.high,
                      color: colorWhite,
                      image: Image.asset(
                        'assets/scretchlogo.png',
                        fit: BoxFit.fill,
                        height: 30,
                        // width: 150,
                      ),
                      onChange: (value) {},
                      onThreshold: () {
                        setState(() {
                          isScratched = true;
                        });
                      },
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xffF5FAFF),
                              Color(0xff128AF8),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/logo2.png',
                                  ),
                                ),
                              ),
                            ),
                            isScratched
                                ? RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      text: 'Congratulations\n.tr',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        color: colorBlack,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'You win\n'.tr,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                            color: colorBlack,
                                          ),
                                        ),
                                        TextSpan(
                                          text: getRandomReward(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: colorWhite,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Get Wallet Api Method

  Future<void> getWalletData() async {
    try {
      setState(() {
        isProgressRunning = true;
      });
      String? myWalletResp = await APIServices.getWalletAmount(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID));

      if (myWalletResp != null) {
        SharedPreference.setValue(PrefConstants.WALLET_AMOUNT, myWalletResp);
      }
    } catch (error) {
      debugPrint(error.toString());
      // showErrorDialog(context, error);
    } finally {
      setState(() {
        isProgressRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: primaryColor),
            onPressed: () async {
              createOrder();
              // await _createNewOrder();
              // _handlePaymentSuccess(PaymentSuccessResponse("0", "0", "0"));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "PAY NOW".tr,
                style: const TextStyle(fontSize: 18, color: colorWhite),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Wrap(
                children: [
                  for (int i = 0; i < rechargeAmountData.length; i++) ...{
                    GestureDetector(
                      onTap: () {
                        if (mounted) {
                          setState(() {
                            rechargeAmountData[i].isSelected = true;
                            amount = rechargeAmountData[i].amount;
                            for (int j = 0;
                                j < rechargeAmountData.length;
                                j++) {
                              if (i != j) {
                                rechargeAmountData[j].isSelected = false;
                              }
                            }
                            setState(() {
                              int amt = int.parse(amount);
                              double val = amt * 3 / 99;
                              gst = val.round();
                              totalAmt = gst + amt;
                            });
                          });
                        }
                      },
                      child: Container(
                        height: 35,
                        width: 85,
                        margin:
                            const EdgeInsets.only(left: 10, top: 20, right: 10),
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: rechargeAmountData[i].isSelected
                                  ? Colors.green
                                  : Colors.black12,
                            ),
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(25)),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "₹ ${rechargeAmountData[i].amount}/-",
                                  style: TextStyle(
                                    color: rechargeAmountData[i].isSelected
                                        ? Colors.green
                                        : textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  },
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recharge Details".tr,
                    style: TextStyle(color: textColor),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Amount:".tr,
                        style: TextStyle(color: textColor),
                      ),
                      Text(
                        "₹ $amount.0",
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Talktime".tr,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: textColor),
                      ),
                      Text(
                        "$amount.0",
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "GST".tr,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: textColor),
                      ),
                      Text(
                        "$gst.0",
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Amount payable".tr,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: textColor),
                      ),
                      Text(
                        "₹ $totalAmt.0",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: textColor),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 20),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     Container(
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(10),
                  //         color: primaryColor,
                  //       ),
                  //       padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                  //       child: InkWell(
                  //         onTap: () async {
                  //           createOrder();
                  //         },
                  //         child: const Text(
                  //           'PAY NOW',
                  //           style: TextStyle(
                  //               fontWeight: FontWeight.bold,
                  //               fontSize: 14,
                  //               color: colorWhite),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Expanded(
                  //       child: Text(
                  //         "*** For UPI payments, \n Please WhatsApp us on".tr,
                  //         maxLines: 2,
                  //         style: TextStyle(
                  //             fontWeight: FontWeight.bold,
                  //             fontSize: 14,
                  //             color: textColor),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "If unable to pay:".tr,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: textColor),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: primaryColor,
                    ),
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    child: InkWell(
                      onTap: () async {
                        await launchUrl(
                            Uri.parse(
                                "https://wa.me/+919310351710?text=Recharge my account with $amount. UserId - ${SharedPreference.getValue(PrefConstants.MERA_USER_ID)}, Username - ${SharedPreference.getValue(PrefConstants.LISTENER_NAME)}"),
                            mode: LaunchMode.externalApplication);
                      },
                      child: Text(
                        'CONTACT US'.tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: colorWhite),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }

  void makeStripePayment() async {
    try {
      paymentIntent = await createPaymentIntent(totalAmt.toString(), 'INR');
      //Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  // applePay: const PaymentSheetApplePay(merchantCountryCode: '+92',),
                  googlePay: const PaymentSheetGooglePay(
                      currencyCode: "INR", merchantCountryCode: "IN"),
                  style: ThemeMode.dark,
                  merchantDisplayName: 'Support'))
          .then((value) {});

      ///now finally display payment sheeet
      displayPaymentSheet();
    } catch (e, s) {
      debugPrint('exception:$e$s');
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
        'receipt_email': SharedPreference.getValue(PrefConstants.EMAIL),
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $STRIPE_SECRET_KEY',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      // ignore: avoid_print
      print('Payment Intent Body->>> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      // ignore: avoid_print
      print('err charging user: ${err.toString()}');
    }
  }

  displayPaymentSheet() async {
    String generateTxn() {
      math.Random random = math.Random();
      const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
      String result = '';
      for (int i = 0; i < 18; i++) {
        result += chars[random.nextInt(chars.length)];
      }
      return result;
    }

    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: colorBlue,
                          ),
                          Text("Payment Successfull".tr),
                        ],
                      ),
                    ],
                  ),
                ));

        _handlePaymentSuccessStripe(
            generateTxn(), generateTxn(), generateTxn());
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("paid successfully")));

        paymentIntent = null;
      }).onError((error, stackTrace) {
        debugPrint('Error is:--->$error $stackTrace');
      });
    } on StripeException catch (e) {
      debugPrint('Error is:---> $e');
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text("Cancelled ".tr),
              ));
    } catch (e) {
      APIServices.updateErrorLogs(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID),
          'presentPaymentSheet()');
      debugPrint('$e');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;
    return calculatedAmout.toString();
  }

  Map<String, dynamic> getPrice() {
    int minValue = 0;
    int maxValue = 0;
    int lpPoints = 0;
    int rpPoints = 0;

    if (amount == '99') {
      minValue = 0;
      maxValue = 5;
      lpPoints = math.Random().nextInt(25);
    } else if (amount == '199') {
      minValue = 5;
      maxValue = 10;
      lpPoints = math.Random().nextInt(25) + 25;
    } else if (amount == '299') {
      minValue = 10;
      maxValue = 20;
      lpPoints = math.Random().nextInt(50) + 50;
    } else if (amount == '499') {
      minValue = 20;
      maxValue = 40;
      lpPoints = math.Random().nextInt(100) + 100;
    } else if (amount == '999') {
      minValue = 40;
      maxValue = 90;
      lpPoints = math.Random().nextInt(200) + 250;
    } else if (amount == '2499') {
      minValue = 90;
      maxValue = 200;
      lpPoints = math.Random().nextInt(450) + 550;
    } else if (amount == '4999') {
      minValue = 200;
      maxValue = 500;
      lpPoints = math.Random().nextInt(1000) + 1500;
    }

    scratchAmount =
        (math.Random().nextInt(maxValue - minValue + 1) + minValue).toString();
    rpPoints = math.Random().nextInt(maxValue - minValue + 1) + minValue;

    return {
      'scratchAmount': scratchAmount,
      'lpPoints': lpPoints,
      'rpPoints': rpPoints,
    };
  }

  String getRandomReward() {
    Map<String, dynamic> result = getPrice();

    int randomIndex = math.Random().nextInt(3);
    switch (randomIndex) {
      case 0:
        debugPrint(result['scratchAmount'].toString());
        addMoneyReward(int.parse(result['scratchAmount']));
        return '${result['scratchAmount']} ₹';
      case 1:
        addLpReward(result['lpPoints']);
        debugPrint(result['lpPoints'].toString());
        return '${result['lpPoints']} LP';
      case 2:
        addRpReward(result['rpPoints']);
        return '${result['rpPoints']} RP';
      default:
        return 'Better luck next time!';
    }
  }

  void addMoneyReward(int amount) async {
    await APIServices.addMoney(
      SharedPreference.getValue(PrefConstants.MERA_USER_ID),
      amount,
    );
    await APIServices.storeScratchCard(
      DateTime.now().millisecondsSinceEpoch.toString(),
      SharedPreference.getValue(PrefConstants.MERA_USER_ID),
      amount,
      'Money',
      'used',
    );
    debugPrint('money added successfully, amount of rp: $amount');
  }

  void addRpReward(int rpPoints) async {
    await APIServices.setUserRate(
      int.parse(SharedPreference.getValue(PrefConstants.MERA_USER_ID)),
      rpPoints,
    );
    await APIServices.storeScratchCard(
      DateTime.now().millisecondsSinceEpoch.toString(),
      SharedPreference.getValue(PrefConstants.MERA_USER_ID),
      rpPoints,
      'RP',
      'used',
    );
    debugPrint('Rp added successfully, amount of rp: $rpPoints');
  }

  void addLpReward(int lpPoints) async {
    await APIServices.setUserLp(
      int.parse(SharedPreference.getValue(PrefConstants.MERA_USER_ID)),
      lpPoints,
    );
    await APIServices.storeScratchCard(
      DateTime.now().millisecondsSinceEpoch.toString(),
      SharedPreference.getValue(PrefConstants.MERA_USER_ID),
      lpPoints,
      'LP',
      'used',
    );
    debugPrint('Lp added successfully, amount of lp: $lpPoints');
  }
}
