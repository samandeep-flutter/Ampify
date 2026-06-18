import 'package:ampify/data/utils/exports.dart';

class LikedSongsEvent extends Equatable {
  const LikedSongsEvent();

  @override
  List<Object?> get props => [];
}

class LikedSongsInitial extends LikedSongsEvent {}

class SongRemoved extends LikedSongsEvent {
  final String id;
  const SongRemoved(this.id);

  @override
  List<Object?> get props => [id, super.props];
}

class LoadMoreSongs extends LikedSongsEvent {}

class LoadMoreTrigger extends LikedSongsEvent {}

class LikedSongsTitleFade extends LikedSongsEvent {
  final double opacity;
  const LikedSongsTitleFade(this.opacity);

  @override
  List<Object?> get props => [opacity];
}

class LikedSongsState extends Equatable {
  final double titileOpacity;
  final List<Track> tracks;
  final bool loading;
  final int totalTracks;
  final bool moreLoading;

  const LikedSongsState({
    required this.titileOpacity,
    required this.tracks,
    required this.loading,
    required this.totalTracks,
    required this.moreLoading,
  });

  const LikedSongsState.init()
      : titileOpacity = 0,
        loading = false,
        totalTracks = 0,
        moreLoading = false,
        tracks = const [];

  LikedSongsState copyWith({
    List<Track>? tracks,
    int? totalTracks,
    bool? loading,
    bool? moreLoading,
    double? titileOpacity,
  }) {
    return LikedSongsState(
      titileOpacity: titileOpacity ?? this.titileOpacity,
      moreLoading: moreLoading ?? this.moreLoading,
      totalTracks: totalTracks ?? this.totalTracks,
      tracks: tracks ?? this.tracks,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props =>
      [tracks, totalTracks, loading, moreLoading, titileOpacity];
}

class LikedSongsBloc extends Bloc<LikedSongsEvent, LikedSongsState> {
  LikedSongsBloc() : super(const LikedSongsState.init()) {
    on<LikedSongsInitial>(_onInit);
    on<SongRemoved>(_onRemoved);
    on<LoadMoreSongs>(_onLoadMore);
    on<LikedSongsTitleFade>(_titleFade);
    on<LoadMoreTrigger>(_onLoadTrigger,
        transformer: Utils.debounce(Durations.short4));
  }
  String get uid => BoxServices.instance.uid!;

  final scrollController = ScrollController();
  bool libRefresh = false;

  void onPlay(BuildContext context) {
    final player = context.read<PlayerBloc>();
    player
        .add(MusicGroupPlayed(id: UniqueIds.likedSongs, tracks: state.tracks));
  }

  void _titleFadeListener() {
    if (!scrollController.hasClients) return;
    final appbarHeight = scrollController.position.extentInside * .15;
    if (scrollController.offset > (appbarHeight - kToolbarHeight)) {
      add(const LikedSongsTitleFade(1));
      return;
    }
    add(const LikedSongsTitleFade(0));
  }

  void _loadMoreSongs() {
    if (!scrollController.hasClients || state.moreLoading) return;
    if (state.tracks.length >= state.totalTracks) return;
    final pos = scrollController.position;
    if (pos.extentAfter < pos.maxScrollExtent * .3) {
      add(LoadMoreSongs());
    }
  }

  void songRemoved(String id) => add(SongRemoved(id));

  void _onRemoved(SongRemoved event, Emitter<LikedSongsState> emit) async {
    // TODO: implement remove song as well
    libRefresh = true;
    List<Track> tracks = state.tracks;
    tracks.removeWhere((e) => e.id == event.id);
    emit(state.copyWith(tracks: tracks, totalTracks: state.totalTracks - 1));
  }

  Future<void> _onInit(
      LikedSongsInitial event, Emitter<LikedSongsState> emit) async {
    emit(state.copyWith(loading: true, titileOpacity: 0));
    scrollController.addListener(_titleFadeListener);
    scrollController.addListener(_loadMoreSongs);
    libRefresh = false;
    final _likedRepo = AppConstants.likedCollection(uid);

    try {
      final query = await _likedRepo
          .limit(100)
          .orderBy('added_at', descending: true)
          .get();
      final tracks = query.docs.map((e) => Track.fromJson(e.data())).toList();
      emit(state.copyWith(tracks: tracks, loading: false));
    } catch (e) {
      logPrint(e, 'liked-songs');
      emit(state.copyWith(loading: false));
    }
  }

  void _onLoadMore(LoadMoreSongs event, Emitter<LikedSongsState> emit) {
    emit(state.copyWith(moreLoading: true));
    add(LoadMoreTrigger());
  }

  Future<void> _onLoadTrigger(
      LoadMoreTrigger event, Emitter<LikedSongsState> emit) async {
    // final _likedRepo = AppConstants.likedCollection(uid);

    try {
      // TODO: refactor load more tracks
      // final query = await _likedRepo
      //     .limit(100)
      //     .orderBy('added_at', descending: true)
      //     .get();
      // final tracks = query.docs.map((e) => Track.fromJson(e.data())).toList();
      // emit(state.copyWith(tracks: tracks, moreLoading: false));
    } catch (e) {
      logPrint(e, 'liked-songs');
      emit(state.copyWith(moreLoading: false));
    }
  }

  void _titleFade(LikedSongsTitleFade event, Emitter<LikedSongsState> emit) {
    emit(state.copyWith(titileOpacity: event.opacity));
  }
}
