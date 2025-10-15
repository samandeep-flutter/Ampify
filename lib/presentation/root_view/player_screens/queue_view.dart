import 'package:ampify/buisness_logic/player_bloc/player_events.dart';
import 'package:flutter/material.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../buisness_logic/player_bloc/player_bloc.dart';
import '../../../buisness_logic/player_bloc/player_slider_bloc.dart';
import '../../../buisness_logic/player_bloc/player_state.dart';
import '../../track_widgets/track_tile.dart';

class QueueView extends StatelessWidget {
  const QueueView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayerBloc>();
    final scheme = context.scheme;

    return BaseWidget(
      color: scheme.background,
      resizeBottom: false,
      shapeRadius:
          BorderRadius.vertical(top: Radius.circular(Dimens.borderMedium)),
      bottom: const BottomPlayer(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlocListener<PlayerBloc, PlayerState>(
                listener: (context, state) {
                  if (state.playerState.isHidden) Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.only(top: Dimens.sizeMedSmall),
                  height: Dimens.sizeExtraSmall,
                  width: Dimens.sizeUltraLarge,
                  decoration: BoxDecoration(
                    color: scheme.textColorLight,
                    borderRadius: BorderRadius.circular(Dimens.sizeMini),
                  ),
                ),
              )
            ],
          ),
          ListTile(
            visualDensity: VisualDensity.compact,
            title: Text(StringRes.queue),
            titleTextStyle: TextStyle(
              fontSize: Dimens.fontXLarge,
              fontWeight: FontWeight.bold,
              color: scheme.textColor,
            ),
            subtitle: Text(StringRes.queueTitle),
            subtitleTextStyle: TextStyle(
              color: scheme.textColorLight,
              fontWeight: FontWeight.w500,
              fontSize: Dimens.fontDefault,
            ),
          ),
          BlocBuilder<PlayerBloc, PlayerState>(
            buildWhen: (pr, cr) => pr.track != cr.track,
            builder: (_, state) => TrackDetailsTile.playing(state.track),
          ),
          const SizedBox(height: Dimens.sizeMedSmall),
          Expanded(
            child: BlocBuilder<PlayerBloc, PlayerState>(
              buildWhen: (pr, cr) {
                final next = pr.upNext != cr.upNext;
                return pr.queue != cr.queue || next;
              },
              builder: (context, state) {
                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    if (state.queue.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Row(
                          children: [
                            const SizedBox(width: Dimens.sizeDefault),
                            Text(
                              StringRes.nextQueue,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: Dimens.fontXXXLarge),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: bloc.clearQueue,
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                foregroundColor: scheme.textColorLight,
                              ),
                              child: const Text(StringRes.clearQueue),
                            ),
                            const SizedBox(width: Dimens.sizeDefault),
                          ],
                        ),
                      ),
                    SliverReorderableList(
                      itemCount: state.queue.length,
                      itemBuilder: (context, index) {
                        final item = state.queue[index];
                        return TrackDetailsTile(
                          item,
                          key: ValueKey(item.id),
                          trailing: Icon(Icons.menu_outlined,
                              size: Dimens.iconMedSmall),
                        );
                      },
                      onReorder: bloc.onQueueReorder,
                    ),
                    const SliverSizedBox(height: Dimens.sizeSmall),
                    if (state.upNext.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Row(
                          children: [
                            const SizedBox(width: Dimens.sizeDefault),
                            Text(
                              StringRes.upNext,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: Dimens.fontXXXLarge),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: bloc.clearUpnext,
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                foregroundColor: scheme.textColorLight,
                              ),
                              child: const Text(StringRes.clear),
                            ),
                            const SizedBox(width: Dimens.sizeDefault),
                          ],
                        ),
                      ),
                    SliverList.builder(
                      itemCount: state.upNext.length,
                      itemBuilder: (_, i) => TrackTile.queue(state.upNext[i]),
                    ),
                    SliverSizedBox(height: context.height * .05)
                  ],
                );
              },
            ),
          ),
        ],
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
                          final factor =
                              slider.current.widthFactor(state.track.duration);
                          return AnimatedContainer(
                              duration: slider.animate,
                              width: factor * constraints.maxWidth,
                              color: scheme.primary);
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
                  onPressed: () => bloc.add(PlayerPreviousTrack()),
                  color: scheme.textColor,
                  iconSize: Dimens.iconXLarge,
                  icon: const Icon(Icons.skip_previous_rounded),
                ),
                const SizedBox(width: Dimens.sizeDefault),
                BlocBuilder<PlayerBloc, PlayerState>(buildWhen: (pr, cr) {
                  return pr.playerState != cr.playerState;
                }, builder: (context, state) {
                  return LoadingIcon(
                    onPressed: bloc.onPlayPause,
                    iconSize: Dimens.iconXLarge,
                    loaderSize: Dimens.iconXLarge,
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
                const SizedBox(width: Dimens.sizeDefault),
                IconButton(
                  onPressed: () => bloc.add(PlayerNextTrack()),
                  iconSize: Dimens.iconXLarge,
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
