import 'dart:math';
import 'package:ampify/data/utils/dimens.dart';
import 'package:ampify/data/utils/image_resources.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/presentation/widgets/base_widget.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../buisness_logic/player_bloc/player_bloc.dart';
import '../../../buisness_logic/player_bloc/player_slider_bloc.dart';
import '../../../buisness_logic/player_bloc/player_state.dart';
import '../../widgets/loading_widgets.dart';
import '../../track_widgets/track_tile.dart';

class QueueView extends StatelessWidget {
  const QueueView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayerBloc>();
    final scheme = context.scheme;
    return SafeArea(
      minimum: const EdgeInsets.only(top: kToolbarHeight),
      child: BaseWidget(
        padding: EdgeInsets.zero,
        color: scheme.background,
        resizeBottom: false,
        appBar: AppBar(
          backgroundColor: scheme.background,
          automaticallyImplyLeading: false,
          title: const Text(StringRes.queueTitle),
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: Dimens.fontLarge,
            fontWeight: FontWeight.w600,
            color: scheme.textColor,
          ),
          leading: Align(
            alignment: Alignment.topCenter,
            child: IconButton(
                onPressed: () => Navigator.pop(context),
                iconSize: Dimens.iconDefault,
                icon: Transform.rotate(
                  angle: 3 * pi / 2,
                  child: const Icon(Icons.arrow_back_ios),
                )),
          ),
        ),
        bottom: const BottomPlayer(),
        child: Column(
          children: [
            const SizedBox(height: Dimens.sizeDefault),
            Row(
              children: [
                SizedBox(width: Dimens.sizeDefault),
                Text(
                  StringRes.nowPlaying,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Dimens.fontLarge),
                ),
              ],
            ),
            BlocBuilder<PlayerBloc, PlayerState>(
              buildWhen: (pr, cr) => pr.track != cr.track,
              builder: (_, state) {
                return TrackDetailsTile(
                  track: state.track,
                  title: RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textScaler: MediaQuery.textScalerOf(context),
                      text: TextSpan(
                          style: TextStyle(
                              color: scheme.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: Dimens.fontLarge),
                          children: [
                            WidgetSpan(
                              child: SizedBox.square(
                                  dimension: Dimens.iconMedSmall,
                                  child: BlocBuilder<PlayerBloc, PlayerState>(
                                      buildWhen: (pr, cr) =>
                                          pr.playerState != cr.playerState,
                                      builder: (_, state) {
                                        if (state.playerState ==
                                            MusicState.playing) {
                                          return Image.asset(ImageRes.musicWave,
                                              fit: BoxFit.cover,
                                              color: scheme.primary);
                                        }

                                        return Image.asset(
                                            ImageRes.musicWavePaused,
                                            fit: BoxFit.cover,
                                            color: scheme.primary);
                                      })),
                            ),
                            const WidgetSpan(
                                child: SizedBox(width: Dimens.sizeExtraSmall)),
                            TextSpan(text: state.track.title ?? ''),
                          ])),
                );
              },
            ),
            Expanded(
              child: BlocBuilder<PlayerBloc, PlayerState>(
                buildWhen: (pr, cr) => pr.queue != cr.queue,
                builder: (context, state) {
                  if (state.queue.isEmpty) return const SizedBox.shrink();

                  return Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: Dimens.sizeDefault),
                          Text(
                            StringRes.nextQueue,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Dimens.fontLarge),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: bloc.clearQueue,
                            style: TextButton.styleFrom(
                                foregroundColor: scheme.disabled,
                                textStyle: TextStyle(
                                    color: scheme.textColorLight,
                                    fontWeight: FontWeight.bold)),
                            child: const Text(StringRes.clearQueue),
                          ),
                          const SizedBox(width: Dimens.sizeDefault),
                        ],
                      ),
                      Expanded(
                        child: ReorderableListView.builder(
                          itemCount: state.queue.length,
                          itemBuilder: (context, index) {
                            final item = state.queue[index];
                            return TrackDetailsTile(
                              track: item,
                              key: ValueKey(item.id),
                              trailing: Icon(Icons.menu_outlined,
                                  size: Dimens.iconMedSmall),
                            );
                          },
                          onReorder: bloc.onQueueReorder,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomPlayer extends StatefulWidget {
  const BottomPlayer({super.key});

  @override
  State<BottomPlayer> createState() => _BottomPlayerState();
}

class _BottomPlayerState extends State<BottomPlayer> {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayerBloc>();
    final scheme = context.scheme;
    final color = context.isDarkMode ? scheme.surface : scheme.backgroundDark;

    return Container(
      decoration: BoxDecoration(
        color: scheme.background,
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(100),
            offset: Offset(Dimens.zero, -Dimens.sizeMedium),
            blurRadius: Dimens.sizeMedium,
          )
        ],
      ),
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.only(bottom: Dimens.sizeSmall),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<PlayerBloc, PlayerState>(
                buildWhen: (pr, cr) => pr.track != cr.track,
                builder: (context, state) {
                  return LayoutBuilder(builder: (context, constraints) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.sizeMini),
                      child: Container(
                        width: constraints.maxWidth,
                        height: Dimens.sizeExtraSmall,
                        alignment: AlignmentDirectional.centerStart,
                        color: scheme.backgroundDark,
                        child: BlocBuilder<PlayerSliderBloc, PlayerSliderState>(
                            builder: (context, slider) {
                          Duration duration = Duration.zero;
                          double width = 0;
                          if (state.length != 0) {
                            duration = const Duration(seconds: 1);
                            width = (slider.current / (state.length ?? 0)) *
                                constraints.maxWidth;
                          }
                          return AnimatedContainer(
                              duration: duration,
                              color: scheme.primary,
                              width: width);
                        }),
                      ),
                    );
                  });
                }),
            const SizedBox(height: Dimens.sizeDefault),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: Dimens.sizeDefault),
                IconButton(
                  onPressed: bloc.onPrevious,
                  color: scheme.textColor,
                  iconSize: Dimens.iconLarge,
                  icon: const Icon(Icons.skip_previous_rounded),
                ),
                const SizedBox(width: Dimens.sizeDefault),
                BlocBuilder<PlayerBloc, PlayerState>(
                  buildWhen: (pr, cr) {
                    return pr.playerState != cr.playerState;
                  },
                  builder: (context, state) {
                    return LoadingIcon(
                      onPressed: bloc.onPlayPause,
                      iconSize: Dimens.iconLarge,
                      loaderSize: Dimens.iconLarge,
                      loading: state.playerState == MusicState.loading,
                      isSelected: state.playerState == MusicState.playing,
                      selectedIcon: const Icon(Icons.pause),
                      style: IconButton.styleFrom(
                          backgroundColor: scheme.textColor,
                          foregroundColor: scheme.surface,
                          splashFactory: NoSplash.splashFactory),
                      icon: const Icon(Icons.play_arrow),
                    );
                  },
                ),
                const SizedBox(width: Dimens.sizeDefault),
                IconButton(
                  onPressed: bloc.onNext,
                  iconSize: Dimens.iconLarge,
                  color: scheme.textColor,
                  icon: const Icon(Icons.skip_next_rounded),
                ),
                const SizedBox(width: Dimens.sizeDefault),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
