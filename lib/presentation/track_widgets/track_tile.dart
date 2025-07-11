import 'package:ampify/buisness_logic/player_bloc/player_bloc.dart';
import 'package:ampify/buisness_logic/player_bloc/player_slider_bloc.dart';
import 'package:ampify/data/data_models/common/tracks_model.dart';
import 'package:ampify/data/utils/dimens.dart';
import 'package:ampify/data/utils/utils.dart';
import 'package:ampify/presentation/track_widgets/track_bottom_sheet.dart';
import 'package:ampify/presentation/widgets/my_cached_image.dart';
import 'package:ampify/presentation/widgets/top_widgets.dart';
import 'package:ampify/services/extension_services.dart';
import '../../buisness_logic/player_bloc/player_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../buisness_logic/player_bloc/player_state.dart';

class TrackTile extends StatelessWidget {
  final Track track;
  final bool? liked;
  final bool? showImage;
  const TrackTile(this.track, {this.liked, this.showImage, super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayerBloc>();
    final sliderBloc = context.read<PlayerSliderBloc>();
    final scheme = context.scheme;

    final widget = InkWell(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        bloc.add(PlayerTrackChanged(track, liked: liked));
        sliderBloc.add(const PlayerSliderChange(0));
      },
      child: Padding(
        padding: Utils.insetsOnly(Dimens.sizeSmall, left: Dimens.sizeDefault),
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
                  Text(
                    track.name ?? '',
                    style: TextStyle(
                      color: scheme.textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: Dimens.fontXXXLarge,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SubtitleWidget(
                    style: TextStyle(
                        color: scheme.textColorLight,
                        fontSize: Dimens.fontDefault),
                    type: track.type?.capitalize ?? '',
                    subtitle: track.artists?.asString ?? '',
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  useRootNavigator: true,
                  builder: (_) => TrackBottomSheet(track, liked: liked),
                );
              },
              iconSize: Dimens.iconDefault,
              icon: const Icon(Icons.more_vert_outlined),
            ),
          ],
        ),
      ),
    );

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
      child: widget,
    );
  }
}

class TrackDetailsTile extends StatelessWidget {
  final TrackDetails track;
  final Widget? title;
  final Widget? trailing;
  const TrackDetailsTile(
      {super.key, required this.track, this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Padding(
      padding: Utils.insetsOnly(Dimens.sizeSmall, left: Dimens.sizeDefault),
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
                Text(
                  track.title ?? '',
                  style: TextStyle(
                    color: scheme.textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: Dimens.fontXXXLarge,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
