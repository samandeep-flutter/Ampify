import 'dart:async';
import 'package:ampify/data/data_models/common/album_model.dart';
import 'package:ampify/data/data_models/common/other_models.dart';
import 'package:ampify/data/data_models/common/tracks_model.dart';
import 'package:ampify/data/data_models/library_model.dart';
import 'package:ampify/data/repository/library_repo.dart';
import 'package:ampify/services/getit_instance.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/data_models/common/playlist_model.dart';
import '../../data/utils/utils.dart';

class CollectionEvent extends Equatable {
  const CollectionEvent();

  @override
  List<Object?> get props => [];
}

class CollectionInitial extends CollectionEvent {
  final String id;
  final LibItemType type;
  const CollectionInitial({required this.id, required this.type});

  @override
  List<Object?> get props => [id];
}

class CollectionTitleFade extends CollectionEvent {
  final double opacity;
  const CollectionTitleFade(this.opacity);

  @override
  List<Object?> get props => [opacity];
}

class CollectionState extends Equatable {
  final double titileOpacity;
  final String? image;
  final Color? color;
  final String? title;
  final CollectionDetails? details;
  final List<Track> tracks;
  final LibItemType? type;
  final bool isFav;
  final bool loading;

  const CollectionState({
    required this.image,
    required this.color,
    required this.title,
    required this.type,
    required this.details,
    required this.titileOpacity,
    required this.isFav,
    required this.tracks,
    required this.loading,
  });

  const CollectionState.init()
      : image = null,
        titileOpacity = 0,
        type = null,
        color = Colors.white,
        title = null,
        details = null,
        isFav = false,
        loading = false,
        tracks = const [];

  CollectionState copyWith({
    String? image,
    Color? color,
    String? title,
    CollectionDetails? details,
    List<Track>? tracks,
    LibItemType? type,
    bool? isFav,
    bool? loading,
    double? titileOpacity,
  }) {
    return CollectionState(
      image: image ?? this.image,
      color: color ?? this.color,
      title: title ?? this.title,
      isFav: isFav ?? this.isFav,
      details: details,
      type: type ?? this.type,
      titileOpacity: titileOpacity ?? this.titileOpacity,
      tracks: tracks ?? this.tracks,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [
        image,
        color,
        title,
        tracks,
        type,
        loading,
        details,
        titileOpacity,
        isFav
      ];
}

class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  CollectionBloc() : super(const CollectionState.init()) {
    on<CollectionInitial>(_onInit);
    on<CollectionTitleFade>(_titleFade);
  }
  final LibraryRepo _repo = getIt();
  final scrollController = ScrollController();

  _scrollListener() {
    if (!scrollController.hasClients) return;
    final appbarHeight = scrollController.position.extentInside * .4;
    if (scrollController.offset > (appbarHeight - kToolbarHeight)) {
      add(const CollectionTitleFade(1));
      return;
    }
    add(const CollectionTitleFade(0));
  }

  _onInit(CollectionInitial event, Emitter<CollectionState> emit) async {
    emit(state.copyWith(loading: true, titileOpacity: 0));
    scrollController.addListener(_scrollListener);
    final completer = Completer<bool>();

    if (event.type == LibItemType.album) {
      await _repo.albumDetails(event.id, onSuccess: (json) async {
        final album = Album.fromJson(json);
        final color = await Utils.getImageColor(album.image?.url);
        completer.complete(true);

        final details = CollectionDetails(
          owner: album.artists?.first.name,
          copyrights: album.copyrights,
          releaseDate: album.releaseDate,
        );
        emit(state.copyWith(
          loading: false,
          color: color,
          title: album.name,
          tracks: album.tracks,
          image: album.image?.url,
          type: LibItemType.album,
          details: details,
        ));
      });
      await completer.future;
      return;
    }

    await _repo.playlistDetails(event.id, onSuccess: (json) async {
      final playlist = Playlist.fromJson(json);
      final List<Track> tracks = [];
      for (PLitemDetails item in playlist.tracks ?? []) {
        if (item.track != null) tracks.add(item.track!);
      }
      final color = await Utils.getImageColor(playlist.image?.url);
      completer.complete(true);

      final details = CollectionDetails(
        owner: playlist.owner?.displayName,
        description: playlist.description,
      );
      emit(state.copyWith(
        image: playlist.image?.url,
        tracks: tracks,
        type: LibItemType.playlist,
        color: color,
        title: playlist.name,
        details: details,
        loading: false,
      ));
    });

    await completer.future;
  }

  _titleFade(CollectionTitleFade event, Emitter<CollectionState> emit) {
    emit(state.copyWith(titileOpacity: event.opacity));
  }

  void onFav() {}
}

class CollectionDetails extends Equatable {
  final String? owner;
  final String? description;
  final String? releaseDate;
  final List<Copyrights>? copyrights;

  const CollectionDetails(
      {this.owner, this.description, this.copyrights, this.releaseDate});

  @override
  List<Object?> get props => [owner, description, copyrights, releaseDate];
}
