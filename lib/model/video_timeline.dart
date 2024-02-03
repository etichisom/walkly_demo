import 'package:equatable/equatable.dart';

class VideoTimeLine extends Equatable {
  const VideoTimeLine({
    required this.value,
    required this.isStart,
    required this.isEnd,
    this.text,
  });

  final int value;
  final bool isStart;
  final bool isEnd;
  final String? text;

  @override
  List<Object?> get props =>
      [
        value,
        isStart,
        isEnd,
        text,
      ];
}
