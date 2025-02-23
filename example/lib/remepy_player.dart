import 'package:better_player_plus/better_player_plus.dart';
import 'package:better_player_example/constants.dart';
import 'package:flutter/material.dart';

import '../main.dart';

const String cdnUrl = 'https://dev-api.remepy.com';
const int _lineLength = 60;
const int version = 2;
const anatVideoName = 'f6cea56c-f46e-40e6-82e1-8a9322f0ea1d';
const arielVideoName = '214a2daa-ec17-485b-aeca-98ce3a57059c';
const amirVideoName = '2ffc67de-faea-4400-b224-168e23b9e926';
const anatBigVideoName = '26475486-49d5-4abd-a14f-12b740d401d5';
const seekDuration = Duration(seconds: 15);

class RemepyPlayer extends StatefulWidget {
  late BetterPlayerController _betterPlayerController;
  final int index;
  late final String movieName;
  late final String author;

  String get _subtitlesUrl =>
      'https://dev-cdn.remepy.com/subtitles/$movieName.srt?line_length=$_lineLength&v=$version';

  String get _url =>
      'https://dev-cdn.remepy.com/hls/2/$movieName/index.m3u8'; // video

  String accessToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6Ijc4YmY5ZGQyLTVjZWEtNDc1YS05Y2IxLTQxY2U2NzAwOWQzYyIsInVzZXJfaWQiOiJhZTIyOWRmZC05OTQ5LTRjZDgtOTFiMi1lZTJhZjU1Yzk3YzgiLCJyb2xlIjoiNjNjMjkwYzgtM2E2Yy00ZTYzLWJjZmYtMmNlMWYyNGQwYjgxIiwiYXBwX2FjY2VzcyI6MCwiYWRtaW5fYWNjZXNzIjowLCJtb2JpbGVfYWNjZXNzIjoxLCJpYXQiOjE3Mzg4NTY0MzgsImV4cCI6MTczODg2MzYzOCwiaXNzIjoiZGlyZWN0dXMifQ.MjaDexVwa_IRLyZnK-SULczQ7oovyV2Z69jn5XQGp-I';

  RemepyPlayer({Key? key, required this.index}) : super(key: key) {
    switch (index % 4) {
      case 0:
        movieName = anatVideoName;
        author = 'Anat';
        break;
      case 1:
        movieName = arielVideoName;
        author = 'Ariel';
        break;
      case 2:
        movieName = anatBigVideoName;
        author = 'Anat Big video';
        break;
      case 3:
        movieName = amirVideoName;
        author = 'Amir';
        break;
    }
  }

  @override
  _RemepyPlayerState createState() => _RemepyPlayerState();

  void pause() {
    _betterPlayerController.videoPlayerController?.pause();
  }
}

class _RemepyPlayerState extends State<RemepyPlayer> with RouteAware {
  bool isPlaying = true;

  BetterPlayerDataSource get _dataSource {
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
    };
    List<BetterPlayerSubtitlesSource> subtitles = [
      BetterPlayerSubtitlesSource(
        type: BetterPlayerSubtitlesSourceType.network,
        selectedByDefault: true,
        urls: [widget._subtitlesUrl],
        headers: headers,
      )
    ];
    return BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget._url,
      subtitles: subtitles,
      headers: headers,
      videoFormat: BetterPlayerVideoFormat.hls,
    );
  }

  @override
  void initState() {
    BetterPlayerConfiguration configuration = BetterPlayerConfiguration(
      fit: BoxFit.fitHeight,
      expandToFill: false,
      handleLifecycle: true,
      // placeholder: Container(
      //   color: AppThemeData.colorScheme.surface,
      // ),
      showPlaceholderUntilPlay: false,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        enableMute: false,
        enableSkips: false,
        enableQualities: false,
        enableSubtitles: true,
        enableFullscreen: false,
        enableAudioTracks: false,
        enableOverflowMenu: false,
        enablePlaybackSpeed: false,
        showControls: true,
      ),
    );
    widget._betterPlayerController = BetterPlayerController(configuration,
        betterPlayerDataSource: _dataSource);

    super.initState();
  }

  //widget._betterPlayerController.setupDataSource(dataSource);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Click play on player to show notification in status bar.",
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              double availableHeight = constraints.maxHeight;
              return SizedBox(
                  height: availableHeight,
                  child:
                      BetterPlayer(controller: widget._betterPlayerController));
            }),
          ),
          Row(
            children: [
              TextButton(
                  onPressed: () => Navigator.pop(context), child: Text("Back")),
              SizedBox(width: 2),
              TextButton(onPressed: () => _rewind(), child: Text("Rewind")),
              SizedBox(width: 2),
              TextButton(
                  onPressed: () => _pause(),
                  child: Text(isPlaying ? "Pause" : "Play")),
              SizedBox(width: 2),
              TextButton(onPressed: () => _forward(), child: Text("Forward")),
              // SizedBox(width: 2),
              // TextButton(onPressed: () => _next(context), child: Text("Next"))
            ],
          )
        ],
      ),
    );
  }

  void _next(BuildContext context) {
    // return Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => RemepyPlayerPage(index: widget.index + 1)),
    // );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    print("GUYGUY ${widget.index} Screen is now visible");
  }

  @override
  void didPop() {
    print("GUYGUY ${widget.index} Screen was popped (navigated away)");
    widget._betterPlayerController.videoPlayerController?.pause();
  }

  @override
  void didPushNext() {
    print("GUYGUY ${widget.index} Another screen was pushed on top");
    widget._betterPlayerController.videoPlayerController?.pause();
    //_betterPlayerController.dispose();
  }

  @override
  void didPopNext() {
    print(
        "GUYGUY ${widget.index} Returned to this screen (previous screen popped)");
  }

  Future<void> _rewind() async {
    Duration? pos =
        await widget._betterPlayerController.videoPlayerController?.position;
    widget._betterPlayerController.seekTo(pos! - seekDuration);
  }

  Future<void> _forward() async {
    Duration? pos =
        await widget._betterPlayerController.videoPlayerController?.position;
    widget._betterPlayerController.seekTo(pos! + seekDuration);
  }

  Future<void> _pause() async {
    if (widget._betterPlayerController.isPlaying() == true) {
      widget._betterPlayerController.pause();
    } else {
      widget._betterPlayerController.play();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }
}
