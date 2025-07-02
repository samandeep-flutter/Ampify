import 'package:ampify/buisness_logic/library_bloc/library_bloc.dart';
import 'package:ampify/config/routes/app_routes.dart';
import 'package:ampify/data/data_models/library_model.dart';
import 'package:ampify/data/utils/dimens.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/data/utils/utils.dart';
import 'package:ampify/presentation/widgets/loading_widgets.dart';
import 'package:ampify/presentation/widgets/my_cached_image.dart';
import 'package:ampify/presentation/widgets/top_widgets.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../buisness_logic/root_bloc/addto_playlist_bloc.dart';

class AddtoPlaylistSheet extends StatelessWidget {
  const AddtoPlaylistSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AddtoPlaylistBloc>();
    final scheme = context.scheme;
    return SizedBox(
      height: context.height * .55,
      child: BlocBuilder<LibraryBloc, LibraryState>(
          buildWhen: (pr, cr) => pr.items != cr.items,
          builder: (context, state) {
            final playlists = state.items.where((e) {
              final isPlaylist = e.type == LibItemType.playlist;
              final myPlaylists = e.owner?.id == bloc.box.profile!.id;
              return isPlaylist && myPlaylists;
            }).toList();
            return Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: Dimens.sizeLarge),
                    Text(
                      StringRes.addtoPlaylist,
                      style: TextStyle(
                        color: scheme.textColor,
                        fontSize: Dimens.fontLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        final id = bloc.box.profile!.id!;
                        context.pushNamed(AppRoutes.createPlaylist,
                            pathParameters: {'userId': id});
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primaryAdaptive,
                          foregroundColor: scheme.onPrimary,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.only(
                              left: Dimens.sizeSmall,
                              right: Dimens.sizeDefault)),
                      icon: Icon(Icons.add_outlined, size: Dimens.iconMedSmall),
                      label: Text(StringRes.playlist,
                          style: TextStyle(fontSize: Dimens.fontDefault)),
                    ),
                    const SizedBox(width: Dimens.sizeDefault),
                  ],
                ),
                const SizedBox(height: Dimens.sizeSmall),
                const MyDivider(),
                const SizedBox(height: Dimens.sizeDefault),
                BlocBuilder<AddtoPlaylistBloc, AddtoPlaylistState>(
                    builder: (context, state) {
                  if (playlists.isEmpty) {
                    return const Expanded(
                        child: ToolTipWidget(title: StringRes.noPlaylists));
                  }
                  return Flexible(
                    child: GridView.builder(
                      padding: Utils.insetsHoriz(Dimens.sizeDefault),
                      scrollDirection: playlists.length > 2
                          ? Axis.horizontal
                          : Axis.vertical,
                      gridDelegate:
                          Utils.fixedCrossAxis(2, spacing: Dimens.sizeSmall),
                      itemCount: playlists.length,
                      itemBuilder: (context, index) {
                        final item = playlists[index];

                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                    child: InkWell(
                                  onTap: () => bloc.onItemAdded(item.id!),
                                  borderRadius: BorderRadius.circular(
                                      Dimens.circularBoder),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return MyCachedImage(
                                        item.image,
                                        height: constraints.maxHeight,
                                        width: constraints.maxHeight,
                                        borderRadius: Dimens.circularBoder,
                                      );
                                    },
                                  ),
                                )),
                                const SizedBox(height: Dimens.sizeSmall),
                                Text(
                                  item.name ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: scheme.textColor,
                                      fontSize: Dimens.fontDefault,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: Dimens.sizeSmall),
                              ],
                            ),
                            if (state.playlists.contains(item.id))
                              Container(
                                margin: const EdgeInsets.only(
                                    right: Dimens.sizeMedSmall,
                                    top: Dimens.sizeSmall),
                                alignment: Alignment.topRight,
                                child: CircleAvatar(
                                  radius: Dimens.iconExtraSmall,
                                  backgroundColor: scheme.primary,
                                  child: Icon(Icons.check_outlined,
                                      color: scheme.onPrimary,
                                      size: Dimens.iconMedSmall),
                                ),
                              )
                          ],
                        );
                      },
                    ),
                  );
                }),
                BlocListener<AddtoPlaylistBloc, AddtoPlaylistState>(
                    listener: (context, state) {
                      if (state.success) {
                        Navigator.pop(context);
                        context.read<LibraryBloc>().add(LibraryInitial());
                      }
                    },
                    child: const SizedBox(height: Dimens.sizeDefault)),
                BlocBuilder<AddtoPlaylistBloc, AddtoPlaylistState>(
                  buildWhen: (pr, cr) {
                    final loading = pr.loading != cr.loading;
                    final ids = pr.playlists != cr.playlists;
                    return loading || ids;
                  },
                  builder: (context, state) {
                    return LoadingButton(
                      margin: Utils.insetsHoriz(Dimens.sizeDefault),
                      width: double.infinity,
                      isLoading: state.loading,
                      enable: state.playlists.isNotEmpty,
                      onPressed: () => bloc.add(AddTracktoPlaylists()),
                      child: const Text(StringRes.submit),
                    );
                  },
                ),
                const SafeArea(child: SizedBox(height: Dimens.sizeSmall))
              ],
            );
          }),
    );
  }
}
