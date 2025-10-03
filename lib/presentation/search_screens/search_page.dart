import 'package:ampify/buisness_logic/search_bloc/search_bloc.dart';
import 'package:ampify/presentation/music_groups/music_group_tile.dart';
import 'package:ampify/presentation/track_widgets/track_tile.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final bloc = context.read<SearchBloc>();

    return BaseWidget(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: scheme.background,
        // toolbarHeight: Dimens.sizeUltraLarge,
        title: SizedBox(
          height: Dimens.sizeExtraDoubleLarge,
          child: PopScope(
            onPopInvokedWithResult: (didPop, _) => bloc.onSearchClear(),
            child: BlocBuilder<SearchBloc, SearchState>(
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
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  borderRadius: Dimens.borderSmall,
                );
              },
            ),
          ),
        ),
      ),
      child: Column(
        children: [
          BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state.isLoading) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: 12,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: Dimens.sizeDefault),
                    itemBuilder: (_, __) => const SongTileShimmer(),
                  ),
                );
              } else if (state.results == null) {
                return ToolTipWidget.placeHolder(
                  scrolable: true,
                  icon: ImageRes.music,
                  title: StringRes.searchBarSubtitle,
                );
              } else if (state.results!.isEmpty) {
                return ToolTipWidget.placeHolder(
                  scrolable: true,
                  icon: ImageRes.search,
                  title: StringRes.emptySearchResults,
                );
              }

              return Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: context.height * .18),
                  itemCount: state.results?.length ?? 0,
                  itemBuilder: (context, index) {
                    final item = state.results![index];

                    if (item.type.isTrack) return TrackTile(item.asTrack);
                    return MusicGroupTile(item,
                        imageHeight: Dimens.iconUltraLarge);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
