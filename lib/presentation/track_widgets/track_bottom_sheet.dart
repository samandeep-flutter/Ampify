import 'dart:convert';

import 'package:ampify/buisness_logic/library_bloc/liked_songs_bloc.dart';
import 'package:ampify/presentation/track_widgets/addto_playlist.dart';
import 'package:ampify/data/utils/exports.dart';
import '../../buisness_logic/player_bloc/player_bloc.dart';
import '../../buisness_logic/player_bloc/player_events.dart';
import '../../buisness_logic/music_group_bloc/addto_playlist_bloc.dart';

class TrackBottomSheet extends StatelessWidget {
  final Track track;
  final bool? liked;
  final bool? fromPlayer;
  const TrackBottomSheet(this.track, {super.key, this.liked, this.fromPlayer});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayerBloc>();
    final scheme = context.scheme;

    return MyBottomSheet.dragable(
      customTitle: Row(
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
                      fontSize: Dimens.fontXXXLarge),
                ),
                const SizedBox(height: Dimens.sizeExtraSmall),
                Text(track.artists?.asString ?? '',
                    style: TextStyle(
                      color: scheme.textColorLight,
                      fontSize: Dimens.fontXXXLarge - 1,
                    ))
              ],
            ),
          ),
          const SizedBox(width: Dimens.sizeDefault),
        ],
      ),
      titleBottomSpacing: Dimens.sizeSmall,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: Dimens.sizeSmall),
          BottomSheetListTile(
            onTap: () => _onTrackLiked(context),
            leading: LikedSongsCover(
                size: Dimens.iconXLarge, iconSize: Dimens.iconSmall),
            title:
                liked ?? false ? StringRes.removeLiked : StringRes.addtoLiked,
          ),
          BottomSheetListTile(
              onTap: () => _addToPlaylist(context),
              title: StringRes.addtoPlaylist,
              icon: Icons.add_circle_outline),
          BottomSheetListTile(
            onTap: () {
              bloc.add(PlayerQueueAdded(track));
              Navigator.pop(context);
            },
            title: StringRes.addtoQueue,
            icon: Icons.queue_music_outlined,
          ),
          BottomSheetListTile(
              onTap: () => _toAlbum(context),
              enable: track.album?.id != null,
              title: StringRes.gotoAlbum,
              icon: Icons.album_outlined),
          BottomSheetListTile(
              onTap: () => _toRadio(context),
              title: StringRes.gotoRadio,
              icon: Icons.radio_outlined),
          BottomSheetListTile(
            onTap: () {
              bloc.onTrackShare(track.id!);
              Navigator.pop(context);
            },
            enable: false,
            title: StringRes.share,
            icon: Icons.share_sharp,
          ),
        ],
      ),
    );
  }

  void _toAlbum(BuildContext context) {
    context.close(fromPlayer ?? false ? 2 : 1);
    final type = LibItemType.album.name;
    context.pushNamed(AppRoutes.musicGroup,
        pathParameters: {'id': track.album!.id!, 'type': type});
  }

  void _toRadio(BuildContext context) {
    context.close(fromPlayer ?? false ? 2 : 1);
    context.pushNamed(AppRoutes.songRadio,
        pathParameters: {'id': track.id!}, extra: jsonEncode(track.toJson()));
  }

  void _onTrackLiked(BuildContext context) {
    final _player = context.read<PlayerBloc>();
    _player.onTrackLiked(track.id!, liked);
    if (liked ?? false) {
      try {
        final bloc = context.read<LikedSongsBloc>();
        bloc.songRemoved(track.id!);
      } catch (_) {}
    }
    Navigator.pop(context);
  }

  void _addToPlaylist(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) {
        return BlocProvider(
            create: (_) => AddtoPlaylistBloc(),
            child: AddtoPlaylistSheet(track.uri!));
      },
    );
  }
}
