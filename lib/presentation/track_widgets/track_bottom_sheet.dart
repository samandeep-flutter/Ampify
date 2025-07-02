import 'package:ampify/buisness_logic/library_bloc/liked_songs_bloc.dart';
import 'package:ampify/config/routes/app_routes.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/presentation/track_widgets/addto_playlist.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../buisness_logic/player_bloc/player_bloc.dart';
import '../../buisness_logic/player_bloc/player_events.dart';
import '../../buisness_logic/root_bloc/addto_playlist_bloc.dart';
import '../../data/data_models/common/tracks_model.dart';
import '../../data/utils/dimens.dart';
import '../widgets/my_cached_image.dart';
import '../widgets/top_widgets.dart';

class TrackBottomSheet extends StatelessWidget {
  final Track track;
  final bool? liked;
  const TrackBottomSheet(this.track, {this.liked, super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayerBloc>();
    final likedSongsBloc = context.read<LikedSongsBloc>();
    final scheme = context.scheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const SizedBox(width: Dimens.sizeDefault),
            Builder(builder: (context) {
              final double _height = 50;
              final _scalar = MediaQuery.textScalerOf(context);
              final height = _scalar.scale(_height);
              final width = _scalar.scale(_height + Dimens.sizeMedSmall);
              return MyCachedImage(track.album?.image,
                  borderRadius: Dimens.sizeMini, height: height, width: width);
            }),
            const SizedBox(width: Dimens.sizeDefault),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: scheme.textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: Dimens.fontLarge),
                  ),
                  const SizedBox(height: Dimens.sizeExtraSmall),
                  Text(track.artists?.asString ?? '',
                      style: TextStyle(
                        color: scheme.textColorLight,
                        fontSize: Dimens.fontLarge - 1,
                      ))
                ],
              ),
            ),
            const SizedBox(width: Dimens.sizeDefault),
          ],
        ),
        const SizedBox(height: Dimens.sizeSmall),
        const MyDivider(),
        BottomSheetListTile(
          onTap: () {
            bloc.onTrackLiked(track.id!, liked);
            if (liked ?? false) {
              likedSongsBloc.songRemoved(track.id!);
            }
            Navigator.pop(context);
          },
          leading: LikedSongsCover(
              size: Dimens.iconLarge, iconSize: Dimens.iconSmall),
          title: liked ?? false ? StringRes.removeLiked : StringRes.addtoLiked,
        ),
        BottomSheetListTile(
            onTap: () {
              Navigator.pop(context);
              final bloc = context.read<AddtoPlaylistBloc>();
              bloc.add(PlaylistInitial(track.uri!));
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                isScrollControlled: true,
                useSafeArea: true,
                useRootNavigator: true,
                builder: (_) => const AddtoPlaylistSheet(),
              );
            },
            title: StringRes.addtoPlaylist,
            leading: Icon(Icons.add_circle_outline, size: Dimens.iconLarge)),
        BottomSheetListTile(
          onTap: () {
            bloc.add(PlayerQueueAdded(track));
            Navigator.pop(context);
          },
          title: StringRes.addtoQueue,
          leading: Icon(Icons.queue_music_outlined, size: Dimens.iconLarge),
        ),
        BottomSheetListTile(
            onTap: () {
              Navigator.pop(context);
              context.pushNamed(
                AppRoutes.musicGroup,
                pathParameters: {'id': track.album!.id!, 'type': track.type!},
              );
            },
            enable: track.album?.id != null,
            title: StringRes.gotoAlbum,
            leading: Icon(Icons.album_outlined, size: Dimens.iconLarge)),
        BottomSheetListTile(
          onTap: () {
            bloc.onTrackShare(track.id!);
            Navigator.pop(context);
          },
          enable: false,
          title: StringRes.share,
          leading: Icon(Icons.share_sharp, size: Dimens.iconMedium),
        ),
        SizedBox(height: context.height * .05)
      ],
    );
  }
}
