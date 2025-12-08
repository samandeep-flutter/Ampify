import 'dart:async';
import 'package:ampify/buisness_logic/player_bloc/player_state.dart';
import 'package:ampify/data/repositories/library_repo.dart';
import 'package:ampify/data/repositories/music_repo.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:audio_service/audio_service.dart';
import 'player_events.dart';

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
    // on<PlayerQueueStream>(_onQueueStream,
    //     transformer: Utils.debounce(Durations.long2));
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
  final MusicRepo _musicRepo = getIt();
  final LibraryRepo _libRepo = getIt();

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

  void onTrackLiked(String id, [bool? liked]) {
    add(PlayerTrackLiked(id, liked: liked));
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

  void _onMediaStream(
      PlayerMediaStream event, Emitter<PlayerState> emit) async {
    try {
      final item = event.mediaItem;
      if (item.id == UniqueIds.emptyTrack) return;
      final track = TrackDetails.fromJson(item.extras!);
      emit(state.copyWith(track: track, isLiked: false));
      try {
        final isLiked = await _libRepo.isLiked([track.id!]);
        emit(state.copyWith(isLiked: isLiked.firstElement));
      } catch (e) {
        logPrint(e, 'liked');
      }
    } catch (e) {
      logPrint(e, 'media stream');
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
      emit(state.copyWith(playerState: playerState, loopMode: loop));
    } catch (e) {
      logPrint(e, 'playback stream');
    }
  }

  void _onNextTrack(PlayerNextTrack event, Emitter<PlayerState> emit) async {
    await _audioHandler.skipToNext();
    try {
      final queue = _audioHandler.queue.value;
      final _index = queue.indexWhere((e) => e.id == state.track.id);
      if (queue.length == _index + 1) throw FormatException();
      if (state.queue.isNotEmpty) {
        if (queue[_index + 1].id == state.queue.first.id) return;
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
    emit(state.copyWith(queue: [state.track, ...state.queue]));
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
      logPrint(e, 'queue next');
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
      logPrint(e, 'upnext next');
    }
  }

  Future<void> _onTrackLiked(
      PlayerTrackLiked event, Emitter<PlayerState> emit) async {
    try {
      final shouldEmit = state.track.id == event.id;
      if (event.liked ?? false) {
        if (shouldEmit) emit(state.copyWith(isLiked: false));
        final result = await _libRepo.removefromLikedSongs(event.id);
        if (!result) throw FormatException();
      } else {
        if (shouldEmit) emit(state.copyWith(isLiked: true));
        final result = await _libRepo.addtoLikedSongs(event.id);
        if (!result) throw FormatException();
      }
    } on FormatException {
      if (state.track.id != event.id) return;
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

  // Future<void> _onQueueStream(
  //     PlayerQueueStream event, Emitter<PlayerState> emit) async {
  //   final queue =
  //       event.queue.map((e) => TrackDetails.fromJson(e.extras!)).toList();
  //   emit(state.copyWith(queue: [...queue, ...state.queue]));
  // }

  Future<void> _onQueueAdded(
      PlayerQueueAdded event, Emitter<PlayerState> emit) async {
    try {
      if (state.playerState.isHidden) throw FormatException();
      showToast(StringRes.queueAdded);
      final track = await Utils.getTrackDetails(event.track);
      emit(state.copyWith(queue: [...state.queue, track]));
      if (state.upNext.isNotEmpty) {
        await _audioHandler.customAction(PlayerActions.removeUpcomming);
      }
      if (_audioHandler.queue.isLast(state.queue)) return;
      add(PlayerPrepareNextTrack());
    } on FormatException {
      add(PlayerTrackChanged(event.track));
    } catch (e) {
      logPrint(e, 'queue instaneous');
    }
  }

  Future<void> _onTrackEnded(
      PlayerTrackEnded event, Emitter<PlayerState> emit) async {
    try {
      if (event.id is! String) throw FormatException();
      if (state.queue.isNotEmpty) {
        if (state.queue.first.id != event.id) return;
        emit(state.copyWith(queue: state.queue.skip(1).toList()));
      } else if (state.upNext.isNotEmpty) {
        if (state.upNext.first.id != event.id) return;
        emit(state.copyWith(upNext: state.upNext.skip(1).toList()));
      }
      add(PlayerPrepareNextTrack());
    } on FormatException {
      if (state.loopMode != MusicLoopMode.off) return;
      await _audioHandler.stop();
      emit(PlayerState.init());
    } catch (e) {
      logPrint(e, 'track ended');
    }
  }

  Future<void> _onPrepareTrack(
      PlayerPrepareNextTrack event, Emitter<PlayerState> emit) async {
    try {
      if (state.queue.isNotEmpty) {
        try {
          final track = state.queue.first;
          final uri = await _musicRepo.fromVideoId(track.videoId);
          if (uri == null) throw FormatException();
          final _media = Utils.toMediaItem(track, uri: uri);
          await _audioHandler.addQueueItem(_media);
        } catch (_) {
          emit(state.copyWith(queue: state.queue.skip(1).toList()));
          add(PlayerPrepareNextTrack());
        }
      } else if (state.upNext.isNotEmpty) {
        try {
          final track = await Utils.getTrackDetails(state.upNext.first);
          final uri = await _musicRepo.fromVideoId(track.videoId);
          if (uri == null) throw FormatException();
          final _media = Utils.toMediaItem(track, uri: uri);
          await _audioHandler.addQueueItem(_media);
        } catch (_) {
          emit(state.copyWith(upNext: state.upNext.skip(1).toList()));
          add(PlayerPrepareNextTrack());
        }
      }
    } catch (e) {
      logPrint(e, 'preloading track');
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
      final track = await Utils.getTrackDetails(event.tracks.first);
      final uri = await _musicRepo.fromVideoId(track.videoId);
      if (uri == null) throw FormatException();
      final _media = Utils.toMediaItem(track, uri: uri);
      _audioHandler.playMediaItem(_media);
      add(PlayerPrepareNextTrack());
    } on FormatException {
      emit(state.copyWith(upNext: event.tracks.skip(1).toList()));
      showToast(StringRes.cannotbePlayed);
      add(PlayerUpNextHandler());
    }
  }

  Future<void> _onUpNextHandler(
      PlayerUpNextHandler event, Emitter<PlayerState> emit) async {
    if (state.upNext.isEmpty) return;
    final track = state.upNext.first;
    final upnext = state.upNext.skip(1).toList();
    emit(state.copyWith(track: track.asTrackDetails, upNext: upnext));
    try {
      final _track = await Utils.getTrackDetails(track);
      final uri = await _musicRepo.fromVideoId(_track.videoId);
      if (uri == null) throw FormatException();
      final _media = Utils.toMediaItem(_track, uri: uri);
      _audioHandler.playMediaItem(_media);
      add(PlayerPrepareNextTrack());
    } on FormatException {
      emit(state.copyWith(upNext: state.upNext.skip(1).toList()));
      add(PlayerUpNextHandler());
    }
  }

  Future<void> _onTrackChange(
      PlayerTrackChanged event, Emitter<PlayerState> emit) async {
    _audioHandler.pause();
    // TODO: implement clear before playing, also modify playMediaItem.
    emit(state.withTrack(event.track.asTrackDetails));
    final track = await Utils.getTrackDetails(event.track);
    emit(state.copyWith(track: track, isLiked: event.liked));
    try {
      _audioHandler.customAction(PlayerActions.clearQueue);
      emit(state.copyWith(queue: []));
      final uri = await _musicRepo.fromVideoId(track.videoId);
      if (uri == null) throw FormatException();
      final _media = Utils.toMediaItem(track, uri: uri);
      await _audioHandler.playMediaItem(_media);
    } on FormatException {
      showToast(StringRes.cannotbePlayed);
      emit(state.copyWith(playerState: MusicState.hidden));
    } catch (e) {
      logPrint(e, 'track change');
      showToast(StringRes.somethingWrong);
      emit(state.copyWith(playerState: MusicState.pause));
    }
  }
}
