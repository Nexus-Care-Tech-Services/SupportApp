/// nickname : [{"id":1032,"from_id":"9193","to_id":"19691","nickname":"cutie","created_at":"2024-05-07T15:08:42.000Z","updated_at":"2024-05-07T15:08:42.000Z"}]

class NicknameGetModel {
  NicknameGetModel({
    this.nickname,
  });

  NicknameGetModel.fromJson(dynamic json) {
    if (json['nickname'] != null) {
      nickname = [];
      json['nickname'].forEach((v) {
        nickname?.add(Nickname.fromJson(v));
      });
    }
  }

  List<Nickname>? nickname;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (nickname != null) {
      map['nickname'] = nickname?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// id : 1032
/// from_id : "9193"
/// to_id : "19691"
/// nickname : "cutie"
/// created_at : "2024-05-07T15:08:42.000Z"
/// updated_at : "2024-05-07T15:08:42.000Z"

class Nickname {
  Nickname({
    this.id,
    this.fromId,
    this.toId,
    this.nickname,
    this.createdAt,
    this.updatedAt,
  });

  Nickname.fromJson(dynamic json) {
    id = json['id'];
    fromId = json['from_id'];
    toId = json['to_id'];
    nickname = json['nickname'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  int? id;
  String? fromId;
  String? toId;
  String? nickname;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['from_id'] = fromId;
    map['to_id'] = toId;
    map['nickname'] = nickname;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}
