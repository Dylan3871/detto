// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, depend_on_referenced_packages, duplicate_ignore, prefer_final_fields, unused_field, file_names

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class Paginavideo extends StatefulWidget {
  @override
  _PaginavideoState createState() => _PaginavideoState();
}

class _PaginavideoState extends State<Paginavideo> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/images/Detto.mp4')
      ..initialize().then((_) {
        setState(() {});
      });

    _chewieController = ChewieController(
      videoPlayerController: _controller,
      aspectRatio: 16 / 9,
      autoInitialize: true,
      looping: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video'),
      ),
      body: Stack(
        children: [
          Center(
            child: _controller.value.isInitialized
                ? Chewie(
                    controller: _chewieController,
                  )
                : CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chewieController.dispose();
    _controller.dispose();
    super.dispose();
  }
}
