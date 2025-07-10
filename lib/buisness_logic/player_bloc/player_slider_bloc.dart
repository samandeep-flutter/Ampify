import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerSliderEvents extends Equatable {
  const PlayerSliderEvents();

  @override
  List<Object?> get props => [];
}

class PlayerSliderChange extends PlayerSliderEvents {
  final int current;
  const PlayerSliderChange(this.current);

  @override
  List<Object?> get props => [current, super.props];
}

class PlayerSliderState extends Equatable {
  final int current;
  const PlayerSliderState(this.current);

  const PlayerSliderState.init() : current = 0;

  PlayerSliderState copyWith([int? current]) {
    return PlayerSliderState(current ?? this.current);
  }

  @override
  List<Object?> get props => [current];
}

class PlayerSliderBloc extends Bloc<PlayerSliderEvents, PlayerSliderState> {
  PlayerSliderBloc() : super(const PlayerSliderState.init()) {
    on<PlayerSliderChange>(_onSliderChange);
  }

  void _onSliderChange(
      PlayerSliderChange event, Emitter<PlayerSliderState> emit) {
    emit(state.copyWith(event.current));
  }
}
