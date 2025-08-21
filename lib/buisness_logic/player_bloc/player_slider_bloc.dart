import 'package:ampify/data/utils/exports.dart';
import 'package:audio_service/audio_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerSliderEvents extends Equatable {
  const PlayerSliderEvents();

  @override
  List<Object?> get props => [];
}

class PlayerSliderChange extends PlayerSliderEvents {
  final Duration current;
  const PlayerSliderChange(this.current);

  @override
  List<Object?> get props => [current, super.props];
}

class PlayerSliderReset extends PlayerSliderEvents {}

class PlayerSliderState extends Equatable {
  final Duration current;
  const PlayerSliderState(this.current);

  const PlayerSliderState.init() : current = Duration.zero;

  PlayerSliderState copyWith([Duration? current]) {
    return PlayerSliderState(current ?? this.current);
  }

  Duration get animate {
    return current.isZero ? Duration.zero : Durations.extralong4;
  }

  @override
  List<Object?> get props => [current];
}

class PlayerSliderBloc extends Bloc<PlayerSliderEvents, PlayerSliderState> {
  PlayerSliderBloc() : super(const PlayerSliderState.init()) {
    on<PlayerSliderChange>(_onSliderChange);
    on<PlayerSliderReset>(_onSliderReset,
        transformer: Utils.debounce(Durations.long2));

    _audioHandler.customEvent.listen((duration) {
      if (duration is! Duration) return;
      if (!state.current.isZero && state.current == duration) {
        add(PlayerSliderReset());
      } else {
        add(PlayerSliderChange(duration.ceil()));
      }
    });
  }

  @override
  void onEvent(PlayerSliderEvents event) {
    dprint(event.runtimeType.toString());
    super.onEvent(event);
  }

  final AudioHandler _audioHandler = getIt();

  void _onSliderChange(
      PlayerSliderChange event, Emitter<PlayerSliderState> emit) {
    if (event.current == state.current) return;
    emit(state.copyWith(event.current));
  }

  void _onSliderReset(
      PlayerSliderReset event, Emitter<PlayerSliderState> emit) {
    emit(const PlayerSliderState.init());
  }
}
