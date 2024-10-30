/// status : true
/// search_result : [{"id":9193,"name":"Rajshree","mobile_no":"+917096094748","helping_category":"rajshree12@gmail.com","image":"image/listner/screenshot-2024-07-03-094725_1725118505.png","age":"26","interest":"Career","language":"English","sex":"F","available_on":"all","about":"I was dealing with trust issues a year back, there was no one for me when I wanted talk after going through few terrible years which turned out be disaster and disappointment after which I lost interest and stopped trusting people, I was all alone everyone were busy in their lives going through the rough phase and no one to talk to about my situation I know the importance of having someone to talk to, someone who can provide you emotional support when you are going through the bad phase in your life. I have been through situation when you are their support someone with all you have but return you just end up feeling used when they are gone from your life and that happened two times simultaneously in result you start to blame yourself for all the happened in your life. But I decided that I have to move ahead in life. I'm here to be that friend for you, Let's talk and work together 🤝","user_type":"listner","charge":"5.00","device_token":"eL_PMIH3QW6FdX70iwABls:APA91bHVfp6CqXSUg97zB9z3PTEzWRdDXKe4oiTt6X3qXXMBFoaxxnfob_nDFbVDvLETygSCR8ZnvSHCLsrP2NNanBL7q35yfwvXQitF3NTcVxwWSD24DPcZGNhNNBzvvTdsJccV1L45","status":1,"online_status":0,"busy_status":0,"ac_delete":0,"delete_status":0,"created_at":"2023-08-10 11:55:55","updated_at":"2024-09-10 18:56:52","total_review_count":44,"avg_rating":4.9,"rating_reviews":{}}]
/// search_msg : "Data Found"

class SearchModel {
  SearchModel({
      this.status, 
      this.searchResult, 
      this.searchMsg,});

  SearchModel.fromJson(dynamic json) {
    status = json['status'];
    if (json['search_result'] != null) {
      searchResult = [];
      json['search_result'].forEach((v) {
        searchResult?.add(SearchResult.fromJson(v));
      });
    }
    searchMsg = json['search_msg'];
  }
  bool? status;
  List<SearchResult>? searchResult;
  String? searchMsg;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    if (searchResult != null) {
      map['search_result'] = searchResult?.map((v) => v.toJson()).toList();
    }
    map['search_msg'] = searchMsg;
    return map;
  }

}

/// id : 9193
/// name : "Rajshree"
/// mobile_no : "+917096094748"
/// helping_category : "rajshree12@gmail.com"
/// image : "image/listner/screenshot-2024-07-03-094725_1725118505.png"
/// age : "26"
/// interest : "Career"
/// language : "English"
/// sex : "F"
/// available_on : "all"
/// about : "I was dealing with trust issues a year back, there was no one for me when I wanted talk after going through few terrible years which turned out be disaster and disappointment after which I lost interest and stopped trusting people, I was all alone everyone were busy in their lives going through the rough phase and no one to talk to about my situation I know the importance of having someone to talk to, someone who can provide you emotional support when you are going through the bad phase in your life. I have been through situation when you are their support someone with all you have but return you just end up feeling used when they are gone from your life and that happened two times simultaneously in result you start to blame yourself for all the happened in your life. But I decided that I have to move ahead in life. I'm here to be that friend for you, Let's talk and work together 🤝"
/// user_type : "listner"
/// charge : "5.00"
/// device_token : "eL_PMIH3QW6FdX70iwABls:APA91bHVfp6CqXSUg97zB9z3PTEzWRdDXKe4oiTt6X3qXXMBFoaxxnfob_nDFbVDvLETygSCR8ZnvSHCLsrP2NNanBL7q35yfwvXQitF3NTcVxwWSD24DPcZGNhNNBzvvTdsJccV1L45"
/// status : 1
/// online_status : 0
/// busy_status : 0
/// ac_delete : 0
/// delete_status : 0
/// created_at : "2023-08-10 11:55:55"
/// updated_at : "2024-09-10 18:56:52"
/// total_review_count : 44
/// avg_rating : 4.9
/// rating_reviews : {}

class SearchResult {
  SearchResult({
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
      this.avgRating, 
      this.ratingReviews,});

  SearchResult.fromJson(dynamic json) {
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
    avgRating = json['avg_rating'];
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
  num? avgRating;
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
    map['avg_rating'] = avgRating;
    map['rating_reviews'] = ratingReviews;
    return map;
  }

}