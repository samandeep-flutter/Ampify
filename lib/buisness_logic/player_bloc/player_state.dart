import 'dart:convert';
import 'package:ampify/data/data_models/common/tracks_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerState extends Equatable {
  final String? musicGroupId;
  final TrackDetails track;
  final Duration? length;
  final bool shuffle;
  final bool isLiked;
  final MusicLoopMode loopMode;
  final MusicState? playerState;
  final List<TrackDetails> queue;
  final List<Track> upNext;

  const PlayerState({
    required this.musicGroupId,
    required this.track,
    required this.length,
    required this.isLiked,
    required this.shuffle,
    required this.loopMode,
    required this.playerState,
    required this.queue,
    required this.upNext,
  });

  const PlayerState.init()
      : track = const TrackDetails.init(),
        musicGroupId = null,
        shuffle = false,
        isLiked = false,
        length = Duration.zero,
        upNext = const [],
        queue = const [],
        loopMode = MusicLoopMode.off,
        playerState = MusicState.hidden;

  PlayerState copyWith({
    String? musicGroupId,
    TrackDetails? track,
    Duration? length,
    bool? isLiked,
    bool? shuffle,
    List<TrackDetails>? queue,
    List<Track>? upNext,
    MusicLoopMode? loopMode,
    MusicState? playerState,
  }) {
    return PlayerState(
        musicGroupId: musicGroupId ?? this.musicGroupId,
        track: track ?? this.track,
        length: length ?? this.length,
        isLiked: isLiked ?? this.isLiked,
        queue: queue ?? this.queue,
        upNext: upNext ?? this.upNext,
        shuffle: shuffle ?? this.shuffle,
        loopMode: loopMode ?? this.loopMode,
        playerState: playerState ?? this.playerState);
  }

  @override
  List<Object?> get props => [
        musicGroupId,
        track,
        length,
        shuffle,
        loopMode,
        isLiked,
        queue,
        upNext,
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

enum MusicState { playing, pause, loading, hidden }

enum MusicLoopMode {
  off(CupertinoIcons.repeat),
  all(CupertinoIcons.repeat),
  once(CupertinoIcons.repeat_1);

  final IconData icon;

  const MusicLoopMode(this.icon);
}

extension HelperState on Change<PlayerState> {
  String get changesOnly => _changes(currentState, nextState);

  String _changes(PlayerState cr, PlayerState next) {
    final items = {
      if (cr.musicGroupId != next.musicGroupId) 'musicGroupId': cr.musicGroupId,
      if (cr.track != next.track) 'track': cr.track.title,
      if (cr.length != next.length) 'length': cr.length,
      if (cr.shuffle != next.shuffle) 'shuffle': cr.shuffle,
      if (cr.loopMode != next.loopMode) 'loopMode': cr.loopMode.name,
      if (cr.isLiked != next.isLiked) 'liked': cr.isLiked,
      if (cr.queue != next.queue) 'queue': cr.queue.length,
      if (cr.upNext != next.upNext) 'upNext': cr.upNext.length,
      if (cr.playerState != next.playerState)
        'playerState': cr.playerState?.name,
    };

    if (items.isEmpty) return 'No changes';
    return jsonEncode(items);
  }
}
