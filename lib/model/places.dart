import 'package:equatable/equatable.dart';
import 'package:walkly/model/video_timeline.dart';

class GroupedTimeline extends Equatable {
  const GroupedTimeline({
    required this.name,
    required this.timeLines,
  });

  final List<VideoTimeLine> timeLines;
  final String name;

  @override
  List<Object?> get props => [
        timeLines,
        name,
      ];
}
