import 'package:ampify/data/data_models/common/playlist_model.dart';
import 'package:ampify/data/data_models/library_model.dart';
import 'package:ampify/data/data_models/profile_model.dart';
import 'package:ampify/data/repository/library_repo.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:ampify/services/getit_instance.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../config/routes/app_routes.dart';
import '../../data/utils/app_constants.dart';
import '../../data/utils/color_resources.dart';
import '../../data/utils/dimens.dart';
import '../../data/utils/string.dart';
import '../../presentation/widgets/my_alert_dialog.dart';
import '../../services/box_services.dart';
import '../../services/notification_services.dart';

class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

class LibraryInitial extends LibraryEvent {}

class LibraryRefresh extends LibraryEvent {}

class LibrarySorted extends LibraryEvent {
  final SortOrder order;
  const LibrarySorted(this.order);

  @override
  List<Object?> get props => [order, super.props];
}

class LibraryState extends Equatable {
  final ProfileModel? profile;
  final SortOrder? sortby;
  final List<Playlist> playlists;
  final bool loading;
  const LibraryState({
    required this.profile,
    required this.sortby,
    required this.playlists,
    required this.loading,
  });
  const LibraryState.init()
      : profile = null,
        sortby = SortOrder.custom,
        playlists = const [],
        loading = true;

  LibraryState copyWith({
    ProfileModel? profile,
    List<Playlist>? playlists,
    SortOrder? sortby,
    bool? loading,
  }) {
    return LibraryState(
      profile: profile ?? this.profile,
      sortby: sortby ?? this.sortby,
      playlists: playlists ?? this.playlists,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [profile, playlists, sortby, loading];
}

enum SortOrder { alphabetical, owner, custom }

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc() : super(const LibraryState.init()) {
    on<LibraryInitial>(_onInit);
    on<LibraryRefresh>(_onRefresh);
    on<LibrarySorted>(_onSorted);
  }
  final LibraryRepo _repo = getIt();
  final _box = BoxServices.to;

  _onSorted(LibrarySorted event, Emitter<LibraryState> emit) async {
    switch (event.order) {
      case SortOrder.alphabetical:
        final playlist = state.playlists
          ..sort((a, b) => a.name?.compareTo(b.name ?? '') ?? 0);
        emit(state.copyWith(
          playlists: playlist,
          sortby: SortOrder.alphabetical,
        ));
        break;
      case SortOrder.owner:
        final playlist = state.playlists
          ..sort((a, b) {
            final first = a.owner?.displayName;
            final second = b.owner?.displayName;
            return first?.compareTo(second ?? '') ?? 0;
          });

        emit(state.copyWith(playlists: playlist, sortby: SortOrder.owner));
        break;
      case SortOrder.custom:
        final playlist = state.playlists
          ..sort((a, b) => a.id?.compareTo(b.id ?? '') ?? 0);
        emit(state.copyWith(playlists: playlist, sortby: SortOrder.custom));
        break;
    }
  }

  _onRefresh(LibraryRefresh event, Emitter<LibraryState> emit) async {
    emit(state.copyWith(loading: true));
    await _repo.getMyPlaylists(
      onSuccess: (json) {
        final model = LibraryModel.fromJson(json);
        model.items?.sort((a, b) => a.id?.compareTo(b.id ?? '') ?? 0);
        emit(state.copyWith(playlists: model.items, loading: false));
      },
      onError: (json) => logPrint('playlists: $json'),
    );
  }

  _onInit(LibraryInitial event, Emitter<LibraryState> emit) async {
    final json = _box.read(BoxKeys.profile);
    final profile = ProfileModel.fromJson(json);
    emit(state.copyWith(profile: profile));
    await _repo.getUserPlaylists(
      profile.id,
      onSuccess: (json) {
        final model = LibraryModel.fromJson(json);
        model.items?.sort((a, b) => a.id?.compareTo(b.id ?? '') ?? 0);
        emit(state.copyWith(playlists: model.items, loading: false));
      },
      onError: (json) => logPrint('playlists: $json'),
    );
    Future(MyNotifications.initialize);
  }

  void createPlaylist() {}

  void logout(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return MyAlertDialog(
            title: '${StringRes.logout} ?',
            content: const Text(StringRes.logoutDesc),
            actionPadding: const EdgeInsets.only(
                right: Dimens.sizeDefault, bottom: Dimens.sizeSmall),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: context.scheme.textColor,
                ),
                child: const Text(StringRes.cancel),
              ),
              TextButton(
                onPressed: () {
                  BoxServices.to.remove(BoxKeys.token);
                  context.goNamed(AppRoutes.auth);
                },
                style: TextButton.styleFrom(
                  foregroundColor: ColorRes.error,
                ),
                child: Text(StringRes.logout.toUpperCase()),
              ),
            ],
          );
        });
  }
}
