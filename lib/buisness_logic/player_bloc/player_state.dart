import 'dart:convert';
import 'package:ampify/data/data_models/common/tracks_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerState extends Equatable {
  final String? musicGroupId;
  final TrackDetails track;
  final bool shuffle;
  final bool isLiked;
  final MusicLoopMode loopMode;
  final MusicState? playerState;
  final List<TrackDetails> queue;
  final List<Track> upNext;

  const PlayerState({
    required this.musicGroupId,
    required this.track,
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
        upNext = const [],
        queue = const [],
        loopMode = MusicLoopMode.off,
        playerState = MusicState.hidden;

  PlayerState copyWith({
    String? musicGroupId,
    TrackDetails? track,
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
      isLiked: isLiked ?? this.isLiked,
      queue: queue ?? this.queue,
      upNext: upNext ?? this.upNext,
      shuffle: shuffle ?? this.shuffle,
      loopMode: loopMode ?? this.loopMode,
      playerState: playerState ?? this.playerState,
    );
  }

  PlayerState withTrack(TrackDetails track) {
    return copyWith(
        musicGroupId: '', track: track, playerState: MusicState.loading);
  }

  PlayerState withMusicGroup(String id,
      {required List<Track> tracks, bool? isLiked}) {
    return copyWith(
      musicGroupId: id,
      isLiked: isLiked,
      playerState: MusicState.loading,
      track: tracks.first.asTrackDetails,
      upNext: tracks.skip(1).toList(),
      queue: [],
    );
  }

  bool get isEmptyOrFinished =>
      queue.isEmpty && upNext.isEmpty && loopMode == MusicLoopMode.off;

  @override
  List<Object?> get props => [
        musicGroupId,
        track,
        shuffle,
        loopMode,
        isLiked,
        queue,
        upNext,
        playerState,
      ];

  @override
  String toString() {
    final items = {
      'musicGroupId': musicGroupId,
      'track': '${track.title} [${track.videoId}]',
      'shuffle': shuffle,
      'loopMode': loopMode.name,
      'liked': isLiked,
      'queue': queue.length,
      'upNext': upNext.length,
      'playerState': playerState?.name,
    };
    return jsonEncode(items);
  }
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

  String _changes(PlayerState pr, PlayerState cr) {
    final items = {
      if (pr.musicGroupId != cr.musicGroupId) 'musicGroupId': cr.musicGroupId,
      if (pr.track != cr.track)
        'track': '${cr.track.title} [${cr.track.videoId}]',
      if (pr.shuffle != cr.shuffle) 'shuffle': cr.shuffle,
      if (pr.loopMode != cr.loopMode) 'loopMode': cr.loopMode.name,
      if (pr.isLiked != cr.isLiked) 'liked': cr.isLiked,
      if (pr.queue != cr.queue) 'queue': cr.queue.length,
      if (pr.upNext != cr.upNext) 'upNext': cr.upNext.length,
      if (pr.playerState != cr.playerState) 'playerState': cr.playerState?.name,
    };
    if (items.isEmpty) return 'No changes';
    return jsonEncode(items);
  }
}
