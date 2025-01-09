import 'package:flutter/material.dart';
import 'package:ampify/data/utils/dimens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ampify/presentation/widgets/loading_widgets.dart';
import 'package:ampify/presentation/widgets/my_cached_image.dart';
import 'package:ampify/services/extension_services.dart';
import '../../../buisness_logic/player_bloc/player_bloc.dart';
import '../../../buisness_logic/player_bloc/player_events.dart';
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

    const duration = Duration(milliseconds: 300);
    const double playerHeight = 60;
    const double padding = 5;

    return BlocConsumer<PlayerBloc, PlayerState>(
      buildWhen: (pr, cr) {
        final id = pr.track.id != cr.track.id;
        final isShow = pr.showPlayer != cr.showPlayer;
        final isStateChange = pr.playerState != cr.playerState;
        return id || isShow || isStateChange;
      },
      listener: (context, state) {
        if (state.playerState == MusicState.loading) {
          sliderBloc.add(const PlayerSliderChange(0));
          return;
        }
        if (state.playerState == MusicState.playing) {
          bloc.positionStream?.listen((duration) {
            final current = duration.inSeconds;
            sliderBloc.add(PlayerSliderChange(current));
          });
        }
      },
      builder: (context, state) {
        final bgColor = state.track.bgColor?.withOpacity(.15) ?? Colors.white;
        final selected = state.playerState == MusicState.playing;
        final loading = state.playerState == MusicState.loading;

        return AnimatedSlide(
          duration: duration,
          offset: Offset(0.0, state.showPlayer ?? false ? 0.07 : 1),
          child: Container(
            height: playerHeight,
            width: double.infinity,
            margin: const EdgeInsets.only(
                bottom: Dimens.kNavBarHeight,
                left: Dimens.sizeSmall,
                right: Dimens.sizeSmall),
            padding: const EdgeInsets.fromLTRB(padding, padding, padding, 0),
            decoration: BoxDecoration(
              color: Color.alphaBlend(bgColor, Colors.white),
              borderRadius: BorderRadius.circular(Dimens.sizeSmall - 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Row(
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
                              MyCachedImage(
                                state.track.image,
                                width: playerHeight - padding * 2,
                                borderRadius: 2,
                              ),
                              const SizedBox(width: Dimens.sizeSmall),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.track.title ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      state.track.subtitle ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: scheme.textColorLight,
                                          fontSize: Dimens.fontMed),
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
                        iconSize: Dimens.sizeMidLarge,
                        isSelected: selected,
                        selectedIcon: const Icon(Icons.pause),
                        style: IconButton.styleFrom(
                            splashFactory: NoSplash.splashFactory),
                        icon: const Icon(Icons.play_arrow),
                      ),
                      const SizedBox(width: Dimens.sizeSmall),
                    ],
                  ),
                ),
                const SizedBox(height: Dimens.sizeExtraSmall),
                LayoutBuilder(builder: (context, constraints) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Container(
                      width: constraints.maxWidth,
                      height: Dimens.sizeExtraSmall - 1,
                      alignment: AlignmentDirectional.centerStart,
                      color: Color.alphaBlend(bgColor, Colors.grey[100]!),
                      child: BlocConsumer<PlayerSliderBloc, PlayerSliderState>(
                          listener: (context, slider) {
                        if (slider.current == state.length &&
                            state.length != 0) {
                          bloc.add(PlayerTrackEnded());
                        }
                      }, builder: (context, slider) {
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
                          width: width,
                        );
                      }),
                    ),
                  );
                })
              ],
            ),
          ),
        );
      },
    );
  }
}
