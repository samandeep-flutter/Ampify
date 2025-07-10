import 'package:ampify/data/repositories/music_group_repo.dart';
import 'package:ampify/data/utils/app_constants.dart';
import 'package:ampify/services/box_services.dart';
import 'package:ampify/services/getit_instance.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/data_models/profile_model.dart';

class AddtoPlaylistEvents extends Equatable {
  const AddtoPlaylistEvents();

  @override
  List<Object?> get props => [];
}

class PlaylistInitial extends AddtoPlaylistEvents {
  final String uri;
  const PlaylistInitial(this.uri);

  @override
  List<Object?> get props => [uri, super.props];
}

class PlaylistSelected extends AddtoPlaylistEvents {
  final String id;
  const PlaylistSelected(this.id);

  @override
  List<Object?> get props => [id, super.props];
}

class AddTracktoPlaylists extends AddtoPlaylistEvents {}

class AddtoPlaylistState extends Equatable {
  final ProfileModel? profile;
  final String? trackUri;
  final List<String> playlists;
  final bool loading;
  final bool success;

  const AddtoPlaylistState({
    required this.trackUri,
    required this.profile,
    required this.playlists,
    required this.loading,
    required this.success,
  });

  const AddtoPlaylistState.init()
      : trackUri = null,
        profile = null,
        playlists = const [],
        loading = false,
        success = false;

  AddtoPlaylistState copyWith({
    String? trackUri,
    ProfileModel? profile,
    List<String>? playlists,
    bool? loading,
    bool? success,
  }) {
    return AddtoPlaylistState(
      trackUri: trackUri ?? this.trackUri,
      profile: profile ?? this.profile,
      playlists: playlists ?? this.playlists,
      loading: loading ?? this.loading,
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props => [playlists, loading];
}

class AddtoPlaylistBloc extends Bloc<AddtoPlaylistEvents, AddtoPlaylistState> {
  AddtoPlaylistBloc() : super(const AddtoPlaylistState.init()) {
    on<PlaylistInitial>(_onInit);
    on<PlaylistSelected>(_onAdded);
    on<AddTracktoPlaylists>(_onAddTrigger);
  }

  final box = BoxServices.instance;
  final MusicGroupRepo _repo = getIt();

  void onItemAdded(String id) => add(PlaylistSelected(id));

  void _onInit(PlaylistInitial event, Emitter<AddtoPlaylistState> emit) {
    final json = BoxServices.instance.read(BoxKeys.profile);
    emit(state.copyWith(
      profile: ProfileModel.fromJson(json),
      trackUri: event.uri,
      playlists: [],
      loading: false,
      success: false,
    ));
  }

  Future<void> _onAddTrigger(
      AddTracktoPlaylists event, Emitter<AddtoPlaylistState> emit) async {
    emit(state.copyWith(loading: true));
    try {
      for (final playlist in state.playlists) {
        await _repo.addTracktoPlaylist(playlist, trackUri: [state.trackUri!]);
      }
      emit(state.copyWith(loading: false, success: true));
    } catch (_) {}
  }

  Future<void> _onAdded(PlaylistSelected event, Emitter<AddtoPlaylistState> emit) async {
    List<String> list = List<String>.from(state.playlists);
    if (list.contains(event.id)) {
      list.remove(event.id);
    } else {
      list.add(event.id);
    }
    emit(state.copyWith(playlists: list));
  }
}
