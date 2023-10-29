import 'package:flutter/material.dart';

import 'package:giga_share/resources/color_constants.dart';

import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  String url;
  VideoPage({required this.url});
  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _controller;
  late IconData playPauseIcon;
  bool isControllerInitialized = false;

  Future<void> initializeVideoPlayer(String videoUrl) async {
    _controller = VideoPlayerController.network(videoUrl);

    await _controller.initialize();
    setState(() {
      isControllerInitialized = true;
      playPauseIcon = Icons.play_arrow;
    });

    // Listen to video playback status
    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        // Video has ended
        setState(() {
          playPauseIcon = Icons.replay;
        });
        // Seek to the beginning
        _controller.seekTo(Duration(seconds: 0));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initializeVideoPlayer(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          floatingActionButton: isControllerInitialized
              ? FloatingActionButton(
                  onPressed: () {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                      setState(() {
                        playPauseIcon = Icons.play_arrow;
                      });
                    } else {
                      _controller.play();
                      setState(() {
                        playPauseIcon = Icons.pause;
                      });
                    }
                  },
                  child: Icon(playPauseIcon),
                )
              : null,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: ColorConstants.appColor,
            title: Text(
              'Video',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: isControllerInitialized
                ? Container(
                    height: MediaQuery.of(context).size.height *
                        0.7, // Set the desired height
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : CircularProgressIndicator(), // Show loading indicator until video is initialized
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
