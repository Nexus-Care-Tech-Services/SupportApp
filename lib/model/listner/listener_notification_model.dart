class ListenerNotification {
  ListenerNotification({
    this.status,
    this.message,
    this.notifications,
  });

  ListenerNotification.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    if (json['notifications'] != null) {
      notifications = [];
      json['notifications'].forEach((v) {
        notifications?.add(Notifications.fromJson(v));
      });
    }
  }

  bool? status;
  String? message;
  List<Notifications>? notifications;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (notifications != null) {
      map['notifications'] = notifications?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Notifications {
  Notifications({
    this.id,
    this.userId,
    this.listnerId,
    this.userDp,
    this.userName,
    this.createdAt,
    this.updatedAt,
  });

  Notifications.fromJson(dynamic json) {
    id = json['id'];
    userId = json['user_id'];
    listnerId = json['listner_id'];
    userDp = json['user_dp'];
    userName = json['user_name'];
    createdAt = DateTime.parse(json['created_at']);
    updatedAt = DateTime.parse(json['updated_at']);
  }

  int? id;
  int? userId;
  int? listnerId;
  String? userDp;
  String? userName;
  DateTime? createdAt;
  DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['user_id'] = userId;
    map['listner_id'] = listnerId;
    map['user_dp'] = userDp;
    map['user_name'] = userName;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}
