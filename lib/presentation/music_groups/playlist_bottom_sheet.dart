import 'package:ampify/buisness_logic/root_bloc/edit_playlist_bloc.dart';
import 'package:ampify/config/routes/app_routes.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/presentation/widgets/my_alert_dialog.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:image_picker/image_picker.dart';
import '../../buisness_logic/root_bloc/music_group_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/utils/dimens.dart';
import '../widgets/my_cached_image.dart';
import '../widgets/top_widgets.dart';

class PlaylistBottomSheet extends StatelessWidget {
  final String? id;
  final String? image;
  final String? title;
  final MusicGroupDetails? details;
  const PlaylistBottomSheet({
    super.key,
    required this.id,
    required this.image,
    required this.title,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final bloc = context.read<MusicGroupBloc>();
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
                        fontWeight: FontWeight.w600,
                        fontSize: Dimens.fontLarge),
                  ),
                  const SizedBox(height: Dimens.sizeExtraSmall),
                  DefaultTextStyle.merge(
                    style: TextStyle(
                      color: scheme.textColorLight,
                      fontSize: Dimens.fontLarge - 1,
                    ),
                    child: Row(
                      children: [
                        Flexible(
                            child: Text(details?.owner?.name ?? '',
                                maxLines: 1, overflow: TextOverflow.ellipsis)),
                        PaginationDots(
                          current: true,
                          color: scheme.textColorLight,
                          margin: Dimens.sizeSmall,
                        ),
                        Text(details?.public ?? false
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
          enable: false,
          onTap: () {},
          title: StringRes.addTracks,
          leading: const Icon(
            Icons.music_note_outlined,
            size: Dimens.sizeMidLarge,
          ),
        ),
        BottomSheetListTile(
          onTap: () => onPicker(context),
          title: StringRes.editCover,
          leading: const Icon(
            Icons.photo_outlined,
            size: Dimens.sizeMidLarge,
          ),
        ),
        BottomSheetListTile(
          onTap: () {
            Navigator.pop(context);
            final plbloc = context.read<EditPlaylistBloc>();
            plbloc.add(EditPlaylistInitial(
                id: id,
                image: image,
                title: title,
                desc: details?.description));
            context.pushNamed(AppRoutes.modifyPlaylist);
          },
          title: StringRes.editDetails,
          leading: const Icon(
            Icons.title,
            size: Dimens.sizeMidLarge,
          ),
        ),
        if (details?.public ?? false)
          BottomSheetListTile(
            onTap: () {
              Navigator.pop(context);
              bloc.add(const PlaylistVisibility(false));
            },
            title: 'Make Private',
            leading: const Icon(
              Icons.lock_outline,
              size: Dimens.sizeMidLarge,
            ),
          )
        else
          BottomSheetListTile(
            onTap: () {
              Navigator.pop(context);
              bloc.add(const PlaylistVisibility(true));
            },
            title: 'Make Public',
            leading: const Icon(
              Icons.public,
              size: Dimens.sizeMidLarge,
            ),
          ),
        BottomSheetListTile(
          enable: false,
          onTap: () {},
          title: StringRes.share,
          leading: const Icon(
            Icons.ios_share,
            size: Dimens.sizeMidLarge,
          ),
        ),
        SizedBox(height: context.height * .07)
      ],
    );
  }

  void onPicker(BuildContext context) {
    Navigator.pop(context);
    final bloc = context.read<MusicGroupBloc>();
    showDialog(
        context: context,
        builder: (context) {
          return MyAlertDialog(
            title: 'Choose Image',
            actionPadding: EdgeInsets.zero,
            actions: const [],
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    bloc.pickImage(ImageSource.gallery);
                  },
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text(StringRes.gallery),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    bloc.pickImage(ImageSource.camera);
                  },
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text(StringRes.camera),
                ),
              ],
            ),
          );
        });
  }
}
