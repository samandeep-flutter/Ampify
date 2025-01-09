import 'package:ampify/buisness_logic/player_bloc/player_state.dart';
import 'package:ampify/data/data_models/common/tracks_model.dart';
import 'package:equatable/equatable.dart';

class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlayerStatusChanged extends PlayerEvent {}

class PlayerTrackLiked extends PlayerEvent {}

class PlayerShuffleToggle extends PlayerEvent {}

class PlayerRepeatToggle extends PlayerEvent {}

class PlayerTrackEnded extends PlayerEvent {}

class PlayerInitial extends PlayerEvent {}

class PlayerQueueAdded extends PlayerEvent {
  final TrackDetails track;

  const PlayerQueueAdded(this.track);

  @override
  List<Object?> get props => [track, super.props];
}

class PlayerTrackChanged extends PlayerEvent {
  final Track track;

  const PlayerTrackChanged(this.track);

  @override
  List<Object?> get props => [track, super.props];
}
