import 'dart:convert';
import 'package:ampify/data/data_models/common/tracks_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class PlayerState extends Equatable {
  final String? musicGroupId;
  final TrackDetails track;
  final int? length;
  final bool shuffle;
  final bool liked;
  final bool? showPlayer;
  final MusicLoopMode loopMode;
  final MusicState? playerState;
  final List<TrackDetails> queue;
  final List<TrackDetails> upNext;
  final bool durationLoading;

  const PlayerState({
    required this.musicGroupId,
    required this.track,
    required this.length,
    required this.liked,
    required this.shuffle,
    required this.loopMode,
    required this.showPlayer,
    required this.playerState,
    required this.queue,
    required this.upNext,
    required this.durationLoading,
  });

  const PlayerState.init()
      : track = const TrackDetails.init(),
        musicGroupId = null,
        showPlayer = false,
        shuffle = false,
        liked = false,
        length = 0,
        upNext = const [],
        queue = const [],
        durationLoading = false,
        loopMode = MusicLoopMode.off,
        playerState = MusicState.loading;

  PlayerState copyWith({
    String? musicGroupId,
    TrackDetails? track,
    int? length,
    bool? liked,
    bool? shuffle,
    bool? showPlayer,
    bool? durationLoading,
    List<TrackDetails>? queue,
    List<TrackDetails>? upNext,
    MusicLoopMode? loopMode,
    MusicState? playerState,
  }) {
    return PlayerState(
        musicGroupId: musicGroupId ?? this.musicGroupId,
        track: track ?? this.track,
        length: length ?? this.length,
        liked: liked ?? this.liked,
        queue: queue ?? this.queue,
        upNext: upNext ?? this.upNext,
        shuffle: shuffle ?? this.shuffle,
        loopMode: loopMode ?? this.loopMode,
        durationLoading: durationLoading ?? this.durationLoading,
        showPlayer: showPlayer ?? this.showPlayer,
        playerState: playerState ?? this.playerState);
  }

  @override
  List<Object?> get props => [
        musicGroupId,
        track,
        length,
        shuffle,
        loopMode,
        liked,
        queue,
        upNext,
        showPlayer,
        durationLoading,
        playerState
      ];

  // @override
  // String toString() {
  //   return '''{
  //     'musicGroupId': $musicGroupId,
  //     'track': ${track.title} ${track.id},
  //     'length': $length,
  //     'shuffle': $shuffle,
  //     'loopMode': ${loopMode.name},
  //     'liked': $liked,
  //     'queue': ${queue.length},
  //     'upNext': ${upNext.length},
  //     'playerState': ${playerState?.name},
  //   }''';
  // }
}

enum MusicState { playing, pause, loading }

enum MusicLoopMode {
  off(CupertinoIcons.repeat),
  all(CupertinoIcons.repeat),
  once(CupertinoIcons.repeat_1);

  final IconData icon;

  const MusicLoopMode(this.icon);
}
