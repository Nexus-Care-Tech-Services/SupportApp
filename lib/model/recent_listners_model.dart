/// status : true
/// message : "Last 5 listeners who have received transactions from the specified user retrieved successfully"
/// listeners : [{"id":9193,"name":"Rajshree"}]

class RecentListnersModel {
  RecentListnersModel({
    this.status,
    this.message,
    this.listeners,
  });

  RecentListnersModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    if (json['listeners'] != null) {
      listeners = [];
      json['listeners'].forEach((v) {
        listeners?.add(Listeners.fromJson(v));
      });
    }
  }

  bool? status;
  String? message;
  List<Listeners>? listeners;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (listeners != null) {
      map['listeners'] = listeners?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// id : 9193
/// name : "Rajshree"

class Listeners {
  Listeners({
    this.id,
    this.name,
  });

  Listeners.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
  }

  int? id;
  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    return map;
  }
}
