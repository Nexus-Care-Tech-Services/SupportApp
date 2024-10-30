/// type : "chat"
/// date : "2024-05-04T04:15:54.000Z"
/// user_id : "35763"
/// user_name : "OnionCute"
/// user_image : "https://laravel.supportletstalk.com/assets/avatar/864129.png"

class MissedDataModel {
  MissedDataModel({
    this.type,
    this.date,
    this.userId,
    this.userName,
    this.userImage,
  });

  MissedDataModel.fromJson(dynamic json) {
    type = json['type'];
    date = json['date'];
    userId = json['user_id'];
    userName = json['user_name'];
    userImage = json['user_image'];
  }

  String? type;
  String? date;
  String? userId;
  String? userName;
  String? userImage;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = type;
    map['date'] = date;
    map['user_id'] = userId;
    map['user_name'] = userName;
    map['user_image'] = userImage;
    return map;
  }
}
