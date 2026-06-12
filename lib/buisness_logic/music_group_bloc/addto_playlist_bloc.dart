import 'package:ampify/data/utils/exports.dart';

class AddtoPlaylistEvents extends Equatable {
  const AddtoPlaylistEvents();

  @override
  List<Object?> get props => [];
}

class PlaylistInitial extends AddtoPlaylistEvents {
  final String id;
  const PlaylistInitial(this.id);

  @override
  List<Object?> get props => [id, super.props];
}

class PlaylistSelected extends AddtoPlaylistEvents {
  final String id;
  const PlaylistSelected(this.id);

  @override
  List<Object?> get props => [id, super.props];
}

class AddTracktoPlaylists extends AddtoPlaylistEvents {}

class AddtoPlaylistState extends Equatable {
  final String? trackId;
  final List<String> playlists;
  final bool loading;
  final bool success;

  const AddtoPlaylistState({
    required this.trackId,
    required this.playlists,
    required this.loading,
    required this.success,
  });

  const AddtoPlaylistState.init()
      : trackId = null,
        playlists = const [],
        loading = false,
        success = false;

  AddtoPlaylistState copyWith({
    String? trackId,
    List<String>? playlists,
    bool? loading,
    bool? success,
  }) {
    return AddtoPlaylistState(
      trackId: trackId ?? this.trackId,
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

  void onItemAdded(String id) => add(PlaylistSelected(id));

  void _onInit(PlaylistInitial event, Emitter<AddtoPlaylistState> emit) {
    emit(AddtoPlaylistState.init().copyWith(trackId: event.id));
  }

  Future<void> _onAddTrigger(
      AddTracktoPlaylists event, Emitter<AddtoPlaylistState> emit) async {
    emit(state.copyWith(loading: true));
    try {
      // TODO: implement add tacks to playlist
      // for (final playlist in state.playlists) {
      // await _repo.addTracktoPlaylist(playlist, trackUri: [state.trackId!]);
      // }
      emit(state.copyWith(loading: false, success: true));
    } catch (_) {}
  }

  Future<void> _onAdded(
      PlaylistSelected event, Emitter<AddtoPlaylistState> emit) async {
    List<String> list = List<String>.from(state.playlists);
    if (list.contains(event.id)) {
      list.remove(event.id);
    } else {
      list.add(event.id);
    }
    emit(state.copyWith(playlists: list));
  }
}
