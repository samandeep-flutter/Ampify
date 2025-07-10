// ignore_for_file: use_build_context_synchronously

import 'package:ampify/buisness_logic/library_bloc/library_bloc.dart';
import 'package:ampify/config/routes/app_routes.dart';
import 'package:ampify/data/data_models/library_model.dart';
import 'package:ampify/data/utils/app_constants.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/utils/dimens.dart';
import '../widgets/my_cached_image.dart';
import '../widgets/top_widgets.dart';

class MusicGroupTile extends StatelessWidget {
  final LibraryModel item;
  final double? imageHeight;
  const MusicGroupTile(this.item, {this.imageHeight, super.key});

  @override
  Widget build(BuildContext context) {
    final isLikedSongs = item.id == UniqueIds.likedSongs;
    final scheme = context.scheme;

    return InkWell(
      onTap: () async {
        FocusManager.instance.primaryFocus?.unfocus();
        await Future.delayed(const Duration(milliseconds: 200));
        if (isLikedSongs) {
          final result = await context.pushNamed<bool>(AppRoutes.likedSongs);
          if (result ?? false) {
            context.read<LibraryBloc>().add(LibraryRefresh());
          }
          return;
        }
        final result = await context.pushNamed<bool>(
          AppRoutes.musicGroup,
          pathParameters: {'id': item.id!, 'type': item.type!.name},
        );

        if (result ?? false) {
          context.read<LibraryBloc>().add(LibraryRefresh());
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: Dimens.sizeDefault, vertical: Dimens.sizeSmall),
        child: Row(
          children: [
            Builder(builder: (context) {
              final _scalar = MediaQuery.textScalerOf(context);
              final double dimen = imageHeight ?? _scalar.scale(55);

              if (isLikedSongs) {
                return LikedSongsCover(size: dimen);
              }
              return MyCachedImage(item.image,
                  borderRadius: Dimens.sizeMini, height: dimen, width: dimen);
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
                        fontSize: Dimens.fontLarge),
                  ),
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
