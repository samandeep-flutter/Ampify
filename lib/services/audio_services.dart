import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import '../data/utils/exports.dart';

Future<AudioHandler> audioServicesInit() async {
  return await AudioService.init(
    builder: MyAudioHandler.instance.init,
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.samtech.ampify.notification',
      androidNotificationChannelDescription: StringRes.notiDesc,
      androidNotificationChannelName: 'Media',
      androidNotificationOngoing: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler {
  MyAudioHandler._init();
  static MyAudioHandler? _instance;
  static MyAudioHandler get instance => _instance ??= MyAudioHandler._init();

  final _player = AudioPlayer();
  int _index = 0;

  MyAudioHandler init() {
    _playerStream();
    _positionStream();
    _indexChanges();
    _interruptionListener();
    playbackState.add(playbackState.value.copyWith(
      systemActions: const {
        MediaAction.seek,
        MediaAction.play,
        MediaAction.pause,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious
      },
      androidCompactActionIndices: const [0, 1, 3],
      repeatMode: _player.loopMode.toRepeatMode,
      shuffleMode: AudioServiceShuffleMode.none,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    ));
    return this;
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    await _player.addAudioSource(mediaItem.toAudioSource);
    queue.add([...queue.value, mediaItem]);
  }

  @override
  Future<void> play() async {
    final session = getIt<AuthServices>().session;
    session?.setActive(true);
    await _player.play();
  }

  @override
  Future<void> pause() async {
    final session = getIt<AuthServices>().session;
    session?.setActive(false);
    await _player.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    queue.drain();
    await _player.setAudioSource(mediaItem.toAudioSource);
    this.mediaItem.add(mediaItem);
    queue.add([mediaItem]);
    _player.play();
  }

  @override
  Future<void> skipToNext() async {
    try {
      if (!_player.hasNext) return;
      await _player.seekToNext();
    } catch (e) {
      logPrint(e, 'audio next');
    }
  }

  @override
  Future<void> skipToPrevious() async {
    try {
      if (!_player.hasPrevious) return;
      await _player.seekToPrevious();
    } catch (e) {
      logPrint(e, 'audio previous');
    }
  }

  @override
  Future customAction(String name, [Map<String, dynamic>? extras]) async {
    switch (name) {
      case PlayerActions.clearQueue:
        await _clearQueue();
        break;
      case PlayerActions.removeRange:
        await _removeRange(extras?['start'], extras?['end']);
        break;
      case PlayerActions.removeUpcomming:
        await _removeUpcomming();
        break;
      default:
        logPrint('no action set', 'audio actions');
    }
  }

  Future<void> _clearQueue() async {
    await _player.clearAudioSources();
    queue.drain();
  }

  Future<void> _removeRange(int? start, int? end) async {
    try {
      await _player.removeAudioSourceRange(start!, end!);
      queue.value.removeRange(start, end);
    } catch (_) {
      logPrint('range not specified', 'audio range');
    }
  }

  Future<void> _removeUpcomming() async {
    try {
      final _end = _player.audioSources.length - 1;
      await _player.removeAudioSourceRange(_player.nextIndex ?? 0, _end);
      queue.value.removeRange(_player.nextIndex ?? 0, queue.value.length - 1);
    } catch (e) {
      logPrint(e, 'audio queue');
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.all:
        await _player.setLoopMode(LoopMode.all);
        break;

      default:
        await _player.setLoopMode(LoopMode.off);
        break;
    }
  }

  @override
  Future<void> stop() async {
    final session = getIt<AuthServices>().session;
    session?.setActive(false);
    await _player.stop();
    return super.stop();
  }

  void _playerStream() {
    _player.playerStateStream.listen((state) {
      final processing = state.processingState.toAudioState;
      final _processing = playbackState.value.processingState;
      PlaybackState _state = playbackState.value;
      if (processing != _processing) {
        _state = _state.copyWith(processingState: processing);
      }
      if (state.playing != playbackState.value.playing) {
        _state = _state.copyWith(
          playing: state.playing,
          controls: [
            MediaControl.skipToPrevious,
            _player.playing ? MediaControl.pause : MediaControl.play,
            MediaControl.skipToNext,
          ],
        );
      }
      if (_state == playbackState.value) return;
      playbackState.add(_state);
    });
  }

  void _positionStream() {
    _player.positionStream.listen((duration) {
      customEvent.add(duration.ceil());
    });
  }

  void _indexChanges() {
    _player.currentIndexStream.listen((index) {
      if (index == null || index == _index) return;
      mediaItem.add(queue.value[index]);
      _index = index;
    });
  }

  Future<void> _interruptionListener() async {
    final session = getIt<AuthServices>().session;
    session?.becomingNoisyEventStream.listen((_) => pause());
    session?.interruptionEventStream.listen((event) {
      switch (event.type) {
        case AudioInterruptionType.duck:
          _player.setVolume(event.begin ? .3 : 1);
          break;
        case AudioInterruptionType.pause:
          event.begin ? pause() : play();
          break;
        case AudioInterruptionType.unknown:
          event.begin ? pause() : stop();
          break;
      }
    });
  }
}
