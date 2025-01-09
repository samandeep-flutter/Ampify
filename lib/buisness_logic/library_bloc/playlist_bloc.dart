import 'dart:async';
import 'package:ampify/data/data_models/common/tracks_model.dart';
import 'package:ampify/data/repository/library_repo.dart';
import 'package:ampify/data/utils/app_constants.dart';
import 'package:ampify/services/getit_instance.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/data_models/common/playlist_model.dart';
import '../../data/utils/utils.dart';

class PlaylistEvent extends Equatable {
  const PlaylistEvent();

  @override
  List<Object?> get props => [];
}

class PlaylistInitial extends PlaylistEvent {
  final String id;
  const PlaylistInitial(this.id);

  @override
  List<Object?> get props => [id];
}

class PlaylistTitleFade extends PlaylistEvent {
  final double opacity;
  const PlaylistTitleFade(this.opacity);

  @override
  List<Object?> get props => [opacity];
}

class PlaylistState extends Equatable {
  final double titileOpacity;
  final String? image;
  final Color? color;
  final String? title;
  final String? description;
  final String? owner;
  final List<Track> tracks;
  final bool isFav;
  final bool loading;

  const PlaylistState({
    required this.titileOpacity,
    required this.image,
    required this.color,
    required this.title,
    required this.owner,
    required this.description,
    required this.isFav,
    required this.tracks,
    required this.loading,
  });

  const PlaylistState.init()
      : image = null,
        titileOpacity = 0,
        color = Colors.white,
        title = null,
        owner = null,
        description = null,
        isFav = false,
        loading = false,
        tracks = const [];

  PlaylistState copyWith({
    String? image,
    Color? color,
    String? title,
    String? description,
    String? owner,
    List<Track>? tracks,
    bool? isFav,
    bool? loading,
    double? titileOpacity,
  }) {
    return PlaylistState(
      image: image ?? this.image,
      color: color ?? this.color,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      isFav: isFav ?? this.isFav,
      titileOpacity: titileOpacity ?? this.titileOpacity,
      description: description ?? this.description,
      tracks: tracks ?? this.tracks,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [
        image,
        color,
        title,
        description,
        tracks,
        loading,
        titileOpacity,
        owner,
        isFav
      ];
}

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  PlaylistBloc() : super(const PlaylistState.init()) {
    on<PlaylistInitial>(_onInit);
    on<PlaylistTitleFade>(_titleFade);
  }
  final LibraryRepo _repo = getIt();
  final scrollController = ScrollController();

  _scrollListener() {
    if (!scrollController.hasClients) return;
    final appbarHeight = scrollController.position.extentInside * .4;
    if (scrollController.offset > (appbarHeight - kToolbarHeight)) {
      add(const PlaylistTitleFade(1));
      return;
    }
    add(const PlaylistTitleFade(0));
  }

  _onInit(PlaylistInitial event, Emitter<PlaylistState> emit) async {
    emit(state.copyWith(loading: true, titileOpacity: 0));
    scrollController.addListener(_scrollListener);
    final completer = Completer<bool>();
    await _repo.playlistDetails(
      event.id,
      onSuccess: (json) async {
        final playlist = Playlist.fromJson(json);
        final List<Track> tracks = [];
        for (TrackItems item in playlist.tracks ?? []) {
          if (item.track != null) tracks.add(item.track!);
        }
        final color = await Utils.getImageColor(playlist.image?.url);
        completer.complete(true);
        emit(state.copyWith(
          image: playlist.image?.url,
          tracks: tracks,
          color: color,
          title: playlist.name,
          owner: playlist.owner?.displayName,
          description: playlist.description,
          loading: false,
        ));
      },
      onError: (json) => logPrint('playlist details: $json'),
    );

    await completer.future;
  }

  _titleFade(PlaylistTitleFade event, Emitter<PlaylistState> emit) {
    emit(state.copyWith(titileOpacity: event.opacity));
  }

  void onFav() {}
}
