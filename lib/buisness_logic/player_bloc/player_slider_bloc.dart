import 'package:ampify/services/extension_services.dart';
import 'package:equatable/equatable.dart';
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
    return current.isZero ? Duration.zero : Duration(seconds: 1);
  }

  @override
  List<Object?> get props => [current];
}

class PlayerSliderBloc extends Bloc<PlayerSliderEvents, PlayerSliderState> {
  PlayerSliderBloc() : super(const PlayerSliderState.init()) {
    on<PlayerSliderChange>(_onSliderChange);
    on<PlayerSliderReset>(_onSliderReset);
  }

  void _onSliderChange(
      PlayerSliderChange event, Emitter<PlayerSliderState> emit) {
    emit(state.copyWith(event.current));
  }

  void _onSliderReset(
      PlayerSliderReset event, Emitter<PlayerSliderState> emit) {
    emit(const PlayerSliderState.init());
  }
}
