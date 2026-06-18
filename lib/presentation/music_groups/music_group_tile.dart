import 'package:ampify/data/utils/exports.dart';

class MusicGroupTile extends StatelessWidget {
  final LibraryModel item;
  final double? imageHeight;
  const MusicGroupTile(this.item, {this.imageHeight, super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return InkWell(
      onTap: () => _onTap(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: Dimens.sizeDefault, vertical: Dimens.sizeSmall - 2),
        child: Row(
          children: [
            Builder(builder: (context) {
              final _dimen = Dimens.iconTileLarge;
              final _scalar = MediaQuery.textScalerOf(context);
              final double dimen = imageHeight ?? _scalar.scale(_dimen);
              if (isLikedSongs) return LikedSongsCover(size: dimen);

              return SizedBox.square(
                dimension: dimen,
                child: MyCachedImage(item.thumbnail?.url,
                    border: Dimens.sizeMini, isAvatar: item.type.isArtist),
              );
            }),
            const SizedBox(width: Dimens.sizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: Dimens.fontXXXLarge,
                    ),
                  ),
                  const SizedBox(height: Dimens.sizeExtraSmall),
                  SubtitleWidget(
                    style: TextStyle(
                        color: scheme.textColorLight,
                        fontSize: Dimens.fontDefault),
                    type: item.type.name.capitalize,
                    subtitle: item.artist?.name,
                  )
                ],
              ),
            ),
            const SizedBox(width: Dimens.sizeXLarge),
          ],
        ),
      ),
    );
  }

  bool get isLikedSongs => item.id == UniqueIds.likedSongs;

  void _onTap(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    switch (item.type) {
      // case LibItemType.artist:

      case LibItemType.video:
      case LibItemType.track:
        final player = context.read<PlayerBloc>();
        final slider = context.read<PlayerSliderBloc>();
        player.add(PlayerTrackChanged(Track.fromJson(item.toJson())));
        slider.add(PlayerSliderReset());
        break;

      case LibItemType.playlist:
      case LibItemType.album:
        context.pushNamed(
            isLikedSongs ? AppRoutes.likedSongs : AppRoutes.musicGroup,
            pathParameters: {'id': item.id, 'type': item.type.id});
        break;
      default:
        break;
    }
  }
}
