import 'package:ampify/data/data_models/common/tracks_model.dart';
import 'package:equatable/equatable.dart';

class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlayerInitial extends PlayerEvent {}

class PlayerStatusChanged extends PlayerEvent {}

class PlayerTrackLiked extends PlayerEvent {
  final String id;
  final bool? liked;
  const PlayerTrackLiked(this.id, {this.liked});

  @override
  List<Object?> get props => [id, liked, super.props];
}

class PlayerShuffleToggle extends PlayerEvent {}

class PlayerRepeatToggle extends PlayerEvent {}

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

class PlayerTrackChanged extends PlayerEvent {
  final Track track;
  final bool? liked;

  const PlayerTrackChanged(this.track, {this.liked});

  @override
  List<Object?> get props => [track, liked, super.props];
}
