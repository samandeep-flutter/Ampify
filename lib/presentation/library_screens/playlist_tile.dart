import 'package:ampify/config/routes/app_routes.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/data_models/common/playlist_model.dart';
import '../../data/utils/dimens.dart';
import '../widgets/my_cached_image.dart';
import '../widgets/top_widgets.dart';

class PlaylistTile extends StatelessWidget {
  final Playlist playlist;
  const PlaylistTile({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return ListTile(
      onTap: () => context.goNamed(AppRoutes.playlistView, extra: playlist.id),
      leading: MyCachedImage(
        playlist.image?.url,
        fit: BoxFit.cover,
        borderRadius: 2,
        height: 55,
        width: 55,
      ),
      title: Text(
        playlist.name ?? '',
        style: TextStyle(
            color: scheme.textColor,
            fontWeight: FontWeight.w500,
            fontSize: Dimens.fontLarge),
      ),
      subtitle: SubtitleWidget(
        style: TextStyle(color: scheme.textColorLight),
        type: playlist.type?.capitalize ?? '',
        subtitle: playlist.owner?.displayName ?? '',
      ),
    );
  }
}
