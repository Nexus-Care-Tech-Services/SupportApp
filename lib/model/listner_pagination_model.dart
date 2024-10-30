/// status : true
/// message : "Data retrieved successfully"
/// data : [{"id":5466,"name":"Smita","mobile_no":"+916200551961","helping_category":"smitabhatt1996@gmail.com","image":"public/image/listner/WhatsApp Image 2024-09-16 at 12.12.06 PM.jpeg","age":"28","interest":"Studies,Friendship,Career","language":"English Hindi","sex":"F","available_on":"all","about":"I like talking to people and listening to their problems and giving them solutions so that they remain stress free and happy.\n\nI am a good listener because Listening is the ability to accurately receive and interpret messages in the communication process.\n\nI love communication between two people.\nSo Listening, however, requires more than that: it requires focus and concentrated effort, both mental and sometimes physical as well.","user_type":"listner","charge":"5.00","device_token":"d0qZ87zJTWmLWlla40_rDn:APA91bET2jj0-U0GPen79HXM71ewXNG6ZUrywkEdQmQ-F9UeJBD9k5OTlVr-WdbDyO0_jmeO4rGoiFKvuGYE_yvBLWDEswS61gTfrBE5yzPM-ZBXBVwQkskuSb9bY_YyaJgm7VyQ6ttA","status":1,"online_status":1,"busy_status":0,"ac_delete":0,"delete_status":0,"created_at":"2023-05-24 18:00:45","updated_at":"2024-09-16 12:29:42","total_review_count":774,"average_rating":4.7,"rating_reviews":{}}]
/// pagination : {"page":1,"limit":10,"totalItems":99,"totalPages":10}

class ListnerPaginationModel {
  ListnerPaginationModel({
      this.status, 
      this.message, 
      this.data, 
      this.pagination,});

  ListnerPaginationModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(Data.fromJson(v));
      });
    }
    pagination = json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null;
  }
  bool? status;
  String? message;
  List<Data>? data;
  Pagination? pagination;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      map['pagination'] = pagination?.toJson();
    }
    return map;
  }

}

/// page : 1
/// limit : 10
/// totalItems : 99
/// totalPages : 10

class Pagination {
  Pagination({
      this.page, 
      this.limit, 
      this.totalItems, 
      this.totalPages,});

  Pagination.fromJson(dynamic json) {
    page = json['page'];
    limit = json['limit'];
    totalItems = json['totalItems'];
    totalPages = json['totalPages'];
  }
  num? page;
  num? limit;
  num? totalItems;
  num? totalPages;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['page'] = page;
    map['limit'] = limit;
    map['totalItems'] = totalItems;
    map['totalPages'] = totalPages;
    return map;
  }

}

/// id : 5466
/// name : "Smita"
/// mobile_no : "+916200551961"
/// helping_category : "smitabhatt1996@gmail.com"
/// image : "public/image/listner/WhatsApp Image 2024-09-16 at 12.12.06 PM.jpeg"
/// age : "28"
/// interest : "Studies,Friendship,Career"
/// language : "English Hindi"
/// sex : "F"
/// available_on : "all"
/// about : "I like talking to people and listening to their problems and giving them solutions so that they remain stress free and happy.\n\nI am a good listener because Listening is the ability to accurately receive and interpret messages in the communication process.\n\nI love communication between two people.\nSo Listening, however, requires more than that: it requires focus and concentrated effort, both mental and sometimes physical as well."
/// user_type : "listner"
/// charge : "5.00"
/// device_token : "d0qZ87zJTWmLWlla40_rDn:APA91bET2jj0-U0GPen79HXM71ewXNG6ZUrywkEdQmQ-F9UeJBD9k5OTlVr-WdbDyO0_jmeO4rGoiFKvuGYE_yvBLWDEswS61gTfrBE5yzPM-ZBXBVwQkskuSb9bY_YyaJgm7VyQ6ttA"
/// status : 1
/// online_status : 1
/// busy_status : 0
/// ac_delete : 0
/// delete_status : 0
/// created_at : "2023-05-24 18:00:45"
/// updated_at : "2024-09-16 12:29:42"
/// total_review_count : 774
/// average_rating : 4.7
/// rating_reviews : {}

class Data {
  Data({
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
      this.totalReviewCount, 
      this.averageRating, 
      this.ratingReviews,});

  Data.fromJson(dynamic json) {
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
    totalReviewCount = json['total_review_count'];
    averageRating = json['average_rating'];
    ratingReviews = json['rating_reviews'];
  }
  num? id;
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
  num? status;
  num? onlineStatus;
  num? busyStatus;
  num? acDelete;
  num? deleteStatus;
  String? createdAt;
  String? updatedAt;
  num? totalReviewCount;
  num? averageRating;
  dynamic ratingReviews;

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
    map['total_review_count'] = totalReviewCount;
    map['average_rating'] = averageRating;
    map['rating_reviews'] = ratingReviews;
    return map;
  }

}