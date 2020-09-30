import 'package:flutter/material.dart';

class BetterPlayerUtils {
  static String formatBitrate(int bitrate) {
    assert(bitrate != null, "Bitrate can't be null");
    if (bitrate < 1000) {
      return "$bitrate bit/s";
    }
    if (bitrate < 1000000) {
      var kbit = (bitrate / 1000).floor();
      return "~$kbit KBit/s";
    }
    var mbit = (bitrate / 1000000).floor();
    return "~$mbit MBit/s";
  }

  static String formatDuration(Duration position) {
    assert(position != null, "Position can't be null!");
    final ms = position.inMilliseconds;

    int seconds = ms ~/ 1000;
    final int hours = seconds ~/ 3600;
    seconds = seconds % 3600;
    var minutes = seconds ~/ 60;
    seconds = seconds % 60;

    final hoursString = hours >= 10 ? '$hours' : hours == 0 ? '00' : '0$hours';

    final minutesString =
        minutes >= 10 ? '$minutes' : minutes == 0 ? '00' : '0$minutes';

    final secondsString =
        seconds >= 10 ? '$seconds' : seconds == 0 ? '00' : '0$seconds';

    final formattedTime =
        '${hoursString == '00' ? '' : hoursString + ':'}$minutesString:$secondsString';

    return formattedTime;
  }

  static double calculateAspectRatio(BuildContext context) {
    assert(context != null, "Context can't be null!");
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return width > height ? width / height : height / width;
  }
}