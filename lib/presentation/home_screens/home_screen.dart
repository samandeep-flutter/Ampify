import 'dart:ui';
import 'package:ampify/buisness_logic/home_bloc/home_bloc.dart';
import 'package:ampify/data/utils/exports.dart';

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
              centerTitle: false,
              backgroundColor: context.scheme.background,
              title: const Text(StringRes.appName),
              titleTextStyle: Utils.defTitleStyle(scheme.textColor),
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(Dimens.sizeDefault),
                  child: Row(
                    children: [
                      const SizedBox(width: Dimens.sizeDefault),
                      Text(
                        StringRes.homeSubtitle,
                        style: TextStyle(
                            color: scheme.textColorLight,
                            fontSize: Dimens.fontDefault),
                      ),
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
            const SliverSizedBox(height: Dimens.sizeXLarge),
            SliverToBoxAdapter(
                child: Wrap(
              spacing: Dimens.sizeExtraSmall,
              runSpacing: Dimens.sizeExtraSmall,
              alignment: WrapAlignment.center,
              children: List.generate(6, (index) {
                return RecentlyPlayedTile(title: StringRes.commingSoon);
              }),
            )),
            const SliverSizedBox(height: Dimens.sizeLarge),
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (pr, cr) {
                final loading = pr.albumLoading != cr.albumLoading;
                return pr.albums != cr.albums || loading;
              },
              builder: (context, state) {
                if (state.albumLoading) {
                  return SliverToBoxAdapter(child: const AlbumShimmer());
                } else if (state.albums.isEmpty) {
                  return SliverToBoxAdapter(
                    child: ToolTipWidget(
                      alignment: Alignment.center,
                      margin: Utils.insetsHoriz(Dimens.sizeXLarge),
                      title: StringRes.noNewTracks,
                    ),
                  );
                }
                return SliverList.builder(
                  itemCount: state.albums.length,
                  itemBuilder: (_, i) {
                    final item = state.albums[i];
                    if (item.contents.isEmpty) return SizedBox.shrink();
                    return HomeSectionBuilder(item);
                  },
                );
              },
            ),
            SliverSizedBox(height: context.height * .15),
          ],
        ));
  }

  // void _playTrack(BuildContext context, {required Track track}) {
  //   final player = context.read<PlayerBloc>();
  //   final slider = context.read<PlayerSliderBloc>();
  //   player.add(PlayerTrackChanged(track));
  //   slider.add(PlayerSliderReset());
  // }
}

class RecentlyPlayedTile extends StatelessWidget {
  final String? title;
  final String? subtitle;

  final VoidCallback? onTap;
  const RecentlyPlayedTile({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return SizedBox(
      width: context.width * .48,
      child: Card(
        color: scheme.backgroundDark.withAlpha(150),
        shape: Utils.roundedBorder(Dimens.borderSmall),
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimens.borderMini),
          onTap: onTap,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadiusGeometry.horizontal(
                    left: Radius.circular(Dimens.borderMini + 2)),
                child: SizedBox.square(
                    dimension: Dimens.sizeExtraDoubleLarge,
                    child: MyCachedImage.error(
                      backgroundColor: scheme.backgroundDark,
                      foregroundColor: scheme.disabled.withAlpha(100),
                    )),
              ),
              const SizedBox(width: Dimens.sizeSmall),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (title != null)
                    Text(
                      title ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: Dimens.fontDefault,
                          fontWeight: FontWeight.w600),
                    ),
                  if (subtitle != null)
                    Text(
                      subtitle ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: Dimens.fontMed,
                          color: scheme.textColorLight),
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class HomeSectionBuilder extends StatelessWidget {
  final MyHomeSection section;
  const HomeSectionBuilder(this.section, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: Dimens.sizeDefault),
          child: Text(section.title, style: Utils.titleStyleLarge(context)),
        ),
        const SizedBox(height: Dimens.sizeSmall),
        if (section.type.isPlaylist || section.type.isAlbum)
          SizedBox(
            height: clampDouble(context.height * .25, 150, 200),
            child: GridView.builder(
              padding: Utils.insetsHoriz(Dimens.sizeDefault),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              gridDelegate: Utils.fixedCrossAxis(1,
                  aspectRatio: 1.3, spacing: Dimens.sizeMedSmall),
              itemCount: section.contents.length,
              itemBuilder: (context, index) {
                return PlaylistDetailedTile(section.contents[index],
                    onTap: (pl) => _toMusicGroup(context, pl));
              },
            ),
          )
        else
          ToolTipWidget(
            title: StringRes.homeSecDesc,
            margin: EdgeInsets.all(Dimens.sizeExtraLarge),
          ),
        const SizedBox(height: Dimens.sizeXLarge)
      ],
    );
  }

  void _toMusicGroup(BuildContext context, MyHomeDetailed pl) {
    context.pushNamed(AppRoutes.musicGroup,
        pathParameters: {'id': pl.id, 'type': pl.type.id});
  }
}

class PlaylistDetailedTile extends StatelessWidget {
  final MyHomeDetailed item;
  final void Function(MyHomeDetailed pl)? onTap;
  const PlaylistDetailedTile(this.item, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return InkWell(
      borderRadius: BorderRadius.circular(Dimens.sizeExtraSmall),
      onTap: () => onTap?.call(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyCachedImage(item.thumbnail?.url, border: Dimens.sizeExtraSmall),
          Padding(
            padding: const EdgeInsets.only(left: Dimens.sizeExtraSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: Dimens.fontDefault,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  item.artist.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: Dimens.fontMed, color: scheme.textColorLight),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
