class ChatModel {
  String? chatid;
  String? message;
  bool? isSent;
  bool? isRead;
  String? replyid;
  String? replymessage;
  String? sender;

  ChatModel(this.chatid, this.message, this.isSent, this.isRead, this.replyid,
      this.replymessage, this.sender);
}
