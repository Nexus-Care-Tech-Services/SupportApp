// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:support/model/reaction_model.dart';

class UserPost {
  final String id;
  final int userId;
  final String content;
  final String name;
  final String profilePic;
  String emoji;
  final String status;
  Reaction? reaction;
  List<int> likes;
  List<int>? love;
  List<int>? happy;
  List<int>? please;
  List<int>? sad;
  List<int>? wow;
  final List<Map<String, dynamic>> comments;

  UserPost({
    required this.id,
    required this.userId,
    required this.content,
    required this.name,
    required this.profilePic,
    required this.emoji,
    required this.status,
    this.reaction,
    required this.likes,
    required this.love,
    required this.happy,
    required this.please,
    required this.sad,
    required this.wow,
    required this.comments,
  });

  UserPost copyWith({
    String? id,
    int? userId,
    String? content,
    String? name,
    String? profilePic,
    String? emoji,
    String? status,
    Reaction? reaction,
    List<int>? likes,
    List<int>? love,
    List<int>? happy,
    List<int>? please,
    List<int>? sad,
    List<int>? wow,
    List<Map<String, dynamic>>? comments,
  }) {
    return UserPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      emoji: emoji ?? this.emoji,
      status: status ?? this.status,
      reaction: reaction ?? this.reaction,
      likes: likes ?? this.likes,
      love: love ?? this.love,
      happy: happy ?? this.happy,
      sad: sad ?? this.sad,
      please: please ?? this.please,
      wow: wow ?? this.wow,
      comments: comments ?? this.comments,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'content': content,
      'name': name,
      'profilePic': profilePic,
      'emoji': emoji,
      'status': status,
      'reaction': reaction?.index,
      'likes': likes,
      'love': love,
      'please': please,
      'wow': wow,
      'happy': happy,
      'sad': sad,
    };
  }

  factory UserPost.fromMap(Map<String, dynamic> map) {
    return UserPost(
      id: map['id'].toString(),
      userId: map['userId'],
      content: map['content'],
      name: map['name'],
      profilePic: map['profilePic'],
      emoji: map['emoji'],
      status: map['status'],
      reaction:
          map['reaction'] != null ? Reaction.values[map['reaction']] : null,
      likes: List<int>.from(map['likes'] ?? []),
      love: List<int>.from(map['love'] ?? []),
      happy: List<int>.from(map['happy'] ?? []),
      please: List<int>.from(map['please'] ?? []),
      sad: List<int>.from(map['sad'] ?? []),
      wow: List<int>.from(map['wow'] ?? []),
      comments: List<Map<String, dynamic>>.from(map['comments'] ?? []),
    );
  }

  factory UserPost.fromJson(String json) => UserPost.fromMap(jsonDecode(json));

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'UserPost(id: $id, userId: $userId, content: $content, name: $name, profilePic: $profilePic, emoji: $emoji,status: $status, reaction: $reaction, likes: $likes,love: $love,happy: $happy,sad: $sad,please: $please,wow: $wow, comments: $comments)';
  }

  @override
  bool operator ==(covariant UserPost other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.content == content &&
        other.name == name &&
        other.profilePic == profilePic &&
        other.emoji == emoji &&
        other.status == status &&
        other.reaction == reaction &&
        listEquals(other.likes, likes) &&
        listEquals(other.love, love) &&
        listEquals(other.sad, sad) &&
        listEquals(other.happy, happy) &&
        listEquals(other.wow, wow) &&
        listEquals(other.please, please) &&
        listEquals(other.comments, comments);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        content.hashCode ^
        name.hashCode ^
        profilePic.hashCode ^
        emoji.hashCode ^
        status.hashCode ^
        reaction.hashCode ^
        likes.hashCode ^
        love.hashCode ^
        wow.hashCode ^
        sad.hashCode ^
        happy.hashCode ^
        please.hashCode ^
        comments.hashCode;
  }
}
