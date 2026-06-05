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
              backgroundColor: context.scheme.background,
              title: const Text(StringRes.appName),
              centerTitle: false,
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
            const SliverSizedBox(height: Dimens.sizeXLarge),
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (pr, cr) {
                final loading = pr.albumLoading != cr.albumLoading;
                return pr.albums != cr.albums || loading;
              },
              builder: (context, state) {
                if (state.albumLoading) {
                  return SliverGridWidget(child: const AlbumShimmer());
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
                  itemBuilder: (_, i) => HomeSectionBuilder(state.albums[i]),
                );
              },
            ),
            SliverSizedBox(height: context.height * .15),
          ],
        ));
  }

  // void _toMusicGroup(BuildContext context, {required Album album}) {
  //   context.pushNamed(AppRoutes.musicGroup,
  //       pathParameters: {'id': album.id!, 'type': album.type?.name ?? ''});
  // }

  // void _playTrack(BuildContext context, {required Track track}) {
  //   final player = context.read<PlayerBloc>();
  //   final slider = context.read<PlayerSliderBloc>();
  //   player.add(PlayerTrackChanged(track));
  //   slider.add(PlayerSliderReset());
  // }
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
          if (title?.isNotEmpty ?? false) ...[
            Padding(
              padding: const EdgeInsets.only(left: Dimens.sizeDefault),
              child: Text(title!, style: Utils.titleStyleLarge(context)),
            ),
            const SizedBox(height: Dimens.sizeSmall),
          ],
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
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle ?? '',
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
        SizedBox(
          height: context.height * .25,
          child: GridView.builder(
              padding: Utils.insetsHoriz(Dimens.sizeDefault),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              gridDelegate: Utils.fixedCrossAxis(1,
                  aspectRatio: 1.3, spacing: Dimens.sizeMedSmall),
              itemCount: section.contents.length,
              itemBuilder: (context, index) {
                final item = section.contents[index];
                return Placeholder();
              }),
        ),
      ],
    );
  }
}
