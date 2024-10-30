// ignore_for_file: unnecessary_this

class Comment {
  final String id;
  final int createdAtSeconds;
  final int createdAtNanoseconds;
  final String type;
  final String content;
  final String name;

  Comment({
    required this.id,
    required this.createdAtSeconds,
    required this.createdAtNanoseconds,
    required this.type,
    required this.content,
    required this.name,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      createdAtSeconds: map['created_at']['seconds'] ?? 0,
      createdAtNanoseconds: map['created_at']['nanoseconds'] ?? 0,
      type: map['type'] ?? '',
      content: map['content'] ?? '',
      name: map['name'] ?? '',
    );
  }
}
