import 'package:ampify/buisness_logic/player_bloc/player_bloc.dart';
import 'package:ampify/buisness_logic/player_bloc/player_slider_bloc.dart';
import 'package:ampify/data/data_models/common/tracks_model.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:ampify/presentation/track_widgets/track_bottom_sheet.dart';
import '../../buisness_logic/player_bloc/player_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../buisness_logic/player_bloc/player_state.dart';

class TrackTile extends StatelessWidget {
  final Track track;
  final bool? liked;
  final bool? showImage;
  final Widget? trailing;
  final bool _isQueue;
  final bool _isSearch;
  const TrackTile(this.track, {this.liked, this.showImage, super.key})
      : trailing = null,
        _isQueue = false,
        _isSearch = false;
  const TrackTile.queue(this.track,
      {this.liked, this.showImage, this.trailing, super.key})
      : _isQueue = true,
        _isSearch = false;
  const TrackTile.search(this.track, {this.liked, this.showImage, super.key})
      : trailing = null,
        _isQueue = false,
        _isSearch = true;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayerBloc>();
    final scheme = context.scheme;

    if (_isQueue) return _builder(context);
    return Dismissible(
      key: ValueKey(track.id ?? ''),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async => false,
      onUpdate: (details) {
        if (details.previousReached || details.previousReached) return;
        if (details.progress < .3) return;
        bloc.add(PlayerQueueAdded(track));
      },
      dismissThresholds: const {DismissDirection.startToEnd: .3},
      background: Container(
        alignment: Alignment.centerLeft,
        color: scheme.primaryAdaptive,
        padding: const EdgeInsets.only(left: Dimens.sizeLarge),
        child: Icon(Icons.add_to_queue,
            color: scheme.onPrimary, size: Dimens.iconDefault),
      ),
      child: _builder(context),
    );
  }

  Widget _builder(BuildContext context) {
    final sliderBloc = context.read<PlayerSliderBloc>();
    final bloc = context.read<PlayerBloc>();
    final scheme = context.scheme;

    return InkWell(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        bloc.add(PlayerTrackChanged(track, liked: liked));
        sliderBloc.add(PlayerSliderReset());
      },
      child: Padding(
        padding: Utils.insetsOnly(Dimens.sizeSmall,
            left: Dimens.sizeDefault, right: Dimens.zero),
        child: Row(
          children: [
            if (showImage ?? true) ...[
              Builder(
                builder: (context) {
                  final dimen = Dimens.iconUltraLarge;
                  return SizedBox.square(
                      dimension: dimen,
                      child: MyCachedImage(track.album?.image,
                          borderRadius: Dimens.sizeMini));
                },
              ),
              const SizedBox(width: Dimens.sizeDefault),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<PlayerBloc, PlayerState>(
                    buildWhen: (pr, cr) {
                      final playing = pr.playerState != cr.playerState;
                      final _track = pr.track.id != cr.track.id;
                      final isRelevant =
                          cr.track.id == track.id || pr.track.id == track.id;

                      return (playing || _track) && isRelevant;
                    },
                    builder: (context, state) {
                      final isActive = state.track.id == track.id;

                      return Row(
                        children: [
                          AnimatedContainer(
                            duration: Durations.short4,
                            width: isActive ? Dimens.iconMedSmall : 0,
                            child: Image.asset(
                                state.playerState.isPaused
                                    ? ImageRes.musicWavePaused
                                    : ImageRes.musicWave,
                                fit: BoxFit.cover,
                                color: scheme.primary),
                          ),
                          const SizedBox(width: Dimens.sizeExtraSmall),
                          Expanded(
                            child: TweenAnimationBuilder(
                                tween: ColorTween(
                                    end: isActive
                                        ? scheme.primary
                                        : scheme.textColor),
                                duration: Durations.medium1,
                                builder: (context, color, _) {
                                  return Text(
                                    track.name ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w500,
                                      fontSize: Dimens.fontXXXLarge,
                                    ),
                                  );
                                }),
                          )
                        ],
                      );
                      // return RichText(
                      //   maxLines: 1,
                      //   overflow: TextOverflow.ellipsis,
                      //   text: TextSpan(
                      //     children: [
                      //       WidgetSpan(
                      //           child: AnimatedContainer(
                      //         duration: Durations.short4,
                      //         width: isActive ? Dimens.iconMedSmall : 0,
                      //         child: Image.asset(
                      //             state.playerState.isPlaying
                      //                 ? ImageRes.musicWave
                      //                 : ImageRes.musicWavePaused,
                      //             fit: BoxFit.cover,
                      //             color: scheme.primary),
                      //       )),
                      //       const WidgetSpan(
                      //           child: SizedBox(width: Dimens.sizeExtraSmall)),
                      //       WidgetSpan(
                      //           child: TweenAnimationBuilder(
                      //               tween: ColorTween(
                      //                   end: isActive
                      //                       ? scheme.primary
                      //                       : scheme.textColor),
                      //               duration: Durations.medium1,
                      //               builder: (context, color, _) {
                      //                 return Text(
                      //                   track.name ?? '',
                      //                   maxLines: 1,
                      //                   style: TextStyle(
                      //                     color: color,
                      //                     fontWeight: FontWeight.w500,
                      //                     fontSize: Dimens.fontXXXLarge,
                      //                   ),
                      //                 );
                      //               })),
                      //     ],
                      //   ),
                      // );
                    },
                  ),
                  const SizedBox(height: Dimens.sizeMini),
                  SubtitleWidget(
                    style: TextStyle(
                      color: scheme.textColorLight,
                      fontSize: Dimens.fontDefault - 1,
                    ),
                    type: _isSearch ? track.type?.capitalize ?? '' : null,
                    subtitle: track.artists?.asString ?? '',
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  useRootNavigator: true,
                  builder: (_) => TrackBottomSheet(track, liked: liked),
                );
              },
              iconSize: Dimens.iconDefault,
              icon: trailing ?? Icon(Icons.more_vert_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class TrackDetailsTile extends StatelessWidget {
  final TrackDetails track;
  final Widget? title;
  final Widget? trailing;
  final bool isPlaying;
  const TrackDetailsTile(this.track, {super.key, this.title, this.trailing})
      : isPlaying = false;
  const TrackDetailsTile.playing(this.track, {super.key, this.trailing})
      : title = null,
        isPlaying = true;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: Dimens.sizeSmall, horizontal: Dimens.sizeDefault),
      child: Row(
        children: [
          Builder(
            builder: (context) {
              final dimen = Dimens.iconUltraLarge;
              return SizedBox.square(
                  dimension: dimen,
                  child: MyCachedImage(track.image,
                      borderRadius: Dimens.sizeMini));
            },
          ),
          const SizedBox(width: Dimens.sizeDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(builder: (context) {
                  if (!isPlaying) {
                    if (title != null) return title!;
                    return Text(
                      track.title ?? '',
                      style: TextStyle(
                        color: scheme.textColor,
                        fontWeight: FontWeight.w500,
                        fontSize: Dimens.fontXXXLarge,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  }
                  return RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textScaler: MediaQuery.textScalerOf(context),
                      text: TextSpan(
                          style: TextStyle(
                              color: scheme.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: Dimens.fontXXXLarge),
                          children: [
                            WidgetSpan(
                                child: SizedBox.square(
                              dimension: Dimens.iconMedSmall,
                              child: BlocBuilder<PlayerBloc, PlayerState>(
                                  buildWhen: (pr, cr) {
                                return pr.playerState != cr.playerState;
                              }, builder: (_, state) {
                                return Image.asset(
                                    state.playerState.isPaused
                                        ? ImageRes.musicWavePaused
                                        : ImageRes.musicWave,
                                    fit: BoxFit.cover,
                                    color: scheme.primary);
                              }),
                            )),
                            const WidgetSpan(
                                child: SizedBox(width: Dimens.sizeExtraSmall)),
                            TextSpan(text: track.title ?? ''),
                          ]));
                }),
                Text(
                  track.subtitle ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.textColorLight,
                    fontSize: Dimens.fontDefault,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
