import 'package:ampify/buisness_logic/search_bloc/search_bloc.dart';
import 'package:ampify/data/data_models/common/album_model.dart';
import 'package:ampify/data/data_models/common/artist_model.dart';
import 'package:ampify/data/data_models/common/tracks_model.dart';
import 'package:ampify/data/data_models/library_model.dart';
import 'package:ampify/data/utils/dimens.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/presentation/music_groups/music_group_tile.dart';
import 'package:ampify/presentation/track_widgets/track_tile.dart';
import 'package:ampify/presentation/widgets/base_widget.dart';
import 'package:ampify/presentation/widgets/my_text_field_widget.dart';
import 'package:ampify/presentation/widgets/shimmer_widget.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/utils/image_resources.dart';
import '../widgets/top_widgets.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final bloc = context.read<SearchBloc>();

    return BaseWidget(
      padding: EdgeInsets.zero,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: scheme.background,
        toolbarHeight: Dimens.circularBoder,
        title: BlocBuilder<SearchBloc, SearchState>(
          buildWhen: (previous, current) {
            final query = bloc.searchContr.text.trim();
            return query.isEmpty || query.length == 1;
          },
          builder: (context, state) {
            final query = bloc.searchContr.text;
            return SearchTextField(
              title: 'Search',
              controller: bloc.searchContr,
              focusNode: bloc.focusNode,
              trailing: query.isNotEmpty
                  ? IconButton(
                      onPressed: bloc.onSearchClear,
                      color: scheme.disabled,
                      icon: const Icon(Icons.clear))
                  : null,
              borderRadius: Dimens.borderSmall,
            );
          },
        ),
      ),
      child: Column(
        children: [
          BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state.isLoading) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: 10,
                    padding: const EdgeInsets.only(top: Dimens.sizeDefault),
                    itemBuilder: (_, __) => const SongTileShimmer(),
                  ),
                );
              }
              if (state.results == null) {
                return ToolTipWidget.placeHolder(
                  scrolable: true,
                  icon: ImageRes.music,
                  title: StringRes.searchBarSubtitle,
                );
              }

              if (state.results!.isEmpty) {
                return ToolTipWidget.placeHolder(
                  scrolable: true,
                  icon: ImageRes.search,
                  title: StringRes.emptySearchResults,
                );
              }

              return Expanded(
                child: ListView.builder(
                    padding: EdgeInsets.only(bottom: context.height * .18),
                    itemCount: state.results?.length ?? 0,
                    itemBuilder: (context, index) {
                      final item = state.results![index];

                      if (item.type == LibItemType.track) {
                        final artists = item.owner?.name?.split(',') ?? [];
                        return TrackTile(Track(
                          id: item.id,
                          name: item.name,
                          type: item.type?.name,
                          album: Album(image: item.image, id: item.albumId),
                          artists: List<Artist>.from(artists.map((e) {
                            return Artist(name: e);
                          })),
                        ));
                      }

                      return MusicGroupTile(item,
                          imageHeight: Dimens.sizeExtraLarge);
                    }),
              );
            },
          ),
        ],
      ),
    );
  }
}
