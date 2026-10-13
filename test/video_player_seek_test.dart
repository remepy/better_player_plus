import 'dart:async';

import 'package:better_player_plus/src/configuration/better_player_buffering_configuration.dart';
import 'package:better_player_plus/src/video_player/video_player.dart';
import 'package:better_player_plus/src/video_player/video_player_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records the position the controller hands the native player on seek.
class _FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  final List<Duration?> seeks = <Duration?>[];

  @override
  Future<void> init() async {}

  @override
  Future<int?> create({
    BetterPlayerBufferingConfiguration? bufferingConfiguration,
  }) async =>
      1;

  @override
  Stream<VideoEvent> videoEventsFor(int? textureId) =>
      const Stream<VideoEvent>.empty();

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
  late _FakeVideoPlayerPlatform platform;

  setUpAll(() {
    platform = _FakeVideoPlayerPlatform();
    VideoPlayerPlatform.instance = platform;
  });

  setUp(() => platform.seeks.clear());

  Future<VideoPlayerController> controllerWithDuration(
    Duration duration,
  ) async {
    final VideoPlayerController controller = VideoPlayerController();
    // Lets _create() finish before the value is set.
    await Future<void>.delayed(Duration.zero);
    controller.value = VideoPlayerValue(duration: duration);
    return controller;
  }

  group('VideoPlayerController.seekTo', () {
    test('clamps to a known duration', () async {
      final VideoPlayerController controller =
          await controllerWithDuration(const Duration(seconds: 100));

      await controller.seekTo(const Duration(seconds: 150));

      expect(platform.seeks, <Duration>[const Duration(seconds: 100)]);
    });

    test('passes the seek through when AVPlayer reported a 0 duration',
        () async {
      final VideoPlayerController controller =
          await controllerWithDuration(Duration.zero);

      await controller.seekTo(const Duration(seconds: 30));

      expect(platform.seeks, <Duration>[const Duration(seconds: 30)]);
    });

    test('passes the seek through when ExoPlayer reported C.TIME_UNSET',
        () async {
      final VideoPlayerController controller =
          await controllerWithDuration(const Duration(milliseconds: 1));

      await controller.seekTo(const Duration(seconds: 30));

      expect(platform.seeks, <Duration>[const Duration(seconds: 30)]);
    });

    test('still clamps a negative seek to 0 with an unknown duration',
        () async {
      final VideoPlayerController controller =
          await controllerWithDuration(Duration.zero);

      await controller.seekTo(const Duration(seconds: -5));

      expect(platform.seeks, <Duration>[Duration.zero]);
    });
  });

  group('VideoPlayerValue.hasKnownDuration', () {
    test('is false for null, 0 and sub-second durations', () {
      expect(VideoPlayerValue(duration: null).hasKnownDuration, isFalse);
      expect(
          VideoPlayerValue(duration: Duration.zero).hasKnownDuration, isFalse);
      expect(
        VideoPlayerValue(duration: const Duration(milliseconds: 1))
            .hasKnownDuration,
        isFalse,
      );
    });

    test('is true from one second', () {
      expect(
        VideoPlayerValue(duration: const Duration(seconds: 1)).hasKnownDuration,
        isTrue,
      );
    });
  });
}
