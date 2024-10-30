/// views : [{"user_name":"Anonymous","user_type":"user","created_at":{"seconds":1703170345,"nanoseconds":253000000},"user_image":null,"user_id":19691}]
/// image_url : "https://firebasestorage.googleapis.com/v0/b/support-stress-free.appspot.com/o/stories%2F5bdbe5fffd7cb4db80025fed72c82b74.jpg?alt=media"
/// expires_at : {"seconds":1703255897,"nanoseconds":837000000}
/// listner_id : 9193
/// image_path : "stories/5bdbe5fffd7cb4db80025fed72c82b74.jpg"
/// created_at : {"seconds":1703169497,"nanoseconds":837000000}

class StoryDetailsModel {
  StoryDetailsModel({
    this.views,
    this.imageUrl,
    this.expiresAt,
    this.listnerId,
    this.imagePath,
    this.createdAt,
  });

  StoryDetailsModel.fromJson(dynamic json) {
    if (json['views'] != null) {
      views = [];
      json['views'].forEach((v) {
        views?.add(Views.fromJson(v));
      });
    }
    imageUrl = json['image_url'];
    expiresAt = json['expires_at'] != null
        ? ExpiresAt.fromJson(json['expires_at'])
        : null;
    listnerId = json['listner_id'];
    imagePath = json['image_path'];
    createdAt = json['created_at'] != null
        ? CreatedAt.fromJson(json['created_at'])
        : null;
  }

  List<Views>? views;
  String? imageUrl;
  ExpiresAt? expiresAt;
  int? listnerId;
  String? imagePath;
  CreatedAt? createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (views != null) {
      map['views'] = views?.map((v) => v.toJson()).toList();
    }
    map['image_url'] = imageUrl;
    if (expiresAt != null) {
      map['expires_at'] = expiresAt?.toJson();
    }
    map['listner_id'] = listnerId;
    map['image_path'] = imagePath;
    if (createdAt != null) {
      map['created_at'] = createdAt?.toJson();
    }
    return map;
  }
}

/// seconds : 1703169497
/// nanoseconds : 837000000

class CreatedAt {
  CreatedAt({
    this.seconds,
    this.nanoseconds,
  });

  CreatedAt.fromJson(dynamic json) {
    seconds = json['seconds'];
    nanoseconds = json['nanoseconds'];
  }

  int? seconds;
  int? nanoseconds;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['seconds'] = seconds;
    map['nanoseconds'] = nanoseconds;
    return map;
  }
}

/// seconds : 1703255897
/// nanoseconds : 837000000

class ExpiresAt {
  ExpiresAt({
    this.seconds,
    this.nanoseconds,
  });

  ExpiresAt.fromJson(dynamic json) {
    seconds = json['seconds'];
    nanoseconds = json['nanoseconds'];
  }

  int? seconds;
  int? nanoseconds;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['seconds'] = seconds;
    map['nanoseconds'] = nanoseconds;
    return map;
  }
}

/// user_name : "Anonymous"
/// user_type : "user"
/// created_at : {"seconds":1703170345,"nanoseconds":253000000}
/// user_image : null
/// user_id : 19691

class Views {
  Views({
    this.userName,
    this.userType,
    this.createdAt,
    this.userImage,
    this.userId,
  });

  Views.fromJson(dynamic json) {
    userName = json['user_name'];
    userType = json['user_type'];
    createdAt = json['created_at'] != null
        ? CreatedAt.fromJson(json['created_at'])
        : null;
    userImage = json['user_image'];
    userId = json['user_id'];
  }

  String? userName;
  String? userType;
  CreatedAt? createdAt;
  dynamic userImage;
  int? userId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['user_name'] = userName;
    map['user_type'] = userType;
    if (createdAt != null) {
      map['created_at'] = createdAt?.toJson();
    }
    map['user_image'] = userImage;
    map['user_id'] = userId;
    return map;
  }
}
