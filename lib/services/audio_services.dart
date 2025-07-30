import 'package:ampify/data/utils/app_constants.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

Future<AudioHandler> audioServicesInit() async {
  return await AudioService.init(
    builder: MyAudioHandler.instance.init,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.samtech.ampify',
      androidNotificationChannelName: 'Media',
      androidNotificationChannelDescription:
          'Notification related to media playback in the application',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler {
  MyAudioHandler._init();
  static MyAudioHandler? _instance;
  static MyAudioHandler get instance => _instance ??= MyAudioHandler._init();

  final _player = AudioPlayer();

  MyAudioHandler init() {
    _playbackStream();
    // _durationListener();
    return this;
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    await _player.addAudioSource(mediaItem.toAudioSource);
    queue.add([...queue.value, mediaItem]);
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) {
    // TODO: implement updateMediaItem
    return super.updateMediaItem(mediaItem);
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    await _player.seekToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    await _player.seekToPrevious();
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
  }

  Future<void> _removeRange(int? start, int? end) async {
    try {
      await _player.removeAudioSourceRange(start!, end!);
    } catch (_) {
      logPrint('range not specified', 'audio range');
    }
  }

  Future<void> _removeUpcomming() async {
    try {
      final _end = _player.audioSources.length - 1;
      await _player.removeAudioSourceRange(_player.nextIndex ?? 0, _end);
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
    await _player.stop();
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
    ));
  }

  void _playbackStream() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          _player.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0, 1, 3],
        processingState: _player.processingState.toAudioState,
        repeatMode: _player.loopMode.toRepeatMode,
        shuffleMode: _player.shuffleModeEnabled
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  // void _durationListener() {
  //   _player.durationStream.listen((duration) {
  //     var index = _player.currentIndex;
  //     final newQueue = queue.value;
  //     if (index == null || newQueue.isEmpty) return;
  //     if (_player.shuffleModeEnabled) {
  //       index = _player.shuffleIndices.indexOf(index);
  //     }
  //     final oldMediaItem = newQueue[index];
  //     final newMediaItem = oldMediaItem.copyWith(duration: duration);
  //     newQueue[index] = newMediaItem;
  //     queue.add(newQueue);
  //     mediaItem.add(newMediaItem);
  //   });
  // }
}
