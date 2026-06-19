import 'package:ampify/buisness_logic/library_bloc/library_bloc.dart';
import '../../buisness_logic/music_group_bloc/music_group_bloc.dart';
import 'package:ampify/data/utils/exports.dart';
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

          if (state.loading) return const MusicGroupShimmer();

          return CustomScrollView(
            controller: bloc.scrollController,
            physics: const BottomBounceScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: context.height * .35,
                pinned: true,
                centerTitle: false,
                title: PopScope(
                  onPopInvokedWithResult: (didPop, _) {
                    if (!bloc.libRefresh) return;
                    context.read<LibraryBloc>().add(LibraryRefresh());
                  },
                  child: BlocBuilder<MusicGroupBloc, MusicGroupState>(
                    buildWhen: (pr, cr) => pr.titileOpacity != cr.titileOpacity,
                    builder: (context, state) {
                      return AnimatedOpacity(
                        opacity: state.titileOpacity,
                        duration: Durations.long2,
                        child: Text(state.item?.title ?? ''),
                      );
                    },
                  ),
                ),
                backgroundColor: Color.alphaBlend(fgColor, scheme.background),
                titleTextStyle: Utils.defTitleStyle(scheme.textColor),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: Utils.insetsHoriz(Dimens.sizeDefault),
                  background: Align(
                    alignment: Alignment.bottomCenter,
                    child: BlocBuilder<MusicGroupBloc, MusicGroupState>(
                      buildWhen: (pr, cr) => pr.item != cr.item,
                      builder: (context, state) {
                        return MyCachedImage(
                          state.item?.thumbnail?.url,
                          loading: state.cover?.isEmpty ?? true,
                          height: context.height * .3,
                          width: context.height * .3,
                          border: Dimens.sizeExtraSmall,
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
                      const SizedBox(height: Dimens.sizeSmall),
                      Text(state.item?.title ?? '',
                          style: Utils.titleStyleLarge(context)),
                      if (state.description?.isNotEmpty ?? false) ...[
                        const SizedBox(height: Dimens.sizeExtraSmall),
                        Text(
                          state.description!.unescape,
                          style: TextStyle(
                            color: scheme.textColorLight,
                            fontSize: Dimens.fontDefault - 1,
                          ),
                        ),
                      ],
                      const SizedBox(height: Dimens.sizeDefault),
                      Wrap(
                        runSpacing: Dimens.sizeSmall,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: state.type.isAlbum
                                ? const EdgeInsets.symmetric(
                                    vertical: Dimens.sizeExtraSmall,
                                    horizontal: Dimens.sizeDefault,
                                  )
                                : EdgeInsets.zero,
                            decoration: state.type.isAlbum
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
                                  margin: Dimens.sizeMedSmall,
                                  color: scheme.textColor,
                                ),
                                if (state.subtitle?.isNotEmpty ?? false)
                                  Text(
                                    state.subtitle ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: Dimens.fontDefault,
                                      color: scheme.textColorLight,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (state.type.isAlbum)
                            const SizedBox(width: Dimens.sizeDefault),
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
                                  onPressed: () {
                                    bloc.add(MusicGroupFav(state.id!,
                                        type: state.type!,
                                        liked: state.isFav ?? false));
                                  },
                                  isSelected: state.isFav ?? false,
                                  selectedIcon: Icon(Icons.check,
                                      color: scheme.onPrimary),
                                  icon: Icon(Icons.add,
                                      color: scheme.textColorLight),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: Dimens.sizeSmall),
                          ElevatedButton.icon(
                              onPressed: () => _appendTracks(state),
                              style: ElevatedButton.styleFrom(
                                padding: Utils.insetsHoriz(Dimens.sizeDefault),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: scheme.textColor,
                                foregroundColor: scheme.background,
                              ),
                              iconAlignment: IconAlignment.end,
                              label: Text(StringRes.append),
                              icon: Icon(Icons.library_music_outlined)),
                          const SizedBox(width: Dimens.sizeSmall),
                          IconButton(
                            onPressed: () => _toMoreDetails(bloc, state),
                            style: IconButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                            iconSize: Dimens.iconDefault,
                            icon: const Icon(Icons.more_vert),
                          ),
                          const Spacer(),
                          DisabledWidget(
                            child: BlocBuilder<PlayerBloc, PlayerState>(
                                buildWhen: (pr, cr) => pr.shuffle != cr.shuffle,
                                builder: (context, state) {
                                  return IconButton(
                                    onPressed: _shuffleToggle,
                                    iconSize: Dimens.iconDefault,
                                    isSelected: state.shuffle,
                                    style: IconButton.styleFrom(
                                        backgroundColor: state.shuffle
                                            ? scheme.primary
                                            : null),
                                    selectedIcon: Image.asset(ImageRes.shuffle,
                                        width: Dimens.iconMedium,
                                        color: scheme.onPrimary),
                                    icon: Image.asset(ImageRes.shuffle,
                                        height: Dimens.iconMedium,
                                        color: scheme.textColor),
                                  );
                                }),
                          ),
                          const SizedBox(width: Dimens.sizeDefault),
                          BlocBuilder<PlayerBloc, PlayerState>(
                              buildWhen: (pr, cr) {
                            return pr.playerState != cr.playerState;
                          }, builder: (context, pl) {
                            final group = pl.musicGroupId == state.id;
                            return IconButton(
                              onPressed: () => bloc.onPlay(context),
                              iconSize: Dimens.iconXLarge,
                              isSelected: group && pl.playerState.isPlaying,
                              selectedIcon: const Icon(Icons.pause),
                              style: IconButton.styleFrom(
                                backgroundColor: scheme.textColor,
                                foregroundColor: scheme.surface,
                                splashFactory: NoSplash.splashFactory,
                              ),
                              icon: const Icon(Icons.play_arrow),
                            );
                          }),
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
              const SliverSizedBox(height: Dimens.sizeXLarge),
              SliverToBoxAdapter(
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                      color: scheme.textColorLight,
                      fontSize: Dimens.fontDefault + 1),
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
                      if (state.subtitle != null)
                        Text(state.subtitle ?? '')
                      else
                        Text(state.tracks.duration.pretty)
                    ],
                  ),
                ),
              ),
              SliverSizedBox(height: context.height * .2),
            ],
          );
        },
      ),
    );
  }

  void _appendTracks(MusicGroupState state) {
    final player = context.read<PlayerBloc>();
    player.add(PlayerAppendTracks(state.tracks, id: state.id));
  }

  void _shuffleToggle() {
    final player = context.read<PlayerBloc>();
    player.add(PlayerShuffleToggle());
  }

  void _toMoreDetails(MusicGroupBloc bloc, MusicGroupState state) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocProvider.value(
            value: bloc, child: PlaylistBottomSheet(state: state));
      },
    );
  }
}
