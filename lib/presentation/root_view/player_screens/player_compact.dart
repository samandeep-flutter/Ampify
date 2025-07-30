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
        return track || pr.playerState != cr.playerState;
      },
      listener: (context, state) {
        if (state.playerState.isLoading) {
          sliderBloc.add(PlayerSliderReset());
          return;
        }
        if (state.playerState.isPlaying) {
          bloc.positionStream?.listen((duration) {
            sliderBloc.add(PlayerSliderChange(duration));
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
                  return ended && !state.length.isZero && !cr.current.isZero;
                },
                listener: (context, slider) {
                  if (state.playerState.isLoading) return;
                  final _slider = context.read<PlayerSliderBloc>();
                  if (!state.length.isZero && !slider.current.isZero) {
                    if (slider.current == state.length) {
                      bloc.add(PlayerTrackEnded());
                      _slider.add(PlayerSliderReset());
                    }
                  }
                },
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
                        final factor = slider.current.widthFactor(state.length);
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
        );
      },
    );
  }
}
