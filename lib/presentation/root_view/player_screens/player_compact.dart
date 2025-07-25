import 'package:ampify/buisness_logic/player_bloc/player_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ampify/data/utils/exports.dart';
import '../../../buisness_logic/player_bloc/player_bloc.dart';
import '../../../buisness_logic/player_bloc/player_slider_bloc.dart';
import '../../../buisness_logic/player_bloc/player_state.dart';
import 'player_screen.dart';

class PlayerCompact extends StatelessWidget {
  const PlayerCompact({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final bloc = context.read<PlayerBloc>();
    final sliderBloc = context.read<PlayerSliderBloc>();

    return BlocConsumer<PlayerBloc, PlayerState>(
      buildWhen: (pr, cr) {
        final track = pr.track != cr.track;

        final isDuration = pr.durationLoading != cr.durationLoading;
        final isStateChange = pr.playerState != cr.playerState;
        return track || isStateChange || isDuration;
      },
      listener: (context, state) {
        if (state.playerState.isLoading || state.durationLoading) {
          sliderBloc.add(const PlayerSliderChange(0));
          return;
        }
        if (state.playerState.isPlaying) {
          bloc.positionStream?.listen((duration) {
            final current = duration.inSeconds;
            sliderBloc.add(PlayerSliderChange(current));
          });
        }
      },
      builder: (context, state) {
        final _bg =
            context.isDarkMode ? state.track.darkBgColor : state.track.bgColor;
        final bgColor = _bg?.withAlpha(100) ?? scheme.background;
        final selected = state.playerState.isPlaying;
        final loading = state.playerState.isLoading;

        return Container(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        enableDrag: true,
                        builder: (_) => const PlayerScreen(),
                      );
                    },
                    child: ColoredBox(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          Builder(builder: (context) {
                            final _scalar = MediaQuery.textScalerOf(context);
                            final dimen = _scalar.scale(Dimens.iconTileLarge);

                            return MyCachedImage(state.track.image,
                                borderRadius: Dimens.sizeMini, width: dimen);
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
                                      fontSize: Dimens.fontXXXLarge,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  state.track.subtitle ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: scheme.textColor.withAlpha(200),
                                      fontSize: Dimens.fontDefault),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
              BlocListener<PlayerSliderBloc, PlayerSliderState>(
                listenWhen: (pr, cr) {
                  final ended = cr.current == state.length;
                  final length = state.length != 0 && cr.current != 0;
                  return ended && length;
                },
                listener: (_, slider) => bloc.onTrackEnded(slider),
                child: const SizedBox.shrink(),
              ),
              const SizedBox(height: Dimens.sizeExtraSmall),
              SizedBox(
                height: Dimens.sizeExtraSmall,
                child: LayoutBuilder(builder: (context, constraints) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(Dimens.sizeMini),
                    child: Container(
                      width: constraints.maxWidth,
                      alignment: AlignmentDirectional.centerStart,
                      color: Color.alphaBlend(
                          bgColor, scheme.textColorLight.withAlpha(150)),
                      child: BlocBuilder<PlayerSliderBloc, PlayerSliderState>(
                          builder: (context, slider) {
                        Duration duration = Duration.zero;
                        double width = 0;
                        if (state.length != 0) {
                          width = (slider.current / (state.length ?? 0)) *
                              constraints.maxWidth;
                        }

                        if (state.length != 0 && slider.current != 0) {
                          duration = const Duration(seconds: 1);
                        }
                        return AnimatedContainer(
                            duration: duration,
                            width: width,
                            color: scheme.textColor);
                      }),
                    ),
                  );
                }),
              )
            ],
          ),
        );
      },
    );
  }
}
