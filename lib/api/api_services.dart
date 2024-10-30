import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:support/model/block_user.dart';
import 'package:support/model/block_user_list.dart';
import 'package:support/model/listner/listener_notification_model.dart';
import 'package:support/model/listner/nick_name_model.dart';
import 'package:support/model/listner_list_model.dart';
import 'package:support/model/missed_data_model.dart';
import 'package:support/model/moods_model.dart';
import 'package:support/model/nickname_get_model.dart';
import 'package:support/model/post_model.dart';
import 'package:support/model/razorpay_orderid.dart';
import 'package:support/model/reaction_model.dart';
import 'package:support/model/recent_listners_model.dart';
import 'package:support/model/reel_model.dart';
import 'package:support/model/send_bell_icon_notification_model.dart';
import 'package:support/model/story_model.dart';

import 'package:support/model/addmoneyinwallet.dart';
import 'package:support/model/agora_data_model.dart';
import 'package:support/model/busy_online.dart';
import 'package:support/model/charge_wallet_model.dart';
import 'package:support/model/chat_notification.dart';
import 'package:support/model/delete_model.dart';
import 'package:support/model/feedback_model.dart';
import 'package:support/model/get_call_id_model.dart';
import 'package:support/model/get_chat_end.dart';
import 'package:support/model/get_chat_end_model.dart';
import 'package:support/model/get_chat_request_from_user.dart';
import 'package:support/model/listner/block_user_model.dart';
import 'package:support/model/listner/listner_availability_model.dart';
import 'package:support/model/listner/listner_chat_request_model.dart';
import 'package:support/model/listner/togglebutton_on_off_model.dart';
import 'package:support/model/listner/update_chat_request_model.dart';
import 'package:support/model/listner_display_model.dart';
import 'package:support/model/register_model.dart';
import 'package:support/model/report_model.dart';
import 'package:support/model/send_chat_id.dart';
import 'package:support/model/show_transaction_model.dart';
import 'package:support/model/support_chat_model.dart';
import 'package:support/model/user_chat_send_request.dart';
import 'package:support/model/withdrawal_model.dart';
import 'package:support/screen/call/call.dart';
import 'package:support/sharedpreference/sharedpreference.dart';
import 'package:support/api/api_constant.dart';
import 'package:support/api/dioclient.dart';
import 'package:http/http.dart' as http;

class APIServices {
  // Register API
  static Future<RegistrationModel> registerAPI(
      String mobileNumber, String deviceToken) async {
    try {
      var response =
          await dio.post(APIConstants.API_BASE_URL + APIConstants.REGISTER_API,
              data: FormData.fromMap({
                "mobile_no": mobileNumber,
                // "helping_category": helpingCategory,
                "device_token": deviceToken,
              }));

      // log("${response.data}", name: 'Before registerAPI');
      // log(response.realUri.path);
      if (response.statusCode == 200) {
        return RegistrationModel.fromJson(response.data);
      } else {
        log("Response data rather than 200");
        return RegistrationModel(
            status: false, message: "Something went wrong", data: null);
      }
    } catch (e) {
      log("registerAPI $e");
      return RegistrationModel(
          status: false, message: "Something went wrong", data: null);
    }
  }

