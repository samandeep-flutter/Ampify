import 'package:ampify/buisness_logic/library_bloc/library_bloc.dart';
import 'package:ampify/buisness_logic/root_bloc/root_bloc.dart';
import 'package:ampify/data/data_models/library_model.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:ampify/presentation/music_groups/music_group_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        leadingWidth: (Dimens.iconMedSmall * 2) + Dimens.sizeDefault,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: Dimens.sizeSmall),
            BlocBuilder<RootBloc, RootState>(
                buildWhen: (pr, cr) => pr.profile != cr.profile,
                builder: (context, state) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: state.profile?.product == 'premium'
                          ? SweepGradient(
                              colors: [
                                Color(0xFF6A2E8B),
                                Color(0xFF5271FF),
                                Color(0xFF00C2FF),
                                Color(0xFF2D3A68),
                                Color(0xFF7EC8FF),
                                Color(0xFFFFB84D),
                                Color(0xFF833AB4),
                              ],
                            )
                          : null,
                      borderRadius:
                          BorderRadius.all(Radius.circular(Dimens.borderLarge)),
                    ),
                    child: MyAvatar(
                      state.profile?.image,
                      isAvatar: true,
                      padding: EdgeInsets.all(Dimens.sizeExtraSmall),
                      onTap: () => context.pushNamed(AppRoutes.profile),
                      avatarRadius: Dimens.iconMedSmall,
                    ),
                  );
                }),
          ],
        ),
        title: const Text(StringRes.myLibrary),
        titleTextStyle: Utils.defTitleStyle(context),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(Dimens.sizeExtraLarge),
          child: BlocBuilder<LibraryBloc, LibraryState>(
            buildWhen: (pr, cr) => pr.filterSel != cr.filterSel,
            builder: (context, state) {
              return Row(
                children: [
                  const SizedBox(width: Dimens.sizeDefault),
                  ...[LibItemType.playlist, LibItemType.album].map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(right: Dimens.sizeSmall),
                      child: TextButton(
                        onPressed: () => bloc.add(LibraryFiltered(e)),
                        style: defTextButtonStyle(e == state.filterSel),
                        child: Text(
                          e.name.capitalize,
                          style: TextStyle(fontSize: Dimens.fontDefault),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: scheme.textColor),
            onPressed: () {
              context.pushNamed(AppRoutes.createPlaylist,
                  pathParameters: {'userId': bloc.box.uid!});
            },
            label: Text(
              StringRes.create,
              style: TextStyle(fontSize: Dimens.fontDefault),
            ),
            iconAlignment: IconAlignment.end,
            icon: Icon(Icons.library_add_outlined, size: Dimens.iconDefault),
          ),
          const SizedBox(width: Dimens.sizeSmall),
        ],
      ),
      padding: EdgeInsets.zero,
      child: ListView(
        controller: bloc.scrollController,
        children: [
          const SizedBox(height: Dimens.sizeSmall),
          Row(
            children: [
              const SizedBox(width: Dimens.sizeSmall),
              BlocBuilder<LibraryBloc, LibraryState>(
                buildWhen: (pr, cr) => pr.sortby != cr.sortby,
                builder: (context, state) {
                  return TextButton.icon(
                    onPressed: sortBy,
                    style: IconButton.styleFrom(
                      foregroundColor: scheme.textColor,
                    ),
                    label: Text(
                      state.sortby?.name.capitalize ?? StringRes.sortBy,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Dimens.fontDefault),
                    ),
                    icon: Image.asset(ImageRes.sort,
                        height: Dimens.iconSmall, color: scheme.textColor),
                  );
                },
              ),
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
                  }),
                );
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
    final defBGcolor = scheme.backgroundDark;

    return TextButton.styleFrom(
      visualDensity: VisualDensity.compact,
      padding: Utils.insetsHoriz(Dimens.sizeDefault),
      backgroundColor: sel ? scheme.primary : defBGcolor,
      foregroundColor: sel ? scheme.onPrimary : scheme.textColor,
    );
  }

  void sortBy() {
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
                  fontSize: Dimens.fontXXXLarge,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
