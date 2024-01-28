// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Paginavideo extends StatefulWidget {
  @override
  _PaginavideoState createState() => _PaginavideoState();
}

class _PaginavideoState extends State<Paginavideo> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Asegúrate de reemplazar 'URL_DEL_VIDEO' con la URL o la ruta de tu video.
    _controller = VideoPlayerController.asset('VIDEO DETTO')
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video'),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            // Puedes manejar la lógica de reproducción/pausa del video aquí
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
