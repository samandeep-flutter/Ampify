import 'dart:async';
import 'package:ampify/data/utils/exports.dart';
import 'package:audio_service/audio_service.dart';

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
  final Duration animate;
  const PlayerSliderState({required this.current, required this.animate});

  const PlayerSliderState.init()
      : current = Duration.zero,
        animate = Duration.zero;

  PlayerSliderState copyWith({Duration? current, Duration? animate}) {
    return PlayerSliderState(
      current: current ?? this.current,
      animate: animate ?? this.animate,
    );
  }

  @override
  List<Object?> get props => [current, animate];
}

class PlayerSliderBloc extends Bloc<PlayerSliderEvents, PlayerSliderState> {
  PlayerSliderBloc() : super(const PlayerSliderState.init()) {
    on<PlayerSliderChange>(_onSliderChange);
    on<PlayerSliderReset>(_onSliderReset);
  }

  // @override
  // void onEvent(PlayerSliderEvents event) {
  //   dprint(event.runtimeType.toString());
  //   super.onEvent(event);
  // }

  final AudioHandler _audioHandler = getIt();
  StreamSubscription? streamSub;
  Stream get durationStream => _audioHandler.customEvent;

  void _onSliderChange(
      PlayerSliderChange event, Emitter<PlayerSliderState> emit) {
    if (event.current == state.current) return;
    final animate = _difference(event.current, state.current);
    emit(state.copyWith(current: event.current, animate: animate));
  }

  void _onSliderReset(
      PlayerSliderReset event, Emitter<PlayerSliderState> emit) {
    emit(const PlayerSliderState.init());
  }

  Duration _difference(Duration d1, Duration d2) {
    final diff = (d1.inSeconds - d2.inSeconds).abs();
    return diff > 1 ? Duration.zero : Duration(seconds: 1);
  }

  @override
  Future<void> close() {
    streamSub?.cancel();
    return super.close();
  }
}
