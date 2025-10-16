import 'dart:math';
import 'package:ampify/presentation/root_view/player_screens/queue_view.dart';
import 'package:flutter/material.dart';
import 'package:ampify/buisness_logic/player_bloc/player_bloc.dart';
import 'package:ampify/buisness_logic/player_bloc/player_events.dart';
import '../../../buisness_logic/player_bloc/player_slider_bloc.dart';
import '../../../buisness_logic/player_bloc/player_state.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../track_widgets/track_bottom_sheet.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final bloc = context.read<PlayerBloc>();
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverSafeArea(sliver: SliverSizedBox(height: Dimens.sizeSmall)),
          SliverAppBar(
            forceMaterialTransparency: true,
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                iconSize: Dimens.iconDefault,
                icon: Transform.rotate(
                  angle: 3 * pi / 2,
                  child: const Icon(Icons.arrow_back_ios),
                )),
            actions: [
              IconButton(
                onPressed: () => _toTrackDetails(context),
                iconSize: Dimens.iconDefault,
                icon: const Icon(Icons.more_vert),
              ),
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
                    GestureDetector(
                      onHorizontalDragEnd: (details) {
                        if ((details.primaryVelocity ?? 0) < 0) {
                          bloc.add(PlayerNextTrack());
                        } else if ((details.primaryVelocity ?? 0) > 0) {
                          bloc.add(PlayerPreviousTrack());
                        }
                      },
                      child: BlocBuilder<PlayerBloc, PlayerState>(
                          buildWhen: (pre, cur) => pre.track != cur.track,
                          builder: (context, state) {
                            final _bg = context.isDarkMode
                                ? state.track.darkBgColor
                                : state.track.bgColor;
                            final fgColor = _bg?.withAlpha(150);
                            final bgColor = scheme.background;
                            return ShadowWidget(
                              offset: const Offset(0, -Dimens.sizeDefault),
                              darkShadow: context.isDarkMode,
                              margin: const EdgeInsets.all(Dimens.sizeMedium),
                              color:
                                  Color.alphaBlend(fgColor ?? bgColor, bgColor),
                              child: MyCachedImage(state.track.image,
                                  borderRadius: Dimens.sizeExtraSmall),
                            );
                          }),
                    ),
                    BlocListener<PlayerBloc, PlayerState>(
                      listener: (context, state) {
                        if (state.playerState.isHidden) Navigator.pop(context);
                      },
                      child: SizedBox(height: context.height * .05),
                    ),
                    Padding(
                      padding: Utils.insetsHoriz(Dimens.sizeMedium),
                      child: Row(
                        children: [
                          Expanded(
                            child: BlocBuilder<PlayerBloc, PlayerState>(
                                buildWhen: (pr, cr) => pr.track != cr.track,
                                builder: (context, state) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.track.title ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: Dimens.fontXXLarge,
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
                            buildWhen: (pr, cr) => pr.isLiked != cr.isLiked,
                            builder: (context, state) {
                              return IconButton(
                                onPressed: () {
                                  final id = state.track.id;
                                  bloc.onTrackLiked(id!, state.isLiked);
                                },
                                isSelected: state.isLiked,
                                selectedIcon: const Icon(Icons.favorite),
                                iconSize: Dimens.iconXLarge,
                                icon: const Icon(Icons.favorite_outline),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimens.sizeDefault),
                    BlocBuilder<PlayerBloc, PlayerState>(
                      buildWhen: (pr, cr) => pr.track != cr.track,
                      builder: (context, state) {
                        final loading = state.playerState.isLoading;
                        return BlocBuilder<PlayerSliderBloc, PlayerSliderState>(
                            builder: (context, slider) {
                          double current = 0;
                          Duration length = Durations.extralong4;
                          if (!loading && !state.track.duration.isZero) {
                            current = slider.current.inSeconds.toDouble();
                            length =
                                state.track.duration ?? Durations.extralong4;
                          }

                          return SliderTheme(
                            data: const SliderThemeData(
                                trackHeight: Dimens.sizeMini,
                                thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: 5,
                                )),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: Dimens.sizeMedium,
                                  child: Slider(
                                    value: current,
                                    divisions: length.inSeconds,
                                    activeColor: scheme.textColor,
                                    inactiveColor: scheme.textColorLight,
                                    min: Dimens.zero,
                                    max: length.inSeconds.toDouble(),
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
                                      Text(slider.current.format()),
                                      const Spacer(),
                                      Text(state.track.duration.format()),
                                      const SizedBox(width: Dimens.sizeLarge),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        });
                      },
                    ),
                    const SizedBox(height: Dimens.sizeDefault),
                    Padding(
                      padding: Utils.insetsHoriz(Dimens.sizeMedSmall),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DisabledWidget(
                            child: BlocBuilder<PlayerBloc, PlayerState>(
                                buildWhen: (pr, cr) => pr.shuffle != cr.shuffle,
                                builder: (context, state) {
                                  return IconButton(
                                    onPressed: bloc.onShuffle,
                                    iconSize: Dimens.iconDefault,
                                    isSelected: state.shuffle,
                                    style: IconButton.styleFrom(
                                        backgroundColor: state.shuffle
                                            ? scheme.primary
                                            : null),
                                    selectedIcon: Image.asset(ImageRes.shuffle,
                                        width: Dimens.iconMedium,
                                        color: scheme.onPrimary),
                                    icon: Image.asset(ImageRes.shuffle,
                                        height: Dimens.iconMedium,
                                        color: scheme.textColor),
                                  );
                                }),
                          ),
                          IconButton(
                            onPressed: () => bloc.add(PlayerPreviousTrack()),
                            color: scheme.textColor,
                            iconSize: Dimens.iconLarge,
                            icon: const Icon(Icons.skip_previous_rounded),
                          ),
                          BlocBuilder<PlayerBloc, PlayerState>(
                              buildWhen: (pr, cr) {
                            return pr.playerState != cr.playerState;
                          }, builder: (context, state) {
                            return LoadingIcon(
                              onPressed: bloc.onPlayPause,
                              iconSize: Dimens.iconExtraLarge,
                              loaderSize: Dimens.iconExtraLarge,
                              loading: state.playerState.isLoading,
                              isSelected: state.playerState.isPlaying,
                              selectedIcon: const Icon(Icons.pause),
                              style: IconButton.styleFrom(
                                  backgroundColor: scheme.textColor,
                                  foregroundColor: scheme.surface,
                                  splashFactory: NoSplash.splashFactory),
                              icon: const Icon(Icons.play_arrow),
                            );
                          }),
                          IconButton(
                            onPressed: () => bloc.add(PlayerNextTrack()),
                            iconSize: Dimens.iconLarge,
                            color: scheme.textColor,
                            icon: const Icon(Icons.skip_next_rounded),
                          ),
                          DisabledWidget(
                            child: BlocBuilder<PlayerBloc, PlayerState>(
                                buildWhen: (pr, cr) =>
                                    pr.loopMode != cr.loopMode,
                                builder: (context, state) {
                                  return IconButton(
                                      onPressed: bloc.onRepeat,
                                      isSelected: !state.loopMode.isOff,
                                      style: IconButton.styleFrom(
                                          backgroundColor: !state.loopMode.isOff
                                              ? scheme.primary
                                              : null),
                                      iconSize: Dimens.iconDefault,
                                      selectedIcon: Icon(state.loopMode.icon,
                                          color: scheme.onPrimary),
                                      icon: Icon(state.loopMode.icon,
                                          color: scheme.textColor));
                                }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimens.sizeDefault),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          style: IconButton.styleFrom(
                              foregroundColor: scheme.textColor),
                          onPressed: () => _toQueue(context),
                          label: Text(StringRes.queue,
                              style: TextStyle(fontSize: Dimens.fontDefault)),
                          icon: Icon(Icons.queue_music_rounded,
                              size: Dimens.iconDefault),
                        )
                      ],
                    )
                  ],
                )),
          ),
        ],
      ),
    );
  }

  void _toTrackDetails(BuildContext context) {
    final state = context.read<PlayerBloc>().state;
    showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        builder: (context) =>
            TrackBottomSheet(state.track.asTrack, liked: state.isLiked));
  }

  void _toQueue(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(
            top: Radius.circular(Dimens.borderLarge)),
      ),
      backgroundColor: context.scheme.background,
      builder: (_) => const QueueView(),
    );
  }
}
