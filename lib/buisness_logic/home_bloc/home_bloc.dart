import 'dart:async';
import 'package:ampify/data/data_models/common/album_model.dart';
import 'package:ampify/data/data_models/common/playlist_model.dart';
import 'package:ampify/data/data_models/common/tracks_model.dart';
import 'package:ampify/data/data_models/search_model.dart';
import 'package:ampify/data/repositories/home_repo.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeEvent {}

class HomeState extends Equatable {
  final bool albumLoading;
  final bool recentLoading;
  final List<Album> albums;
  final List<Track> recentlyPlayed;
  const HomeState({
    required this.albums,
    required this.recentlyPlayed,
    required this.albumLoading,
    required this.recentLoading,
  });

  const HomeState.init()
      : albums = const [],
        recentlyPlayed = const [],
        recentLoading = true,
        albumLoading = true;

  HomeState copyWith({
    bool? albumLoading,
    bool? recentLoading,
    List<Track>? recentlyPlayed,
    List<Album>? albums,
  }) {
    return HomeState(
      albums: albums ?? this.albums,
      recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
      albumLoading: albumLoading ?? this.albumLoading,
      recentLoading: recentLoading ?? this.recentLoading,
    );
  }

  @override
  List<Object?> get props =>
      [albums, albumLoading, recentlyPlayed, recentLoading];
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState.init()) {
    on<HomeInitial>(_onInIt);
  }

  final HomeRepo repo = getIt();

  Future<void> _onInIt(HomeInitial event, Emitter<HomeState> emit) async {
    final getReleases = Completer<bool>();
    final getRecentlyPlayed = Completer<bool>();
    repo.getNewReleases(
      onSuccess: (json) {
        final album = AlbumModel.fromJson(json['albums']);
        emit(state.copyWith(albums: album.items, albumLoading: false));
        getReleases.complete(true);
      },
      onError: (error) {
        logPrint(error, 'releases');
        emit(state.copyWith(albumLoading: false));
        getReleases.complete(false);
      },
    );

    repo.recentlyPlayed(
      onSuccess: (json) {
        final items = PLtracksItems.fromJson(json);
        List<Track> tracks = [];
        items.track?.forEach((e) {
          if (e.track == null) return;
          if (!tracks.contains(e.track)) tracks.add(e.track!);
        });
        emit(state.copyWith(recentlyPlayed: tracks, recentLoading: false));
        getRecentlyPlayed.complete(true);
      },
      onError: (error) {
        logPrint(error, 'recents');
        emit(state.copyWith(recentLoading: false));
        getRecentlyPlayed.complete(false);
      },
    );
    await getReleases.future;
    await getRecentlyPlayed.future;
    Future(MyNotifications.initialize);
  }
}
