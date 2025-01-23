import 'package:ampify/config/routes/app_routes.dart';
import 'package:ampify/data/data_models/library_model.dart';
import 'package:ampify/data/utils/app_constants.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/utils/dimens.dart';
import '../widgets/my_cached_image.dart';
import '../widgets/top_widgets.dart';

class CollectionTile extends StatelessWidget {
  final LibraryModel playlist;
  const CollectionTile(this.playlist, {super.key});

  @override
  Widget build(BuildContext context) {
    final isLikedSongs = playlist.id == UniqueIds.likedSongs;
    final scheme = context.scheme;
    return ListTile(
      onTap: () {
        if (isLikedSongs) return context.goNamed(AppRoutes.likedSongs);
        context.goNamed(
          AppRoutes.collectionView,
          pathParameters: {'id': playlist.id!, 'type': playlist.type!.name},
        );
      },
      leading: Builder(builder: (context) {
        const double dimen = 55;

        if (isLikedSongs) {
          return Container(
            height: dimen,
            width: dimen,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(Icons.favorite, color: scheme.background),
          );
        }
        return MyCachedImage(
          playlist.image?.url,
          fit: BoxFit.cover,
          borderRadius: 2,
          height: dimen,
          width: dimen,
        );
      }),
      title: Text(
        playlist.name ?? '',
        style: TextStyle(
            color: scheme.textColor,
            fontWeight: FontWeight.w500,
            fontSize: Dimens.fontLarge),
      ),
      subtitle: SubtitleWidget(
        style: TextStyle(color: scheme.textColorLight),
        type: playlist.type?.name.capitalize ?? '',
        subtitle: playlist.owner ?? '',
      ),
    );
  }
}
