import 'dart:convert';
import 'package:flutter/material.dart';


class VideoInfo extends StatefulWidget {
  const VideoInfo({Key? key}) : super(key: key);
  @override
  _VideoInfoState createState() => _VideoInfoState();
}
class _VideoInfoState extends State<VideoInfo> {
  late List<dynamic> videoInfo;
  bool _playArea = false;
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    try {
      String jsonData = await DefaultAssetBundle.of(context)
          .loadString("json/videoinfo.json");
      setState(() {
        videoInfo = json.decode(jsonData);
      });
    } catch (e) {
      print('Error loading video info: $e');
      videoInfo = []; // Ensure videoInfo is initialized even on error
    }
  }

  void _onTapVideo(String videoUrl) {
    _controller = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() {
          _playArea = true;
        });
        _controller.play();
      });

    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    final bool isPlaying = _controller.value.isPlaying;
    if (isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = isPlaying;
      });
    }
  }

  void _playOrPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  void _rewind() {
    final Duration currentPosition = _controller.value.position;
    if (currentPosition > Duration(seconds: 5)) {
      _controller.seekTo(currentPosition - Duration(seconds: 5));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: _playArea
              ? null
              : LinearGradient(
            colors: [
              Colors.blue.withOpacity(0.9),
              Colors.blue,
            ],
            begin: const FractionalOffset(0.0, 0.4),
            end: Alignment.topRight,
          ),
          color: _playArea ? Colors.blue : null,
        ),
        child: Column(
          children: [
            _buildTopSection(),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(70),
                  ),
                ),
                child: _buildVideoList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return _playArea
        ? Container(
      height: 300, // Adjust height based on your requirement
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          _buildControlView(),
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                setState(() {
                  _playArea = false;
                  _controller.pause();
                });
              },
              color: Colors.white,
            ),
          ),
        ],
      ),
    )
        : Container(
      padding: const EdgeInsets.only(top: 70,  ),
      width: MediaQuery.of(context).size.width,
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Legs Toning and Glutes Workout",
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 50),
          Row(
            children: [
              _buildInfoContainer("68 min"),
              SizedBox(width: 10),
              _buildInfoContainer("Resistant band, kettlebell"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContainer(String text) {
    return Container(
      width: 170,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [
            Colors.blueAccent.withOpacity(0.9),
            Colors.blueAccent,
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildVideoList() {
    return ListView.builder(
      itemCount: videoInfo.length,
      itemBuilder: (context, index) {
        final video = videoInfo[index];
        return GestureDetector(
          onTap: () {
            _onTapVideo(video['videoUrl']);
          },
          child: _buildVideoItem(video),
        );
      },
    );
  }

  Widget _buildVideoItem(Map<String, dynamic> video) {
    return Container(
      height: 135,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage(
                      video['thumbnail'] ?? 'assets/images/placeholder.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video['title'] ?? '', // Ensure title is not null
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      video['time'] ?? '', // Ensure time is not null
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 80,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(0xFFeaeefc),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '15s rest',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff001a4a),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: Color(0xFF389fed),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _rewind,
          icon: Icon(
            Icons.fast_rewind,
            size: 36,
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: _playOrPause,
          icon: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            size: 36,
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: _rewind,
          icon: Icon(
            Icons.fast_rewind,
            size: 36,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
