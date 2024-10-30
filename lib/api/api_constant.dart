// ignore_for_file: constant_identifier_names

class APIConstants {
  static const String BASE_URL = "https://laravel.support2heal.cloud/manage/";
  static const String NODE_URL = "https://support2heal.cloud/";

  static const String API_BASE_URL = "${BASE_URL}api/";
  static const String NODE_BASE_URL = "${NODE_URL}api/";
  static const CONNECTION_TIMEOUT = 300000;
  static const RECEIVE_TIMEOUT = 300000;

  /// API Requests
  static const String SEND_BELL_NOTIFICATION = "/sendBellNotification";
  static const String SEND_NOTIFICATION_TO_USER = "/sendNotificationToUser";
  static const String GET_LISTENER_NOTIFICATION = "/get_listner_notification";
  static const String REGISTER_API = "registrations";
  static const String REGISTER_WITH_EMAIL_API = "registerWithEmail";
  static const String LISTNER_DISPLAY_API = "listners";
  static const String GET_LISTNER = "listner/";
  static const String LISTNER_DISPLAY_API_BY_ID = "listner/";

  static const String RAZOR_PAY_ORDERID = "no_generated";
  static const String ADDMONEY_INTO_WALLET = "store_wallet/";
  static const String GET_HELPERS_LIST = "registrations";
  static const String GET_AGORA_TOKEN = "agoraToken";
  static const String SEARCH_API = "searchListner";
  static const String WALLET_AMOUNT = "show_wallet/";
  static const String CHARGE_WALLET_DEDUCTION = "charge";
  static const String CHARGE_VIDEO_CALL = "charge_video_call";
  static const String WITHDRAWAL_WALLET = "withdrawal";
  static const String REPORT = "report";
  static const String GET_USER = "user/";

  static const String WALLET_STORE = "store_wallet";
  static const String DELETE_API = "delete";
  static const String NICKNAME_API = "nickname";
  static const String NICKNAME_GET_API = 'nickname_get';
  static const String FEEDBACK_API = "feedback";
  static const String DISPLAY_NICKNAME_API = "nickname_get/";
  static const String CHAT_NOTIFY_API = "get_notification/";
  static const String CHAT_READ_NOTIFY_API = "notification_read";

  static const String SHOW_TRANSACTION = "show_transaction/";
  static const String SHOW_TOGGLE_ONOFF = "onlineOfline";
  static const String LISTNER_AVALIABILITY = "update_listner";
  static const String BELL_ICON_NOTIFY = "bellnotify";

  static const String BLOCK = "block";

  static const String ONLINE_API = "busy_status";
  static const String START_RECORDING = "call_start";
  static const String STOP_RECORDING = "call_end";
  static const String CREATE_TOKEN = "create_token";
  static const String userChatSendRequest = "chat_request";
  static const String listnerChatRequest = "listener_chat_request/";
  static const String UpdateChatRequest = "update_chat_request";
  static const String getChatRequestByUser = "get_chat_request/";
  static const String getChat = "get_chat";
  static const String chatEnd = "chat_end";
  static const String getCallID = "get_call";
  static const String GET_ADMIN_MESSAGE_FROM_SUPPORT = "get_admin_message/";
  static const String READ_ADMIN_MESSAGE_FROM_SUPPORT = "admin_message_read";
  static const String CALL_CHAT_LOGS = "call_chat_logs";
  static const String ERROR_LOGS = "log_errors";

  //agora chat
  static const String AGORA = "/agora/";
  static const String CHAT_TOKEN = "chat/app-token";
  static const String USER_TOKEN = "chat/user-token";
  static const String CHAT_START = "/chat/start";
  static const String GET_CHAT_ID = "/chat";
  static const String CHAT_STOP = "/chat/stop";

  //status
  static const String STATUS = "story";
  static const String VERSION_2 = "/v2";
  static const String GET_LISTNER_STORY = "/by-listner";

  // listner Profile Update
  static const String UPDATE_REQUEST = "listner/request-update/v3";
  static const String UPDATE_PROFILE = "listner/new-lisntnerprofileimg";

  //video call recording
  static const String VIDEO_CALL_START = "video-call/start";
  static const String VIDEO_CALL_STOP = "video-call/stop";

  //missed call, chats, video call
  static const String DASHBOARD_URL =
      "https://dashboard.supportletstalk.com/api";
  static const String MISSED_DATA_URL = "/public/listner-analytics-2/";

  //missed logs for user
  static const String USER_MISSED_URL = "user-missed";

  //mood
  static const String USER_MOOD = 'user/set-mood';

  //emotional story
  static const String EMOTIONAL_STORY = 'emotional-story/';
  static const String COMMENT = 'comment';
  static const String LIKE = 'like';
  static const String REACT = 'react';

  //add money using scratch card
  static const String ADD_MONEY = 'scratch_cards/addmoney';

  //lp points
  static const String SET_LP_POINTS = 'user/set-lp';
  static const String LP_ADD_MONEY = 'loyalty_points/addmoney';

  //user_rating
  static const String USER_RATING = 'user/rate/v2';

  //leaderboard data
  static const String LEADERBOARD = 'leaderboard/rp_points';

  //add scratch card
  static const String ADD_SCRATCH_CARD = 'scratch_card/addcard';

  // Block User
  static const String BLOCK_USER = 'block_user';

  // Unblock User
  static const String UNBLOCK_USER = 'unblock_user';

  // Block List
  static const String BLOCK_LIST = 'block_list';

  // Unblock Penalty
  static const String UNBLOCK_PENALTY = 'unblock_penalty';

  // Like Listner Profile
  static const String LIKE_PROFILE = 'profile-like';

  // Like Listner Bio
  static const String LIKE_BIO = 'bio-like';

  //missed Data
  static const String MISSED = 'missed';
  static const String DETAIL = '/detail';

  //Offline Listner
  static const String OFFLINE_LISTENER = 'listner-offline/';

  //Recent Listners
  static const String RECENT_LISTNERS = 'recent_listner/';

  //Reels
  static const String REELS = 'reel';
  static const String REELSV2 = 'reel/v2';
  static const String VIEWS = 'views';
  static const String REPLY = 'reply';
  static const String GIFT = '/gift';

  //listner-list
  static const String LISTNER_LIST = 'listner-list-new';

  // Update Device Token
  static const String UPDATE_DEVICE_TOKEN = 'update-device-token';

  //Moods
  static const String MOODS = 'mode';

  //UPI Payment
  static const String UPI_PAY = 'payment/v2';
}

class PrefConstants {
  static const String WALLET_AMOUNT = "wallet_amount";
  static const String MOBILE_NUMBER = "mobile_number";
  static const String LISTENER_NAME = "listener_name";
  static const String LISTENER_IMAGE = "listener_image";
  static const String MERA_USER_ID = "user_id1";
  static const String ONLINE = "online";
  static const String USER_TYPE = "user_type";
  static const String LISTNER_AVAILABILITY = "listner_availability";
  static const String LISTNER_CHAT_REQUEST = "listner_chat_request";
  static const String USER_AVAILABLE_BALANCE = "user_available_balance";
  static const String USER_NAME = "name";
  static const String USER_IMAGE = "listener_image";
  static const String UI_MODE = "light";
  static const String EMAIL = "email";
  static const String LANGUAGE = "language";
  static const String INTEREST = "interest";
  static const String LAST_UPDATE_TIMESTAMP = "last_update_timestamp";
  static const String CHARGE = "charge";

  static const String AGORA_UID_TWO = "agora_uid_two";
  static const String AGORA_TOKEN_TWO = "agora_token_two";
}
