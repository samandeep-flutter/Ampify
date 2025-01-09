import 'package:ampify/data/utils/string.dart';
import 'package:ampify/presentation/search_screens/track_tile.dart';
import 'package:ampify/presentation/widgets/my_cached_image.dart';
import 'package:ampify/presentation/widgets/shimmer_widget.dart';
import 'package:ampify/presentation/widgets/top_widgets.dart';
import 'package:flutter/material.dart';
import 'package:ampify/data/utils/dimens.dart';
import 'package:ampify/data/utils/utils.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../buisness_logic/library_bloc/playlist_bloc.dart';
import '../widgets/loading_widgets.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlaylistBloc>();
    final scheme = context.scheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: BlocBuilder<PlaylistBloc, PlaylistState>(
        buildWhen: (pr, cr) => pr.loading != cr.loading,
        builder: (context, state) {
          final fgColor = state.color?.withOpacity(.4) ?? Colors.grey[300]!;

          if (state.loading) return const PlaylistShimmer();

          return CustomScrollView(
            controller: bloc.scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: context.height * .35,
                pinned: true,
                centerTitle: false,
                title: BlocBuilder<PlaylistBloc, PlaylistState>(
                    buildWhen: (pr, cr) => pr.titileOpacity != cr.titileOpacity,
                    builder: (context, state) {
                      return AnimatedOpacity(
                        opacity: state.titileOpacity,
                        duration: const Duration(milliseconds: 500),
                        child: Text(state.title ?? ''),
                      );
                    }),
                backgroundColor: Color.alphaBlend(fgColor, Colors.white),
                titleTextStyle: Utils.defTitleStyle,
                flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(
                        horizontal: Dimens.sizeDefault),
                    background: Align(
                      alignment: Alignment.bottomCenter,
                      child: MyCachedImage(
                        state.image,
                        loading: state.image?.isEmpty ?? true,
                        height: context.height * .3,
                        width: context.height * .3,
                        borderRadius: Dimens.sizeExtraSmall,
                      ),
                    )),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(Dimens.sizeDefault),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                        Color.alphaBlend(fgColor, Colors.white),
                        Colors.white,
                      ])),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.title ?? '', style: Utils.defTitleStyle),
                      if (state.description?.isNotEmpty ?? false)
                        Text(state.description!.unescape,
                            style: TextStyle(color: scheme.textColorLight)),
                      const SizedBox(height: Dimens.sizeSmall),
                      Wrap(
                        runSpacing: Dimens.sizeSmall,
                        spacing: Dimens.sizeSmall,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: Dimens.sizeExtraSmall,
                                horizontal: Dimens.sizeDefault),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: state.color ?? Colors.grey,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  Dimens.sizeDefault,
                                )),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(StringRes.playlist,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: scheme.textColorLight)),
                                PaginationDots(
                                  current: true,
                                  margin: Dimens.sizeSmall,
                                  color: scheme.textColorLight,
                                ),
                                RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: scheme.textColorLight),
                                      children: [
                                        const TextSpan(text: 'by '),
                                        TextSpan(text: state.owner)
                                      ]),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.track_changes,
                                color: scheme.textColorLight,
                              ),
                              const SizedBox(width: Dimens.sizeExtraSmall),
                              Text('${state.tracks.length} tracks',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: scheme.textColorLight))
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: Dimens.sizeDefault),
                      Row(
                        children: [
                          BlocBuilder<PlaylistBloc, PlaylistState>(
                            buildWhen: (pr, cr) => pr.isFav != cr.isFav,
                            builder: (context, state) {
                              return IconButton(
                                style: IconButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    shape: CircleBorder(
                                        side: BorderSide(
                                      width: 2,
                                      color: state.isFav
                                          ? scheme.primary
                                          : scheme.textColorLight,
                                    )),
                                    backgroundColor: state.isFav
                                        ? scheme.primary
                                        : Colors.transparent),
                                onPressed: bloc.onFav,
                                isSelected: state.isFav,
                                iconSize: Dimens.sizeLarge,
                                selectedIcon:
                                    Icon(Icons.check, color: scheme.onPrimary),
                                icon: const Icon(Icons.add),
                              );
                            },
                          ),
                          const SizedBox(width: Dimens.sizeSmall),
                          IconButton(
                            onPressed: () {},
                            style: IconButton.styleFrom(
                                visualDensity: VisualDensity.compact),
                            iconSize: Dimens.sizeMedium,
                            icon: const Icon(Icons.more_vert),
                          ),
                          const Spacer(),
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
                    return TrackTile(track: track);
                  })
            ],
          );
        },
      ),
    );
  }
}
