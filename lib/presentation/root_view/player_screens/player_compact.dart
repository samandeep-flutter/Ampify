import 'package:ampify/buisness_logic/player_bloc/player_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ampify/data/utils/exports.dart';
import '../../../buisness_logic/player_bloc/player_bloc.dart';
import 'package:ampify/presentation/root_view/player_screens/player_screen.dart';
import '../../../buisness_logic/player_bloc/player_slider_bloc.dart';
import '../../../buisness_logic/player_bloc/player_state.dart';

class PlayerCompact extends StatelessWidget {
  const PlayerCompact({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final bloc = context.read<PlayerBloc>();

    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (pr, cr) {
        final track = pr.track != cr.track;
        return track || pr.playerState != cr.playerState;
      },
      builder: (context, state) {
        final _bg =
            context.isDarkMode ? state.track.darkBgColor : state.track.bgColor;
        final bgColor = _bg?.withAlpha(150) ?? scheme.background;
        final selected = state.playerState.isPlaying;
        final loading = state.playerState.isLoading;

        return AnimatedContainer(
          duration: Durations.long2,
          margin: Utils.insetsOnly(Dimens.sizeSmall, bottom: Dimens.zero),
          padding: Utils.insetsOnly(Dimens.sizeExtraSmall, bottom: Dimens.zero),
          decoration: BoxDecoration(
            color: Color.alphaBlend(bgColor, scheme.surface),
            borderRadius: BorderRadius.circular(Dimens.sizeExtraSmall),
            boxShadow: [
              BoxShadow(
                color: scheme.surface.withAlpha(150),
                offset: Offset(0, Dimens.sizeLarge),
                blurRadius: Dimens.sizeMedium,
                spreadRadius: Dimens.sizeLarge,
              ),
              BoxShadow(
                color: scheme.surface.withAlpha(100),
                blurRadius: Dimens.sizeMedium,
                spreadRadius: Dimens.sizeLarge,
              ),
              BoxShadow(
                color: Colors.black26,
                blurRadius: Dimens.sizeMedium,
                spreadRadius: Dimens.sizeExtraSmall,
              ),
            ],
          ),
          child: GestureDetector(
            onTap: () => toPlayerScreen(context),
            onHorizontalDragEnd: (details) {
              if ((details.primaryVelocity ?? 0) < 0) {
                bloc.add(PlayerNextTrack());
              } else if ((details.primaryVelocity ?? 0) > 0) {
                bloc.add(PlayerPreviousTrack());
              }
            },
            child: ColoredBox(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Row(
                        children: [
                          Builder(builder: (context) {
                            return DecoratedBox(
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: Dimens.sizeMedium,
                                  spreadRadius: Dimens.sizeExtraSmall,
                                ),
                              ]),
                              child: MyCachedImage(
                                state.track.image,
                                borderRadius: Dimens.sizeMini,
                                width: Dimens.iconUltraLarge,
                              ),
                            );
                          }),
                          const SizedBox(width: Dimens.sizeSmall),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.track.title ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: Dimens.fontDefault + 1,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  state.track.subtitle ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: scheme.textColor.withAlpha(200),
                                      fontSize: Dimens.fontDefault - 1),
                                )
                              ],
                            ),
                          ),
                        ],
                      )),
                      const SizedBox(width: Dimens.sizeSmall),
                      LoadingIcon(
                        loading: loading,
                        onPressed: bloc.onPlayPause,
                        iconSize: Dimens.iconXLarge,
                        isSelected: selected,
                        selectedIcon: const Icon(Icons.pause),
                        style: IconButton.styleFrom(
                            foregroundColor: scheme.textColor,
                            splashFactory: NoSplash.splashFactory),
                        icon: const Icon(Icons.play_arrow),
                      ),
                      const SizedBox(width: Dimens.sizeSmall),
                    ],
                  ),
                  Builder(builder: (context) {
                    final bloc = context.read<PlayerSliderBloc>();
                    return BlocListener<PlayerBloc, PlayerState>(
                      listenWhen: (pr, cr) => pr.track != cr.track,
                      listener: (context, state) {
                        bloc.streamSub?.cancel();
                        bloc.add(PlayerSliderReset());
                        bloc.streamSub = bloc.durationStream.listen((duration) {
                          if (duration is! Duration) return;
                          final _duration = state.track.duration;
                          if (duration <= (_duration ?? Duration.zero)) {
                            bloc.add(PlayerSliderChange(duration));
                          }
                        });
                      },
                      child: SizedBox.shrink(),
                    );
                  }),
                  BlocListener<PlayerSliderBloc, PlayerSliderState>(
                    listenWhen: (pr, cr) {
                      final ended = cr.current == state.track.duration;
                      final notSame = pr.current != cr.current;
                      return ended && notSame && !cr.current.isZero;
                    },
                    listener: (context, slider) {
                      if (state.playerState.isLoading) return;
                      if (slider.current == state.track.duration) {
                        bloc.add(PlayerTrackEnded());
                      }
                    },
                    child: const SizedBox.shrink(),
                  ),
                  const SizedBox(height: Dimens.sizeExtraSmall),
                  SizedBox(
                    height: Dimens.sizeExtraSmall - 1,
                    child: LayoutBuilder(builder: (context, constraints) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(Dimens.sizeMini),
                        child: Container(
                          width: constraints.maxWidth,
                          alignment: AlignmentDirectional.centerStart,
                          color: Color.alphaBlend(
                              bgColor, scheme.textColorLight.withAlpha(150)),
                          child:
                              BlocBuilder<PlayerSliderBloc, PlayerSliderState>(
                                  builder: (context, slider) {
                            final factor = slider.current
                                .widthFactor(state.track.duration);
                            return AnimatedContainer(
                                duration: slider.animate,
                                width: factor * constraints.maxWidth,
                                color: scheme.textColor);
                          }),
                        ),
                      );
                    }),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void toPlayerScreen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const PlayerScreen(),
    );
  }
}
