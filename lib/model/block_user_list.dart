/// blockedListeners : [{"id":50,"name":"Amreen","image":"public/image/listner/12345.jpg","block_count":3}]

class BlockUserList {
  BlockUserList({
    this.blockedListeners,
  });

  BlockUserList.fromJson(dynamic json) {
    if (json['blockedListeners'] != null) {
      blockedListeners = [];
      json['blockedListeners'].forEach((v) {
        blockedListeners?.add(BlockedListeners.fromJson(v));
      });
    }
  }

  List<BlockedListeners>? blockedListeners;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (blockedListeners != null) {
      map['blockedListeners'] =
          blockedListeners?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// id : 50
/// name : "Amreen"
/// image : "public/image/listner/12345.jpg"
/// block_count : 3

class BlockedListeners {
  BlockedListeners({
    this.id,
    this.name,
    this.image,
    this.blockCount,
  });

  BlockedListeners.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    blockCount = json['block_count'];
  }

  int? id;
  String? name;
  String? image;
  int? blockCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['image'] = image;
    map['block_count'] = blockCount;
    return map;
  }
}
