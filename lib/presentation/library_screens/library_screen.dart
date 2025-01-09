import 'package:ampify/buisness_logic/library_bloc/library_bloc.dart';
import 'package:ampify/data/utils/image_resources.dart';
import 'package:ampify/data/utils/utils.dart';
import 'package:ampify/presentation/library_screens/playlist_tile.dart';
import 'package:ampify/presentation/widgets/my_alert_dialog.dart';
import 'package:ampify/presentation/widgets/top_widgets.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/utils/color_resources.dart';
import '../../data/utils/dimens.dart';
import '../../data/utils/string.dart';
import '../widgets/base_widget.dart';
import '../widgets/shimmer_widget.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LibraryBloc>();
    final scheme = context.scheme;

    return BaseWidget(
      appBar: AppBar(
        title: Row(
          children: [
            BlocBuilder<LibraryBloc, LibraryState>(
              buildWhen: (pr, cr) => pr.profile != cr.profile,
              builder: (context, state) {
                return PopupMenuButton(
                  position: PopupMenuPosition.under,
                  splashRadius: 0,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                        onTap: () => bloc.logout(context),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: Dimens.sizeSmall),
                            Icon(Icons.logout, color: ColorRes.error),
                            SizedBox(width: Dimens.sizeDefault),
                            Text(StringRes.logout),
                          ],
                        )),
                  ],
                  child: MyAvatar(
                    state.profile?.image?.url,
                    isAvatar: true,
                    avatarRadius: Dimens.sizeDefault,
                  ),
                );
              },
            ),
            const SizedBox(width: Dimens.sizeSmall),
            const Text(StringRes.myLibrary),
          ],
        ),
        titleTextStyle: Utils.defTitleStyle,
        centerTitle: false,
        // actions: [
        //   TextButton.icon(
        //     onPressed: bloc.createPlaylist,
        //     label: const Text(StringRes.create),
        //     iconAlignment: IconAlignment.end,
        //     icon: const Icon(
        //       Icons.library_add_outlined,
        //       size: Dimens.sizeLarge,
        //     ),
        //   ),
        //   const SizedBox(width: Dimens.sizeSmall)
        // ],
      ),
      padding: EdgeInsets.zero,
      child: RefreshIndicator(
        onRefresh: () async => bloc.add(LibraryRefresh()),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: Dimens.sizeSmall),
                BlocBuilder<LibraryBloc, LibraryState>(
                    buildWhen: (pr, cr) => pr.sortby != cr.sortby,
                    builder: (context, state) {
                      return TextButton.icon(
                        onPressed: () => sortBy(context),
                        style: IconButton.styleFrom(
                            foregroundColor: scheme.textColor),
                        label: Text(
                          state.sortby?.name.capitalize ?? StringRes.sortBy,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        icon: Image.asset(ImageRes.sort, height: 16),
                      );
                    }),
              ],
            ),
            BlocBuilder<LibraryBloc, LibraryState>(
              buildWhen: (pr, cr) {
                final loading = pr.loading != cr.loading;
                final sort = pr.sortby != cr.sortby;

                return loading || sort;
              },
              builder: (context, state) {
                if (state.loading) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: 10,
                      padding: const EdgeInsets.only(top: Dimens.sizeDefault),
                      itemBuilder: (_, __) =>
                          const SongTileShimmer(iconSize: 55),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: state.playlists.length,
                    itemBuilder: (context, index) {
                      final item = state.playlists[index];
                      return PlaylistTile(playlist: item);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void sortBy(BuildContext context) {
    final scheme = context.scheme;
    final bloc = context.read<LibraryBloc>();
    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (context) {
          return MyBottomSheet(
            title: StringRes.sortOrder,
            vsync: this,
            child: Column(
              children: SortOrder.values.map((e) {
                return ListTile(
                  onTap: () async {
                    bloc.add(LibrarySorted(e));
                    await Future.delayed(const Duration(milliseconds: 200));
                    // ignore: use_build_context_synchronously
                    if (mounted) Navigator.pop(context);
                  },
                  title: Text(e.name.capitalize),
                  titleTextStyle: TextStyle(
                    color: scheme.textColor,
                    fontSize: Dimens.fontLarge,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          );
        });
  }
}
