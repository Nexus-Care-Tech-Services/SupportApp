import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:support/model/reel_model.dart';
import 'package:support/screen/reels/options_screen.dart';
import 'package:support/utils/color.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoTile extends StatefulWidget {
  const VideoTile(
      {Key? key,
      required this.video,
      required this.currentIndex,
      required this.data})
      : super(key: key);
  final String video;
  final ReelModel data;
  final int currentIndex;

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  late CachedVideoPlayerPlusController _videoController;
  late Future _initializeVideoPlayer;
  bool isPlaying = true;
  XFile? thumbnailImage;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    _videoController = CachedVideoPlayerPlusController.networkUrl(
        Uri.parse(widget.video),
        invalidateCacheIfOlderThan: const Duration(days: 30));
    _initializeVideoPlayer = _videoController.initialize();
    _videoController.setLooping(true);
    _videoController.play();
    createThumbnail();
    super.initState();
  }

  Future<void> createThumbnail() async {
    setState(() {
      isLoading = true;
    });
    final thumbnailData = await VideoThumbnail.thumbnailData(
      video: widget.data.data![widget.currentIndex].reelUrl!,
      imageFormat: ImageFormat.PNG,
      maxWidth: 200,
      quality: 100,
    );
    final String dir = (await getTemporaryDirectory()).path;

    // Save thumbnail data to a temporary file
    final String filePath = '$dir/thumbnail.png';
    await File(filePath).writeAsBytes(thumbnailData!);
    thumbnailImage = XFile(filePath);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void _pausePlayVideo() {
    isPlaying ? _videoController.pause() : _videoController.play();
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 1.15,
      width: MediaQuery.of(context).size.width,
      color: colorBlack,
      child: FutureBuilder(
        future: _initializeVideoPlayer,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return InkWell(
              onTap: () {
                _pausePlayVideo();
              },
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Stack(
                      alignment: Alignment.center,
                      fit: StackFit.loose,
                      children: [
                          AspectRatio(
                              aspectRatio: _videoController.value.aspectRatio,
                              child: CachedVideoPlayerPlus(_videoController)),
                          IconButton(
                              onPressed: () {
                                _pausePlayVideo();
                              },
                              icon: Icon(
                                Icons.play_arrow,
                                color: Colors.white
                                    .withOpacity(isPlaying ? 0 : 0.5),
                                size: 60,
                              )),
                          OptionsScreen(
                            name: widget
                                .data.data![widget.currentIndex].listnerName!,
                            image: widget
                                .data.data![widget.currentIndex].listnerImage!,
                            reelId:
                                widget.data.data![widget.currentIndex].reelId!,
                            listnerId: int.parse(widget
                                .data.data![widget.currentIndex].listnerId
                                .toString()),
                            caption: widget
                                    .data.data![widget.currentIndex].caption ??
                                "",
                            index: widget.currentIndex,
                            thumbnailImage: thumbnailImage!,
                          )
                        ]),
            );
          } else {
            return Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
