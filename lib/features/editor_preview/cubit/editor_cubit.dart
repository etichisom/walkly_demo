import 'package:bloc/bloc.dart';
import 'package:walkly/features/editor_preview/cubit/editor_state.dart';
import 'package:walkly/service/video_tineline_service.dart';

class EditorCubit extends Cubit<EditorState> {
  EditorCubit({
    required this.videoTimeLineServices,
  }) : super(const EditorState());

  final VideoTimeLineServices videoTimeLineServices;

  void init(int duration) {
    emit(
      state.copyWith(
        timelines: videoTimeLineServices.getTimeline(duration),
        isInitialised: true,
      ),
    );
  }

  void updateIsPlaying({
    required bool isPlaying,
  }) {
    if (isPlaying == state.isPlaying) return;
    emit(
      state.copyWith(
        isPlaying: isPlaying,
      ),
    );
  }
}
