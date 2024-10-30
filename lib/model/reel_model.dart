/// data : [{"reel_id":"TWT3uUGaVWuJF0gbIRhp","listner_id":1543,"listner_name":"Rashi","listner_image":"public/image/listner/WhatsApp Image 2024-07-23 at 3.47.54 PM.jpeg","reel_url":"https://firebasestorage.googleapis.com/v0/b/support-stress-free.appspot.com/o/Reels%2F1726051034430.mp4?alt=media&token=84786bd2-f19e-4f85-9cf6-e6cbdae65389","duration":15,"caption":"💙😊","likes":2,"views":9,"created_at":"Wed Sep 11 2024 10:39:01 GMT+0000 (Coordinated Universal Time)","status":"success"}]

class ReelModel {
  ReelModel({
      this.data,});

  ReelModel.fromJson(dynamic json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(Data.fromJson(v));
      });
    }
  }
  List<Data>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// reel_id : "TWT3uUGaVWuJF0gbIRhp"
/// listner_id : 1543
/// listner_name : "Rashi"
/// listner_image : "public/image/listner/WhatsApp Image 2024-07-23 at 3.47.54 PM.jpeg"
/// reel_url : "https://firebasestorage.googleapis.com/v0/b/support-stress-free.appspot.com/o/Reels%2F1726051034430.mp4?alt=media&token=84786bd2-f19e-4f85-9cf6-e6cbdae65389"
/// duration : 15
/// caption : "💙😊"
/// likes : 2
/// views : 9
/// created_at : "Wed Sep 11 2024 10:39:01 GMT+0000 (Coordinated Universal Time)"
/// status : "success"

class Data {
  Data({
      this.reelId, 
      this.listnerId, 
      this.listnerName, 
      this.listnerImage, 
      this.reelUrl, 
      this.duration, 
      this.caption, 
      this.likes, 
      this.views, 
      this.createdAt, 
      this.status,});

  Data.fromJson(dynamic json) {
    reelId = json['reel_id'];
    listnerId = json['listner_id'];
    listnerName = json['listner_name'];
    listnerImage = json['listner_image'];
    reelUrl = json['reel_url'];
    duration = json['duration'];
    caption = json['caption'];
    likes = json['likes'];
    views = json['views'];
    createdAt = json['created_at'];
    status = json['status'];
  }
  String? reelId;
  num? listnerId;
  String? listnerName;
  String? listnerImage;
  String? reelUrl;
  num? duration;
  String? caption;
  num? likes;
  num? views;
  String? createdAt;
  String? status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['reel_id'] = reelId;
    map['listner_id'] = listnerId;
    map['listner_name'] = listnerName;
    map['listner_image'] = listnerImage;
    map['reel_url'] = reelUrl;
    map['duration'] = duration;
    map['caption'] = caption;
    map['likes'] = likes;
    map['views'] = views;
    map['created_at'] = createdAt;
    map['status'] = status;
    return map;
  }

}