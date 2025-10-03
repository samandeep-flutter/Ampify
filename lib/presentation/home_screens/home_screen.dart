import 'package:ampify/buisness_logic/home_bloc/home_bloc.dart';
import 'package:ampify/buisness_logic/player_bloc/player_bloc.dart';
import 'package:ampify/data/data_models/common/album_model.dart';
import 'package:ampify/data/data_models/common/tracks_model.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:ampify/presentation/widgets/custom_scroll_physics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../buisness_logic/player_bloc/player_events.dart';
import '../../buisness_logic/player_bloc/player_slider_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return Scaffold(
        backgroundColor: scheme.background,
        body: CustomScrollView(
          physics: const BottomBounceScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: context.background,
              title: const Text(StringRes.appName),
              centerTitle: false,
              titleTextStyle: Utils.defTitleStyle(context),
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(Dimens.sizeDefault),
                  child: Row(
                    children: [
                      const SizedBox(width: Dimens.sizeDefault),
                      Text(StringRes.homeSubtitle,
                          style: TextStyle(
                              color: scheme.textColorLight,
                              fontSize: Dimens.fontDefault + 1)),
                    ],
                  )),
              actions: [
                IconButton(
                  onPressed: () => context.pushNamed(AppRoutes.listnHistory),
                  icon: Image.asset(ImageRes.history,
                      height: Dimens.iconMedSmall, color: scheme.textColor),
                ),
                const SizedBox(width: Dimens.sizeDefault),
              ],
            ),
            const SliverSizedBox(height: Dimens.sizeLarge),
            SliverGridWidget(
              title: StringRes.recentlyPlayed,
              child: GridView.builder(
                  padding: Utils.insetsHoriz(Dimens.sizeDefault),
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  gridDelegate: Utils.fixedCrossAxis(1,
                      aspectRatio: 1.3, spacing: Dimens.sizeMedSmall),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return HomeAlbumTile(
                      image: null,
                      title: StringRes.commingSoon,
                      subtitle: '',
                    );
                  }),
            ),
            const SliverSizedBox(height: Dimens.sizeLarge),
            SliverGridWidget(
              title: StringRes.spotifyRecent,
              child: BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (pr, cr) {
                  final tracks = pr.recentlyPlayed != cr.recentlyPlayed;
                  final loading = pr.recentLoading != cr.recentLoading;
                  return tracks || loading;
                },
                builder: (context, state) {
                  if (state.recentLoading) return const AlbumShimmer();
                  if (state.recentlyPlayed.isEmpty) {
                    return ToolTipWidget(
                      alignment: Alignment.center,
                      margin: Utils.insetsHoriz(Dimens.sizeLarge),
                      title: StringRes.noSpotifyTracks,
                    );
                  }

                  return GridView.builder(
                      padding: Utils.insetsHoriz(Dimens.sizeDefault),
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      gridDelegate: Utils.fixedCrossAxis(1,
                          aspectRatio: 1.3, spacing: Dimens.sizeMedSmall),
                      itemCount: state.recentlyPlayed.length,
                      itemBuilder: (context, index) {
                        final item = state.recentlyPlayed[index];
                        return HomeAlbumTile(
                          title: item.name,
                          subtitle: item.artists?.asString,
                          image: item.album?.image,
                          onTap: () => playRecentlyPlayed(context, track: item),
                        );
                      });
                },
              ),
            ),
            const SliverSizedBox(height: Dimens.sizeLarge),
            SliverGridWidget(
              title: StringRes.newReleases,
              child: BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (pr, cr) {
                  final albums = pr.albums != cr.albums;
                  final loading = pr.albumLoading != cr.albumLoading;
                  return albums || loading;
                },
                builder: (context, state) {
                  if (state.albumLoading) return const AlbumShimmer();
                  if (state.albums.isEmpty) {
                    return ToolTipWidget(
                      alignment: Alignment.center,
                      margin: Utils.insetsHoriz(Dimens.sizeLarge),
                      title: StringRes.noNewTracks,
                    );
                  }

                  return GridView.builder(
                      padding: Utils.insetsHoriz(Dimens.sizeDefault),
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      gridDelegate: Utils.fixedCrossAxis(1,
                          aspectRatio: 1.3, spacing: Dimens.sizeMedSmall),
                      itemCount: state.albums.length,
                      itemBuilder: (context, index) {
                        final item = state.albums[index];

                        return HomeAlbumTile(
                          image: item.image,
                          title: item.name,
                          onTap: () => toMusicGroup(context, album: item),
                          subtitle: item.artists?.asString,
                        );
                      });
                },
              ),
            ),
            SliverSizedBox(height: context.height * .15),
          ],
        ));
  }

  void toMusicGroup(BuildContext context, {required Album album}) {
    context.pushNamed(AppRoutes.musicGroup,
        pathParameters: {'id': album.id!, 'type': album.type?.name ?? ''});
  }

  void playRecentlyPlayed(BuildContext context, {required Track track}) {
    final player = context.read<PlayerBloc>();
    final slider = context.read<PlayerSliderBloc>();
    player.add(PlayerTrackChanged(track));
    slider.add(PlayerSliderReset());
  }
}

class SliverGridWidget extends StatelessWidget {
  final String? title;
  final Widget child;
  const SliverGridWidget({super.key, this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          if (title?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(left: Dimens.sizeDefault),
              child: Text(title!,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: Dimens.fontXXLarge,
                  )),
            ),
          const SizedBox(height: Dimens.sizeSmall),
          SizedBox(height: context.height * .25, child: child),
        ]));
  }
}

class HomeAlbumTile extends StatelessWidget {
  final String? image;
  final String? title;
  final String? subtitle;
  final VoidCallback? onTap;
  const HomeAlbumTile({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return InkWell(
      borderRadius: BorderRadius.circular(Dimens.sizeExtraSmall),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyCachedImage(image, borderRadius: Dimens.sizeExtraSmall),
          Padding(
            padding: const EdgeInsets.only(left: Dimens.sizeExtraSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: Dimens.fontDefault + 1,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: Dimens.fontDefault,
                      color: scheme.textColorLight),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
