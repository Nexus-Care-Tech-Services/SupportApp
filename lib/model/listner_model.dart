/// status : true
/// message : "Data retrive successfull"
/// data : [{"id":43438,"name":"Kashish","mobile_no":"+918178007285","helping_category":"","image":"public/image/listner/Kashishxxx1723876304553.png","age":"34","interest":"Loneliness,Breakup,Friendship","language":"English,Hindi","sex":"F","available_on":"chat & cal","about":"I once found myself in a work environment that was nothing short of hostile. A few of my female colleagues began to target me, not just with harsh words but with actions that were meant to humiliate me publicly. They shouted at me, laughed at my expense, and openly degraded me in front of others. The fear that I might secure the job permanently seemed to fuel their cruelty. Each day became a battle, as their relentless attempts to demoralize me chipped away at my confidence. The pain and embarrassment were overwhelming, and I often questioned whether I could endure another day in that toxic atmosphere.\r\nBut amidst the darkness, I found a spark within myself that refused to be extinguished. I decided that I wouldn’t let their behavior define my worth or dictate my future. I began to focus on my strengths, honing my skills, and boosting my capabilities despite the daily struggles. It wasn’t easy, but I refused to let their attempts to tear me down succeed. Slowly but surely, I rebuilt my confidence, proving to myself that I was stronger than their words and actions. In the end, I emerged from the experience not just as a survivor, but as someone who had grown through the pain, turning their attempts to shame me into a source of newfound strength and resilience.","user_type":"listner","charge":"5.00","device_token":"eFu7PBybQzm4ivkDKxBHAV:APA91bHQ43lqKSSOUvppfmf9S0hjoWYutQ_WONAVSVSBubqaSxmIAg632ru8B4grUVYTDxZYTIzrhziO72wzw5ys3ud2FyY9GG7atc7yYUo8jT2eb-KQdAIcm9LH-HIqANk_8Rmhcupf","status":1,"online_status":1,"busy_status":0,"ac_delete":0,"delete_status":0,"created_at":"2024-08-11 20:25:58","updated_at":"2024-09-02 12:32:26","total_review_count":10,"average_rating":4.8,"rating_reviews":{}}]

class ListnerModel {
  ListnerModel({
      this.status, 
      this.message, 
      this.data,});

  ListnerModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(Data.fromJson(v));
      });
    }
  }
  bool? status;
  String? message;
  List<Data>? data;

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

/// id : 43438
/// name : "Kashish"
/// mobile_no : "+918178007285"
/// helping_category : ""
/// image : "public/image/listner/Kashishxxx1723876304553.png"
/// age : "34"
/// interest : "Loneliness,Breakup,Friendship"
/// language : "English,Hindi"
/// sex : "F"
/// available_on : "chat & cal"
/// about : "I once found myself in a work environment that was nothing short of hostile. A few of my female colleagues began to target me, not just with harsh words but with actions that were meant to humiliate me publicly. They shouted at me, laughed at my expense, and openly degraded me in front of others. The fear that I might secure the job permanently seemed to fuel their cruelty. Each day became a battle, as their relentless attempts to demoralize me chipped away at my confidence. The pain and embarrassment were overwhelming, and I often questioned whether I could endure another day in that toxic atmosphere.\r\nBut amidst the darkness, I found a spark within myself that refused to be extinguished. I decided that I wouldn’t let their behavior define my worth or dictate my future. I began to focus on my strengths, honing my skills, and boosting my capabilities despite the daily struggles. It wasn’t easy, but I refused to let their attempts to tear me down succeed. Slowly but surely, I rebuilt my confidence, proving to myself that I was stronger than their words and actions. In the end, I emerged from the experience not just as a survivor, but as someone who had grown through the pain, turning their attempts to shame me into a source of newfound strength and resilience."
/// user_type : "listner"
/// charge : "5.00"
/// device_token : "eFu7PBybQzm4ivkDKxBHAV:APA91bHQ43lqKSSOUvppfmf9S0hjoWYutQ_WONAVSVSBubqaSxmIAg632ru8B4grUVYTDxZYTIzrhziO72wzw5ys3ud2FyY9GG7atc7yYUo8jT2eb-KQdAIcm9LH-HIqANk_8Rmhcupf"
/// status : 1
/// online_status : 1
/// busy_status : 0
/// ac_delete : 0
/// delete_status : 0
/// created_at : "2024-08-11 20:25:58"
/// updated_at : "2024-09-02 12:32:26"
/// total_review_count : 10
/// average_rating : 4.8
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