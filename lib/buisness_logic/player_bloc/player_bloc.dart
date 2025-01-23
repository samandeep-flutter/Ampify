import 'dart:async';
import 'package:ampify/buisness_logic/player_bloc/player_state.dart';
import 'package:ampify/data/repository/music_repo.dart';
import 'package:ampify/data/utils/app_constants.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/data/utils/utils.dart';
import 'package:ampify/services/getit_instance.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;
import 'package:rxdart/transformers.dart';
import 'player_events.dart';

EventTransformer<T> _debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc() : super(const PlayerState.init()) {
    on<PlayerInitial>(_onInit);
    on<PlayerStatusChanged>(_onStateChanged);
    on<PlayerTrackLiked>(_onTrackLiked);
    on<PlayerShuffleToggle>(_shuffleToggle);
    // on<PlayerRepeatToggle>(_repeatToggle);
    on<PlayerQueueAdded>(_onQueueAdded, transformer: _debounce(duration));
    on<PlayerNextTrack>(_onNextTrack);
    on<PlayerPreTrack>(_onPreTrack);
    on<QueueItemSelected>(_onItemSelected);
    on<PlayerQueueCleared>(_onQueueCleared);
    on<PlayerTrackChanged>(_onTrackChange);
  }

  @override
  Future<void> close() {
    _player.dispose();
    return super.close();
  }

  final duration = const Duration(milliseconds: 500);
  final _player = AudioPlayer();
  final MusicRepo _musicRepo = getIt();
  int? get current => _player.currentIndex;

  Stream<Duration>? positionStream;
  final queue = ConcatenatingAudioSource(children: []);

  _onInit(PlayerInitial event, Emitter<PlayerState> emit) async {
    await _player.setAudioSource(queue);
  }

  void onSelected(int index) => add(QueueItemSelected(index));

  void onSliderChange(double value) async {
    final pos = Duration(seconds: value.round());
    await _player.seek(pos);
  }

  void onPlayPause() => add(PlayerStatusChanged());

  void onTrackLiked() => add(PlayerTrackLiked());

  void onShuffle() => add(PlayerShuffleToggle());

  void onRepeat() => add(PlayerRepeatToggle());

  void clearQueue() => add(PlayerQueueCleared());

  void onPrevious() {}

  void onNext() {}

  void onTrackEnded() => add(PlayerNextTrack());

  _createPosition(Duration? duration) {
    positionStream = _player.createPositionStream(
      steps: duration?.inSeconds ?? 60,
      maxPeriod: duration ?? const Duration(minutes: 1),
    );
  }

  Future<Duration?> _getDuration() async {
    final compeleter = Completer<Duration>();
    final stream = _player.processingStateStream.listen((state) {
      if (state == ProcessingState.ready) {
        compeleter.complete(_player.duration);
      }
    });
    final duration = await compeleter.future;
    stream.cancel();
    return duration;
  }

  _reset() async {
    try {
      await _player.stop();
      await positionStream?.drain();
    } catch (e) {
      logPrint('Track reset: $e');
    }
  }

  _onStateChanged(PlayerStatusChanged event, Emitter<PlayerState> emit) async {
    switch (state.playerState) {
      case MusicState.pause:
        emit(state.copyWith(playerState: MusicState.playing));
        await _player.play();
        break;
      case MusicState.playing:
        emit(state.copyWith(playerState: MusicState.pause));
        await _player.pause();
        break;
      default:
        return;
    }
  }

  _onTrackLiked(PlayerTrackLiked event, Emitter<PlayerState> emit) {
    // TODO: add song liked logic.
    emit(state.copyWith(liked: !state.liked));
  }

  _shuffleToggle(PlayerShuffleToggle event, Emitter<PlayerState> emit) async {
    emit(state.copyWith(shuffle: !state.shuffle));
    // await _player.setShuffleModeEnabled(!state.shuffle);
  }

  _repeatToggle(PlayerRepeatToggle event, Emitter<PlayerState> emit) async {
    switch (_player.loopMode) {
      case LoopMode.one:
        emit(state.copyWith(loopMode: MusicLoopMode.all));
        await _player.setLoopMode(LoopMode.all);
        break;
      case LoopMode.all:
        emit(state.copyWith(loopMode: MusicLoopMode.off));
        await _player.setLoopMode(LoopMode.off);
        break;

      default:
        emit(state.copyWith(loopMode: MusicLoopMode.once));
        await _player.setLoopMode(LoopMode.one);
        break;
    }
  }

  _onQueueAdded(PlayerQueueAdded event, Emitter<PlayerState> emit) async {
    try {
      showToast(StringRes.queueAdded);
      final track = await Utils.getTrackDetails(event.track);
      final selected = List.generate(state.queue.length + 1, (_) => false);
      emit(state
          .copyWith(queue: [...state.queue, track], queueSelected: selected));
      if (_player.hasNext) return;
      logPrint('song added instaneously...');
      final artist = track.subtitle?.split(',').first;
      final uri = await _musicRepo.searchSongs('${track.title} $artist');
      final source = AudioSource.uri(uri!);
      await queue.add(source);
    } catch (e) {
      logPrint('Queue instaneous: $e');
    }
  }

  _onNextTrack(PlayerNextTrack event, Emitter<PlayerState> emit) async {
    if (!_player.hasNext) {
      logPrint('empty queue...');
      emit(state.copyWith(
        playerState: MusicState.loading,
        showPlayer: false,
      ));
      return;
    }
    TrackDetails track = state.queue.first;
    logPrint('next from queue: ${track.title}');
    final newQueue = state.queue..skip(1);
    emit(state.copyWith(
      track: track,
      queue: newQueue,
      playerState: MusicState.loading,
    ));
    try {
      final duration = await _getDuration();
      _createPosition(duration);
      emit(state.copyWith(playerState: MusicState.playing));
    } catch (e) {
      emit(state.copyWith(playerState: MusicState.pause));
      logPrint('Duration: $e');
    }

    if (state.queue.isEmpty) return;
    track = state.queue.first;
    final artist = track.subtitle?.split(',').first;
    try {
      final uri = await _musicRepo.searchSongs('${track.title} $artist');
      final source = AudioSource.uri(uri!);
      await queue.add(source);
    } catch (e) {
      logPrint('Queue next: $e');
    }
  }

  _onPreTrack(PlayerPreTrack event, Emitter<PlayerState> emit) async {
    // TODO: previous song logic.
  }

  void _onItemSelected(QueueItemSelected event, Emitter<PlayerState> emit) {
    List<bool> selected = state.queueSelected;
    selected[event.index] = !selected[event.index];
    emit(state.copyWith(queueSelected: selected));
  }

  void _onQueueCleared(PlayerQueueCleared event, Emitter<PlayerState> emit) {
    queue.clear();
    emit(state.copyWith(queue: [], queueSelected: []));
  }

  _onTrackChange(PlayerTrackChanged event, Emitter<PlayerState> emit) async {
    _player.pause();
    final track = await Utils.getTrackDetails(event.track);
    emit(state.copyWith(
        track: track,
        length: 0,
        showPlayer: true,
        playerState: MusicState.loading));
    try {
      await queue.clear();
      emit(state.copyWith(queue: []));
      final artist = track.subtitle?.split(',').first;
      final uri = await _musicRepo.searchSongs('${track.title} $artist');
      final source = AudioSource.uri(uri!);
      await queue.add(source);
      final duration = await _getDuration();
      _createPosition(duration);
      emit(state.copyWith(
        playerState: MusicState.playing,
        length: duration?.inSeconds ?? 0,
      ));
      await _player.play();
    } catch (e) {
      logPrint('Track Change: $e');
      showToast(StringRes.somethingWrong);
      emit(state.copyWith(playerState: MusicState.pause));
    }
  }
}
