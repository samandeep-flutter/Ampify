import 'package:ampify/data/utils/exports.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LikedSongsEvent extends Equatable {
  const LikedSongsEvent();

  @override
  List<Object?> get props => [];
}

class LikedSongsInitial extends LikedSongsEvent {
  final int? totalTracks;
  const LikedSongsInitial(this.totalTracks);

  @override
  List<Object?> get props => [totalTracks, super.props];
}

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
  final List<TrackDbModel> tracks;
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
    List<TrackDbModel>? tracks,
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

  final LibraryRepo _libRepo = getIt();
  String get uid => BoxServices.instance.uid!;

  final scrollController = ScrollController();
  bool libRefresh = false;

  bool _hasMore = false;
  DocumentSnapshot? _snapshotId;

  void onPlay(BuildContext context) {
    final player = context.read<PlayerBloc>();
    final _tracks = state.tracks.map((e) => e.item).toList();
    player.add(MusicGroupPlayed(id: UniqueIds.likedSongs, tracks: _tracks));
  }

  Future<void> _onInit(
      LikedSongsInitial event, Emitter<LikedSongsState> emit) async {
    add(LoadMoreTrigger());
    emit(state.copyWith(
        loading: true, titileOpacity: 0, totalTracks: event.totalTracks));
    scrollController.addListener(_titleFadeListener);
    scrollController.addListener(_loadMoreSongs);
    libRefresh = false;
  }

  void onDispose() {
    scrollController.removeListener(_titleFadeListener);
    scrollController.removeListener(_loadMoreSongs);
    _snapshotId = null;
  }

  void _loadMoreSongs() {
    if (!_hasMore) return;
    if (!scrollController.hasClients || state.moreLoading) return;
    if (state.tracks.length >= state.totalTracks) return;
    final pos = scrollController.position;
    if (pos.extentAfter < pos.maxScrollExtent * .3) {
      add(LoadMoreSongs());
    }
  }

  void songRemoved(String id) => add(SongRemoved(id));

  void _onRemoved(SongRemoved event, Emitter<LikedSongsState> emit) async {
    libRefresh = true;
    List<TrackDbModel> tracks = state.tracks;
    tracks.removeWhere((e) => e.trackId == event.id);
    emit(state.copyWith(tracks: tracks, totalTracks: state.totalTracks - 1));
    _libRepo.removefromLikedSongs(uid, event.id);
  }

  void _onLoadMore(LoadMoreSongs event, Emitter<LikedSongsState> emit) {
    emit(state.copyWith(moreLoading: true));
    add(LoadMoreTrigger());
  }

  Future<void> _onLoadTrigger(
      LoadMoreTrigger event, Emitter<LikedSongsState> emit) async {
    try {
      final _docs =
          await _libRepo.likedTracks(uid, limit: 100, snapshot: _snapshotId);
      final tracks = _docs.map((e) => TrackDbModel.fromJson(e.data())).toList();
      emit(state.copyWith(tracks: tracks, moreLoading: false, loading: false));
      if (_docs.lastOrNull != null) _snapshotId = _docs.lastOrNull;
      _hasMore = _docs.length == 100;
    } catch (e) {
      logPrint(e, 'liked-songs');
      emit(state.copyWith(moreLoading: false, loading: false));
    }
  }

  void _titleFadeListener() {
    if (!scrollController.hasClients) return;
    final appbarHeight = scrollController.position.extentInside * .15;
    if (scrollController.offset > (appbarHeight - kToolbarHeight)) {
      add(const LikedSongsTitleFade(1));
    } else {
      add(const LikedSongsTitleFade(0));
    }
  }

  void _titleFade(LikedSongsTitleFade event, Emitter<LikedSongsState> emit) {
    emit(state.copyWith(titileOpacity: event.opacity));
  }
}
