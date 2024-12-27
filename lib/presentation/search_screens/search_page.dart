import 'package:ampify/buisness_logic/search_bloc/search_bloc.dart';
import 'package:ampify/data/utils/dimens.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/presentation/search_screens/track_tile.dart';
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
        title: BlocBuilder<SearchBloc, SearchState>(
          buildWhen: (previous, current) {
            final searchText = bloc.searchContr.text;
            return searchText.isEmpty || searchText.length == 1;
          },
          builder: (context, state) {
            final searchText = bloc.searchContr.text;
            return SearchTextField(
              title: 'Search',
              controller: bloc.searchContr,
              focusNode: bloc.focusNode,
              trailing: searchText.isNotEmpty
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
                    padding: const EdgeInsets.only(top: Dimens.sizeDefault),
                    itemCount: state.results?.length ?? 0,
                    itemBuilder: (context, index) {
                      final track = state.results![index];
                      return TrackTile(track: track);
                    }),
              );
            },
          ),
        ],
      ),
    );
  }
}
