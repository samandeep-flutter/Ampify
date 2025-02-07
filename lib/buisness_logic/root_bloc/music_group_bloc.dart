import 'dart:async';
import 'package:ampify/data/data_models/common/album_model.dart';
import 'package:ampify/data/data_models/common/other_models.dart';
import 'package:ampify/data/data_models/common/tracks_model.dart';
import 'package:ampify/data/data_models/library_model.dart';
import 'package:ampify/data/data_models/profile_model.dart';
import 'package:ampify/data/repository/music_group_repo.dart';
import 'package:ampify/data/utils/app_constants.dart';
import 'package:ampify/services/box_services.dart';
import 'package:ampify/services/getit_instance.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/data_models/common/playlist_model.dart';
import '../../data/utils/utils.dart';

class MusicGroupEvent extends Equatable {
  const MusicGroupEvent();

  @override
  List<Object?> get props => [];
}

class MusicGroupInitial extends MusicGroupEvent {
  final String id;
  final LibItemType type;
  const MusicGroupInitial({required this.id, required this.type});

  @override
  List<Object?> get props => [id, type, super.props];
}

class PlaylistInitial extends MusicGroupEvent {
  final String id;
  const PlaylistInitial(this.id);

  @override
  List<Object?> get props => [id, super.props];
}

class MusicGroupFav extends MusicGroupEvent {
  final String id;
  final bool liked;
  final LibItemType type;
  const MusicGroupFav(this.id, {required this.type, required this.liked});

  @override
  List<Object?> get props => [id, type, liked, super.props];
}

class AlbumInitial extends MusicGroupEvent {
  final String id;
  final LibItemType type;
  const AlbumInitial({required this.id, required this.type});

  @override
  List<Object?> get props => [id, type, super.props];
}

class MusicGroupTitleFade extends MusicGroupEvent {
  final double opacity;
  const MusicGroupTitleFade(this.opacity);

  @override
  List<Object?> get props => [opacity];
}

class MusicGroupState extends Equatable {
  final String? id;
  final double titileOpacity;
  final String? image;
  final Color? color;
  final String? title;
  final MusicGroupDetails? details;
  final List<Track> tracks;
  final LibItemType? type;
  final bool? isFav;
  final bool loading;

