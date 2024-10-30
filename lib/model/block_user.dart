/// message : "Blocked successfully"
/// existingBlockedUser : {"id":2,"user_id":1991,"listner_id":50,"block_count":2,"block_reason":"arrogant","unblock_cost":299,"account_blocked_until":"","account_status":"blocked","created_at":"2024-02-20T12:38:03.000Z","updated_at":"2024-02-20T12:38:03.000Z"}

class BlockUser {
  BlockUser({
    this.message,
    this.existingBlockedUser,
  });

  BlockUser.fromJson(dynamic json) {
    message = json['message'];
    existingBlockedUser = json['existingBlockedUser'] != null
        ? ExistingBlockedUser.fromJson(json['existingBlockedUser'])
        : null;
  }

  String? message;
  ExistingBlockedUser? existingBlockedUser;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    if (existingBlockedUser != null) {
      map['existingBlockedUser'] = existingBlockedUser?.toJson();
    }
    return map;
  }
}

/// id : 2
/// user_id : 1991
/// listner_id : 50
/// block_count : 2
/// block_reason : "arrogant"
/// unblock_cost : 299
/// account_blocked_until : ""
/// account_status : "blocked"
/// created_at : "2024-02-20T12:38:03.000Z"
/// updated_at : "2024-02-20T12:38:03.000Z"

class ExistingBlockedUser {
  ExistingBlockedUser({
    this.id,
    this.userId,
    this.listnerId,
    this.blockCount,
    this.blockReason,
    this.unblockCost,
    this.accountBlockedUntil,
    this.accountStatus,
    this.createdAt,
    this.updatedAt,
  });

  ExistingBlockedUser.fromJson(dynamic json) {
    id = json['id'];
    userId = json['user_id'];
    listnerId = json['listner_id'];
    blockCount = json['block_count'];
    blockReason = json['block_reason'];
    unblockCost = json['unblock_cost'];
    accountBlockedUntil = json['account_blocked_until'];
    accountStatus = json['account_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  int? id;
  int? userId;
  int? listnerId;
  int? blockCount;
  String? blockReason;
  int? unblockCost;
  String? accountBlockedUntil;
  String? accountStatus;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['user_id'] = userId;
    map['listner_id'] = listnerId;
    map['block_count'] = blockCount;
    map['block_reason'] = blockReason;
    map['unblock_cost'] = unblockCost;
    map['account_blocked_until'] = accountBlockedUntil;
    map['account_status'] = accountStatus;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}
