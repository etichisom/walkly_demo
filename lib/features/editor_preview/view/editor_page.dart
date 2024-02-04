import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:walkly/features/editor_preview/cubit/editor_cubit.dart';
import 'package:walkly/features/editor_preview/cubit/editor_state.dart';
import 'package:walkly/l10n/l10n.dart';
import 'package:walkly/service/video_tineline_service.dart';
import 'package:walkly/utils/const.dart';
import 'package:walkly/widget/icon_button.dart';

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
    viewportFraction: 0.138,
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
            duration: const Duration(
              milliseconds: 300,
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(
          size.width,
          80,
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20,
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.greenAccent,
                        size: 13,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        l10n.back,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(l10n.editorAppBarTitle),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    l10n.close,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<EditorCubit, EditorState>(
        builder: (context, state) {
          return Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              if (_controller.value.isInitialized)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                      child: VideoPlayer(
                        _controller,
                      ),
                    ),
                  ),
                )
              else
                Container(),
              const SizedBox(
                height: 20,
              ),
              if (state.area != null)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: Text(
                    '${state.area} Area, Floor 0',
                  ),
                )
              else
                const SizedBox.shrink(),
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ContainerIcon(
                      icon: Icon(
                        state.isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_arrow_rounded,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        size: 35,
                      ),
                      onPressed: () {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      },
                    ),
                    ContainerIcon(
                      icon: Icon(
                        Icons.exit_to_app_outlined,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        size: 30,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).iconTheme.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        l10n.next,
                        style: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
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
          height: 110,
        ),
        BlocBuilder<EditorCubit, EditorState>(
          builder: (context, state) {
            return SizedBox(
              height: 100,
              child: PageView.builder(
                itemCount: state.timelines.length,
                controller: pageController,
                onPageChanged: (index) {
                  if (!state.isPlaying) {
                    controller.seekTo(Duration(seconds: index));
                  }
                  context.read<EditorCubit>().updateArea(
                        area: state.timelines[index].text,
                      );
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 50,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.purple.shade400,
                            borderRadius: BorderRadius.only(
                              topLeft: data.isStart ? radius : Radius.zero,
                              topRight: data.isEnd ? radius : Radius.zero,
                              bottomLeft: data.isStart ? radius : Radius.zero,
                              bottomRight: data.isEnd ? radius : Radius.zero,
                            ),
                            gradient: LinearGradient(
                              colors: [
                                Colors.indigo,
                                Colors.indigo.shade600,
                              ],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text('${data.value}'),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        if (data.text != null)
                          Text(
                            '${data.text}\nFloor:0',
                            style: const TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w800,
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
      ],
    );
  }
}
