import 'package:ampify/data/utils/exports.dart';

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
  }
  final YtMusicRepo _repo = getIt();
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
      emit(state.copyWith(title: event.track!.title));
      final tracks = await _repo.getUpNexts(event.track!.id);
      emit(state.copyWith(tracks: tracks));
    } catch (e) {
      emit(state.copyWith(error: true));
      logPrint(e, 'radio-init');
    } finally {
      emit(state.copyWith(loading: false));
    }
  }

  void _titleFade(RadioTitleFade event, Emitter<TrackRadioState> emit) {
    emit(state.copyWith(titileOpacity: event.opacity));
  }
}
