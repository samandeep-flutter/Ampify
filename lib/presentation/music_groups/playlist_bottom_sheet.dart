import 'package:ampify/data/utils/exports.dart';
import '../../buisness_logic/music_group_bloc/music_group_bloc.dart';

class PlaylistBottomSheet extends StatefulWidget {
  final String? id;
  final Thumbnail? image;
  final String? title;
  final String? owner;
  final String? description;
  const PlaylistBottomSheet({
    super.key,
    required this.id,
    required this.image,
    required this.title,
    required this.owner,
    required this.description,
  });

  @override
  State<PlaylistBottomSheet> createState() => _PlaylistBottomSheetState();
}

class _PlaylistBottomSheetState extends State<PlaylistBottomSheet> {
  String? get uid => BoxServices.instance.uid;
  bool get isOwner => widget.owner == uid;

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

            return MyCachedImage(widget.image?.url,
                border: Dimens.sizeMini, height: height, width: width);
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
                      // TODO: implement owner name
                      Flexible(
                          child: Text('widget.details?.owner?.name',
                              maxLines: 1, overflow: TextOverflow.ellipsis)),
                      PaginationDots(
                        current: true,
                        color: scheme.textColorLight,
                        margin: Dimens.sizeSmall,
                      ),
                      Text(isOwner
                          ? StringRes.priPlaylist
                          : StringRes.pubPlaylist),
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
              // TODO: implement append tracks to queue.
            },
            title: StringRes.appendTracks,
            icon: Icons.library_music_outlined,
          ),
          if (isOwner) ...[
            BottomSheetListTile(
              enable: false,
              onTap: () {
                // TODO: implement add tracks to playlist.
              },
              title: StringRes.addTracks,
              icon: Icons.music_note_outlined,
            ),
            BottomSheetListTile(
              onTap: () => _pickCoverImage(context),
              title: StringRes.editCover,
              icon: Icons.photo_outlined,
            ),
            BottomSheetListTile(
              onTap: () => _toEditDetails(context),
              title: StringRes.editDetails,
              icon: Icons.title,
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

  void _toEditDetails(BuildContext context) {
    Navigator.pop(context);
    final pathParams = {'id': widget.id!};
    final params = {
      'image': widget.image,
      'title': widget.title,
      'desc': widget.description
    };
    context.pushNamed(AppRoutes.modifyPlaylist,
        pathParameters: pathParams, queryParameters: params);
  }

  void _pickCoverImage(BuildContext context) {
    Navigator.pop(context);
    context.read<MusicGroupBloc>().pickImage();
    // showDialog(
    //     context: context,
    //     builder: (context) {
    //       return MyAlertDialog(
    //         titleText: 'Choose Image',
    //         actionPadding: EdgeInsets.zero,
    //         content: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             ListTile(
    //               onTap: () {
    //                 Navigator.pop(context);
    //                 bloc.pickImage(ImageSource.gallery);
    //               },
    //               contentPadding: Utils.insetsHoriz(Dimens.sizeSmall),
    //               leading: Icon(Icons.photo_library_outlined,
    //                   size: Dimens.iconDefault),
    //               title: Text(StringRes.gallery,
    //                   style: TextStyle(fontSize: Dimens.fontXXXLarge)),
    //             ),
    //             ListTile(
    //               onTap: () {
    //                 Navigator.pop(context);
    //                 bloc.pickImage(ImageSource.camera);
    //               },
    //               contentPadding: Utils.insetsHoriz(Dimens.sizeSmall),
    //               leading: Icon(Icons.photo_camera_outlined,
    //                   size: Dimens.iconDefault),
    //               title: Text(StringRes.camera,
    //                   style: TextStyle(fontSize: Dimens.fontXXXLarge)),
    //             ),
    //           ],
    //         ),
    //       );
    // });
  }
}
