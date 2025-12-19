import 'package:ampify/buisness_logic/player_bloc/player_bloc.dart';
import 'package:ampify/buisness_logic/player_bloc/player_events.dart';
import 'package:ampify/data/repositories/music_repo.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:dart_ytmusic_api/types.dart';
import '../../data/repositories/search_repo.dart';

class TrackRadioEvents extends Equatable {
  const TrackRadioEvents();

  @override
  List<Object?> get props => [];
}

class TrackRadioInitial extends TrackRadioEvents {
  final String id;
  final Track? track;
  const TrackRadioInitial(this.id, {required this.track});

  @override
  List<Object?> get props => [id, track, ...super.props];
}

class TrackRadioAdapter extends TrackRadioEvents {
  final List<UpNextsDetails> tracks;
  const TrackRadioAdapter({required this.tracks});
}

class RadioTitleFade extends TrackRadioEvents {
  final double opacity;
  const RadioTitleFade(this.opacity);

  @override
  List<Object?> get props => [opacity];
}

class TrackRadioState extends Equatable {
  final String? id;
  final double titileOpacity;
  final String? title;
  final List<Track> tracks;
  final bool loading;
  final bool error;

  const TrackRadioState({
    required this.id,
    required this.title,
    required this.titileOpacity,
    required this.tracks,
    required this.loading,
    required this.error,
  });

  const TrackRadioState.init()
      : id = null,
        title = null,
        titileOpacity = 0,
        loading = false,
        error = false,
        tracks = const [];

  TrackRadioState copyWith({
    String? id,
    String? title,
    double? titileOpacity,
    List<Track>? tracks,
    bool? loading,
    bool? error,
  }) {
    return TrackRadioState(
      id: id ?? this.id,
      title: title ?? this.title,
      titileOpacity: titileOpacity ?? this.titileOpacity,
      tracks: tracks ?? this.tracks,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [id, title, titileOpacity, tracks, loading, error];
}

class TrackRadioBloc extends Bloc<TrackRadioEvents, TrackRadioState> {
  TrackRadioBloc() : super(const TrackRadioState.init()) {
    on<TrackRadioInitial>(_onInit);
    on<RadioTitleFade>(_titleFade);
    on<TrackRadioAdapter>(_radioAdapter);
  }

  final MusicRepo _musicRepo = getIt();
  final SearchRepo _searchRepo = getIt();

  final scrollController = ScrollController();

  void onPlay(BuildContext context) {
    final player = context.read<PlayerBloc>();
    if (player.state.musicGroupId == state.id) return player.onPlayPause();
    player.add(MusicGroupPlayed(id: state.id, tracks: state.tracks));
  }

  void _scrollListener() {
    if (!scrollController.hasClients) return;
    final scroll = Utils.titleScroll(scrollController, .1);
    if (scroll != state.titileOpacity) {
      add(RadioTitleFade(scroll));
    }
  }

  void _onInit(TrackRadioInitial event, Emitter<TrackRadioState> emit) async {
    scrollController.addListener(_scrollListener);
    final id = UniqueIds.radioID(event.id);
    emit(state.copyWith(id: id, loading: true));
    try {
      if (event.track == null) throw Exception('track is null');
      emit(state.copyWith(title: event.track!.name));
      final _list = await _musicRepo.getRecomendations(event.track!);
      add(TrackRadioAdapter(tracks: _list ?? []));
    } catch (e) {
      emit(state.copyWith(loading: false, error: true));
      logPrint(e, 'radio-init');
    }
  }

  void _radioAdapter(
      TrackRadioAdapter event, Emitter<TrackRadioState> emit) async {
    try {
      final List<Track> tracks = [];
      if (event.tracks.isEmpty) throw FormatException();
      for (final item in event.tracks) {
        final duration = Duration(seconds: item.duration);
        final details = SongYtDetails(item.videoId, duration: duration);
        final query = '${item.title} ${item.artists.name}'.toLowerCase();
        await _searchRepo.searchTrack(query, onSuccess: (json) {
          final search = SearchModel.fromJson(json);
          final _item = search.tracks?.items?.firstElement;
          if (_item != null) tracks.add(_item.copyWith(details));
        });
      }
      emit(state.copyWith(tracks: tracks));
    } on FormatException {
      emit(state.copyWith(tracks: []));
    } catch (e) {
      logPrint(e, 'radio-adapter');
    } finally {
      emit(state.copyWith(loading: false));
    }
  }

  void _titleFade(RadioTitleFade event, Emitter<TrackRadioState> emit) {
    emit(state.copyWith(titileOpacity: event.opacity));
  }
}
