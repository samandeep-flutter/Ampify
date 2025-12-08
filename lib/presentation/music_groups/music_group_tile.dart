import 'package:ampify/data/utils/exports.dart';

class MusicGroupTile extends StatelessWidget {
  final LibraryModel item;
  final double? imageHeight;
  const MusicGroupTile(this.item, {this.imageHeight, super.key});

  @override
  Widget build(BuildContext context) {
    final isLikedSongs = item.id == UniqueIds.likedSongs;
    final scheme = context.scheme;

    return InkWell(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        if (isLikedSongs) {
          context.pushNamed<bool>(AppRoutes.likedSongs);
        } else {
          context.pushNamed<bool>(AppRoutes.musicGroup,
              pathParameters: {'id': item.id!, 'type': item.type?.name ?? ''});
        }
      },
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
                child: MyCachedImage(item.image, borderRadius: Dimens.sizeMini),
              );
            }),
            const SizedBox(width: Dimens.sizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name ?? '',
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
                    type: item.type?.name.capitalize ?? '',
                    subtitle: item.owner?.name ?? '',
                  )
                ],
              ),
            ),
            const SizedBox(width: Dimens.sizeLarge),
          ],
        ),
      ),
    );
  }
}
