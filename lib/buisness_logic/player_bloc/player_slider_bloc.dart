import 'dart:async';

import 'package:ampify/data/utils/exports.dart';
import 'package:audio_service/audio_service.dart';

class PlayerSliderEvents extends Equatable {
  const PlayerSliderEvents();

  @override
  List<Object?> get props => [];
}

class PlayerSliderInitial extends PlayerSliderEvents {}

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
    on<PlayerSliderInitial>(_onInit);
    on<PlayerSliderChange>(_onSliderChange);
    on<PlayerSliderReset>(_onSliderReset);
  }

  final AudioHandler _audioHandler = getIt();
  StreamSubscription? streamSub;
  MediaItem? _mediaItem;

  void _onInit(
      PlayerSliderInitial event, Emitter<PlayerSliderState> emit) async {
    _audioHandler.mediaItem.listen((mediaItem) {
      if (isClosed || mediaItem == null) return;
      if (mediaItem.id == _mediaItem?.id) return;
      streamSub?.cancel();
      add(PlayerSliderReset());
      streamSub = _audioHandler.customEvent.listen((duration) {
        if (duration is! Duration) return;
        final _duration = _mediaItem?.duration;
        if (duration <= (_duration ?? Duration.zero)) {
          add(PlayerSliderChange(duration));
        }
      });
      _mediaItem = mediaItem;
    });
  }

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
