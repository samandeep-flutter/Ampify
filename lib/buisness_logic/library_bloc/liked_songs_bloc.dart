import 'package:ampify/data/data_models/common/tracks_model.dart';
import 'package:ampify/data/repositories/library_repo.dart';
import 'package:ampify/data/utils/app_constants.dart';
import 'package:ampify/services/getit_instance.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/transformers.dart';
import '../../data/data_models/common/playlist_model.dart';
import '../player_bloc/player_bloc.dart';
import '../player_bloc/player_events.dart';

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

EventTransformer<T> _debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}

class LikedSongsBloc extends Bloc<LikedSongsEvent, LikedSongsState> {
  LikedSongsBloc() : super(const LikedSongsState.init()) {
    on<LikedSongsInitial>(_onInit);
    on<SongRemoved>(_onRemoved);
    on<LoadMoreSongs>(_onLoadMore);
    on<LikedSongsTitleFade>(_titleFade);
    on<LoadMoreTrigger>(_onLoadTrigger, transformer: _debounce(duration));
  }

  final LibraryRepo _repo = getIt();
  final scrollController = ScrollController();

  final duration = const Duration(milliseconds: 200);
  bool libRefresh = false;

  void onPlay(BuildContext context) {
    final player = context.read<PlayerBloc>();
    player.add(MusicGroupPlayed(
      id: UniqueIds.likedSongs,
      tracks: state.tracks,
      liked: true,
    ));
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

    await _repo.getLikedSongs(
      onSuccess: (json) {
        final items = PLtracksItems.fromJson(json);
        final List<Track> tracks = [];
        for (PLitemDetails item in items.track ?? []) {
          if (item.track != null) tracks.add(item.track!);
        }
        emit(state.copyWith(
            tracks: tracks, loading: false, totalTracks: items.total));
      },
    );
  }

  void _onLoadMore(LoadMoreSongs event, Emitter<LikedSongsState> emit) {
    emit(state.copyWith(moreLoading: true));
    add(LoadMoreTrigger());
  }

  Future<void> _onLoadTrigger(
      LoadMoreTrigger event, Emitter<LikedSongsState> emit) async {
    await _repo.getLikedSongs(
      offset: state.tracks.length,
      onSuccess: (json) {
        final items = PLtracksItems.fromJson(json);
        final List<Track> tracks = state.tracks;
        for (PLitemDetails item in items.track ?? []) {
          if (item.track != null) tracks.add(item.track!);
        }
        emit(state.copyWith(tracks: tracks, moreLoading: false));
      },
    );
  }

  void _titleFade(LikedSongsTitleFade event, Emitter<LikedSongsState> emit) {
    emit(state.copyWith(titileOpacity: event.opacity));
  }
}
