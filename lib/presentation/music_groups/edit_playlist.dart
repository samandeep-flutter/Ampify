import 'package:ampify/buisness_logic/library_bloc/library_bloc.dart';
import 'package:ampify/buisness_logic/root_bloc/edit_playlist_bloc.dart';
import 'package:ampify/presentation/widgets/base_widget.dart';
import 'package:ampify/presentation/widgets/loading_widgets.dart';
import 'package:ampify/presentation/widgets/my_cached_image.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../config/routes/app_routes.dart';
import '../../data/utils/dimens.dart';
import '../../data/utils/string.dart';

class EditPlaylistScreen extends StatelessWidget {
  const EditPlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final width = context.width * .6;
    final bloc = context.read<EditPlaylistBloc>();
    return BaseWidget(
      appBar: AppBar(),
      padding: const EdgeInsets.symmetric(horizontal: Dimens.sizeExtraLarge),
      child: BlocBuilder<EditPlaylistBloc, EditPlaylistState>(
        buildWhen: (pr, cr) => pr.id != cr.id,
        builder: (context, state) {
          return ListView(
            children: [
              const SizedBox(height: Dimens.sizeSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyCachedImage(
                    state.image,
                    height: width,
                    width: width,
                    borderRadius: Dimens.sizeExtraSmall,
                  ),
                ],
              ),
              const SizedBox(height: Dimens.sizeExtraLarge),
              TextFormField(
                decoration: const InputDecoration(label: Text('Title')),
                controller: bloc.titleContr,
              ),
              const SizedBox(height: Dimens.sizeMidLarge),
              TextFormField(
                decoration: const InputDecoration(
                  label: Text('Describe your vibe!'),
                  constraints: BoxConstraints(maxHeight: 100),
                ),
                controller: bloc.descContr,
                expands: true,
                maxLines: null,
              ),
              const SizedBox(height: Dimens.sizeSmall),
              Text(
                StringRes.playlistDesc,
                style: TextStyle(
                    color: scheme.textColorLight,
                    fontWeight: FontWeight.w500,
                    fontSize: Dimens.fontLarge),
              ),
              BlocListener<EditPlaylistBloc, EditPlaylistState>(
                  listener: (context, state) {
                    if (state.success) {
                      context.read<LibraryBloc>().add(LibraryInitial());
                      context.goNamed(AppRoutes.libraryView);
                    }
                  },
                  child: SizedBox(height: context.height * .1)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BlocBuilder<EditPlaylistBloc, EditPlaylistState>(
                      builder: (context, state) {
                    return LoadingButton(
                      isLoading: state.loading,
                      width: width,
                      onPressed: bloc.onEdited,
                      child: const Text(StringRes.submit),
                    );
                  }),
                ],
              )
            ],
          );
        },
      ),
    );
  }
}
