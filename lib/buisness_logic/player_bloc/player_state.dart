import 'package:ampify/data/data_models/common/album_model.dart';
import 'package:ampify/data/data_models/common/artist_model.dart';
import 'package:ampify/data/data_models/common/tracks_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlayerState extends Equatable {
  final TrackDetails track;
  final int? length;
  final bool shuffle;
  final bool liked;
  final bool? showPlayer;
  final MusicLoopMode loopMode;
  final MusicState? playerState;
  final List<TrackDetails> queue;
  final bool durationLoading;

  const PlayerState({
    required this.track,
    required this.length,
    required this.liked,
    required this.shuffle,
    required this.loopMode,
    required this.showPlayer,
    required this.playerState,
    required this.queue,
    required this.durationLoading,
  });

  const PlayerState.init()
      : track = const TrackDetails.init(),
        showPlayer = false,
        shuffle = false,
        liked = false,
        length = 0,
        queue = const [],
        durationLoading = false,
        loopMode = MusicLoopMode.off,
        playerState = MusicState.loading;

  PlayerState copyWith({
    TrackDetails? track,
    int? length,
    bool? liked,
    bool? shuffle,
    bool? showPlayer,
    bool? durationLoading,
    List<TrackDetails>? queue,
    MusicLoopMode? loopMode,
    MusicState? playerState,
  }) {
    return PlayerState(
        track: track ?? this.track,
        length: length ?? this.length,
        liked: liked ?? this.liked,
        queue: queue ?? this.queue,
        shuffle: shuffle ?? this.shuffle,
        loopMode: loopMode ?? this.loopMode,
        durationLoading: durationLoading ?? this.durationLoading,
        showPlayer: showPlayer ?? this.showPlayer,
        playerState: playerState ?? this.playerState);
  }

  @override
  List<Object?> get props => [
        track,
        length,
        shuffle,
        loopMode,
        liked,
        queue,
        showPlayer,
        durationLoading,
        playerState
      ];
}

class TrackDetails extends Equatable {
  final String? id;
  final String? albumId;
  final String? image;
  final String? title;
  final String? subtitle;
  final Color? bgColor;

  const TrackDetails({
    required this.id,
    required this.albumId,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.bgColor,
  });

  const TrackDetails.init()
      : id = null,
        albumId = null,
        image = null,
        title = null,
        subtitle = null,
        bgColor = null;

  TrackDetails copyWith({
    String? id,
    String? uri,
    String? albumId,
    String? image,
    String? title,
    String? subtitle,
    Color? bgColor,
  }) {
    return TrackDetails(
      id: id ?? this.id,
      albumId: albumId ?? this.albumId,
      image: image ?? this.image,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      bgColor: bgColor ?? this.bgColor,
    );
  }

  Track toTrack() {
    return Track(
        id: id,
        name: title,
        album: Album(id: albumId, image: image),
        artists: subtitle?.split(',').map((e) {
          return Artist(name: e);
        }).toList());
  }

  @override
  List<Object?> get props => [id, image, title, subtitle, bgColor];
}

enum MusicState { playing, pause, loading }

enum MusicLoopMode {
  off(icon: CupertinoIcons.repeat),
  all(icon: CupertinoIcons.repeat, color: Colors.white),
  once(icon: CupertinoIcons.repeat_1, color: Colors.white);

  final Color? color;
  final IconData icon;

  const MusicLoopMode({required this.icon, this.color});
}
