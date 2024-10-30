import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:support/utils/color.dart';

class ListnerImage extends StatefulWidget {
  final Widget? image;

  const ListnerImage({Key? key, this.image}) : super(key: key);

  @override
  State<ListnerImage> createState() => _ListnerImageState();
}

class _ListnerImageState extends State<ListnerImage> {
  @override
  void initState() {
    super.initState();
    FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  @override
  void dispose() {
    super.dispose();
    FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: backgroundColor,
            ),
            onPressed: () {
              setState(() {
                FlutterWindowManager.clearFlags(
                    FlutterWindowManager.FLAG_SECURE);
              });
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: Center(
            child: InteractiveViewer(
              child: widget.image!,
            ),
          ),
        ));
  }
}