  const MusicGroupState({
    required this.id,
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

  const MusicGroupState.init()
      : id = null,
        image = null,
        titileOpacity = 0,
        type = null,
        color = Colors.white,
        title = null,
        details = null,
        isFav = false,
        loading = false,
        tracks = const [];

  MusicGroupState copyWith({
    String? id,
    String? image,
    Color? color,
    String? title,
    MusicGroupDetails? details,
    List<Track>? tracks,
    LibItemType? type,
    bool? isFav,
    bool? loading,
    double? titileOpacity,
  }) {
    return MusicGroupState(
      id: id ?? this.id,
      image: image ?? this.image,
      color: color ?? this.color,
      title: title ?? this.title,
      isFav: isFav,
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

class MusicGroupBloc extends Bloc<MusicGroupEvent, MusicGroupState> {
  MusicGroupBloc() : super(const MusicGroupState.init()) {
    on<MusicGroupInitial>(_onInit);
    on<AlbumInitial>(_onAlbum);
    on<MusicGroupFav>(_onFav);
    on<PlaylistInitial>(_onPlaylist);
    on<MusicGroupTitleFade>(_titleFade);
  }
  final MusicGroupRepo _repo = getIt();
  final scrollController = ScrollController();
  ProfileModel? profile;
  bool libRefresh = false;

  _scrollListener() {
    if (!scrollController.hasClients) return;
    final appbarHeight = scrollController.position.extentInside * .4;
    if (scrollController.offset > (appbarHeight - kToolbarHeight)) {
      add(const MusicGroupTitleFade(1));
      return;
    }
    add(const MusicGroupTitleFade(0));
  }

  void onFav(String id, {required LibItemType type, required bool liked}) {
    add(MusicGroupFav(id, type: type, liked: liked));
  }

  _onInit(MusicGroupInitial event, Emitter<MusicGroupState> emit) async {
    try {
      final json = BoxServices.to.read(BoxKeys.profile);
      profile = ProfileModel.fromJson(json);
    } catch (_) {}
    emit(state.copyWith(id: event.id, loading: true, titileOpacity: 0));
    scrollController.addListener(_scrollListener);
    libRefresh = false;

    if (event.type == LibItemType.playlist) {
      add(PlaylistInitial(event.id));
      return;
    }
    add(AlbumInitial(id: event.id, type: event.type));
  }

  _onPlaylist(PlaylistInitial event, Emitter<MusicGroupState> emit) async {
    final completer = Completer<bool>();
    _repo.playlistDetails(event.id, onSuccess: (json) async {
      final playlist = Playlist.fromJson(json);

      final List<Track> tracks = [];
      for (PLitemDetails item in playlist.tracks ?? []) {
        if (item.track != null && (item.track!.name?.isNotEmpty ?? false)) {
          tracks.add(item.track!);
        }
      }
      final color = await Utils.getImageColor(playlist.image);
      final isFav = await _repo.isFavPlaylist(event.id);
      String? release;
      try {
        release = playlist.tracks?.first.addedAt;
      } catch (_) {}
      final details = MusicGroupDetails(
          owner: playlist.owner,
          public: playlist.public,
          description: playlist.description,
          releaseDate: DateTime.tryParse(release ?? ''));
      completer.complete(true);
      emit(state.copyWith(
        image: playlist.image,
        tracks: tracks,
        type: LibItemType.playlist,
        color: color ?? Colors.grey[700],
        isFav: isFav,
        title: playlist.name,
        details: details,
        loading: false,
      ));
    });

    await completer.future;
  }

  _onAlbum(AlbumInitial event, Emitter<MusicGroupState> emit) async {
    final completer = Completer<bool>();

    _repo.albumDetails(event.id, onSuccess: (json) async {
      final album = Album.fromJson(json);
      final color = await Utils.getImageColor(album.image);
      final isFav = await _repo.isFavAlbum(event.id);
      final details = MusicGroupDetails(
          copyrights: album.copyrights,
          releaseDate: DateTime.tryParse(album.releaseDate ?? ''),
          owner: OwnerModel(
            name: album.artists?.first.name,
            id: album.artists?.first.id,
          ));
      completer.complete(true);

      emit(state.copyWith(
        loading: false,
        color: color,
        title: album.name,
        tracks: album.tracks,
        isFav: isFav,
        image: album.image,
        type: event.type,
        details: details,
      ));
    });
    await completer.future;
  }

  _onFav(MusicGroupFav event, Emitter<MusicGroupState> emit) async {
    libRefresh = true;
    if (event.liked) {
      try {
        emit(state.copyWith(isFav: false));
        if (event.type == LibItemType.playlist) {
          final result = await _repo.removeSavedPlaylist(event.id);
          if (!result) throw Exception();
          return;
        }
        final result = await _repo.removeSavedAlbum(event.id);
        if (!result) throw Exception();
      } catch (_) {
        emit(state.copyWith(isFav: true));
      }
      return;
    }

    try {
      emit(state.copyWith(isFav: true));
      if (event.type == LibItemType.playlist) {
        final result = await _repo.savePlaylist(event.id);
        if (!result) throw Exception();
        return;
      }
      final result = await _repo.saveAlbum(event.id);
      if (!result) throw Exception();
    } catch (_) {
      emit(state.copyWith(isFav: false));
    }
  }

  _titleFade(MusicGroupTitleFade event, Emitter<MusicGroupState> emit) {
    emit(state.copyWith(titileOpacity: event.opacity));
  }
}

class MusicGroupDetails extends Equatable {
  final OwnerModel? owner;
  final bool? public;
  final String? description;
  final DateTime? releaseDate;
  final List<Copyrights>? copyrights;

  const MusicGroupDetails({
    this.owner,
    this.description,
    this.copyrights,
    this.releaseDate,
    this.public,
  });

  @override
  List<Object?> get props =>
      [owner, public, description, copyrights, releaseDate];
}
