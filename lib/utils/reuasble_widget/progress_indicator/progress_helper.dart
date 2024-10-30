import 'package:flutter/material.dart';

import 'package:support/utils/color.dart';

class ProgressWidget extends StatelessWidget {
  final String? progressText;

  const ProgressWidget({this.progressText, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation(primaryColor),
        ),
      ),
    );
  }
}
