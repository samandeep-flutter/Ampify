import 'package:ampify/buisness_logic/library_bloc/library_bloc.dart';
import 'package:ampify/buisness_logic/player_bloc/player_events.dart';
import 'package:ampify/presentation/widgets/custom_scroll_physics.dart';
import 'package:flutter/material.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../buisness_logic/library_bloc/liked_songs_bloc.dart';
import '../../buisness_logic/player_bloc/player_bloc.dart';
import '../../buisness_logic/player_bloc/player_state.dart';
import '../track_widgets/track_tile.dart';

class LikedSongs extends StatefulWidget {
  const LikedSongs({super.key});

  @override
  State<LikedSongs> createState() => _LikedSongsState();
}

class _LikedSongsState extends State<LikedSongs> {
  @override
  void initState() {
    context.read<LikedSongsBloc>().add(LikedSongsInitial());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LikedSongsBloc>();
    final scheme = context.scheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: scheme.background,
      body: BlocBuilder<LikedSongsBloc, LikedSongsState>(
        buildWhen: (pr, cr) {
          final loading = pr.loading != cr.loading;
          final items = pr.totalTracks != cr.totalTracks;
          final moreLoading = pr.moreLoading != cr.moreLoading;

          return loading || moreLoading || items;
        },
        builder: (context, state) {
          final fgColor = scheme.primaryAdaptive.withAlpha(150);

          if (state.loading) {
            return const MusicGroupShimmer(isLikedSongs: true, itemCount: 12);
          }

          return CustomScrollView(
            controller: bloc.scrollController,
            physics: const BottomBounceScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: context.height * .05,
                pinned: true,
                centerTitle: false,
                title: PopScope(
                  onPopInvokedWithResult: (didPop, _) {
                    if (!bloc.libRefresh) return;
                    context.read<LibraryBloc>().add(LibraryRefresh());
                  },
                  child: BlocBuilder<LikedSongsBloc, LikedSongsState>(
                      buildWhen: (pr, cr) =>
                          pr.titileOpacity != cr.titileOpacity,
                      builder: (context, state) {
                        return AnimatedOpacity(
                          opacity: state.titileOpacity,
                          duration: Durations.long2,
                          child: const Text(StringRes.likedSongs),
                        );
                      }),
                ),
                backgroundColor: Color.alphaBlend(fgColor, scheme.background),
                titleTextStyle: Utils.defTitleStyle(context),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(Dimens.sizeDefault),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0, 1],
                          colors: [fgColor, scheme.background])),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(StringRes.likedSongs,
                          style: Utils.titleStyleLarge(context)),
                      const SizedBox(height: Dimens.sizeSmall),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.track_changes,
                            color: scheme.textColorLight,
                            size: Dimens.iconDefault,
                          ),
                          const SizedBox(width: Dimens.sizeExtraSmall),
                          Text('${state.totalTracks} tracks',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: Dimens.fontDefault,
                                  color: scheme.textColorLight))
                        ],
                      ),
                      const SizedBox(height: Dimens.sizeDefault),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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
                            final group =
                                pl.musicGroupId == UniqueIds.likedSongs;
                            final loading = pl.playerState.isLoading;
                            return LoadingIcon(
                              onPressed: () => bloc.onPlay(context),
                              iconSize: Dimens.iconXLarge,
                              loaderSize: Dimens.iconXLarge,
                              loading: group && loading,
                              isSelected: group,
                              selectedIcon: const Icon(Icons.pause),
                              style: IconButton.styleFrom(
                                  backgroundColor: scheme.textColor,
                                  foregroundColor: scheme.surface,
                                  splashFactory: NoSplash.splashFactory),
                              icon: const Icon(Icons.play_arrow),
                            );
                          }),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SliverList.builder(
                  itemCount: state.tracks.length,
                  itemBuilder: (context, index) {
                    final track = state.tracks[index];
                    return TrackTile(track, liked: true);
                  }),
              if (state.moreLoading)
                SliverToBoxAdapter(
                  child: Column(
                      children: List.generate(3, (_) {
                    return const SongTileShimmer();
                  })),
                ),
              SliverSizedBox(height: context.height * .2)
            ],
          );
        },
      ),
    );
  }

  void _shuffleToggle() {
    final player = context.read<PlayerBloc>();
    player.add(PlayerShuffleToggle());
  }
}
