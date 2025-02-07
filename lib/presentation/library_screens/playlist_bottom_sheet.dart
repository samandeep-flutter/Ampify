import 'package:ampify/data/data_models/common/other_models.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';
import '../../data/utils/dimens.dart';
import '../widgets/my_cached_image.dart';
import '../widgets/top_widgets.dart';

class PlaylistBottomSheet extends StatelessWidget {
  final String? image;
  final String? title;
  final OwnerModel? owner;
  final bool? public;
  const PlaylistBottomSheet({
    super.key,
    required this.image,
    required this.title,
    required this.owner,
    required this.public,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const SizedBox(width: Dimens.sizeDefault),
            MyCachedImage(
              image,
              borderRadius: 2,
              height: 50,
              width: 60,
            ),
            const SizedBox(width: Dimens.sizeDefault),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: scheme.textColor,
                        fontWeight: FontWeight.w500,
                        fontSize: Dimens.fontLarge),
                  ),
                  const SizedBox(height: Dimens.sizeExtraSmall),
                  DefaultTextStyle.merge(
                    style: TextStyle(
                      color: scheme.textColorLight,
                      fontSize: Dimens.fontDefault,
                    ),
                    child: Row(
                      children: [
                        Flexible(
                            child: Text(owner?.name ?? '',
                                maxLines: 1, overflow: TextOverflow.ellipsis)),
                        PaginationDots(
                          current: true,
                          color: scheme.textColorLight,
                          margin: Dimens.sizeSmall,
                        ),
                        Text(public ?? false
                            ? StringRes.pubPlaylist
                            : StringRes.priPlaylist),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: Dimens.sizeDefault),
          ],
        ),
        const SizedBox(height: Dimens.sizeSmall),
        const MyDivider(),
        BottomSheetListTile(
          onTap: () {},
          title: StringRes.editCover,
          leading: const Icon(Icons.photo_outlined),
        ),
        BottomSheetListTile(
          onTap: () {},
          title: StringRes.editDetails,
          leading: const Icon(Icons.title),
        ),
        SizedBox(height: context.height * .07)
      ],
    );
  }
}
