import 'package:ampify/buisness_logic/library_bloc/library_bloc.dart';
import 'package:ampify/config/routes/app_routes.dart';
import 'package:ampify/data/data_models/library_model.dart';
import 'package:ampify/data/utils/image_resources.dart';
import 'package:ampify/data/utils/utils.dart';
import 'package:ampify/presentation/music_groups/music_group_tile.dart';
import 'package:ampify/presentation/widgets/my_alert_dialog.dart';
import 'package:ampify/presentation/widgets/top_widgets.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
        backgroundColor: scheme.background,
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
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: state.profile?.product == 'premium'
                        ? const BoxDecoration(
                            gradient: SweepGradient(colors: ColorRes.primaries),
                            borderRadius: BorderRadius.all(
                              Radius.circular(Dimens.borderLarge),
                            ))
                        : null,
                    child: MyAvatar(
                      padding: const EdgeInsets.all(2),
                      bgColor: scheme.background,
                      state.profile?.image,
                      isAvatar: true,
                      avatarRadius: Dimens.sizeMedium,
                    ),
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
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(Dimens.sizeExtraLarge),
            child: BlocBuilder<LibraryBloc, LibraryState>(
              buildWhen: (pr, cr) => pr.filterSel != cr.filterSel,
              builder: (context, state) {
                final items = [LibItemType.playlist, LibItemType.album];
                return Row(
                  children: [
                    const SizedBox(width: Dimens.sizeDefault),
                    ...items.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(right: Dimens.sizeSmall),
                        child: TextButton(
                          onPressed: () => bloc.add(LibraryFiltered(e)),
                          style: defTextButtonStyle(e == state.filterSel),
                          child: Text(e.name.capitalize),
                        ),
                      );
                    }),
                  ],
                );
              },
            )),
        actions: [
          BlocBuilder<LibraryBloc, LibraryState>(
            builder: (context, state) {
              return TextButton.icon(
                onPressed: () {
                  context.pushNamed(AppRoutes.createPlaylist,
                      pathParameters: {'userId': state.profile!.id!});
                },
                label: const Text(StringRes.create),
                iconAlignment: IconAlignment.end,
                icon: const Icon(
                  Icons.library_add_outlined,
                  size: Dimens.sizeLarge,
                ),
              );
            },
          ),
          const SizedBox(width: Dimens.sizeSmall)
        ],
      ),
      padding: EdgeInsets.zero,
      child: ListView(
        controller: bloc.scrollController,
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
              final sort = pr.sortby != cr.sortby;
              final loading = pr.loading != cr.loading;
              final filtered = pr.filterSel != cr.filterSel;
              final items = pr.items != cr.items;
              final moreLoading = pr.moreLoading != cr.moreLoading;

              return loading || items || sort || filtered || moreLoading;
            },
            builder: (context, state) {
              if (state.loading) {
                return ListView.builder(
                  itemCount: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, __) => const SongTileShimmer(iconSize: 55),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return MusicGroupTile(item);
                },
              );
            },
          ),
          BlocBuilder<LibraryBloc, LibraryState>(
            buildWhen: (pr, cr) => pr.moreLoading != cr.moreLoading,
            builder: (context, state) {
              if (state.moreLoading) {
                return Column(
                    children: List.generate(3, (_) {
                  return const SongTileShimmer(iconSize: 55);
                }));
              }
              return SizedBox(height: context.height * .1);
            },
          ),
        ],
      ),
    );
  }

  ButtonStyle defTextButtonStyle(bool sel) {
    final scheme = context.scheme;
    final defBGcolor = scheme.primaryContainer.withOpacity(.5);

    return TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: Utils.paddingHoriz(Dimens.sizeDefault),
        backgroundColor: sel ? scheme.primary : defBGcolor,
        foregroundColor: sel ? scheme.onPrimary : scheme.onPrimaryContainer);
  }

  void sortBy(BuildContext context) {
    final scheme = context.scheme;
    final bloc = context.read<LibraryBloc>();
    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        useRootNavigator: true,
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
