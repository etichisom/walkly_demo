import 'package:walkly/model/video_places.dart';
import 'package:walkly/model/video_timeline.dart';

class VideoTimeLineServices {
  List<VideoPlaces> getVideoTimeLineFromVideo() {
    return [
      const VideoPlaces(
        name: 'Sitting',
        floor: 0,
        startAt: 0,
        stopAt: 13,
      ),
      const VideoPlaces(
        name: 'Dinning',
        floor: 0,
        startAt: 14,
        stopAt: 30,
      ),
      const VideoPlaces(
        name: 'Kids',
        floor: 0,
        startAt: 31,
        stopAt: 36,
      ),
      const VideoPlaces(
        name: 'Kitchen',
        floor: 0,
        startAt: 37,
        stopAt: 41,
      ),
      const VideoPlaces(
        name: 'Game',
        floor: 0,
        startAt: 42,
        stopAt: 46,
      ),
      const VideoPlaces(
        name: 'Stairs',
        floor: 0,
        startAt: 47,
        stopAt: 54,
      ),
      const VideoPlaces(
        name: 'landry',
        floor: 0,
        startAt: 55,
        stopAt: 64,
      ),
      const VideoPlaces(
        name: 'Space',
        floor: 0,
        startAt: 65,
        stopAt: 70,
      ),
      const VideoPlaces(
        name: 'Bathroom',
        floor: 0,
        startAt: 71,
        stopAt: 81,
      ),
      const VideoPlaces(
        name: 'Bedroom',
        floor: 0,
        startAt: 82,
        stopAt: 89,
      ),
    ];
  }

  List<VideoTimeLine> getTimeline(int duration) {
    final videoTimelines = <VideoTimeLine>[];
    final list = List.generate(duration, (index) => index);
    final timeLine = getVideoTimeLineFromVideo();
    for (final index in list) {
      final isStart = timeLine.where((element) => element.startAt == index);
      final isEnd = timeLine.any((element) => element.stopAt == index);
      final value = _getValue(index, timeLine);
      videoTimelines.add(
        VideoTimeLine(
          value: value,
          isStart: isStart.isNotEmpty,
          isEnd: isEnd,
          text: isStart.isNotEmpty ? isStart.first.name : null,
        ),
      );
    }
    return videoTimelines;
  }

  int _getValue(int index, List<VideoPlaces> timeLine) {
    var value = 0;
    for (final element in timeLine) {
      if (element.startAt <= index && index <= element.stopAt) {
        value = index - element.startAt;
      }
    }
    return value;
  }
}
