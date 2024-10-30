import 'package:flutter/material.dart';
import 'package:support/main.dart';
import 'package:support/utils/color.dart';

class MoodSelectionModal extends StatefulWidget {
  final Function(String) onEmojiSelected;

  const MoodSelectionModal({
    Key? key,
    required this.onEmojiSelected,
  }) : super(key: key);

  @override
  State<MoodSelectionModal> createState() => _MoodSelectionModalState();
}

class _MoodSelectionModalState extends State<MoodSelectionModal> {
  final List<String> emojiPaths = [
    'assets/mood/happy.png',
    'assets/mood/angry.png',
    'assets/mood/bored.png',
    'assets/mood/disappointed.png',
    'assets/mood/embarassed.png',
    'assets/mood/excited.png',
    'assets/mood/hungry.png',
    'assets/mood/lonely.png',
    'assets/mood/hurt.png',
    'assets/mood/nervous.png',
    'assets/mood/proud.png',
    'assets/mood/relaxed.png',
    'assets/mood/scared.png',
    'assets/mood/sick.png',
    'assets/mood/silly.png',
    'assets/mood/stressed.png',
    'assets/mood/surprised.png',
    'assets/mood/tired.png',
    'assets/mood/upset.png',
    'assets/mood/worried.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 20, right: 5, left: 5),
          constraints: const BoxConstraints(maxHeight: 300.0),
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: emojiPaths.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  String selectedEmoji = emojiPaths[index];
                  debugPrint('Selected Emoji: $selectedEmoji');
                  widget.onEmojiSelected(selectedEmoji);
                  _getEmojiName(selectedEmoji);
                },
                child: Column(
                  children: [
                    Image.asset(
                      emojiPaths[index],
                      width: 40.0,
                      height: 40.0,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      _getEmojiName(emojiPaths[index]),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11.0,
                          color: ui_mode == "dark" ? colorWhite : colorBlack),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getEmojiName(String path) {
    String mood = path.split('/').last.split('.').first;
    debugPrint("Selected Emoji: $path");
    debugPrint("Extracted Mood: $mood");
    return mood.substring(0, 1).toUpperCase() + mood.substring(1).toLowerCase();
  }
}
