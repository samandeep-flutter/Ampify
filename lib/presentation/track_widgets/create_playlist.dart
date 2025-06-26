import 'package:ampify/buisness_logic/library_bloc/library_bloc.dart';
import 'package:ampify/data/utils/dimens.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/data/utils/utils.dart';
import 'package:ampify/presentation/widgets/base_widget.dart';
import 'package:ampify/presentation/widgets/loading_widgets.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../buisness_logic/root_bloc/playlist_bloc.dart';

class CreatePlaylistView extends StatelessWidget {
  final String userId;
  const CreatePlaylistView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final bloc = context.read<PlaylistBloc>();

    return BaseWidget(
        appBar: AppBar(backgroundColor: scheme.background),
        child: ListView(
          children: [
            SizedBox(height: context.height * .1),
            Text(
              StringRes.playlistName,
              style: Utils.titleTextStyle(scheme.textColor),
            ),
            SizedBox(height: context.height * .1),
            TextFormField(
              key: bloc.titleKey,
              controller: bloc.titleController,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(
                  fontSize: Dimens.fontExtraTripleLarge,
                  fontWeight: FontWeight.w500),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return StringRes.errorEmpty('Name');
                }
                return null;
              },
            ),
            BlocListener<PlaylistBloc, PlaylistState>(
              listener: (context, state) {
                if (state.success) {
                  context.read<LibraryBloc>().add(LibraryInitial());
                  context.pop();
                }
              },
              child: SizedBox(height: context.height * .1),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            vertical: Dimens.sizeDefault),
                        foregroundColor: scheme.textColor,
                        backgroundColor: scheme.background,
                        shape: ContinuousRectangleBorder(
                          side: BorderSide(color: scheme.primary),
                          borderRadius:
                              BorderRadius.circular(Dimens.borderLarge),
                        )),
                    onPressed: context.pop,
                    child: const Text(
                      StringRes.cancel,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: Dimens.fontLarge),
                    ),
                  ),
                ),
                const SizedBox(width: Dimens.sizeDefault),
                Expanded(
                  child: BlocBuilder<PlaylistBloc, PlaylistState>(
                    builder: (context, state) {
                      return LoadingButton(
                        isLoading: state.loading,
                        loaderColor: scheme.primary,
                        onPressed: () => bloc.createPlaylist(userId),
                        child: const Text(StringRes.submit),
                      );
                    },
                  ),
                ),
              ],
            )
          ],
        ));
  }
}
