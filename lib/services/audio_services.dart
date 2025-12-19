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
      artDownscaleWidth: 512,
      artDownscaleHeight: 512,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler {
  MyAudioHandler._init();
  static MyAudioHandler? _instance;
  static MyAudioHandler get instance => _instance ??= MyAudioHandler._init();

  final _player = AudioPlayer();

  int _index = 0;
  String _trackEnded = '';
  Duration _duration = Duration.zero;

  MyAudioHandler init() {
    try {
      _playerStream();
      _positionStream();
      _indexChanges();
      _interruptionListener();
    } catch (e) {
      logPrint(e, 'audio-init');
    }
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
    ));
    AudioService.asyncError.listen((e) => logPrint(e, 'audio-services'));
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
    try {
      _trackEnded = '';
      _player.setAudioSource(mediaItem.toAudioSource);
      this.mediaItem.add(mediaItem);
      queue.add([mediaItem]);
      play();
    } catch (e) {
      logPrint(e, 'audio play');
    }
  }

  @override
  Future<void> skipToNext() async {
    try {
      if (!_player.hasNext) return;
      await _player.seekToNext();
      play();
    } catch (e) {
      logPrint(e, 'audio next');
    }
  }

  @override
  Future<void> skipToPrevious() async {
    try {
      if (!_player.hasPrevious) return;
      await _player.seekToPrevious();
      play();
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
    queue.add([]);
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
      if (_player.audioSources.isEmpty) return;
      final _end = _player.audioSources.length;
      await _player.removeAudioSourceRange(_index + 1, _end);
      queue.value.removeRange(_index + 1, queue.value.length);
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
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
  }

  void _playerStream() {
    _player.playerStateStream.listen((state) {
      PlaybackState _state = playbackState.value.copyWith(
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _index,
      );
      final processing = state.processingState.toAudioState;
      if (processing != playbackState.value.processingState) {
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
      if (duration.ceil() == _duration) return;
      customEvent.add(duration.ceil());
      _duration = duration.ceil();
      try {
        final item = queue.value[_index];
        final loopOff = _player.loopMode == LoopMode.off;
        if (_trackEnded == item.id && loopOff) return;
        dprint('${duration.format()}, queue: ${queue.value.length},'
            ' index: $_index, ${item.title}: ${item.duration!.floor()}');

        /// current track ended
        if (duration >= item.duration!.floor()) {
          dprint('${item.title} ended, ${duration.format()}');
          if (_index >= queue.value.length - 1) customState.add(false);
          _trackEnded = item.id;
        }
      } catch (e) {
        logPrint(e, 'audio position');
      }
    });
  }

  void _indexChanges() {
    _player.currentIndexStream.listen((index) {
      try {
        if (index == null || index == _index) return;
        if (index > queue.value.length - 1) return;
        mediaItem.add(queue.value[index]);
        if (index > _index) customState.add(queue.value[index].id);
        _index = index;
      } catch (e) {
        logPrint(e, 'audio-index');
      }
    });
  }

  void _interruptionListener() {
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

  @override
  Future<void> onNotificationDeleted() {
    customState.add(false);
    return super.onNotificationDeleted();
  }

  @override
  Future<void> stop() async {
    try {
      final session = getIt<AuthServices>().session;
      session?.setActive(false);
      queue.add([]);
      await _player.stop();
      mediaItem.add(MediaItem(id: UniqueIds.emptyTrack, title: ''));
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
      ));
    } catch (e) {
      logPrint(e, 'audio-stop');
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    mediaItem.close();
    queue.close();
    await stop();
    return super.onTaskRemoved();
  }
}
