import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlayerState extends Equatable {
  final TrackDetails track;
  final int? length;
  final bool shuffle;
  final bool liked;
  final MusicLoopMode loopMode;
  final bool? showPlayer;
  final MusicState? playerState;
  final List<TrackDetails> queue;
  final List<bool> queueSelected;

  const PlayerState({
    required this.track,
    required this.length,
    required this.liked,
    required this.shuffle,
    required this.loopMode,
    required this.showPlayer,
    required this.playerState,
    required this.queue,
    required this.queueSelected,
  });

  const PlayerState.init()
      : track = const TrackDetails.init(),
        showPlayer = false,
        shuffle = false,
        liked = false,
        length = 0,
        queue = const [],
        queueSelected = const [],
        loopMode = MusicLoopMode.off,
        playerState = MusicState.loading;

  PlayerState copyWith({
    TrackDetails? track,
    int? length,
    bool? liked,
    bool? shuffle,
    bool? showPlayer,
    List<TrackDetails>? queue,
    List<bool>? queueSelected,
    MusicLoopMode? loopMode,
    MusicState? playerState,
  }) {
    return PlayerState(
        track: track ?? this.track,
        length: length ?? this.length,
        liked: liked ?? this.liked,
        shuffle: shuffle ?? this.shuffle,
        loopMode: loopMode ?? this.loopMode,
        queue: queue ?? this.queue,
        queueSelected: queueSelected ?? this.queueSelected,
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
        queueSelected,
        showPlayer,
        playerState
      ];
}

class TrackDetails extends Equatable {
  final String? id;
  final String? uri;
  final String? image;
  final String? title;
  final String? subtitle;
  final Color? bgColor;

  const TrackDetails({
    required this.id,
    required this.uri,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.bgColor,
  });

  const TrackDetails.init()
      : id = null,
        uri = null,
        image = null,
        title = null,
        subtitle = null,
        bgColor = null;

  TrackDetails copyWith({
    String? id,
    String? uri,
    String? image,
    String? title,
    String? subtitle,
    Color? bgColor,
  }) {
    return TrackDetails(
      id: id ?? this.id,
      uri: uri ?? this.uri,
      image: image ?? this.image,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      bgColor: bgColor ?? this.bgColor,
    );
  }

  @override
  List<Object?> get props => [id, uri, image, title, subtitle, bgColor];
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
