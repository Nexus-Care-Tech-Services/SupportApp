class SendBellNotificationModel {
  SendBellNotificationModel({
    this.status,
    this.message,
    this.data,
  });

  SendBellNotificationModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  bool? status;
  String? message;
  Data? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }
}

class Data {
  Data({
    this.multicastId,
    this.success,
    this.failure,
    this.canonicalIds,
    this.results,
  });

  Data.fromJson(dynamic json) {
    multicastId = json['multicast_id'];
    success = json['success'];
    failure = json['failure'];
    canonicalIds = json['canonical_ids'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results?.add(Results.fromJson(v));
      });
    }
  }

  int? multicastId;
  int? success;
  int? failure;
  int? canonicalIds;
  List<Results>? results;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['multicast_id'] = multicastId;
    map['success'] = success;
    map['failure'] = failure;
    map['canonical_ids'] = canonicalIds;
    if (results != null) {
      map['results'] = results?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Results {
  Results({
    this.messageId,
  });

  Results.fromJson(dynamic json) {
    messageId = json['message_id'];
  }

  String? messageId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message_id'] = messageId;
    return map;
  }
}