  static Future<RegistrationModel> registerwithEmailAPI(
      String email, String deviceToken) async {
    try {
      var response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.REGISTER_WITH_EMAIL_API,
          data: FormData.fromMap({
            "helping_category": email,
            "device_token": deviceToken,
          }));

      // log("${response.data}", name: 'Before registerAPI');
      // log(response.realUri.path);
      if (response.statusCode == 200) {
        return RegistrationModel.fromJson(response.data);
      } else {
        log("Response data rather than 200");
        return RegistrationModel(
            status: false, message: "Something went wrong", data: null);
      }
    } catch (e) {
      log("registerwithEmailAPI $e");
      return RegistrationModel(
          status: false, message: "Something went wrong", data: null);
    }
  }

  // Listner Display API

  static Future<ListnerDisplayModel> getListnerData() async {
    try {
      var response = await http.get(Uri.parse(
          "${APIConstants.API_BASE_URL}${APIConstants.LISTNER_DISPLAY_API}"));

      debugPrint(response.body);
      if (response.statusCode == 200) {
        // log("${response.data}");
        return ListnerDisplayModel.fromJson(jsonDecode(response.body));
      } else {
        log("Response data rather than 200");
        return ListnerDisplayModel(
            status: false, message: "Something went wrong", data: null);
      }
    } catch (e) {
      log("getListnerData $e");
      return ListnerDisplayModel(
          status: false, message: "Something went wrong", data: null);
    }
  }

  static Future<ListnerListModel> getListnerList(Map query) async {
    try {
      var response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.LISTNER_LIST,
          data: query);

      // debugPrint("Listner List ${response.data}");
      if (response.statusCode == 200) {
        // log("${response.data}");
        return ListnerListModel.fromJson(response.data);
      } else {
        // log("Response data rather than 200");
        return ListnerListModel(
            status: false, message: "Something went wrong", data: null);
      }
    } catch (e) {
      log("getListnerList $e");
      return ListnerListModel(
          status: false, message: "Something went wrong", data: null);
    }
  }

  // Generate 6 digit unique code

  static Future<dynamic> get6digitOrderId(int amount) async {
    try {
      var response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.RAZOR_PAY_ORDERID,
          data: {
            "amount": amount,
          });
      if (response.statusCode == 200) {
        return RazorPayOrderIdModel.fromJson(response.data);
      } else {
        // log("Response data rather than 200");
        return {
          "status": "false",
          "message": "Something went wrong",
          "data": null
        };
      }
    } catch (e) {
      log("get6digitOrderId $e");
      return {
        "status": "false",
        "message": "Something went wrong",
        "data": null
      };
    }
  }

  static Future<ListnerDisplayModel> getListnerDataById(String id) async {
    try {
      var response = await dio.get(APIConstants.API_BASE_URL +
          APIConstants.LISTNER_DISPLAY_API_BY_ID +
          id);

      if (response.statusCode == 200) {
        // log("${response.data}");
        return ListnerDisplayModel.fromJson(response.data);
      } else {
        // log("Response data rather than 200");
        return ListnerDisplayModel(
            status: false, message: "Something went wrong", data: null);
      }
    } catch (e) {
      log("getListnerDataById $e");
      return ListnerDisplayModel(
          status: false, message: "Something went wrong", data: null);
    }
  }

  // Generate 6 digit unique code
  static Future<dynamic> getBusyOnline(
      bool? onlineStatus, String? toUserId) async {
    try {
      var payload = jsonEncode({
        "user_id": toUserId,
        "busy_status": onlineStatus,
      });
      var response = await http.post(
          Uri.parse("${APIConstants.NODE_BASE_URL}${APIConstants.ONLINE_API}"),
          body: payload,
          headers: {"Content-Type": "application/json"});
      debugPrint(response.body);
      if (response.statusCode == 200) {
        // log("${response.data}, name: 'getBusyOnline");
        if (kDebugMode) {
          print(response.body);
        }
        return BusyOnlineModel.fromJson(jsonDecode(response.body));
      } else {
        // log("Response data rather than 200");
        return {
          "status": "false",
          "message": "Something went wrong",
          "data": null
        };
      }
    } catch (e) {
      log("getBusyOnline $e");
      return {
        "status": "false",
        "message": "Something went wrong",
        "data": null
      };
    }
  }

  static Future getAgoraTokens() async {
    try {
      var response =
          await dio.get(APIConstants.API_BASE_URL + APIConstants.CREATE_TOKEN);
      return response.data;
    } catch (e) {
      log("getAgoraTokens $e");
      rethrow;
    }
  }

  static Future<ListnerDisplayModel?> searchListener({required Map map}) async {
    try {
      Response response = await dio
          .post(APIConstants.API_BASE_URL + APIConstants.SEARCH_API, data: map);
      log(response.toString());
      if (response.statusCode == 200) {
        ListnerDisplayModel data = ListnerDisplayModel.fromJson({
          "status": response.data["status"],
          "message": "Successful",
          "data": response.data["search_result"]
        });
        return data;
      } else {
        if (kDebugMode) {
          print("Response code is not 200");
        }
      }
    } catch (e) {
      log("searchListener $e");
    }
    return null;
  }

  static Future<String?> getWalletAmount(String userId) async {
    try {
      var response = await dio
          .get(APIConstants.API_BASE_URL + APIConstants.WALLET_AMOUNT + userId);
      // "${APIConstants.API_BASE_URL}${APIConstants.walletAmountApiUrl}/$userId");
      if (response.statusCode == 200) {
        return response.data["wallet_amount"][0]["wallet_amount"].toString();
      }
    } catch (e) {
      log("getWalletAmount $e");
    }
    return null;
  }

  // Show Transaction History

  static Future<ShowTransactionModel?> getTransactionHistory(
      String userId) async {
    try {
      // ignore: prefer_interpolation_to_compose_strings
      var response = await dio.get(
          APIConstants.API_BASE_URL + APIConstants.SHOW_TRANSACTION + userId);
      log(response.toString());
      if (response.statusCode == 200) {
        return ShowTransactionModel.fromJson(response.data);
      }
    } catch (e) {
      log("getTransactionHistory $e");
    }
    return null;
  }

  static Future<AddMoneyIntoWalletModel?> addMoneyintoWallet(
      {required String userId,
      required String mobileNumber,
      required String paymentId,
      required String orderId,
      required String signatureId,
      required String amount}) async {
    try {
      var response =
          await dio.post(APIConstants.API_BASE_URL + APIConstants.WALLET_STORE,
              data: FormData.fromMap({
                "user_id": userId,
                "mobile_no": mobileNumber,
                "payment_id": paymentId,
                "order_id": orderId,
                "signatre_id": signatureId,
                "cr_amount": amount,
              }));
      if (kDebugMode) {
        print("response is ${response.statusMessage}");
      }
      if (response.statusCode == 200) {
        return AddMoneyIntoWalletModel.fromJson(response.data);
      }
    } catch (e) {
      log("addMoneyintoWallet $e");
    }
    return null;
  }

  static Future<DeleteModel?> getDeleteAccount(String userId) async {
    try {
      var response =
          await dio.post(APIConstants.API_BASE_URL + APIConstants.DELETE_API,
              data: FormData.fromMap({
                "user_id": userId,
              }));

      if (response.statusCode == 200) {
        var data = DeleteModel.fromJson(response.data);
        return data;
      } else {
        // log("Response data rather than 200");
      }
    } catch (e) {
      log("getDeleteAccount $e");
      rethrow;
    }
    return null;
  }

  // Set User NickName
  static Future<NickNameModel?> setNickName(
      String fromId, String userId, String nickName) async {
    try {
      var response = await http.post(
          Uri.parse(APIConstants.NODE_BASE_URL + APIConstants.NICKNAME_API),
          body: {
            "from_id": fromId,
            "to_id": userId,
            "nickname": nickName,
          });

      debugPrint(response.body.toString());
      if (response.statusCode == 200) {
        var data = NickNameModel.fromJson(jsonDecode(response.body));
        return data;
      } else {
        // log("Response data rather than 200");
      }
    } catch (e) {
      log("setNickName $e");
    }
    return null;
  }

  //Get User NickName
  static Future<NicknameGetModel?> getNickName(
      String fromId, String userId) async {
    try {
      var response = await dio.get(
          "${APIConstants.NODE_BASE_URL}${APIConstants.NICKNAME_GET_API}/$fromId?userId=$userId");

      debugPrint(response.toString());
      if (response.statusCode == 200) {
        var data = NicknameGetModel.fromJson(response.data);
        return data;
      } else {
        // log("Response data rather than 200");
      }
    } catch (e) {
      log("getNickName $e");
    }
    return null;
  }

  // Get Notification

  static Future<ChatNotificationModel> getNotification() async {
    String userId = SharedPreference.getValue(PrefConstants.MERA_USER_ID);

    try {
      Response response = await dio.get(
        APIConstants.API_BASE_URL + APIConstants.CHAT_NOTIFY_API + userId,
      );
      if (response.statusCode == 200) {
        return ChatNotificationModel.fromJson(response.data);
      } else {
        return ChatNotificationModel(
            status: false,
            message: "Something went wrong",
            allNotifications: null);
      }
    } catch (e) {
      log('getNotification $e');
      return ChatNotificationModel(
          status: false,
          message: "Something went wrong",
          allNotifications: null);
    }
  }

  // Read Notifications

  static Future<dynamic> readNotificationApi() async {
    try {
      Response response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.CHAT_READ_NOTIFY_API,
          data: FormData.fromMap({
            "user_id": SharedPreference.getValue(PrefConstants.MERA_USER_ID)
          }));
      if (response.statusCode == 200) {
        // log("${response.data}");
        // return ReadNotificationModel.fromJson(response.data);
      }
    } catch (e) {
      log("readNotificationApi $e");
    }
  }

  // Charge Display Model
  static Future<dynamic> chargeWalletDeductionApi(String fromId, String toId,
      String duration, String mode, String sessionId) async {
    try {
      Response response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.CHARGE_WALLET_DEDUCTION,
          data: FormData.fromMap({
            "from_id": fromId,
            "to_id": toId,
            "duration": duration,
            "mode": mode,
            "session_id": sessionId
          }));
      if (response.statusCode == 200) {
        return ChargeWalletModel.fromJson(response.data);
      }
    } catch (e) {
      log("chargeWalletDeductionApi $e");
    }
  }

  // Charge Video Call Display Model
  static Future<dynamic> chargeVideoCallApi(
      String fromId, String toId, String duration, String sessionId) async {
    try {
      Response response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.CHARGE_VIDEO_CALL,
          data: FormData.fromMap({
            "from_id": fromId,
            "to_id": toId,
            "duration": duration,
            "mode": "Video",
            "session_id": sessionId
          }));
      if (response.statusCode == 200) {
        return ChargeWalletModel.fromJson(response.data);
      }
    } catch (e) {
      log("chargeVideoCallApi $e");
    }
  }

  static Future<dynamic> withdrawalWalletApi(String upiId, String amount,
      String accountNo, String ifscCode, String bankName) async {
    try {
      String userId = SharedPreference.getValue(PrefConstants.MERA_USER_ID);
      Response response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.WITHDRAWAL_WALLET,
          data: FormData.fromMap({
            "user_id": userId,
            "upi_id": upiId,
            "amount": amount,
            "account_no": accountNo,
            "ifsc_code": ifscCode,
            "bank_name": bankName,
          }));
      if (response.statusCode == 200) {
        return WithdrawalModel.fromJson(response.data);
      }
    } catch (e) {
      log("withdrawalWalletApi $e");
    }
  }

  static Future<ToggleButtonONOFFModel?> toggleButtonONOFFModel(
    String userId,
  ) async {
    try {
      var response = await http.post(
          Uri.parse(APIConstants.API_BASE_URL + APIConstants.SHOW_TOGGLE_ONOFF),
          body: {"user_id": userId});
      debugPrint(response.body);
      if (response.statusCode == 200) {
        return ToggleButtonONOFFModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      log("toggleButtonONOFFModel $e");
    }
    return null;
  }

  // Listner Availability API
  static Future<ListnerAvaiabilityModel?> listnerAvaiabilityModel(
      String selectAvailability) async {
    try {
      var response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.LISTNER_AVALIABILITY,
          data: FormData.fromMap({
            "available_on": selectAvailability,
            "id": SharedPreference.getValue(PrefConstants.MERA_USER_ID)
          }));
      if (response.statusCode == 200) {
        return ListnerAvaiabilityModel.fromJson(response.data);
      }
    } catch (e) {
      log("listnerAvaiabilityModel $e");
    }
    return null;
  }

  //Send Bell Icon Notification
  static Future<SendBellNotificationModel?> sendBellNotify(
      int listenerId, String senderName, int userid, String image) async {
    try {
      var response = await dio.post(
        APIConstants.NODE_BASE_URL + APIConstants.SEND_BELL_NOTIFICATION,
        data: {
          "listenerId": listenerId,
          "userName": senderName,
          "userId": userid,
          "userDp": image,
        },
      );

      if (response.statusCode == 200) {
        return SendBellNotificationModel.fromJson(response.data);
      }
    } catch (e) {
      log("sendBellNotify $e");
    }
    return null;
  }

  //Send Notification to User
  static Future<SendBellNotificationModel?> sendNotificationUser(
      String listenerName, String image, int userid) async {
    try {
      var response = await dio.post(
        APIConstants.NODE_BASE_URL + APIConstants.SEND_NOTIFICATION_TO_USER,
        data: {
          "listnerName": listenerName,
          "listnerDp": image,
          "userId": userid,
        },
      );

      if (response.statusCode == 200) {
        return SendBellNotificationModel.fromJson(response.data);
      }
    } catch (e) {
      log("sendNotificationUser $e");
    }
    return null;
  }

  //Get Listener Notifications
  static Future<ListenerNotification?> getListenerNotifications(
      int listenerId) async {
    try {
      var response = await dio.get(
          "${APIConstants.NODE_BASE_URL}${APIConstants.GET_LISTENER_NOTIFICATION}/$listenerId");

      if (response.statusCode == 200) {
        return ListenerNotification.fromJson(response.data);
      }
    } catch (e) {
      log("getListenerNotifications $e");
    }
    return null;
  }

  // Report API
  static Future<ReportModel?> reportAPI(
      String userId, String toId, String reason) async {
    try {
      var response =
          await dio.post(APIConstants.API_BASE_URL + APIConstants.REPORT,
              data: FormData.fromMap({
                "from_id": userId,
                "to_id": toId,
                "reason": reason,
              }));
      if (response.statusCode == 200) {
        return ReportModel.fromJson(response.data);
      }
    } catch (e) {
      log("reportAPI $e");
    }
    return null;
  }

  // FeedBack API
  static Future<FeedBackModel?> feedbackAPI(
      String userId, String toId, String rating, String review) async {
    try {
      var response =
          await dio.post(APIConstants.API_BASE_URL + APIConstants.FEEDBACK_API,
              data: FormData.fromMap({
                "from_id": userId,
                "to_id": toId,
                "rating": rating,
                "review": review,
              }));
      if (response.statusCode == 200) {
        return FeedBackModel.fromJson(response.data);
      }
    } catch (e) {
      log("feedbackAPI $e");
    }
    return null;
  }

  //Block API
  static Future<BlockUserModel?> blockAPI(String userId) async {
    try {
      var response =
          await dio.post(APIConstants.API_BASE_URL + APIConstants.BLOCK,
              data: FormData.fromMap({
                "user_id": userId,
              }));
      if (response.statusCode == 200) {
        //  log(response.data.toString());
        return BlockUserModel.fromJson(response.data);
      }
    } catch (e) {
      log("blockAPI $e");
    }
    return null;
  }

  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "support-stress-free",
      "private_key_id": "94e324f7a197a77af6c1f42506f204ca43cb5914",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC7rlphX8o2aPSI\nXJiVHSvcjwGUCaVB7dARi3DGtP1F2VZbMSREMxXpNBUtH5z+m3/QjTBOoakRIR6b\n3/ooHDSIwxiARCczSs5lvwFy6Lq79SOmra7QGY29g4D2jcCr+c5+RAzVfz4A80dz\ntsJPbE+7C4p/CpVf47J2oJo4ptZEwLkF9ieFxgTQ7yrXA4LKPxti+3gY84Pdkg49\nX3cXjheC+WqOUdOiLuoMHm2CBVxL6HxZ2h1zEmC118PFbgAG8opAxsWaclscT08b\nu8vq5izTSxACEe9s7JsrmR6ANXm6sDhXxUqnmbmb0UHQfbBaAG9cWf3TiTAO4HBV\nQcjgerNrAgMBAAECggEADgbP1ms0T7C0ZeSVur89YfSGJ6w4356IaGdFfHRWYXwG\nyjX4AejXgGBWHNM6BoVUnh+PNrE6U39oLDonFgxVmMsL77ooO9shZdVKpG3kVtvR\nWEmuwPrH7xv+7W5WsgOvfRxU4TfrSGLmOi20g/8STmZkaW4/D7WSxu7l18oQRX8I\n6ec6luJFzOSF3ZPJbB21jTA7ts6X0/zctROEVjr6HINUPkonmAiM3ON7p0EQS8QQ\ns3a6tkYi+Mwa8FbWypO8l2UjkRVo3VLWTCKDOdg/e6wQ2hvEbw6gKTj7kUtHQvQa\nzO/ME+sp13iVDx2Vj0tLsYpUFL6MISZvSGo7nAmx4QKBgQDxgsBqm2EeD/wT9pqW\niyuJ6X5JvI8r0K2ST9sFW9+YFDVkrttMISMl4zjeI9ozR6yuHEZEQM9pJInEfSPt\n0OnmcT/Iub/Wypz2xM4IYijWNMnuILRjSF8xkefwROH/fNIHehZsyo+zOdSZbq0l\nP4FXI8hpyrHl1wv3sT+l/AQi+QKBgQDG8NtlaoGB7GsNkWbHqkSBv261XMtGdWOP\nKj0vDfwLApqWq5gXHzIv9kjxK/SeJ3EygwRQ8CcYp9PQAq6tQ2LlFZQBDCG9+5PX\nZnY2SseDXPx0CKMjQO4KlpnUHDxYx3c9QDnXgHaKys+TmI5WypbFmLzFG9VCFJKy\nnJyiTai+gwKBgQCdcFJFbQNTmLIIxZMjHpiEcC1+nihrNL9iCSLLjIfnWQ0xlHer\nWlLSaRzyW0bsdQYR/qaj6egML+CLsdSRPMauDhe5n7V6rVzD1apGds8OTR1yWeme\na1h7NRWRYSY+6jz02Nbzlt00xjdcynSfOpXzm4UTyipMnfLURr0qVG7R6QKBgD2D\nK9Nn4zNxDojbdJQ4KYaU0n5xeskGcwpJXTG3eT9ORs5fsF813ibGWDd6B+D/ARlF\nOYhtOSl+exfOPISGWYXL7j+EqMo9h7EKlXKkHJyZm9Wk9gxofzH27wmO0XoB8vSV\nb00bA4xWuWhBu4FKkuP2Hig0OvR7uABSPHxS1uJRAoGBAIJpVDqwm+AI0DYojBZd\nXxgoHRmW9kJiSQZiRG6QvQxiGjuXkSficrJPjbYxrav6T3GZF7atTX8wnwGdPxBS\nqFCZs3GmEv7ZmvYETsDL53Tmr00s6g3QC8suXp672XBZWhe1T6YnWyqr9Z7dHsWe\nRidTCj+KE0m8YhdbU6vtiXPb\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-z8ufp@support-stress-free.iam.gserviceaccount.com",
      "client_id": "111612693033473587548",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-z8ufp%40support-stress-free.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging",
      "https://www.googleapis.com/auth/firebase.database",
    ];

    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    client.close();

    return credentials.accessToken.data;
  }

  static Future<void> notifyUser(
      {String? deviceToken,
      String? name,
      String? imageDP,
      String? type}) async {
    String accessToken = await getAccessToken();
    const postUrl =
        'https://fcm.googleapis.com/v1/projects/support-stress-free/messages:send';
    String tdata = DateFormat("hh:mm:ss a").format(DateTime.now());
    final data = {
      "message": {
        "notification": {
          "body": type == "listner"
              ? '`India\'s biggest emotional wellness platform'
              : tdata,
          "title": type == "listner"
              ? "$name is Online Now ! 🟢🟢🟢"
              : "$name wants to connect with you!",
          "image": imageDP != '' ? imageDP : ''
          // "sound": 'customsound',
          // 'android_channel_id': 'support1'
        },
        'android': {
          'notification': {
            'channel_id': 'ongoing id',
            'sound': 'default'
          },
        },
        "token": deviceToken
      }
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    var url = Uri.parse(postUrl);

    final response = await http.post(url,
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
    } else {
      log("notifyUser ${response.body}");
    }
  }

  static Future<void> sendNotification({
    String? deviceToken,
    String? listenerId,
    String? userid,
    String? senderName,
    String? senderImageUrl,
    String? cId,
    String? cTn,
    String? uid,
    String? usertype,
  }) async {
    String accessToken = await getAccessToken();
    const postUrl =
        'https://fcm.googleapis.com/v1/projects/support-stress-free/messages:send';
    String tdata = DateFormat("hh:mm:ss a").format(DateTime.now());
    final data = {
      "message": {
        "notification": {
          "body": "at $tdata",
          "title": "Incoming Call from $senderName",
          // "sound": 'customsound',
          // 'android_channel_id': 'support1',
          // 'image_url': senderImageUrl
        },
        'android': {
          'notification': {
            'channel_id': 'support1',
            "sound": 'customsound',
            // "default_sound": false
          },
        },
        "data": {
          "name": senderName,
          "sender_image": senderImageUrl,
          "channel_id": cId,
          "channel_token": cTn,
          "user_id": uid,
          "userid": userid,
          "listenerId": listenerId,
          "to_user_id": SharedPreference.getValue(PrefConstants.MERA_USER_ID),
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "id": "1",
          "status": "done",
          "sound": 'customsound',
          "usertype": usertype,
          // "default_sound": false
        },
        "token": deviceToken
      },
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    var url = Uri.parse(postUrl);

    final response = await http.post(url,
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      // log("sent notification with data: ${response.body}");
      // log("true");
    } else {
      log("failed notification with data: ${response.body}");
      // log("false");
    }
  }

  static Future<void> sendVideoCallNotification({
    String? deviceToken,
    String? senderName,
    String? senderImageUrl,
    String? cId,
    String? cTn,
    String? uid,
    String? listenerId,
    String? userid,
  }) async {
    String accessToken = await getAccessToken();
    const postUrl =
        'https://fcm.googleapis.com/v1/projects/support-stress-free/messages:send';
    String tdata = DateFormat("hh:mm:ss a").format(DateTime.now());
    final data = {
      "message": {
        "notification": {
          "body": "at $tdata",
          "title": "Incoming Video Call from $senderName",
        },
        'android': {
          'notification': {
            'channel_id': 'support1',
            "sound": 'customsound',
          },
        },
        "data": {
          "name": senderName,
          "sender_image": senderImageUrl,
          "channel_id": cId,
          "channel_token": cTn,
          "user_id": uid,
          "userid": userid,
          "listenerId": listenerId,
          "to_user_id": SharedPreference.getValue(PrefConstants.MERA_USER_ID),
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "id": "1",
          "status": "done",
          "sound": 'customsound',
          "type": 'video',
        },
        "token": deviceToken
      }
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    var url = Uri.parse(postUrl);

    final response = await http.post(url,
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      // log("sent notification with data: ${response.body}");
      // log("true");
    } else {
      // log("failed notification with data: ${response.body}");

      // log("false");
    }
  }

  static Future<void> sendAgoraChatNotification({
    String? deviceToken,
    String? senderName,
    String? senderImageUrl,
    String? cId,
    String? cTn,
    String? uid,
    String? listenerId,
    String? userid,
  }) async {
    String accessToken = await getAccessToken();
    const postUrl =
        'https://fcm.googleapis.com/v1/projects/support-stress-free/messages:send';
    String tdata = DateFormat("hh:mm:ss a").format(DateTime.now());
    final data = {
      "message": {
        "notification": {
          "body": "at $tdata",
          "title": "Incoming Chat from $senderName",
        },
        'android': {
          'notification': {
            'channel_id': 'support1',
            "sound": 'customsound',
          },
        },
        "data": {
          "name": senderName,
          "sender_image": senderImageUrl,
          "channel_id": cId,
          "channel_token": cTn,
          "user_id": uid,
          "userid": userid,
          "listenerId": listenerId,
          "to_user_id": SharedPreference.getValue(PrefConstants.MERA_USER_ID),
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "id": "1",
          "status": "done",
          "sound": 'customsound',
          "type": 'chat',
        },
        "token": deviceToken
      }
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    var url = Uri.parse(postUrl);

    final response = await http.post(url,
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      // log("sent notification with data: ${response.body}");
      // log("true");
    } else {
      // log("failed notification with data: ${response.body}");

      // log("false");
    }
  }

  // Chat Push Notification
  static Future<void> sendChatNotification({
    String? deviceToken,
    String? senderName,
  }) async {
    String accessToken = await getAccessToken();
    const postUrl =
        'https://fcm.googleapis.com/v1/projects/support-stress-free/messages:send';
    String tdata = DateFormat("hh:mm:ss a").format(DateTime.now());
    final data = {
      "message": {
        "notification": {
          "body": "at $tdata",
          "title": "Incoming Chat from $senderName",
        },
        'android': {
          'notification': {
            'channel_id': 'support1',
            "sound": 'customsound',
          },
        },
        "data": {
          "name": senderName,
          "to_user_id": SharedPreference.getValue(PrefConstants.MERA_USER_ID),
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "id": "1",
          "status": "done",
          "sound": 'customsound',
        },
        "token": deviceToken
      }
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    var url = Uri.parse(postUrl);

    final response = await http.post(url,
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      // log("sent notification with data: ${response.body}");
      // log("true");
    } else {
      // log("failed notification with data: ${response.body}");

      // log("false");
    }
  }

  static Future<void> sendCustomNotification(
      {String? deviceToken, String? message}) async {
    String accessToken = await getAccessToken();
    const postUrl =
        'https://fcm.googleapis.com/v1/projects/support-stress-free/messages:send';
    String tdata = DateFormat("hh:mm:ss a").format(DateTime.now());
    final data = {
      "message": {
        "notification": {
          "body": "at $tdata",
          "title": "$message",
        },
        'android': {
          'notification': {
            'channel_id': 'ongoing id',
            "sound": 'default',
          },
        },
        "token": deviceToken
      }
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    var url = Uri.parse(postUrl);

    final response = await http.post(url,
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      // log("sent notification with data: ${response.body}");
      // log("true");
    } else {}
  }

  static Future<void> sendChatNotifyNotification(
      {String? deviceToken,
      String? message,
      String? id,
      String? sender}) async {
    String accessToken = await getAccessToken();
    const postUrl =
        'https://fcm.googleapis.com/v1/projects/support-stress-free/messages:send';
    String tdata = DateFormat("hh:mm:ss a").format(DateTime.now());
    final data = {
      "message": {
        "notification": {
          "body": message,
          "title": "Message from $sender at $tdata",
        },
        'android': {
          'notification': {
            'channel_id': 'ongoing id',
            'sound': 'default',
            'tag': id,
          },
        },
        'data': {
          'chat': 'agora',
        },
        "token": deviceToken
      }
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    var url = Uri.parse(postUrl);

    final response = await http.post(url,
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      // log("sent notification with data: ${response.body}");
      // log("true");
    } else {
      log("sendChatNotifyNotification ${response.body}");
    }
  }

  static Future<AgoraRtcUsersJoinChannelStatsModel> getAgoraChannelInfo(
      String channelName) async {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    const authCredentials =
        '36e515a5e3cb4fbdb38b96998bd1e69b:ec729258477c48e19cf0aef30c46d999';
    String encoded = stringToBase64.encode(authCredentials);

    final http.Response response = await http.get(
        Uri.parse(
            'https://api.agora.io/dev/v1/channel/user/$agoraAppId/$channelName'),
        headers: <String, String>{
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Basic $encoded'
        });
    debugPrint(response.body);
    if (response.statusCode == 200) {
      // log(response.body);
      return agoraRtcUsersJoinChannelStatsModelFromJson(response.body);
    } else {
      // log(response.body);

      throw Exception('Failed to get right response.');
    }
  }

  static Future handleRecording(
      Map<String, String> formData, String path) async {
    final http.Response response =
        await http.post(Uri.parse(APIConstants.NODE_BASE_URL + path),
            headers: <String, String>{
              HttpHeaders.acceptHeader: 'application/json',
            },
            body: formData);

    if (response.statusCode == 200) {
      // log(response.body, name: 'start & stop recording');
      return jsonDecode(response.body);
    } else {
      log("handleRecording ${response.body}");
      throw Exception('Failed to get right response.');
    }
  }

  /// Agora Chat API **
  static Future getAgoraChatToken() async {
    try {
      // https://api.supportletstalk.com/api/agora/chat/app-token
      var response = await http.get(
        Uri.parse(
            "${APIConstants.NODE_BASE_URL}${APIConstants.AGORA}${APIConstants.CHAT_TOKEN}"),
      );

      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      log("getAgoraChatToken $e");
    }
  }

  static Future getAgoraChatUserToken(String userid) async {
    try {
      // https://api.supportletstalk.com/api/agora/chat/app-token
      var response = await http.get(
        Uri.parse(
            "${APIConstants.NODE_BASE_URL}${APIConstants.AGORA}${APIConstants.USER_TOKEN}/$userid"),
      );

      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      log("getAgoraChatUserToken $e");
    }
  }

  static Future registerUserAgoraChat(String username, String password) async {
    try {
      String appToken = await getAgoraChatToken();

      var response = await http.post(
        Uri.parse("https://a61.chat.agora.io/611174610/1361852/users"),
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $appToken'
        },
        body: jsonEncode({
          "username": username,
          "password": password,
          "nickname": username,
        }),
      );
      log(response.body);
      if (response.statusCode == 200) {
        Map map = json.decode(response.body);
        if (map["entities"][0]["username"] == username) {
          return true;
        }
      } else {
        debugPrint(response.body);
      }
    } catch (e) {
      debugPrint("registerUserAgoraChat ${e.toString()}");
    }
    return false;
  }

  static Future queryingUserAgoraChat(String username) async {
    try {
      String appToken = await getAgoraChatToken();

      var response = await http.get(
        Uri.parse(
            "https://a61.chat.agora.io/611174610/1361852/users/$username"),
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $appToken',
        },
      );

      if (response.statusCode == 200) {
        Map map = json.decode(response.body);
        if (map["entities"][0]["username"] == username) {
          return true;
        }
      } else {
        debugPrint(response.body);
      }
    } catch (e) {
      debugPrint("queryingUserAgoraChat ${e.toString()}");
    }
    return false;
  }

  static Future startAgoraChat(String userid, String listenerid) async {
    try {
      // https://api.supportletstalk.com/api/chat/start
      var response = await http.post(
          Uri.parse("${APIConstants.NODE_BASE_URL}${APIConstants.CHAT_START}"),
          body: {
            "user_id": userid,
            "listner_id": listenerid,
          });
      log(response.body);
      Map map = json.decode(response.body);
      if (response.statusCode == 200) {
        return map["id"];
      } else {
        return map["message"];
      }
    } catch (e) {
      log("startAgoraChat $e");
    }
  }

  static Future endAgoraChat(String chatid) async {
    try {
      // https://api.supportletstalk.com/api/chat/stop
      var response = await http.post(
          Uri.parse("${APIConstants.NODE_BASE_URL}${APIConstants.CHAT_STOP}"),
          body: {
            "id": chatid,
          });
      log(response.body);
      if (response.statusCode == 200) {
        Map map = json.decode(response.body);
        if (map["message"] == "success") {
          return true;
        }
      }
    } catch (e) {
      log("endAgoraChat $e");
    }
    return false;
  }

  static Future getAgoraChatId(String userid, String listenerid) async {
    try {
      // https://api.supportletstalk.com/api/chat?user_id=$userid&listner_id=$listenerid
      var response = await http.get(
        Uri.parse(
            "${APIConstants.NODE_BASE_URL}${APIConstants.GET_CHAT_ID}?user_id=$userid&listner_id=$listenerid"),
      );
      log(response.body);
      if (response.statusCode == 200) {
        Map map = json.decode(response.body);
        return map["id"];
      }
    } catch (e) {
      log("getAgoraChatId $e");
    }
  }

  static Future agoraChatHistory(
      String chatid, String message, String from) async {
    try {
      // https://api.supportletstalk.com/api/chat/
      var response = await http.post(
          Uri.parse("${APIConstants.NODE_BASE_URL}${APIConstants.GET_CHAT_ID}"),
          body: {"id": chatid, "message": message, "from": from});
      log(response.body);
      if (response.statusCode == 200) {
        Map map = json.decode(response.body);
        if (map["id"] != null) {
          return true;
        }
      }
    } catch (e) {
      log("agoraChatHistory $e");
    }
    return false;
  }

  // User Chat Send Request API

  static Future<SendChatIDModel?> sendChatIDAPI(
      String userId, String listenerId, String chatRoomId) async {
    Map<String, String> formData = {
      "user": userId,
      "listner": listenerId,
      "chatroom": chatRoomId,
    };

    try {
      var response = await http.post(
        Uri.parse('${APIConstants.API_BASE_URL}chats'),
        body: formData,
        headers: <String, String>{
          HttpHeaders.acceptHeader: 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // log(response.body.toString(), name: 'send chat id');
        return SendChatIDModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      log("sendChatIDAPI $e");
    }
    return null;
  }

  // Chat End API

  static Future<GetChatEndModel?> chatEndAPI(int chatId) async {
    try {
      var response =
          await dio.post(APIConstants.API_BASE_URL + APIConstants.chatEnd,
              data: FormData.fromMap({
                "chat_id": chatId,
              }));
      // log(chatId.toString(), name: 'chat id, chat end api');
      if (response.statusCode == 200) {
        // log(response.data.toString());
        return GetChatEndModel.fromJson(response.data);
      }
    } catch (e) {
      log("chatEndAPI $e");
    }
    return GetChatEndModel(status: false, message: "Something went wrong");
  }

  // Get Chat End API

  static Future<APIGetChatEndModel> getChatIdListnerSideAPI(
      String userId, String usertype) async {
    try {
      var response =
          await dio.post(APIConstants.API_BASE_URL + APIConstants.getChat,
              data: FormData.fromMap({
                "user_id": userId,
                "user_type": usertype,
              }));
      if (response.statusCode == 200) {
        return APIGetChatEndModel.fromJson(response.data);
      }
    } catch (e) {
      log("getChatIdListnerSideAPI $e");
    }
    return APIGetChatEndModel(
        status: false, message: "Something went wrong", data: null);
  }

  // User Chat Send Request API

  static Future<UserChatSendRequest?> userChatSendRequestAPI(
      String userId, String toId) async {
    try {
      var response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.userChatSendRequest,
          data: FormData.fromMap({
            "from_id": userId,
            "to_id": toId,
          }));
      if (response.statusCode == 200) {
        return UserChatSendRequest.fromJson(response.data);
      }
    } catch (e) {
      log("userChatSendRequestAPI $e");
    }
    return null;
  }

  // Listner Chat Request
  static Future<ListnerChatRequest?> listnerChatRequestAPI() async {
    try {
      var response = await dio.get(
        APIConstants.API_BASE_URL +
            APIConstants.listnerChatRequest +
            SharedPreference.getValue(PrefConstants.MERA_USER_ID),
      );
      if (response.statusCode == 200) {
        return ListnerChatRequest.fromJson(response.data);
      }
    } catch (e) {
      log("listnerChatRequestAPI $e");
    }
    return null;
  }

  // Update Chat Request from Listner

  static Future<UpdateChatRequestModel?> updateChatRequestFromListnerAPI(
      int requestId, String status) async {
    try {
      var response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.UpdateChatRequest,
          data: FormData.fromMap({
            "request_id": requestId,
            "status": status,
          }));
      if (response.statusCode == 200) {
        return UpdateChatRequestModel.fromJson(response.data);
      }
    } catch (e) {
      log("updateChatRequestFromListnerAPI $e");
    }
    return null;
  }

  // Get Chat Request
  static Future<GetChatRequestByUserModel?> getChatRequestAPI(
      String requestId) async {
    try {
      var response = await dio.get(APIConstants.API_BASE_URL +
          APIConstants.getChatRequestByUser +
          requestId);
      if (response.statusCode == 200) {
        return GetChatRequestByUserModel.fromJson(response.data);
      }
    } catch (e) {
      log("getChatRequestAPI $e");
    }
    return null;
  }

  //Get User Data by ID
  static Future<ListnerDisplayModel> getUserDataById(String id) async {
    try {
      var response =
          await dio.get(APIConstants.API_BASE_URL + APIConstants.GET_USER + id);
      if (response.statusCode == 200) {
        // log("${response.data}");
        return ListnerDisplayModel.fromJson(response.data);
      } else {
        // log("Response data rather than 200");
        return ListnerDisplayModel(
            status: false, message: "Something went wrong", data: null);
      }
    } catch (e) {
      log("getUserDataById $e");
      return ListnerDisplayModel(
          status: false, message: "Something went wrong", data: null);
    }
  }

  // Get Call Id
  static Future<GetCallIdModel?> getCallID(String userType) async {
    try {
      var response =
          await dio.post(APIConstants.API_BASE_URL + APIConstants.getCallID,
              data: FormData.fromMap({
                "user_id":
                    SharedPreference.getValue(PrefConstants.MERA_USER_ID),
                "user_type": userType,
              }));
      if (response.statusCode == 200) {
        return GetCallIdModel.fromJson(response.data);
      }
    } catch (e) {
      log("getCallID $e");
    }
    return null;
  }

  // Get Chat Request
  static Future<SupportChatModel?> getSupportChatAPI(String username) async {
    try {
      var response = await dio.get(APIConstants.API_BASE_URL +
          APIConstants.GET_ADMIN_MESSAGE_FROM_SUPPORT +
          username);
      if (response.statusCode == 200) {
        log(response.toString());
        return SupportChatModel.fromJson(response.data);
      }
    } catch (e) {
      log("getSupportChatAPI $e");
    }
    return null;
  }

  //Message REad
  // Get Chat Request
  static Future<SupportChatModel?> getSupportMessageReadAPI(
      int messageId) async {
    try {
      var response = await dio.post(
          APIConstants.API_BASE_URL +
              APIConstants.READ_ADMIN_MESSAGE_FROM_SUPPORT,
          data: FormData.fromMap({"message_id": messageId}));

      if (response.statusCode == 200) {
        // log(response.toString());
        return SupportChatModel.fromJson(response.data);
      }
    } catch (e) {
      log("getSupportMessageReadAPI $e");
    }
    return null;
  }

  static Future<dynamic> updateCallChatLogs(
      userid, listnerid, event, type) async {
    dio.post(APIConstants.API_BASE_URL + APIConstants.CALL_CHAT_LOGS, data: {
      "user_id": userid,
      "listner_id": listnerid,
      "event": event,
      "type": type
    });
  }

  static Future<dynamic> updateErrorLogs(mobileNo, errMessage) async {
    dio.post(APIConstants.API_BASE_URL + APIConstants.ERROR_LOGS,
        data: {"mobile_no": mobileNo, "err_message": errMessage});
  }

  static Future<dynamic> getMissedData() async {
    try {
      var response = await http.get(Uri.parse(
          "${APIConstants.DASHBOARD_URL}${APIConstants.MISSED_DATA_URL}${SharedPreference.getValue(PrefConstants.MERA_USER_ID)}"));

      debugPrint(response.body);
      if (response.statusCode == 200) {
        Map map = json.decode(response.body);
        return map;
      }
    } catch (e) {
      log("getMissedData $e");
    }
  }

  //Update Profile Request
  static Future<dynamic> profileUpdateRequest(int age, List<String> language,
      List<String> interest, String about) async {
    try {
      // "https://api-test.supportletstalk.com/api/listner/request-update/v2"
      int id = int.parse(SharedPreference.getValue(PrefConstants.MERA_USER_ID));
      var response = await http.post(
        Uri.parse(APIConstants.NODE_BASE_URL + APIConstants.UPDATE_REQUEST),
        body: json.encode({
          "id": id,
          "age": age,
          "language": language,
          "interest": interest,
          "about": about,
        }),
        headers: {
          "Content-type": "application/json",
        },
      );

      debugPrint(response.body);
      if (response.statusCode == 200) {
        Map map = json.decode(response.body);
        if (map["message"] == "success") {
          return true;
        }
      }
    } catch (e) {
      log("profileUpdateRequest $e");
    }
    return false;
  }

  /// Status API *

  Future<String?> viewStory(String storyId, int userId) async {
    // 'http://api-test.supportletstalk.com/api/story/$storyId?user_id=$userId';
    final Uri uri = Uri.parse(
        "${APIConstants.NODE_BASE_URL}${APIConstants.STATUS}/$storyId?user_id=$userId");

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String? imageUrl = responseData['image_url'];
        return imageUrl;
      } else {
        throw Exception('Failed to fetch story image URL');
      }
    } catch (e) {
      log('viewStory $e');
      return null;
    }
  }

  static Future createStory(int listnerId, String? image, int duration,
      String? caption, String? thumbnailurl) async {
    try {
      // "https://api-test.supportletstalk.com/api/story/v2"
      var response = await http.post(
        Uri.parse(APIConstants.NODE_BASE_URL +
            APIConstants.STATUS +
            APIConstants.VERSION_2),
        body: json.encode({
          "listner_id": listnerId,
          "image_url": image,
          "duration": duration,
          "caption": caption,
          "thumbnail": thumbnailurl,
        }),
        headers: {
          "Content-type": "application/json",
        },
      );

      debugPrint(response.body);
      if (response.statusCode == 200) {
        Map map = json.decode(response.body);
        return map;
      }
    } catch (e) {
      log("createStory $e");
    }
  }

  // Status api
  static Future<List<String>?> getStoryByListenerId(int listenerId) async {
    try {
      // "http://api.supportletstalk.com/api/story/by-listner/$listenerId"
      var response = await dio.get(
          "${APIConstants.NODE_BASE_URL}${APIConstants.STATUS}${APIConstants.GET_LISTNER_STORY}/$listenerId");

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200) {
        // Return the response data directly since it's already a List<String>
        return List<String>.from(response.data);
      } else {
        throw Exception(
            "Failed to fetch stories. Status code: ${response.statusCode}");
      }
    } catch (e) {
      log("getStoryByListenerId $e");
    }
    return null;
  }

  // Status api
  static Future getStoryDetailsByListnerId(int listnerId) async {
    try {
      // "http://api.supportletstalk.com/api/story/by-listner/$listnerId?detail=1"
      var response = await http.get(
        Uri.parse(
            "${APIConstants.NODE_BASE_URL}${APIConstants.STATUS}${APIConstants.GET_LISTNER_STORY}/$listnerId?detail=1"),
      );

      debugPrint(response.body.toString());
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      log("getStoryDetailsByListenerId ${e.toString()}");
    }
    return [];
  }

  // Status api
  static Future<List<StoryModel>?> getAllStory() async {
    try {
      // "http://api-test.supportletstalk.com/api/story/v2"
      var response = await http.get(Uri.parse(APIConstants.NODE_BASE_URL +
          APIConstants.STATUS +
          APIConstants.VERSION_2));

      debugPrint('Response code: ${response.statusCode}');
      debugPrint('Response data: ${response.body}');
      if (response.statusCode == 200) {
        List<dynamic> responseData = json.decode(response.body);

        List<StoryModel> storyModels =
            responseData.map((json) => StoryModel.fromJson(json)).toList();

        return storyModels;
      } else {
        throw Exception("Failed to fetch stories: ${response.statusCode}");
      }
    } catch (e) {
      log("getAllStory $e");
    }
    return null;
  }

  // Status api
  static Future getUserViewForStory(String storyId, int userid) async {
    try {
      // "http://api.supportletstalk.com/api/story/$storyId?user_id=$userid"
      var response = await dio.get(
          "${APIConstants.NODE_BASE_URL}${APIConstants.STATUS}/$storyId?user_id=$userid");

      if (response.statusCode == 200) {
        Map map = json.decode(response.data);
        if (map["image_url"] != null) {
          return true;
        }
      }
    } catch (e) {
      log("getUserViewForStory $e");
    }
  }

  // Status api
  static Future<bool> deleteStory(String storyId) async {
    try {
      // "http://api-test.supportletstalk.com/api/story/$storyId"
      var response = await dio.delete(
          '${APIConstants.NODE_BASE_URL}${APIConstants.STATUS}/$storyId');

      debugPrint(response.data);
      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Something went wrong');
        return false;
      }
    } catch (e) {
      // Handle errors
      log("deleteStory $e");
      return false;
    }
  }

  //User Mood
  static Future setUserMood(String userid, String mood) async {
    try {
      // "http://api-test.supportletstalk.com/api/user/set-mood"
      var response = await http.post(
        Uri.parse(APIConstants.NODE_BASE_URL + APIConstants.USER_MOOD),
        body: {
          "user_id": userid,
          "mood": mood,
        },
      );

      debugPrint(response.body);
      if (response.statusCode == 200) {
        Map map = jsonDecode(response.body);
        return map["message"];
      }
    } catch (e) {
      log("setUserMood $e");
    }
  }

  //! Story Comment
  static Future<String?> commentOnStory(
      int userId, String postId, String commentContent) async {
    try {
      // "https://api-test.supportletstalk.com/api/emotional-story/$postId/comment"
      Map<String, dynamic> payload = {
        "user_id": userId,
        "content": commentContent,
      };

      String jsonData = jsonEncode(payload);

      var response = await dio.post(
        "${APIConstants.NODE_BASE_URL}${APIConstants.EMOTIONAL_STORY}/$postId/${APIConstants.COMMENT}",
        data: jsonData,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      debugPrint("Comment On Story Response: ${response.data}");

      if (response.statusCode == 200) {
        Map<String, dynamic> map = response.data;

        if (map.containsKey("id")) {
          String message = map["id"];
          return message;
        } else {
          return "Error commenting on story: Response does not contain 'id'";
        }
      } else {
        return "Error commenting on story: ${response.statusCode}";
      }
    } catch (e) {
      log("commentOnStory $e");
      return "Error commenting on story: $e";
    }
  }

  //! Get stories
  static Future<List<UserPost>?> getEmotionalStories() async {
    try {
      // "https://api-test.supportletstalk.com/api/emotional-story/"
      var response = await dio.get(
        APIConstants.NODE_BASE_URL + APIConstants.EMOTIONAL_STORY,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;

        List<UserPost> posts = data.map((item) {
          return UserPost(
            id: item["id"]?.toString() ?? '',
            userId: item["user_id"],
            profilePic: item["user_image"] ?? '',
            name: item["user_name"] ?? '',
            status: item["status"] ?? '',
            emoji: item["emoji"] ?? '',
            likes: List<int>.from(item["likes"] ?? []),
            love: List<int>.from(item["love"] ?? []),
            happy: List<int>.from(item["happy"] ?? []),
            sad: List<int>.from(item["sad"] ?? []),
            please: List<int>.from(item["please"] ?? []),
            wow: List<int>.from(item["wow"] ?? []),
            reaction: Reaction.none,
            content: item["content"] ?? '',
            comments: List<Map<String, dynamic>>.from(item["comments"] ?? []),
          );
        }).toList();

        debugPrint('Fetch successful');
        return posts;
      } else {
        return null;
      }
    } catch (e) {
      log('getEmotionalStories: $e');
      return null;
    }
  }

  //! Create story
  static Future<String?> createEmotionalStory(
    int userId,
    String content,
    String emoji,
    String reaction,
  ) async {
    try {
      // "https://api-test.supportletstalk.com/api/emotional-story/"
      Map<String, dynamic> payload = {
        "user_id": userId,
        "content": content,
        "emoji": emoji,
        "reaction": reaction,
      };

      String jsonData = jsonEncode(payload);

      var response = await dio.post(
        APIConstants.NODE_BASE_URL + APIConstants.EMOTIONAL_STORY,
        data: jsonData,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      debugPrint("Create Story Response: ${response.data}");

      if (response.statusCode == 200) {
        Map<String, dynamic> map = response.data;

        if (map.containsKey("id")) {
          String message = map["id"];
          return message;
        } else {
          return "Error to create story";
        }
      } else {
        return "Error to create story: ${response.statusCode}";
      }
    } catch (e) {
      log("createEmotionalStory $e");
      return "Error to create story: $e";
    }
  }

  //! add money
  static Future<String?> addMoney(String userId, int lp) async {
    try {
      // "https://api-test.supportletstalk.com/api/scratch_cards/addmoney"
      Map<String, dynamic> payload = {
        "user_id": userId,
        "points": lp,
      };

      String jsonData = jsonEncode(payload);

      var response = await dio.post(
        APIConstants.NODE_BASE_URL + APIConstants.ADD_MONEY,
        data: jsonData,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      debugPrint("Add money Response: ${response.data}");

      if (response.statusCode == 200) {
        Map<String, dynamic> map = response.data;

        if (map.containsKey("message")) {
          String message = map["message"];
          return message;
        } else {
          return "Error to adding money";
        }
      } else {
        return "Error adding money: ${response.statusCode}";
      }
    } catch (e) {
      log("addMoney $e");
      return "Error adding money: $e";
    }
  }

  //! LP Points
  static Future<String?> setUserLp(int userId, int lp) async {
    try {
      // "https://api-test.supportletstalk.com/api/user/set-lp"
      Map<String, dynamic> payload = {
        "user_id": userId,
        "lp": lp,
      };

      String jsonData = jsonEncode(payload);

      var response = await dio.post(
        APIConstants.NODE_BASE_URL + APIConstants.SET_LP_POINTS,
        data: jsonData,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      debugPrint("Set lp Response: ${response.data}");

      if (response.statusCode == 200) {
        Map<String, dynamic> map = response.data;

        if (map.containsKey("message")) {
          String message = map["message"];
          return message;
        } else {
          return "Error setting lp: Response does not contain 'message' key";
        }
      } else {
        return "Error setting lp: ${response.statusCode}";
      }
    } catch (e) {
      log("setUserLp $e");
      return "Error setting lp: $e";
    }
  }

  //! convert LP to Money
  static Future<bool?> addLPMoney(String amount) async {
    try {
      Map<String, dynamic> payload = {
        "user_id": SharedPreference.getValue(PrefConstants.MERA_USER_ID),
        "amount": amount,
      };

      var response = await http.post(
        Uri.parse(APIConstants.NODE_BASE_URL + APIConstants.LP_ADD_MONEY),
        body: payload,
      );

      log(response.body);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log("addLPMoney $e");
    }
    return false;
  }

  //! User Rating
  static Future<String?> setUserRate(int userId, int rate) async {
    try {
      // "http://api-test.supportletstalk.com/api/user/rate/v2"
      Map<String, dynamic> payload = {
        "user_id": userId,
        "rating": rate,
      };

      String jsonData = jsonEncode(payload);

      var response = await dio.post(
        APIConstants.NODE_BASE_URL + APIConstants.USER_RATING,
        data: jsonData,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      debugPrint("Set rating Response: ${response.data}");

      if (response.statusCode == 200) {
        Map<String, dynamic> map = response.data;

        if (map.containsKey("message")) {
          String message = map["message"];
          return message;
        } else {
          return "Error setting rate: Response does not contain 'message' key";
        }
      } else {
        return "Error setting rate: ${response.statusCode}";
      }
    } catch (e) {
      log("setUserRate $e");
      return "Error setting mood: $e";
    }
  }

  //! Leader board
  static Future<Map<String, dynamic>> getLeaderBoardData() async {
    try {
      // "https://api-test.supportletstalk.com/api/leaderboard/rp_points"
      Response response = await dio.get(
        APIConstants.NODE_BASE_URL + APIConstants.LEADERBOARD,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      debugPrint("Leader board Data Response: ${response.data}");

      if (response.statusCode == 200) {
        Map<String, dynamic> map = response.data;

        if (map.containsKey("status") &&
            map.containsKey("message") &&
            map.containsKey("data")) {
          return map;
        } else {
          throw Exception("Invalid response format");
        }
      } else {
        throw Exception(
            "Error fetching leader board data: ${response.statusCode}");
      }
    } catch (e) {
      log("getLeaderBoardData $e");
      throw Exception("Error fetching leader board data: $e");
    }
  }

  //! Add Card
  static Future<String?> storeScratchCard(
    String id,
    String userId,
    int amount,
    String type,
    String status,
  ) async {
    try {
      // "https://api-test.supportletstalk.com/api/scratch_card/addcard"
      Map<String, dynamic> payload = {
        "card_id": id,
        "amount": amount,
        "user_id": userId,
        "status": status,
        "type": type,
      };
      String jsonData = jsonEncode(payload);

      var response = await dio.post(
        APIConstants.NODE_BASE_URL + APIConstants.ADD_SCRATCH_CARD,
        data: jsonData,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      debugPrint("Comment On Story Response: ${response.data}");

      if (response.statusCode == 200) {
        Map<String, dynamic> map = response.data;

        if (map.containsKey("message")) {
          String message = map["message"];
          return message;
        } else {
          return "Error adding scratch card: Response does not contain 'id'";
        }
      } else {
        return "Error adding card on firebase: ${response.statusCode}";
      }
    } catch (e) {
      log("storeScratchCard $e");
      return "Error adding scratch card: $e";
    }
  }

  //Block User
  static Future<BlockUser?> blockUser(
      String userid, String listnerid, String reason) async {
    try {
      // "http://api-test.supportletstalk.com/api/block_user"
      Map<String, dynamic> payload = {
        "userId": userid,
        "listenerId": listnerid,
        "blockReason": reason,
      };

      var response = await http.post(
        Uri.parse(APIConstants.NODE_BASE_URL + APIConstants.BLOCK_USER),
        body: payload,
      );

      debugPrint(response.body);
      if (response.statusCode == 200) {
        return BlockUser.fromJson(json.decode(response.body));
      }
    } catch (e) {
      log("blockUser $e");
    }
    return null;
  }

  //Unblock User
  static Future<bool?> unblockUser(String userid, String listnerid) async {
    try {
      // "http://api-test.supportletstalk.com/api/unblock_user"
      Map<String, dynamic> payload = {
        "userId": userid,
        "listenerId": listnerid,
      };

      var response = await http.post(
        Uri.parse(APIConstants.NODE_BASE_URL + APIConstants.UNBLOCK_USER),
        body: payload,
      );

      debugPrint(response.body);
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      log("unblockUser $e");
    }
    return false;
  }

  //Listner List Blocked User
  static Future<BlockUserList?> blockUserList() async {
    try {
      // "https://api-test.supportletstalk.com/api/block_list
      var response = await http.get(Uri.parse(
          "${APIConstants.NODE_BASE_URL}${APIConstants.BLOCK_LIST}/${int.parse(SharedPreference.getValue(PrefConstants.MERA_USER_ID))}"));

      debugPrint(response.body);
      if (response.statusCode == 200) {
        return BlockUserList.fromJson(json.decode(response.body));
      }
    } catch (e) {
      log("blockUserList $e");
    }
    return null;
  }

  //Unblock User Penalty
  static Future<bool?> unblockPenalty(
      String userid, String listnerid, String amt) async {
    try {
      Map<String, dynamic> payload = {
        "user_id": userid,
        "listner_id": listnerid,
        "dr_amount": amt,
      };

      // "https://api-test.supportletstalk.com/api/unblock_penalty"
      var response = await http.post(
        Uri.parse(APIConstants.NODE_BASE_URL + APIConstants.UNBLOCK_PENALTY),
        body: payload,
      );

      debugPrint(response.body);
      if (response.statusCode == 200) {
        Map map = jsonDecode(response.body);
        if (map["status"] == true) {
          return true;
        } else {
          return false;
        }
      }
    } catch (e) {
      log("unblockPenalty $e");
      return false;
    }
    return false;
  }

  //Get Missed Data for Listners
  static Future<List<MissedDataModel>> getListnerMissedData(
      String listnerID) async {
    try {
      Uri uri = Uri.parse(
          "${APIConstants.NODE_BASE_URL}${APIConstants.MISSED}/$listnerID${APIConstants.DETAIL}");

      var response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);

        List<MissedDataModel> data = list.map((e) {
          return MissedDataModel(
            type: e['type'].toString(),
            userId: e['user_id'].toString(),
            date: e['date'].toString(),
            userImage: e['user_image'].toString(),
            userName: e['user_name'].toString(),
          );
        }).toList();
        return data;
      } else {
        return [];
      }
    } catch (e) {
      log("getListnerMissedData $e");
      return [];
    }
  }

  //Listner Offline API
  static Future<bool> setListnerOffline(String? listnerId) async {
    try {
      var response = await dio.post(
        APIConstants.NODE_BASE_URL + APIConstants.OFFLINE_LISTENER + listnerId!,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log("setListnerOffline $e");
      return false;
    }
  }

  //Recent Listner API
  static Future<RecentListnersModel?> getRecentListners(String? userid) async {
    try {
      // "https://laravel-qa.supportletstalk.com/manage/api/recent_listner/$userid"
      var response = await http.get(Uri.parse(
          APIConstants.API_BASE_URL + APIConstants.RECENT_LISTNERS + userid!));

      debugPrint(response.body.toString());
      if (response.statusCode == 200) {
        return RecentListnersModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      log("getRecentListners $e");
    }
    return null;
  }

  //Create Reel
  static Future<void> sendReelData(int id, String profilePic, String name,
      String url, int duration, String caption) async {
    // Define the URL
    const String baseUrl = APIConstants.NODE_BASE_URL + APIConstants.REELS;

    // Create the JSON request body
    Map<String, dynamic> requestBody = {
      "listner_id": id,
      "listner_image": profilePic,
      "listner_name": name,
      "reel_url": url,
      "duration": [duration],
      "count": 1,
      "caption": caption,
      "thumbnail": " ",
    };

    // Convert the request body to JSON
    String jsonBody = jsonEncode(requestBody);

    try {
      // Make the POST request
      final http.Response response = await http.post(
        Uri.parse(baseUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Add any additional headers if needed
        },
        body: jsonBody,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        debugPrint('Reel data sent successfully!');
        debugPrint('Response: ${response.body}');
      } else {
        debugPrint(
            'Failed to send reel data. Status code: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
      }
    } catch (e) {
      log('sendReelData $e');
    }
  }

  //Fetch Reel
  static Future<ReelModel?> fetchReelData(
      {String? listnerId, bool filterReel = false}) async {
    const String apiUrl = APIConstants.NODE_BASE_URL + APIConstants.REELSV2;

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        ReelModel model = ReelModel.fromJson(jsonDecode(response.body));
        return model;
      } else {
        debugPrint('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      log('fetchReelData $e');
    }
    return null;
  }

  static Future<Map<String, List<dynamic>>> fetchCommentsAndLikes(
      String reelId) async {
    final reelUrl =
        "${APIConstants.NODE_BASE_URL}${APIConstants.REELS}/$reelId";
    try {
      final response = await http.get(Uri.parse(reelUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        List<Map<String, dynamic>> comments = [];
        List<dynamic> commentsList = responseBody['comments'];
        for (var comment in commentsList) {
          String name = comment['name'] ?? '';
          String content = comment['content'] ?? '';
          int id = comment['id'] ?? '';
          String type = comment['type'] ?? '';
          String commentId = comment['commentId'] ?? '';
          List<dynamic> reply = comment['reply'] ?? '';
          comments.add({
            'name': name,
            'content': content,
            'id': id,
            'type': type,
            'commentId': commentId,
            'reply': reply,
          });
        }

        List<dynamic> likes = [];
        List<dynamic> likesList = responseBody['likes'];
        for (var like in likesList) {
          likes.add(like);
        }

        List<dynamic> viewsList = responseBody['views'] ?? [];

        return {
          'comments': comments,
          'likes': likes,
          'views': viewsList,
        };
      } else {
        throw Exception('Failed to load comments and likes');
      }
    } catch (e) {
      log("fetchCommentsAndLikes $e");
      throw Exception('Error: $e');
    }
  }

  static Future<void> updateViews(String reelId, int userId) async {
    final String apiUrl =
        '${APIConstants.NODE_BASE_URL}${APIConstants.REELS}/$reelId/${APIConstants.VIEWS}?user_id=$userId';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        debugPrint('Views Updated');
      } else {
        throw Exception('Failed to load reel views: ${response.statusCode}');
      }
    } catch (e) {
      // Catch any errors that occur during the request
      log("updateViews $e");
      throw Exception('Failed to load reel views: $e');
    }
  }

  static Future<int> toggleLike(String reelId, int userId) async {
    final String apiUrl =
        '${APIConstants.NODE_BASE_URL}${APIConstants.REELS}/$reelId/${APIConstants.LIKE}';

    Map<String, dynamic> body = {
      'user_id': userId,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return response.statusCode;
      } else {
        throw Exception('Failed to like reel');
      }
    } catch (e) {
      log("toggleLike $e");
      throw Exception('Error: $e');
    }
  }

  static Future<String> postReelComment(
      String reelId, int userId, String content) async {
    String url =
        '${APIConstants.NODE_BASE_URL}${APIConstants.REELS}/$reelId/${APIConstants.COMMENT}';

    Map<String, dynamic> body = {
      'user_id': userId,
      'content': content,
      'commentId': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        Map map = jsonDecode(response.body);
        return map['message'];
      } else {
        Map map = jsonDecode(response.body);
        return map['message'];
      }
    } catch (e) {
      log("postReelComment $e");
      rethrow;
    }
  }

  static Future<void> postReply(
      String reelId, String commentId, int userId, String reply) async {
    try {
      final String apiUrl =
          '${APIConstants.NODE_BASE_URL}${APIConstants.REELS}/$reelId/${APIConstants.REPLY}/$commentId';

      final Map<String, dynamic> requestBody = {
        'user_id': userId,
        'content': reply,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      debugPrint("Reels Reply ${response.body}");
      if (response.statusCode == 200) {
        // Request successful
        debugPrint('##Reply posted successfully');
      } else {
        // Request failed
        debugPrint('Failed to post reply: ${response.statusCode}');
        throw Exception('Failed to post reply: ${response.statusCode}');
      }
    } catch (e) {
      log("postReply $e");
    }
  }

  static Future<bool?> sendGift({
    required int fromId,
    required int toId,
    required int amount,
    required String reelId,
    required String gift,
  }) async {
    final url = Uri.parse(
        APIConstants.NODE_BASE_URL + APIConstants.REELS + APIConstants.GIFT);
    final body = json.encode({
      "from_id": fromId,
      "to_id": toId,
      "amount": amount,
      "reel_id": reelId,
      "gift": gift,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        debugPrint('##Gift sent successfully! ${response.body}');
        return true;
        // Handle successful response
      } else {
        debugPrint(
            '##Failed to send gift. Status code: ${response.statusCode}');
        // Handle error response
      }
    } catch (e) {
      log('sendGift $e');
      return false;
      // Handle network or other errors
    }
    return false;
  }

  static Future<Map<String, int>> fetchGifts(
      String listenerId, String reelId) async {
    final String url =
        '${APIConstants.NODE_BASE_URL}${APIConstants.REELS}${APIConstants.GIFT}/$listenerId?reel_id=$reelId';
    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      // Parse the JSON response
      final Map<String, dynamic> data = json.decode(response.body);

      // Initialize a map to store total amounts for each gift type
      Map<String, int> giftTotals = {
        "🌹": 0,
        "🍫": 0,
        "🎁": 0,
        "🎂": 0,
        "💰": 0,
        "👑": 0,
        "🧸": 0,
        "💎": 0,
        "❤️": 0,
        "🎸": 0,
      };
      if (data.isEmpty) {
        return giftTotals;
      }
      // Iterate over the list of gifts and calculate totals
      for (var gift in data['gifts']) {
        String giftType = gift['gift'];
        int amount = gift['amount'];

        // If the gift type is already in the map, add the amount to the existing total
        if (giftTotals.containsKey(giftType)) {
          giftTotals[giftType] = giftTotals[giftType]! + amount;
        } else {
          // If the gift type is not in the predefined keys, ignore it
          debugPrint('Unknown gift type: $giftType');
        }
      }
      debugPrint('##total  gifts: $giftTotals');
      return giftTotals;
    } else {
      throw Exception('Failed to load gifts');
    }
  }

  //Update Device Token
  static Future<bool?> updateDeviceToken(String devicetoken) async {
    try {
      var response = await dio.post(
          APIConstants.API_BASE_URL + APIConstants.UPDATE_DEVICE_TOKEN,
          data: {
            "id": SharedPreference.getValue(PrefConstants.MERA_USER_ID),
            "device_token": devicetoken,
          });

      debugPrint(response.toString());
      if (response.statusCode == 200) {
        if (response.data['message'] == 'Device token updated successfully') {
          return true;
        }
      } else {
        return false;
      }
    } catch (e) {
      log("updateDeviceToken $e");
    }
    return false;
  }

  // User Moods
  static Future<MoodsModel?> getListnersMoods() async {
    try {
      var response =
          await dio.get(APIConstants.API_BASE_URL + APIConstants.MOODS);

      if (response.statusCode == 200) {
        return MoodsModel.fromJson(response.data);
      }
    } catch (e) {
      log("getListnersMoods $e");
    }
    return null;
  }

  // UPI Payment
  static Future<bool> upiPayment(double amount, String transID) async {
    try {
      var response = await dio
          .post(APIConstants.NODE_BASE_URL + APIConstants.UPI_PAY, data: {
        "user_id": SharedPreference.getValue(PrefConstants.MERA_USER_ID),
        "amount": amount,
        "transaction_id": transID
      });

      debugPrint(response.toString());
      if (response.statusCode == 200) {
        if (response.data['id'] != "") {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      log("upiPayment $e");
    }
    return false;
  }

  // Profile Image Update Request
  static Future<String?> updateProfileImg(File? image) async {
    try {
      String name = image!.path.split('/').last;
      var formData = FormData.fromMap({
        'image': [await MultipartFile.fromFile(image.path, filename: name)],
      });

      var response = await dio.post(
        APIConstants.API_BASE_URL + APIConstants.UPDATE_PROFILE,
        data: formData,
        options: Options(
          method: 'POST',
        ),
      );

      if (response.statusCode == 200) {
        Map map = response.data;
        return map["image_url"];
      }
    } catch (e) {
      log("updateProfileImg $e");
    }
    return null;
  }
}

Future<int> fetchStatus(String value) async {
  int onlineStatus = 0;
  try {
    http.Response response = await http.get(Uri.parse(
        APIConstants.API_BASE_URL + APIConstants.GET_LISTNER + value));

    if (response.statusCode == 200) {
      String responseData = response.body;
      Map<String, dynamic> res = jsonDecode(responseData);
      List<dynamic> dataList = res['data'];
      if (dataList.isNotEmpty) {
        Map<String, dynamic> user = dataList[0];
        if (user['online_status'] == 1) {
          onlineStatus = 1;
        } else {
          onlineStatus = 0;
        }
      }
    } else {
      onlineStatus = 0;
    }
  } catch (error) {
    onlineStatus = 0;
  }
  return onlineStatus;
}
