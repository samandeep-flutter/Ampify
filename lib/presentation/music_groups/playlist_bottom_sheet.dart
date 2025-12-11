import 'package:ampify/data/utils/exports.dart';
import 'package:image_picker/image_picker.dart';
import '../../buisness_logic/music_group_bloc/music_group_bloc.dart';

class PlaylistBottomSheet extends StatefulWidget {
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
  State<PlaylistBottomSheet> createState() => _PlaylistBottomSheetState();
}

class _PlaylistBottomSheetState extends State<PlaylistBottomSheet> {
  String? get uid => BoxServices.instance.uid;
  bool get isOwner => widget.details?.owner?.id == uid;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return MyBottomSheet.dragable(
      constraints: HeightConstraints(
        maxHeight: isOwner ? 0.9 : 0.5,
        minHeight: isOwner ? 0.5 : 0.3,
        defaultHeight: isOwner ? 0.5 : 0.4,
      ),
      customTitle: Row(
        children: [
          const SizedBox(width: Dimens.sizeDefault),
          Builder(builder: (context) {
            final _dimen = Dimens.iconTileMedium;
            final _scalar = MediaQuery.textScalerOf(context);
            final double height = _scalar.scale(_dimen);
            final width = _scalar.scale(_dimen + Dimens.sizeMedSmall);

            return MyCachedImage(widget.image,
                borderRadius: Dimens.sizeMini, height: height, width: width);
          }),
          const SizedBox(width: Dimens.sizeDefault),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: scheme.textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: Dimens.fontXXXLarge),
                ),
                const SizedBox(height: Dimens.sizeExtraSmall),
                DefaultTextStyle.merge(
                  style: TextStyle(
                      color: scheme.textColorLight,
                      fontSize: Dimens.fontDefault),
                  child: Row(
                    children: [
                      Flexible(
                          child: Text(widget.details?.owner?.name ?? '',
                              maxLines: 1, overflow: TextOverflow.ellipsis)),
                      PaginationDots(
                        current: true,
                        color: scheme.textColorLight,
                        margin: Dimens.sizeSmall,
                      ),
                      Text(widget.details?.public ?? false
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
      titleBottomSpacing: Dimens.sizeExtraSmall,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: Dimens.sizeSmall),
          BottomSheetListTile(
            enable: false,
            onTap: () {
              // TODO: implement append tracks to upNext.
            },
            title: StringRes.appendTracks,
            icon: Icons.library_music_outlined,
          ),
          if (widget.details?.owner?.id == uid)
            BottomSheetListTile(
              enable: false,
              onTap: () {
                // TODO: implement add tracks to playlist.
              },
              title: StringRes.addTracks,
              icon: Icons.music_note_outlined,
            ),
          if (widget.details?.owner?.id == uid)
            BottomSheetListTile(
              onTap: () => _pickCoverImage(context),
              title: StringRes.editCover,
              icon: Icons.photo_outlined,
            ),
          if (widget.details?.owner?.id == uid)
            BottomSheetListTile(
              onTap: () => _toEditDetails(context),
              title: StringRes.editDetails,
              icon: Icons.title,
            ),
          if (widget.details?.owner?.id == uid) ...[
            if (widget.details?.public ?? false)
              BottomSheetListTile(
                onTap: () => _toggleVisibility(context, false),
                title: 'Make Private',
                icon: Icons.lock_outline,
              )
            else
              BottomSheetListTile(
                onTap: () => _toggleVisibility(context, true),
                title: 'Make Public',
                icon: Icons.public,
              ),
          ],
          BottomSheetListTile(
            enable: false,
            onTap: () {
              // TODO: implement share playlist.
            },
            title: StringRes.share,
            icon: Icons.ios_share,
          ),
        ],
      ),
    );
  }

  void _toggleVisibility(BuildContext context, bool visibility) {
    final bloc = context.read<MusicGroupBloc>();
    Navigator.pop(context);
    bloc.add(PlaylistVisibility(visibility));
  }

  void _toEditDetails(BuildContext context) {
    Navigator.pop(context);
    final pathParams = {'id': widget.id!};
    final params = {
      'image': widget.image,
      'title': widget.title,
      'desc': widget.details?.description
    };
    context.pushNamed(AppRoutes.modifyPlaylist,
        pathParameters: pathParams, queryParameters: params);
  }

  void _pickCoverImage(BuildContext context) {
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
                      style: TextStyle(fontSize: Dimens.fontXXXLarge)),
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
                      style: TextStyle(fontSize: Dimens.fontXXXLarge)),
                ),
              ],
            ),
          );
        });
  }
}
