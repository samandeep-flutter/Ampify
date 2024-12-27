import 'package:ampify/buisness_logic/player_bloc/player_bloc.dart';
import 'package:ampify/buisness_logic/player_bloc/player_slider_bloc.dart';
import 'package:ampify/data/data_models/tracks_model.dart';
import 'package:ampify/data/utils/dimens.dart';
import 'package:ampify/presentation/widgets/my_cached_image.dart';
import 'package:ampify/presentation/widgets/top_widgets.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../buisness_logic/player_bloc/player_events.dart';

class TrackTile extends StatelessWidget {
  final Track track;
  const TrackTile({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayerBloc>();
    final sliderBloc = context.read<PlayerSliderBloc>();
    final scheme = context.scheme;

    return InkWell(
      onTap: () {
        bloc.add(PlayerTrackChanged(track));
        sliderBloc.add(const PlayerSliderChange(0));
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Dimens.sizeDefault,
          Dimens.sizeSmall,
          Dimens.sizeLarge,
          Dimens.sizeSmall,
        ),
        child: Row(
          children: [
            MyCachedImage(
              track.album?.images?.first.url,
              borderRadius: 2,
              height: 40,
              width: 40,
            ),
            const SizedBox(width: Dimens.sizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.name ?? '',
                    style: TextStyle(
                        color: scheme.textColor,
                        fontWeight: FontWeight.w500,
                        fontSize: Dimens.fontLarge),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  DefaultTextStyle.merge(
                    style: TextStyle(color: scheme.textColorLight),
                    child: Row(
                      children: [
                        Text(
                          track.type?.capitalize ?? '',
                        ),
                        PaginationDots(
                          current: true,
                          margin: Dimens.sizeSmall,
                          color: scheme.textColorLight,
                        ),
                        Expanded(
                          child: Text(
                            track.artists?.asString ?? '',
                            style: TextStyle(color: scheme.textColorLight),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
