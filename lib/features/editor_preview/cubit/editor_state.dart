import 'package:equatable/equatable.dart';
import 'package:walkly/model/video_timeline.dart';

class EditorState extends Equatable {
  const EditorState({
    this.isInitialised = false,
    this.isPlaying = false,
    this.timelines = const [],
  });

  final List<VideoTimeLine> timelines;
  final bool isPlaying;
  final bool isInitialised;

  EditorState copyWith({
    List<VideoTimeLine>? timelines,
    bool? isPlaying,
    bool? isInitialised,
  }) {
    return EditorState(
      isInitialised: isInitialised ?? this.isInitialised,
      isPlaying: isPlaying ?? this.isPlaying,
      timelines: timelines ?? this.timelines,
    );
  }

  @override
  List<Object?> get props => [
        timelines,
        isPlaying,
        isInitialised,
      ];
}
