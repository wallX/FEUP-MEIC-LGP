import 'package:flutter/material.dart';
import 'package:app/widgets/video/video_player_page.dart';
import 'package:video_player/video_player.dart';

class VideoThumbnail extends StatefulWidget {
  const VideoThumbnail({super.key, required this.videoPath});

  final String videoPath;

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: InkWell(
        child: _controller.value.isInitialized
            ? SizedBox(
                width: 100.0,
                height: 56.0,
                child: VideoPlayer(_controller),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerPage(videoPath: widget.videoPath),
            ),
          );
        },
      ),
    );
  }
}