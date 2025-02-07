import 'package:ampify/data/utils/string.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../buisness_logic/library_bloc/liked_songs_bloc.dart';
import '../../data/utils/dimens.dart';
import '../../data/utils/utils.dart';
import '../track_widgets/track_tile.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/shimmer_widget.dart';

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
      backgroundColor: Colors.white,
      body: BlocBuilder<LikedSongsBloc, LikedSongsState>(
        buildWhen: (pr, cr) {
          final loading = pr.loading != cr.loading;
          final items = pr.totalTracks != cr.totalTracks;
          final moreLoading = pr.moreLoading != cr.moreLoading;

          return loading || moreLoading || items;
        },
        builder: (context, state) {
          final fgColor = scheme.primary.withOpacity(.6);

          if (state.loading) {
            return const MusicGroupShimmer(
              isLikedSongs: true,
              itemCount: 10,
            );
          }

          return CustomScrollView(
            controller: bloc.scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: context.height * .05,
                pinned: true,
                centerTitle: false,
                title: BlocBuilder<LikedSongsBloc, LikedSongsState>(
                    buildWhen: (pr, cr) => pr.titileOpacity != cr.titileOpacity,
                    builder: (context, state) {
                      return AnimatedOpacity(
                        opacity: state.titileOpacity,
                        duration: const Duration(milliseconds: 500),
                        child: const Text(StringRes.likedSongs),
                      );
                    }),
                leading: IconButton(
                  onPressed: () => context.pop(bloc.libRefresh),
                  icon: const Icon(Icons.arrow_back_outlined),
                ),
                backgroundColor: Color.alphaBlend(fgColor, Colors.white),
                titleTextStyle: Utils.defTitleStyle,
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(Dimens.sizeDefault),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0, 1],
                          colors: [fgColor, Colors.white])),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(StringRes.likedSongs, style: Utils.defTitleStyle),
                      const SizedBox(height: Dimens.sizeSmall),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.track_changes,
                            color: scheme.textColorLight,
                          ),
                          const SizedBox(width: Dimens.sizeExtraSmall),
                          Text('${state.totalTracks} tracks',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: scheme.textColorLight))
                        ],
                      ),
                      const SizedBox(height: Dimens.sizeDefault),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          LoadingIcon(
                            onPressed: () {},
                            iconSize: Dimens.sizeMidLarge,
                            loaderSize: Dimens.sizeMidLarge,
                            loading: false,
                            isSelected: false,
                            selectedIcon: const Icon(Icons.pause),
                            style: IconButton.styleFrom(
                                backgroundColor: scheme.textColor,
                                foregroundColor: scheme.surface,
                                splashFactory: NoSplash.splashFactory),
                            icon: const Icon(Icons.play_arrow),
                          ),
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
              SliverToBoxAdapter(child: SizedBox(height: context.height * .18))
            ],
          );
        },
      ),
    );
  }
}
