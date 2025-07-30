import 'package:ampify/buisness_logic/player_bloc/player_bloc.dart';
import 'package:ampify/buisness_logic/player_bloc/player_state.dart';
import 'package:ampify/data/data_models/library_model.dart';
import 'package:ampify/presentation/track_widgets/track_tile.dart';
import 'package:ampify/data/utils/exports.dart';
import '../../buisness_logic/root_bloc/music_group_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'playlist_bottom_sheet.dart';

class MusicGroupScreen extends StatefulWidget {
  final String id;
  final LibItemType type;
  const MusicGroupScreen({super.key, required this.id, required this.type});

  @override
  State<MusicGroupScreen> createState() => _MusicGroupScreenState();
}

class _MusicGroupScreenState extends State<MusicGroupScreen> {
  @override
  void initState() {
    final bloc = context.read<MusicGroupBloc>();
    bloc.add(MusicGroupInitial(id: widget.id, type: widget.type));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MusicGroupBloc>();
    final scheme = context.scheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: scheme.background,
      body: BlocBuilder<MusicGroupBloc, MusicGroupState>(
        buildWhen: (pr, cr) => pr.loading != cr.loading,
        builder: (context, state) {
          final fgColor = state.bgColor?.withAlpha(30) ?? scheme.backgroundDark;
          final date = state.details?.releaseDate;

          if (state.loading) return const MusicGroupShimmer();

          return CustomScrollView(
            controller: bloc.scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: context.height * .35,
                pinned: true,
                centerTitle: false,
                title: BlocBuilder<MusicGroupBloc, MusicGroupState>(
                  buildWhen: (pr, cr) => pr.titileOpacity != cr.titileOpacity,
                  builder: (context, state) {
                    return AnimatedOpacity(
                      opacity: state.titileOpacity,
                      duration: const Duration(milliseconds: 500),
                      child: Text(state.title ?? ''),
                    );
                  },
                ),
                leading: IconButton(
                  onPressed: () => context.pop(bloc.libRefresh),
                  icon: const Icon(Icons.arrow_back_outlined),
                ),
                backgroundColor: Color.alphaBlend(fgColor, scheme.background),
                titleTextStyle: Utils.defTitleStyle(context),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: Utils.insetsHoriz(Dimens.sizeDefault),
                  background: Align(
                    alignment: Alignment.bottomCenter,
                    child: BlocBuilder<MusicGroupBloc, MusicGroupState>(
                      buildWhen: (pr, cr) => pr.image != cr.image,
                      builder: (context, state) {
                        return MyCachedImage(
                          state.image,
                          loading: state.image?.isEmpty ?? true,
                          height: context.height * .3,
                          width: context.height * .3,
                          borderRadius: Dimens.sizeExtraSmall,
                        );
                      },
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(Dimens.sizeDefault),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.alphaBlend(fgColor, scheme.background),
                        scheme.background,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.title ?? '',
                        style: Utils.defTitleStyle(context),
                      ),
                      if (state.details?.description?.isNotEmpty ?? false)
                        Text(
                          state.details!.description!.unescape,
                          style: TextStyle(
                            color: scheme.textColorLight,
                            fontSize: Dimens.fontDefault,
                          ),
                        ),
                      const SizedBox(height: Dimens.sizeSmall),
                      Wrap(
                        runSpacing: Dimens.sizeSmall,
                        spacing: Dimens.sizeSmall,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: state.type.isPlaylist
                                ? const EdgeInsets.symmetric(
                                    vertical: Dimens.sizeExtraSmall,
                                    horizontal: Dimens.sizeDefault,
                                  )
                                : EdgeInsets.zero,
                            decoration: state.type.isPlaylist
                                ? BoxDecoration(
                                    border: Border.all(
                                      color: state.bgColor ?? scheme.disabled,
                                      width: Dimens.sizeMini,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        Dimens.sizeDefault),
                                  )
                                : null,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.type?.name.capitalize ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: Dimens.fontDefault,
                                    color: scheme.textColor,
                                  ),
                                ),
                                PaginationDots(
                                  current: true,
                                  margin: Dimens.sizeSmall,
                                  color: scheme.textColor,
                                ),
                                Flexible(
                                  child: RichText(
                                    textScaler:
                                        MediaQuery.textScalerOf(context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: Dimens.fontDefault,
                                        color: scheme.textColor,
                                      ),
                                      children: [
                                        if (state.type.isPlaylist)
                                          const TextSpan(text: 'by '),
                                        TextSpan(
                                            text: state.details?.owner?.name),
                                      ],
                                    ),
                                  ),
                                ),
                                if (!state.type.isPlaylist) ...[
                                  PaginationDots(
                                    current: true,
                                    margin: Dimens.sizeSmall,
                                    color: scheme.textColorLight,
                                  ),
                                  Text(
                                    '${date?.year ?? ''}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: scheme.textColorLight,
                                      fontSize: Dimens.fontDefault,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (state.type.isPlaylist)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.track_changes,
                                  color: scheme.textColorLight,
                                  size: Dimens.iconMedSmall,
                                ),
                                const SizedBox(width: Dimens.sizeExtraSmall),
                                Text(
                                  '${state.tracks.length} tracks',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: scheme.textColorLight,
                                    fontSize: Dimens.fontDefault,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: Dimens.sizeDefault),
                      Row(
                        children: [
                          BlocBuilder<MusicGroupBloc, MusicGroupState>(
                            buildWhen: (pr, cr) => pr.isFav != cr.isFav,
                            builder: (context, state) {
                              return SizedBox(
                                height: Dimens.iconDefault,
                                child: IconButton(
                                  tooltip: StringRes.addtoLiked,
                                  style: IconButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    shape: CircleBorder(
                                      side: BorderSide(
                                        width: Dimens.sizeMini,
                                        color: state.isFav ?? false
                                            ? scheme.primary
                                            : scheme.textColorLight,
                                      ),
                                    ),
                                    backgroundColor: state.isFav ?? false
                                        ? scheme.primary
                                        : null,
                                  ),
                                  iconSize: Dimens.iconSmall,
                                  onPressed: () => bloc.onFav(
                                    state.id!,
                                    type: state.type!,
                                    liked: state.isFav ?? false,
                                  ),
                                  isSelected: state.isFav ?? false,
                                  selectedIcon: Icon(Icons.check,
                                      color: scheme.onPrimary),
                                  icon: Icon(Icons.add,
                                      color: scheme.textColorLight),
                                ),
                              );
                            },
                          ),
                          if (bloc.uid! == state.details?.owner?.id) ...[
                            const SizedBox(width: Dimens.sizeSmall),
                            IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  showDragHandle: true,
                                  useRootNavigator: true,
                                  builder: (context) {
                                    return BlocProvider.value(
                                      value: bloc,
                                      child: PlaylistBottomSheet(
                                        id: state.id,
                                        image: state.image,
                                        title: state.title,
                                        details: state.details,
                                      ),
                                    );
                                  },
                                );
                              },
                              style: IconButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                              iconSize: Dimens.iconDefault,
                              icon: const Icon(Icons.more_vert),
                            ),
                          ] else ...[
                            const SizedBox(width: Dimens.sizeSmall),
                            IconButton(
                              onPressed: null,
                              color: scheme.textColorLight,
                              style: IconButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                              iconSize: Dimens.iconDefault,
                              icon: const Icon(Icons.ios_share),
                            ),
                          ],
                          const Spacer(),
                          BlocBuilder<PlayerBloc, PlayerState>(
                            builder: (context, pl) {
                              final group = pl.musicGroupId == state.id;
                              return LoadingIcon(
                                onPressed: () => bloc.onPlay(context),
                                iconSize: Dimens.iconXLarge,
                                loaderSize: Dimens.iconXLarge,
                                isSelected: group && pl.playerState.isPlaying,
                                selectedIcon: const Icon(Icons.pause),
                                style: IconButton.styleFrom(
                                  backgroundColor: scheme.textColor,
                                  foregroundColor: scheme.surface,
                                  splashFactory: NoSplash.splashFactory,
                                ),
                                icon: const Icon(Icons.play_arrow),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (state.tracks.isEmpty)
                SliverToBoxAdapter(
                  child: ToolTipWidget(
                    margin: EdgeInsets.only(top: context.height * .05),
                    title: StringRes.emptyPlaylists,
                  ),
                ),
              SliverList.builder(
                itemCount: state.tracks.length,
                itemBuilder: (context, index) {
                  final track = state.tracks[index];
                  return TrackTile(track, showImage: state.type.isPlaylist);
                },
              ),
              const SliverSizedBox(height: Dimens.sizeLarge),
              if (state.details?.releaseDate != null)
                SliverToBoxAdapter(
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                        color: scheme.textColorLight,
                        fontSize: Dimens.fontXXXLarge),
                    child: Row(
                      children: [
                        const SizedBox(width: Dimens.sizeDefault),
                        Icon(
                          Icons.track_changes,
                          color: scheme.textColorLight,
                          size: Dimens.iconMedSmall,
                        ),
                        const SizedBox(width: Dimens.sizeSmall),
                        Text('${state.tracks.length} Tracks'),
                        PaginationDots(
                          current: true,
                          margin: Dimens.sizeSmall,
                          color: scheme.textColorLight,
                        ),
                        Text(state.details?.releaseDate?.formatDate ?? ''),
                      ],
                    ),
                  ),
                ),
              const SliverSizedBox(height: Dimens.sizeSmall),
              if (!state.type.isPlaylist)
                SliverToBoxAdapter(
                  child: Builder(
                    builder: (context) {
                      final rights = state.details?.copyrights;
                      final symbols =
                          rights?.map((e) => e.type!).toList().asString;
                      return Padding(
                        padding:
                            const EdgeInsets.only(left: Dimens.sizeDefault),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: scheme.textColorLight,
                              fontSize: Dimens.fontDefault + 1,
                            ),
                            children: [
                              if (symbols?.contains(RegExp(r'C')) ?? false) ...[
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Image.asset(ImageRes.copyrightC,
                                      color: scheme.textColorLight,
                                      height: Dimens.fontMed),
                                ),
                                const WidgetSpan(child: SizedBox(width: 8)),
                              ],
                              if (symbols?.contains(RegExp(r'P')) ?? false)
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Image.asset(ImageRes.copyrightP,
                                      color: scheme.textColorLight,
                                      height: Dimens.fontMed),
                                ),
                              const WidgetSpan(child: SizedBox(width: 8)),
                              TextSpan(
                                text: rights?.first.text?.removeCoprights,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              SliverSizedBox(height: context.height * .18),
            ],
          );
        },
      ),
    );
  }
}
