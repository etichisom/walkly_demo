import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pod_player/pod_player.dart';
import 'package:video_player/video_player.dart';
import 'package:walkly/features/editor_preview/cubit/editor_cubit.dart';
import 'package:walkly/features/editor_preview/cubit/editor_state.dart';
import 'package:walkly/l10n/l10n.dart';
import 'package:walkly/service/video_tineline_service.dart';
import 'package:walkly/utils/const.dart';
import 'package:walkly/widget/icon_button.dart';
import 'package:walkly/widget/responsive_layout.dart';

class EditorView extends StatelessWidget {
  const EditorView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditorCubit(
        videoTimeLineServices: VideoTimeLineServices(),
      ),
      child: const ResponsiveLayout(
        mobileWidget: _EditorUi(),
        desktopWidget: _DesktopEditorView(),
      ),
    );
  }
}

class _DesktopEditorView extends StatelessWidget {
  const _DesktopEditorView();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).iconTheme.color,
      body: SizedBox(
        width: size.width,
        child: Column(
          children: [
            SizedBox(
              width: 360,
              height: size.height,
              child: const _EditorUi(),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorUi extends StatefulWidget {
  const _EditorUi();

  @override
  State<_EditorUi> createState() => _EditorUiState();
}

class _EditorUiState extends State<_EditorUi> {
  late PodPlayerController _controller;
  final PageController _pageController = PageController(
    viewportFraction: 0.12,
  );

  @override
  void dispose() {
   _controller.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    final cubit = context.read<EditorCubit>();
    _controller = PodPlayerController(
      podPlayerConfig: const PodPlayerConfig(
        autoPlay: false,
      ),
      playVideoFrom: PlayVideoFrom.network(
        VIDEO_URL,
      ),
    )..initialise().then((value) {
        cubit.init(_controller.totalVideoLength.inSeconds);
      });

    _controller.addListener(() async {
      cubit.updateIsPlaying(
        isPlaying: _controller.isVideoPlaying,
      );
      if (_controller.isVideoPlaying) {
        final position = _controller.currentVideoPosition.inSeconds;
        await _pageController.animateToPage(
          position,
          curve: Curves.ease,
          duration: const Duration(
            milliseconds: 300,
          ),
        );
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
                Text(
                  l10n.editorAppBarTitle,
                ),
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
          if (!_controller.isInitialised) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              if (_controller.isInitialised)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 20,
                        child: PodVideoPlayer(
                          videoAspectRatio: 16 / 20,
                          frameAspectRatio: 16 / 20,
                          controller: _controller,
                          overlayBuilder: (c) {
                            return const SizedBox();
                          },
                          alwaysShowProgressBar: false,
                        ),
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
                        _controller.isVideoPlaying
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

  final PodPlayerController controller;
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
                    controller.videoSeekTo(Duration(seconds: index));
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
