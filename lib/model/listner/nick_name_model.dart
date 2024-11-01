class NickNameModel {
  bool? status;
  String? message;
  Data? data;

  NickNameModel({this.status, this.message, this.data});

  NickNameModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? fromId;
  String? toId;
  String? nickname;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
      this.fromId,
      this.toId,
      this.nickname,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fromId = json['from_id'].toString();
    toId = json['to_id'];
    nickname = json['nickname'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['from_id'] = fromId;
    data['to_id'] = toId;
    data['nickname'] = nickname;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
