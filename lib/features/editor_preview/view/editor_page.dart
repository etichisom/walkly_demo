import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:walkly/features/editor_preview/cubit/editor_cubit.dart';
import 'package:walkly/features/editor_preview/cubit/editor_state.dart';
import 'package:walkly/l10n/l10n.dart';
import 'package:walkly/service/video_tineline_service.dart';
import 'package:walkly/utils/const.dart';

class EditorPage extends StatelessWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditorCubit(
        videoTimeLineServices: VideoTimeLineServices(),
      ),
      child: const CounterView(),
    );
  }
}

class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  late VideoPlayerController _controller;
  final PageController _pageController = PageController(
    viewportFraction: 0.1,
  );

  @override
  void initState() {
    super.initState();
    final cubit = context.read<EditorCubit>();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(VIDEO_URL),
    )..initialize().then((_) {
        cubit.init(_controller.value.duration.inSeconds);
      });

    _controller.addListener(() async {
      cubit.updateIsPlaying(
        isPlaying: _controller.value.isPlaying,
      );
      if (_controller.value.isPlaying) {
        final position = await _controller.position;
        if (position != null) {
          await _pageController.animateToPage(
            position.inSeconds,
            curve: Curves.ease,
            duration: const Duration(milliseconds: 500),
          );
        }
      }
      //_pageController.jumpToPage(_controller.value.duration.inSeconds);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editorAppBarTitle),
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<EditorCubit, EditorState>(
        builder: (context, state) {
          return Column(
            children: [
              if (_controller.value.isInitialized)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: VideoPlayer(_controller),
                    ),
                  ),
                )
              else
                Container(),
              const SizedBox(
                height: 20,
              ),
              _VideoTimeline(
                controller: _controller,
                pageController: _pageController,
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            state.isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_arrow_rounded,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VideoTimeline extends StatelessWidget {
  const _VideoTimeline({
    required this.controller,
    required this.pageController,
  });

  final VideoPlayerController controller;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const SizedBox(
          height: 150,
        ),
        BlocBuilder<EditorCubit, EditorState>(
          builder: (context, state) {
            return SizedBox(
              height: 100,
              child: PageView.builder(
                itemCount: state.timelines.length,
                controller: pageController,
                onPageChanged: (index) {
                  if(!state.isPlaying){
                    controller.seekTo(Duration(seconds: index));
                  }
                },
                itemBuilder: (context, index) {
                  final data = state.timelines[index];
                  const radius = Radius.circular(6);
                  const padding = 5.0;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: data.isEnd ? padding : 0,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.only(
                              topLeft: data.isStart ? radius : Radius.zero,
                              topRight: data.isEnd ? radius : Radius.zero,
                              bottomLeft: data.isStart ? radius : Radius.zero,
                              bottomRight: data.isEnd ? radius : Radius.zero,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text('${data.value}'),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          data.text ?? '',
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
        const Positioned(
          bottom: 5,
          child: IgnorePointer(
            child: Center(
              child: SizedBox(
                height: 120,
                child: VerticalDivider(
                  color: Colors.greenAccent,
                  // Adjust the color of the vertical line
                  thickness: 4, // Adjust the width of the vertical line
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
