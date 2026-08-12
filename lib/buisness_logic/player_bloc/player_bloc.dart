import 'dart:async';
import 'package:ampify/data/utils/exports.dart';
import 'package:audio_service/audio_service.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc() : super(const PlayerState.init()) {
    on<PlayerInitial>(_onInit);
    on<PlayerTrackLiked>(_onTrackLiked);
    on<PlayerShuffleToggle>(_shuffleToggle);
    on<PlayerQueueReordered>(_onQueueReorder);
    on<PlayerUpNextReordered>(_onUpNextReorder);
    on<PlayerQueueAdded>(_onQueueAdded,
        transformer: Utils.debounce(Durations.long2));
    on<PlayerTrackEnded>(_onTrackEnded,
        transformer: Utils.debounce(Durations.long4));
    on<PlayerQueueCleared>(_onQueueCleared);
    on<PlayerUpNextCleared>(_onUpNextCleared);
    on<PlayerPrepareNextTrack>(_onPrepareTrack);
    on<PlayerUpNextHandler>(_onUpNextHandler);
    on<PlayerTrackChanged>(_onTrackChange);
    on<MusicGroupPlayed>(_onMusicGroup);
    on<PlayerMediaStream>(_onMediaStream,
        transformer: Utils.debounce(Durations.long2));
    on<PlayerPlaybackStream>(_onPlaybackStream,
        transformer: Utils.debounce(Durations.long2));
    on<PlayerNextTrack>(_onNextTrack);
    on<PlayerPreviousTrack>(_onPreviousTrack);
    on<PlayerAppendTracks>(_appendTracks);
  }

  // @override
  // void onChange(Change<PlayerState> change) {
  //   dprint(change.changesOnly);
  //   super.onChange(change);
  // }

  // @override
  // void onEvent(PlayerEvent event) {
  //   dprint(event.runtimeType.toString());
  //   super.onEvent(event);
  // }

  final AudioHandler _audioHandler = getIt();
  final YtMusicRepo _musicRepo = getIt();
  final LibraryRepo _libRepo = getIt();

  String get uid => BoxServices.instance.uid!;

  Future<void> _onInit(PlayerInitial event, Emitter<PlayerState> emit) async {
    try {
      _audioHandler.mediaItem.listen((mediaItem) {
        if (isClosed || mediaItem == null) return;
        add(PlayerMediaStream(mediaItem));
      });
      _audioHandler.playbackState.listen((state) {
        if (isClosed) return;
        add(PlayerPlaybackStream(state));
      });
      _audioHandler.customState.listen((state) {
        if (isClosed) return;
        add(PlayerTrackEnded(state));
      });
    } catch (e) {
      logPrint(e, 'player init');
    }
  }

  void onSliderChange(double value) async {
    try {
      await _audioHandler.seek(Duration(seconds: value.round()));
    } catch (e) {
      logPrint(e, 'seek $value');
    }
  }

  void onPlayPause() => _audioHandler.click();

  void onTrackLiked(Track track, [bool? liked]) {
    add(PlayerTrackLiked(track, liked: liked));
  }

  void onTrackShare(String id) {}

  void onShuffle() => add(PlayerShuffleToggle());

  void onRepeat() {
    switch (state.loopMode) {
      case MusicLoopMode.off:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case MusicLoopMode.once:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
      case MusicLoopMode.all:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
    }
    if (!state.isEmptyOrFinished) return;
    _audioHandler.customAction(PlayerActions.removeUpcomming);
  }

  void clearQueue() => add(PlayerQueueCleared());

  void clearUpnext() => add(PlayerUpNextCleared());

  void onQueueReorder(int pr, int cr) {
    add(PlayerQueueReordered(previous: pr, current: cr));
  }

  void onUpNextReorder(int pr, int cr) {
    add(PlayerUpNextReordered(previous: pr, current: cr));
  }

  void _onMediaStream(PlayerMediaStream event, Emitter<PlayerState> emit) {
    try {
      final item = event.mediaItem;
      if (item.id == UniqueIds.emptyTrack) throw FormatException();
      final details = TrackDetails.fromJson(item.extras!);
      emit(state.copyWith(details: details, isLiked: false));
      _libRepo.isLiked(uid, details.track!.id).then((result) {
        emit(state.copyWith(isLiked: result));
      });
    } on FormatException {
      emit(PlayerState.init());
    } catch (e) {
      logPrint(e, 'media-stream');
    }
  }

  void _onPlaybackStream(
      PlayerPlaybackStream event, Emitter<PlayerState> emit) {
    try {
      final _state = event.state.playerState;
      final _loop = event.state.repeatMode.toLoopMode;
      final loop = state.loopMode == _loop ? null : _loop;
      MusicState? playerState = _state == state.playerState ? null : _state;

      /// to avoid emitting hidden state while playing tracks
      if (playerState.isHidden) playerState = null;
      if (playerState == null && loop == null) return;
      emit(state.copyWith(playerState: playerState, loopMode: loop));
    } catch (e) {
      logPrint(e, 'playback-stream');
    }
  }

  void _onNextTrack(PlayerNextTrack event, Emitter<PlayerState> emit) async {
    await _audioHandler.skipToNext();
    try {
      final queue = _audioHandler.queue.value;
      final _index = queue.indexWhere((e) => e.id == state.track!.id);
      if (queue.length == _index + 1) throw FormatException();
      if (state.queue.isNotEmpty) {
        if (queue[_index + 1].id == state.queue.first.track!.id) return;
        throw FormatException();
      } else if (state.upNext.isNotEmpty) {
        if (queue[_index + 1].id == state.upNext.first.id) return;
        throw FormatException();
      }
    } on FormatException {
      add(PlayerPrepareNextTrack());
    } catch (_) {}
  }

  void _onPreviousTrack(
      PlayerPreviousTrack event, Emitter<PlayerState> emit) async {
    emit(state.copyWith(queue: [state.details, ...state.queue]));
    await _audioHandler.skipToPrevious();
  }

  Future<void> _onQueueReorder(
      PlayerQueueReordered event, Emitter<PlayerState> emit) async {
    List<TrackDetails> queue = List<TrackDetails>.from(state.queue);
    final reordered = queue[event.previous];
    queue.removeAt(event.previous);
    queue.insert(event.current, reordered);
    emit(state.copyWith(queue: queue));
    try {
      await _audioHandler.customAction(PlayerActions.removeUpcomming);
      add(PlayerPrepareNextTrack());
    } catch (e) {
      logPrint(e, 'queue-next');
    }
  }

  Future<void> _onUpNextReorder(
      PlayerUpNextReordered event, Emitter<PlayerState> emit) async {
    List<Track> upNext = List<Track>.from(state.upNext);
    final reordered = upNext[event.previous];
    upNext.removeAt(event.previous);
    upNext.insert(event.current, reordered);
    emit(state.copyWith(upNext: upNext));
    try {
      if (state.queue.isNotEmpty) return;
      await _audioHandler.customAction(PlayerActions.removeUpcomming);
      add(PlayerPrepareNextTrack());
    } catch (e) {
      logPrint(e, 'upnext-next');
    }
  }

  Future<void> _onTrackLiked(
      PlayerTrackLiked event, Emitter<PlayerState> emit) async {
    try {
      final shouldEmit = state.track?.id == event.track.id;
      if (event.liked ?? false) {
        if (shouldEmit) emit(state.copyWith(isLiked: false));
        final result = await _libRepo.removefromLikedSongs(uid, event.track.id);
        if (!result) throw FormatException();
      } else {
        if (shouldEmit) emit(state.copyWith(isLiked: true));
        final result = await _libRepo.addtoLikedSongs(uid, event.track);
        if (!result) throw FormatException();
      }
    } on FormatException {
      if (state.track!.id != event.track.id) return;
      emit(state.copyWith(isLiked: !(event.liked ?? false)));
    } catch (e) {
      logPrint(e, 'liked');
    }
  }

  Future<void> _shuffleToggle(
      PlayerShuffleToggle event, Emitter<PlayerState> emit) async {
    await _audioHandler.customAction(PlayerActions.removeUpcomming);
    emit(state.copyWith(shuffle: !state.shuffle));
    await _audioHandler.setShuffleMode(state.shuffle
        ? AudioServiceShuffleMode.all
        : AudioServiceShuffleMode.none);
    // TODO: implement queue, upNext, and recomanded (upcomming) shuffle.
  }

  Future<void> _onQueueAdded(
      PlayerQueueAdded event, Emitter<PlayerState> emit) async {
    try {
      if (state.playerState.isHidden) throw FormatException();
      showToast(StringRes.queueAdded);
      final track = await Utils.getTrackDetails(_musicRepo, event.track);
      emit(state.copyWith(queue: [...state.queue, track]));
      if (state.upNext.isNotEmpty) {
        await _audioHandler.customAction(PlayerActions.removeUpcomming);
      }
      if (_audioHandler.queue.isLast(state.queue)) return;
      add(PlayerPrepareNextTrack());
    } on FormatException {
      add(PlayerTrackChanged(event.track));
    } catch (e) {
      logPrint(e, 'queue-instaneous');
    }
  }

  Future<void> _onTrackEnded(
      PlayerTrackEnded event, Emitter<PlayerState> emit) async {
    try {
      if (event.id is! String) throw FormatException();
      if (state.queue.isNotEmpty) {
        if (state.queue.first.track!.id != event.id) return;
        emit(state.copyWith(queue: state.queue.skip(1).toList()));
      } else if (state.upNext.isNotEmpty) {
        if (state.upNext.first.id != event.id) return;
        emit(state.copyWith(upNext: state.upNext.skip(1).toList()));
      }
      add(PlayerPrepareNextTrack());
    } on FormatException {
      if (state.loopMode != MusicLoopMode.off) return;
      logPrint(state, 'track-ended');
      await _audioHandler.stop();
    } catch (e) {
      logPrint(e, 'track-ended');
    }
  }

  Future<void> _onPrepareTrack(
      PlayerPrepareNextTrack event, Emitter<PlayerState> emit) async {
    try {
      if (state.queue.isNotEmpty) {
        try {
          final details = state.queue.first;
          final uri = await _musicRepo.fromVideoId(details.track!.videoId);
          if (uri == null) throw FormatException();
          final _media = Utils.toMediaItem(details, uri: uri);
          await _audioHandler.addQueueItem(_media);
        } catch (_) {
          emit(state.copyWith(queue: state.queue.skip(1).toList()));
          add(PlayerPrepareNextTrack());
        }
      } else if (state.upNext.isNotEmpty) {
        try {
          final details =
              await Utils.getTrackDetails(_musicRepo, state.upNext.first);
          final uri = await _musicRepo.fromVideoId(details.track!.videoId);
          if (uri == null) throw FormatException();
          final _media = Utils.toMediaItem(details, uri: uri);
          await _audioHandler.addQueueItem(_media);
        } catch (_) {
          emit(state.copyWith(upNext: state.upNext.skip(1).toList()));
          add(PlayerPrepareNextTrack());
        }
      }
    } catch (e) {
      logPrint(e, 'preloading-track');
    }
  }

  Future<void> _onQueueCleared(
      PlayerQueueCleared event, Emitter<PlayerState> emit) async {
    await _audioHandler.customAction(PlayerActions.removeUpcomming);
    emit(state.copyWith(queue: []));
    add(PlayerPrepareNextTrack());
  }

  void _onUpNextCleared(PlayerUpNextCleared event, Emitter<PlayerState> emit) {
    emit(state.copyWith(upNext: []));
    if (state.queue.isNotEmpty) return;
    _audioHandler.customAction(PlayerActions.removeUpcomming);
  }

  Future<void> _onMusicGroup(
      MusicGroupPlayed event, Emitter<PlayerState> emit) async {
    _audioHandler.pause();
    await _audioHandler.customAction(PlayerActions.clearQueue);
    try {
      emit(state.withMusicGroup(event.id!, tracks: event.tracks));
      final details =
          await Utils.getTrackDetails(_musicRepo, event.tracks.first);
      final uri = await _musicRepo.fromVideoId(details.track!.videoId);
      if (uri == null) throw FormatException();
      final _media = Utils.toMediaItem(details, uri: uri);
      _audioHandler.playMediaItem(_media);
      add(PlayerPrepareNextTrack());
    } on FormatException {
      emit(state.copyWith(upNext: event.tracks.skip(1).toList()));
      showToast(StringRes.cannotbePlayed);
      add(PlayerUpNextHandler());
    } catch (e) {
      logPrint(e, 'music-group');
    }
  }

  Future<void> _onUpNextHandler(
      PlayerUpNextHandler event, Emitter<PlayerState> emit) async {
    if (state.upNext.isEmpty) return;
    final track = state.upNext.first;
    final upnext = state.upNext.skip(1).toList();
    emit(state.copyWith(details: TrackDetails.track(track), upNext: upnext));
    try {
      final _details = await Utils.getTrackDetails(_musicRepo, track);
      final uri = await _musicRepo.fromVideoId(_details.track!.videoId);
      if (uri == null) throw FormatException();
      final _media = Utils.toMediaItem(_details, uri: uri);
      _audioHandler.playMediaItem(_media);
      add(PlayerPrepareNextTrack());
    } on FormatException {
      emit(state.copyWith(upNext: state.upNext.skip(1).toList()));
      add(PlayerUpNextHandler());
    }
  }

  void _appendTracks(
      PlayerAppendTracks event, Emitter<PlayerState> emit) async {
    showToast(StringRes.addedtoUpNext);
    try {
      if (state.playerState.isHidden) throw FormatException();
      emit(state.copyWith(musicGroupId: event.id, upNext: event.tracks));
      await _audioHandler.customAction(PlayerActions.removeUpcomming);
      add(PlayerPrepareNextTrack());
    } on FormatException {
      add(MusicGroupPlayed(id: event.id, tracks: event.tracks));
    } catch (e) {
      logPrint(e, 'append-tracks');
    }
  }

  Future<void> _onTrackChange(
      PlayerTrackChanged event, Emitter<PlayerState> emit) async {
    _audioHandler.pause();
    await _audioHandler.customAction(PlayerActions.clearQueue);
    emit(state.withTrack(TrackDetails.track(event.track)));
    final details = await Utils.getTrackDetails(_musicRepo, event.track);
    emit(state.copyWith(details: details, isLiked: event.liked));
    try {
      _audioHandler.customAction(PlayerActions.clearQueue);
      emit(state.copyWith(queue: []));
      final uri = await _musicRepo.fromVideoId(details.track!.videoId);
      if (uri == null) throw FormatException();
      final _media = Utils.toMediaItem(details, uri: uri);
      await _audioHandler.playMediaItem(_media);
      add(PlayerPrepareNextTrack());
    } on FormatException {
      showToast(StringRes.cannotbePlayed);
      emit(state.copyWith(playerState: MusicState.hidden));
    } catch (e) {
      logPrint(e, 'track-change');
      showToast(StringRes.somethingWrong);
      emit(state.copyWith(playerState: MusicState.pause));
    }
  }
}
