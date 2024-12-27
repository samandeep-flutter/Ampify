import 'dart:math';
import 'package:ampify/buisness_logic/player_bloc/player_bloc.dart';
import '../../../buisness_logic/player_bloc/player_events.dart';
import '../../../buisness_logic/player_bloc/player_slider_bloc.dart';
import 'package:ampify/presentation/widgets/my_cached_image.dart';
import 'package:ampify/data/utils/image_resources.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:ampify/data/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../buisness_logic/player_bloc/player_state.dart';
import '../../widgets/loading_widgets.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final bloc = context.read<PlayerBloc>();
    return Scaffold(
      body: CustomScrollView(slivers: [
        const SliverSafeArea(
          sliver: SliverToBoxAdapter(
            child: SizedBox(height: Dimens.sizeDefault),
          ),
        ),
        SliverAppBar(
          forceMaterialTransparency: true,
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Transform.rotate(
                angle: 3 * pi / 2,
                child: const Icon(Icons.arrow_back_ios),
              )),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
            const SizedBox(width: Dimens.sizeSmall),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
              padding: const EdgeInsets.all(Dimens.sizeSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: Dimens.sizeLarge),
                  BlocBuilder<PlayerBloc, PlayerState>(
                      buildWhen: (pre, cur) => pre.track.id != cur.track.id,
                      builder: (context, state) {
                        final fgColor = state.track.bgColor?.withOpacity(.4);
                        const bgColor = Colors.white;
                        return Container(
                          margin: const EdgeInsets.all(Dimens.sizeMedium),
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                color: Color.alphaBlend(
                                    fgColor ?? bgColor, bgColor),
                                offset: const Offset(0, 50),
                                spreadRadius: context.width * .35,
                                blurRadius: context.width * .35),
                            const BoxShadow(
                                color: Colors.black12,
                                spreadRadius: Dimens.sizeSmall,
                                blurRadius: Dimens.sizeExtraDoubleLarge)
                          ]),
                          child: MyCachedImage(
                            state.track.image,
                            borderRadius: Dimens.sizeExtraSmall,
                          ),
                        );
                      }),
                  SizedBox(height: context.height * .05),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: BlocBuilder<PlayerBloc, PlayerState>(
                              buildWhen: (pr, cr) => pr.track.id != cr.track.id,
                              builder: (context, state) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.track.title ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: Dimens.fontExtraLarge,
                                          fontWeight: FontWeight.bold,
                                          color: scheme.textColor),
                                    ),
                                    Text(
                                      state.track.subtitle ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: Dimens.fontDefault,
                                          color: scheme.textColor),
                                    ),
                                  ],
                                );
                              }),
                        ),
                        const SizedBox(width: Dimens.sizeDefault),
                        BlocBuilder<PlayerBloc, PlayerState>(
                          buildWhen: (pr, cr) => pr.liked != cr.liked,
                          builder: (context, state) {
                            return IconButton(
                              onPressed: bloc.onTrackLiked,
                              isSelected: state.liked,
                              selectedIcon: const Icon(Icons.favorite),
                              iconSize: Dimens.sizeMidLarge,
                              icon: const Icon(Icons.favorite_outline),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimens.sizeDefault),
                  BlocBuilder<PlayerBloc, PlayerState>(buildWhen: (pre, cur) {
                    final id = pre.track.id != cur.track.id;
                    final length = pre.length != cur.length;
                    return id || length;
                  }, builder: (context, state) {
                    final loading = state.playerState == MusicState.loading;
                    return BlocConsumer<PlayerSliderBloc, PlayerSliderState>(
                        listener: (context, slider) {
                      if (slider.current == state.length && state.length != 0) {
                        bloc.add(PlayerTrackEnded());
                      }
                    }, builder: (context, slider) {
                      double current = 0;
                      int length = 1;
                      if (!loading && state.length != 0) {
                        current = slider.current.toDouble();
                        length = state.length ?? 1;
                      }
                      final currLength = Duration(seconds: slider.current);
                      final maxLength = Duration(seconds: state.length ?? 0);

                      return SliderTheme(
                        data: const SliderThemeData(
                            trackHeight: Dimens.sizeExtraSmall,
                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: 5,
                            )),
                        child: Column(
                          children: [
                            SizedBox(
                              height: Dimens.sizeMedium,
                              child: Slider(
                                value: current,
                                divisions: length,
                                inactiveColor: scheme.primaryContainer,
                                max: length.toDouble(),
                                onChanged: bloc.onSliderChange,
                              ),
                            ),
                            DefaultTextStyle.merge(
                              style: TextStyle(
                                color: scheme.textColorLight,
                                fontSize: Dimens.fontDefault,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: Dimens.sizeMedium),
                                  Text(currLength.format()),
                                  const Spacer(),
                                  Text(maxLength.format()),
                                  const SizedBox(width: Dimens.sizeLarge),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    });
                  }),
                  const SizedBox(height: Dimens.sizeDefault),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimens.sizeMedSmall),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BlocBuilder<PlayerBloc, PlayerState>(
                            buildWhen: (pr, cr) => pr.shuffle != cr.shuffle,
                            builder: (context, state) {
                              return IconButton(
                                onPressed: bloc.onShuffle,
                                iconSize: Dimens.sizeLarge,
                                isSelected: state.shuffle,
                                style: IconButton.styleFrom(
                                    backgroundColor:
                                        state.shuffle ? scheme.primary : null),
                                selectedIcon: Image.asset(
                                  ImageRes.shuffle,
                                  width: Dimens.sizeMedium + 2,
                                  color: scheme.surface,
                                ),
                                icon: Image.asset(
                                  ImageRes.shuffle,
                                  height: Dimens.sizeMedium + 2,
                                  color: scheme.textColor,
                                ),
                              );
                            }),
                        IconButton(
                          onPressed: bloc.onPrevious,
                          color: scheme.textColor,
                          iconSize: Dimens.sizeMidLarge + 4,
                          icon: const Icon(Icons.skip_previous_rounded),
                        ),
                        BlocBuilder<PlayerBloc, PlayerState>(
                          buildWhen: (pr, cr) {
                            return pr.playerState != cr.playerState;
                          },
                          builder: (context, state) {
                            return LoadingIcon(
                              onPressed: bloc.onPlayPause,
                              iconSize: Dimens.sizeExtraLarge,
                              loaderSize: Dimens.sizeExtraLarge,
                              loading: state.playerState == MusicState.loading,
                              isSelected:
                                  state.playerState == MusicState.playing,
                              selectedIcon: const Icon(Icons.pause),
                              style: IconButton.styleFrom(
                                  backgroundColor: scheme.textColor,
                                  foregroundColor: scheme.surface,
                                  splashFactory: NoSplash.splashFactory),
                              icon: const Icon(Icons.play_arrow),
                            );
                          },
                        ),
                        IconButton(
                          onPressed: bloc.onNext,
                          iconSize: Dimens.sizeMidLarge + 4,
                          color: scheme.textColor,
                          icon: const Icon(Icons.skip_next_rounded),
                        ),
                        BlocBuilder<PlayerBloc, PlayerState>(
                            buildWhen: (pr, cr) => pr.loopMode != cr.loopMode,
                            builder: (context, state) {
                              return IconButton(
                                  onPressed: bloc.onRepeat,
                                  isSelected:
                                      state.loopMode != MusicLoopMode.off,
                                  style: IconButton.styleFrom(
                                      backgroundColor:
                                          state.loopMode != MusicLoopMode.off
                                              ? scheme.primary
                                              : null),
                                  iconSize: Dimens.sizeLarge,
                                  selectedIcon: Icon(
                                    state.loopMode.icon,
                                    color: state.loopMode.color,
                                  ),
                                  icon: Icon(
                                    state.loopMode.icon,
                                    color: scheme.textColor,
                                  ));
                            }),
                      ],
                    ),
                  )
                ],
              )),
        ),
      ]),
    );
  }
}
