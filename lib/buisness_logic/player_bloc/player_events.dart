import 'package:ampify/data/data_models/common/tracks_model.dart';
import 'package:audio_service/audio_service.dart';
import 'package:equatable/equatable.dart';

class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlayerInitial extends PlayerEvent {}

class PlayerTrackLiked extends PlayerEvent {
  final String id;
  final bool? liked;
  const PlayerTrackLiked(this.id, {this.liked});

  @override
  List<Object?> get props => [id, liked, super.props];
}

class PlayerMediaStream extends PlayerEvent {
  final MediaItem mediaItem;
  const PlayerMediaStream(this.mediaItem);

  @override
  List<Object?> get props => [mediaItem, super.props];
}

class PlayerNextTrack extends PlayerEvent {}

class PlayerPreviousTrack extends PlayerEvent {}

class PlayerShuffleToggle extends PlayerEvent {}

class PlayerPlaybackStream extends PlayerEvent {
  final PlaybackState state;
  const PlayerPlaybackStream(this.state);

  @override
  List<Object?> get props => [state, super.props];
}

class PlayerQueueReordered extends PlayerEvent {
  final int previous;
  final int current;

  const PlayerQueueReordered({required this.previous, required this.current});

  @override
  List<Object?> get props => [previous, current, super.props];
}

class PlayerQueueAdded extends PlayerEvent {
  final Track track;

  const PlayerQueueAdded(this.track);

  @override
  List<Object?> get props => [track, super.props];
}

class PlayerQueueCleared extends PlayerEvent {}

class PlayerTrackEnded extends PlayerEvent {}

class MusicGroupPlayed extends PlayerEvent {
  final String? id;
  final List<Track> tracks;
  final bool? liked;

  const MusicGroupPlayed({required this.id, required this.tracks, this.liked});

  @override
  List<Object?> get props => [id, tracks, liked, super.props];
}

class PlayerTrackChanged extends PlayerEvent {
  final Track track;
  final bool? liked;

  const PlayerTrackChanged(this.track, {this.liked});

  @override
  List<Object?> get props => [track, liked, super.props];
}
