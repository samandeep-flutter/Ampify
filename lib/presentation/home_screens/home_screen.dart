import 'package:ampify/buisness_logic/home_bloc/home_bloc.dart';
import 'package:ampify/buisness_logic/player_bloc/player_bloc.dart';
import 'package:ampify/config/routes/app_routes.dart';
import 'package:ampify/data/utils/dimens.dart';
import 'package:ampify/data/utils/image_resources.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/data/utils/utils.dart';
import 'package:ampify/presentation/widgets/my_cached_image.dart';
import 'package:ampify/presentation/widgets/shimmer_widget.dart';
import 'package:ampify/presentation/widgets/top_widgets.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../buisness_logic/player_bloc/player_events.dart';
import '../../buisness_logic/player_bloc/player_slider_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final bloc = context.read<HomeBloc>();

    return Scaffold(
        backgroundColor: scheme.background,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: context.background,
              title: const Text(StringRes.appName),
              centerTitle: false,
              titleTextStyle: Utils.defTitleStyle(context),
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(Dimens.sizeLarge),
                  child: Row(
                    children: [
                      const SizedBox(width: Dimens.sizeDefault),
                      Text(StringRes.homeSubtitle,
                          style: TextStyle(
                              color: scheme.textColorLight,
                              fontSize: Dimens.fontDefault)),
                    ],
                  )),
              actions: [
                IconButton(
                  onPressed: () => bloc.toHistory(context),
                  icon: Image.asset(ImageRes.history,
                      height: Dimens.iconDefault, color: scheme.textColor),
                ),
                const SizedBox(width: Dimens.sizeDefault),
              ],
            ),
            const SliverSizedBox(height: Dimens.sizeLarge),
            SliverGridWidget(
                child: Card(
              color: scheme.shimmer,
              margin: Utils.insetsHoriz(Dimens.sizeDefault),
              child: Container(
                padding: const EdgeInsets.all(Dimens.sizeDefault),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      StringRes.recentlyPlayed,
                      style: TextStyle(
                          color: scheme.textColorLight,
                          fontSize: Dimens.fontDefault),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset(
                            ImageRes.thumbnail,
                            height: context.width * .2,
                            color: scheme.textColorLight,
                          ),
                          const SizedBox(width: Dimens.sizeDefault),
                          Text(
                            StringRes.commingSoon,
                            style: TextStyle(
                              fontSize: Dimens.fontExtraTripleLarge,
                              color: scheme.textColorLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
            const SliverSizedBox(height: Dimens.sizeLarge),
            SliverGridWidget(
              title: StringRes.spotifyRecent,
              child: BlocBuilder<HomeBloc, HomeState>(
                  buildWhen: (pr, cr) => pr.recentlyPlayed != cr.recentlyPlayed,
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
                        scrollDirection: Axis.horizontal,
                        gridDelegate: Utils.fixedCrossAxis(1,
                            aspectRatio: 1.3, spacing: Dimens.sizeMedSmall),
                        itemCount: state.recentlyPlayed.length,
                        itemBuilder: (context, index) {
                          final item = state.recentlyPlayed[index];
                          return HomeAlbumTile(
                            onTap: () {
                              final player = context.read<PlayerBloc>();
                              final slider = context.read<PlayerSliderBloc>();
                              player.add(PlayerTrackChanged(item));
                              slider.add(const PlayerSliderChange(0));
                            },
                            image: item.album?.image,
                            title: item.name,
                            subtitle: item.artists?.asString,
                          );
                        });
                  }),
            ),
            const SliverSizedBox(height: Dimens.sizeLarge),
            SliverGridWidget(
                title: StringRes.newReleases,
                child: BlocBuilder<HomeBloc, HomeState>(
                    buildWhen: (pr, cr) => pr.albums != cr.albums,
                    builder: (context, state) {
                      if (state.recentLoading) return const AlbumShimmer();

                      return GridView.builder(
                          padding: Utils.insetsHoriz(Dimens.sizeDefault),
                          scrollDirection: Axis.horizontal,
                          gridDelegate: Utils.fixedCrossAxis(1,
                              aspectRatio: 1.3, spacing: Dimens.sizeMedSmall),
                          itemCount: state.albums.length,
                          itemBuilder: (context, index) {
                            final item = state.albums[index];

                            return HomeAlbumTile(
                              onTap: () {
                                context.pushNamed(AppRoutes.musicGroup,
                                    pathParameters: {
                                      'id': item.id!,
                                      'type': item.type!.name
                                    });
                              },
                              image: item.image,
                              title: item.name,
                              subtitle: item.artists?.asString,
                            );
                          });
                    })),
            SliverSizedBox(height: context.height * .15),
          ],
        ));
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
                    fontSize: Dimens.fontLarge,
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
                      fontSize: Dimens.fontDefault,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: Dimens.fontDefault - 1,
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
