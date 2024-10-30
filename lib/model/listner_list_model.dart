/// status : true
/// message : "Data retrieved successfully"
/// data : [{"id":1087,"name":"Krishna","mobile_no":"+918921681005","helping_category":"Loneliness","image":"public/image/listner/WhatsApp Image 2024-04-22 at 4.24.52 PM.jpeg","age":"29","interest":"Friendship,Loneliness","language":"Hindi,English,Malayalam","sex":"F","available_on":"all","about":"Loneliness is defined as the absence of connection. I was alone, and no one aided me during my difficult times.\r\nI was emotionally depressed when I realized the people I cared about completely rejected me. But all of the negativity and blame helped to boost my confidence and help me overcome my depression.\r\nThere are people out there just like me who need someone to talk to and a heart to understand them. I may not be able to solve all of your problems, but I can guarantee that you will not have to face them alone.\r\nThe ability to become a good listener is the key to a happy friendship. Let us be friends!","user_type":"listner","charge":"5.00","device_token":"eqrmE3FYRQGo915x_Q207M:APA91bGA1RbwDUZyuKu5vJ5LyPWu_1VZv2r8qi2ZeQt0p5cPBe6gock2e2yaLOdWKDHe88KMo0JVeuNWf6Kkv9MPo-c3Sci2IB3cKcFuEl9-e-vT8E97LtcxwdsfKIAFJDfplVdvoE3h","status":1,"online_status":1,"busy_status":0,"ac_delete":0,"delete_status":0,"created_at":"2023-02-11 02:33:58","updated_at":"2024-04-28 17:00:54","avg_rating":"4.75","rating_count":231}]

class ListnerListModel {
  ListnerListModel({
    this.status,
    this.message,
    this.data,
  });

  ListnerListModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(Dataobj.fromJson(v));
      });
    }
  }

  bool? status;
  String? message;
  List<Dataobj>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// id : 1087
/// name : "Krishna"
/// mobile_no : "+918921681005"
/// helping_category : "Loneliness"
/// image : "public/image/listner/WhatsApp Image 2024-04-22 at 4.24.52 PM.jpeg"
/// age : "29"
/// interest : "Friendship,Loneliness"
/// language : "Hindi,English,Malayalam"
/// sex : "F"
/// available_on : "all"
/// about : "Loneliness is defined as the absence of connection. I was alone, and no one aided me during my difficult times.\r\nI was emotionally depressed when I realized the people I cared about completely rejected me. But all of the negativity and blame helped to boost my confidence and help me overcome my depression.\r\nThere are people out there just like me who need someone to talk to and a heart to understand them. I may not be able to solve all of your problems, but I can guarantee that you will not have to face them alone.\r\nThe ability to become a good listener is the key to a happy friendship. Let us be friends!"
/// user_type : "listner"
/// charge : "5.00"
/// device_token : "eqrmE3FYRQGo915x_Q207M:APA91bGA1RbwDUZyuKu5vJ5LyPWu_1VZv2r8qi2ZeQt0p5cPBe6gock2e2yaLOdWKDHe88KMo0JVeuNWf6Kkv9MPo-c3Sci2IB3cKcFuEl9-e-vT8E97LtcxwdsfKIAFJDfplVdvoE3h"
/// status : 1
/// online_status : 1
/// busy_status : 0
/// ac_delete : 0
/// delete_status : 0
/// created_at : "2023-02-11 02:33:58"
/// updated_at : "2024-04-28 17:00:54"
/// avg_rating : "4.75"
/// rating_count : 231

class Dataobj {
  Dataobj({
    this.id,
    this.name,
    this.mobileNo,
    this.helpingCategory,
    this.image,
    this.age,
    this.interest,
    this.language,
    this.sex,
    this.availableOn,
    this.about,
    this.userType,
    this.charge,
    this.deviceToken,
    this.status,
    this.onlineStatus,
    this.busyStatus,
    this.acDelete,
    this.deleteStatus,
    this.createdAt,
    this.updatedAt,
    this.avgRating,
    this.ratingCount,
  });

  Dataobj.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    mobileNo = json['mobile_no'];
    helpingCategory = json['helping_category'];
    image = json['image'];
    age = json['age'];
    interest = json['interest'];
    language = json['language'];
    sex = json['sex'];
    availableOn = json['available_on'];
    about = json['about'];
    userType = json['user_type'];
    charge = json['charge'];
    deviceToken = json['device_token'];
    status = json['status'];
    onlineStatus = json['online_status'];
    busyStatus = json['busy_status'];
    acDelete = json['ac_delete'];
    deleteStatus = json['delete_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    avgRating = json['avg_rating'];
    ratingCount = json['rating_count'];
  }

  int? id;
  String? name;
  String? mobileNo;
  String? helpingCategory;
  String? image;
  String? age;
  String? interest;
  String? language;
  String? sex;
  String? availableOn;
  String? about;
  String? userType;
  String? charge;
  String? deviceToken;
  int? status;
  int? onlineStatus;
  int? busyStatus;
  int? acDelete;
  int? deleteStatus;
  String? createdAt;
  String? updatedAt;
  String? avgRating;
  int? ratingCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['mobile_no'] = mobileNo;
    map['helping_category'] = helpingCategory;
    map['image'] = image;
    map['age'] = age;
    map['interest'] = interest;
    map['language'] = language;
    map['sex'] = sex;
    map['available_on'] = availableOn;
    map['about'] = about;
    map['user_type'] = userType;
    map['charge'] = charge;
    map['device_token'] = deviceToken;
    map['status'] = status;
    map['online_status'] = onlineStatus;
    map['busy_status'] = busyStatus;
    map['ac_delete'] = acDelete;
    map['delete_status'] = deleteStatus;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['avg_rating'] = avgRating;
    map['rating_count'] = ratingCount;
    return map;
  }
}