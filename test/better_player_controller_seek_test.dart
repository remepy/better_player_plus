import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:better_player_plus/src/video_player/video_player.dart';
import 'package:better_player_plus/src/video_player/video_player_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// A native player whose `initialized` event the test controls, so the race
/// where AVPlayer / ExoPlayer report the length before knowing it is
/// reproduced on every run instead of only sometimes.
class _FakeNativePlayer extends VideoPlayerPlatform {
  final List<Duration?> seeks = <Duration?>[];
  // ignore: close_sinks — closed in main()'s tearDown.
  StreamController<VideoEvent> events = StreamController<VideoEvent>();

  /// Length this player sends in `initialized`, once, when a source is set.
  Duration reportedDuration = Duration.zero;

  @override
  bool get isMock => true;

  @override
  Future<void> init() async {}

  @override
  Future<int?> create({
    BetterPlayerBufferingConfiguration? bufferingConfiguration,
  }) async =>
      1;

  @override
  Stream<VideoEvent> videoEventsFor(int? textureId) => events.stream;

  @override
  Future<void> setDataSource(int? textureId, DataSource dataSource) async =>
      events.add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          key: null,
          duration: reportedDuration,
        ),
      );

  @override
  Future<void> setLooping(int? textureId, bool looping) async {}

  @override
  Future<void> setVolume(int? textureId, double volume) async {}

  @override
  Future<void> play(int? textureId) async {}

  @override
  Future<void> pause(int? textureId) async {}

  @override
  Future<void> setSpeed(int? textureId, double speed) async {}

  @override
  Future<void> seekTo(int? textureId, Duration? position) async =>
      seeks.add(position);

  @override
  Future<Duration> getPosition(int? textureId) async => Duration.zero;

  @override
  Future<DateTime?> getAbsolutePosition(int? textureId) async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final _FakeNativePlayer nativePlayer = _FakeNativePlayer();
  VideoPlayerPlatform.instance = nativePlayer;

  late BetterPlayerController betterPlayerController;
  late List<BetterPlayerEventType> postedEvents;

  /// Opens a video whose native player reports [reportedDuration] once, the
  /// way both platforms do in `initialized`.
  Future<void> openVideo(Duration reportedDuration) async {
    nativePlayer.reportedDuration = reportedDuration;
    final VideoPlayerController videoPlayerController = VideoPlayerController();
    await Future<void>.delayed(Duration.zero);
    await videoPlayerController
        .setNetworkDataSource('https://cdn.example.com/hls/1/media/index.m3u8');
    betterPlayerController.videoPlayerController = videoPlayerController;
  }

  setUp(() {
    nativePlayer.seeks.clear();
    nativePlayer.events = StreamController<VideoEvent>();
    postedEvents = <BetterPlayerEventType>[];
    betterPlayerController =
        BetterPlayerController(const BetterPlayerConfiguration())
          ..addEventsListener(
            (BetterPlayerEvent event) =>
                postedEvents.add(event.betterPlayerEventType),
          );
  });

  tearDown(() => nativePlayer.events.close());

  for (final MapEntry<String, Duration> report in <String, Duration>{
    'AVPlayer (0 ms)': Duration.zero,
    'ExoPlayer (C.TIME_UNSET, 1 ms)': const Duration(milliseconds: 1),
  }.entries) {
    group('when ${report.key} reported no length', () {
      setUp(() => openVideo(report.value));

      test('every seek in the session reaches the native player', () async {
        for (final Duration target in <Duration>[
          const Duration(seconds: 30),
          const Duration(seconds: 90),
          const Duration(seconds: 15),
        ]) {
          await betterPlayerController.seekTo(target);
        }

        expect(nativePlayer.seeks, <Duration>[
          const Duration(seconds: 30),
          const Duration(seconds: 90),
          const Duration(seconds: 15),
        ]);
      });

      test('a seek is not reported as the video finishing', () async {
        await betterPlayerController.seekTo(const Duration(seconds: 60));

        expect(postedEvents, contains(BetterPlayerEventType.seekTo));
        expect(postedEvents, isNot(contains(BetterPlayerEventType.finished)));
      });

      test('seeking a paused video back to the start keeps it paused',
          () async {
        final VideoPlayerController videoPlayerController =
            betterPlayerController.videoPlayerController!;
        videoPlayerController.value = videoPlayerController.value.copyWith(
          position: const Duration(seconds: 30),
        );

        await betterPlayerController.seekTo(Duration.zero);

        expect(videoPlayerController.value.isPlaying, isFalse);
      });
    });
  }

  group('when the native player reported a real length', () {
    setUp(() => openVideo(const Duration(seconds: 100)));

    test('a seek past the end is clamped and reported as finished', () async {
      await betterPlayerController.seekTo(const Duration(seconds: 150));

      expect(nativePlayer.seeks, <Duration>[const Duration(seconds: 100)]);
      expect(postedEvents, contains(BetterPlayerEventType.finished));
    });

    test('a seek inside the video goes through unchanged', () async {
      await betterPlayerController.seekTo(const Duration(seconds: 40));

      expect(nativePlayer.seeks, <Duration>[const Duration(seconds: 40)]);
      expect(postedEvents, isNot(contains(BetterPlayerEventType.finished)));
    });
  });
}
