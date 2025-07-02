import 'package:ampify/buisness_logic/root_bloc/edit_playlist_bloc.dart';
import 'package:ampify/config/routes/app_routes.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/data/utils/utils.dart';
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
            Builder(builder: (context) {
              final double _height = 50;
              final _scalar = MediaQuery.textScalerOf(context);
              final height = _scalar.scale(_height);
              final width = _scalar.scale(_height + Dimens.sizeMedSmall);

              return MyCachedImage(image,
                  borderRadius: Dimens.sizeMini, height: height, width: width);
            }),
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
                        fontSize: Dimens.fontDefault),
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
          leading: Icon(Icons.music_note_outlined, size: Dimens.iconLarge),
        ),
        BottomSheetListTile(
          onTap: () => onPicker(context),
          title: StringRes.editCover,
          leading: Icon(Icons.photo_outlined, size: Dimens.iconLarge),
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
          leading: Icon(Icons.title, size: Dimens.iconLarge),
        ),
        if (details?.public ?? false)
          BottomSheetListTile(
            onTap: () {
              Navigator.pop(context);
              bloc.add(const PlaylistVisibility(false));
            },
            title: 'Make Private',
            leading: Icon(Icons.lock_outline, size: Dimens.iconLarge),
          )
        else
          BottomSheetListTile(
            onTap: () {
              Navigator.pop(context);
              bloc.add(const PlaylistVisibility(true));
            },
            title: 'Make Public',
            leading: Icon(Icons.public, size: Dimens.iconLarge),
          ),
        BottomSheetListTile(
          enable: false,
          onTap: () {},
          title: StringRes.share,
          leading: Icon(Icons.ios_share, size: Dimens.iconLarge),
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    bloc.pickImage(ImageSource.gallery);
                  },
                  contentPadding: Utils.insetsHoriz(Dimens.sizeSmall),
                  leading: Icon(Icons.photo_library_outlined,
                      size: Dimens.iconDefault),
                  title: Text(StringRes.gallery,
                      style: TextStyle(fontSize: Dimens.fontLarge)),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    bloc.pickImage(ImageSource.camera);
                  },
                  contentPadding: Utils.insetsHoriz(Dimens.sizeSmall),
                  leading: Icon(Icons.photo_camera_outlined,
                      size: Dimens.iconDefault),
                  title: Text(StringRes.camera,
                      style: TextStyle(fontSize: Dimens.fontLarge)),
                ),
              ],
            ),
          );
        });
  }
}
