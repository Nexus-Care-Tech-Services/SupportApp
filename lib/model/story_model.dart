/// listner_id : 9193
/// listner_image : "public/image/listner/WhatsApp Image 2023-11-18 at 9.23.43 PM.jpeg"
/// listner_name : "Rajshree"
/// image_url : "https://firebasestorage.googleapis.com/v0/b/support-stress-free.appspot.com/o/stories%2Fc2be83c7a50732998cd5e4c7d807c76f.jpg?alt=media"
/// count : 2

class StoryModel {
  final int listenerId;
  final String listenerImage;
  final String listenerName;
  final List<String> imageURLs;
  final List<int> duration;
  final List<String> captions;
  final int count;

  StoryModel({
    required this.listenerId,
    required this.listenerImage,
    required this.listenerName,
    required this.imageURLs,
    required this.duration,
    required this.captions,
    required this.count,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      listenerId: json['listner_id'],
      listenerImage: json['listner_image'],
      listenerName: json['listner_name'],
      imageURLs: List<String>.from(json['image_url']),
      duration: List<int>.from(json['duration']),
      captions: List<String>.from(json['caption']),
      count: json['count'],
    );
  }
}
