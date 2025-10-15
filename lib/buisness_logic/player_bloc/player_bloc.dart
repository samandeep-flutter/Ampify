import 'dart:async';
import 'package:ampify/buisness_logic/player_bloc/player_state.dart';
import 'package:ampify/data/repositories/library_repo.dart';
import 'package:ampify/data/repositories/music_repo.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/data_models/common/tracks_model.dart';
import 'player_events.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc() : super(const PlayerState.init()) {
    on<PlayerInitial>(_onInit);
    on<PlayerTrackLiked>(_onTrackLiked);
    on<PlayerShuffleToggle>(_shuffleToggle);
    on<PlayerQueueReordered>(_onReorder);
    on<PlayerQueueAdded>(_onQueueAdded,
        transformer: Utils.debounce(Durations.long2));
    on<PlayerTrackEnded>(_onTrackEnded,
        transformer: Utils.debounce(longDuration));
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

  final longDuration = const Duration(seconds: 2);

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
  }

  void clearQueue() => add(PlayerQueueCleared());

  void clearUpnext() => add(PlayerUpNextCleared());

  void onQueueReorder(int pr, int cr) {
    add(PlayerQueueReordered(previous: pr, current: cr));
  }

  void _onMediaStream(PlayerMediaStream event, Emitter<PlayerState> emit) {
    try {
      final json = event.mediaItem.extras;
      final track = TrackDetails.fromJson(json!);
      if (track == state.track) return;
      emit(state.copyWith(track: track));
    } catch (e) {
      logPrint(e, 'media stream');
    }
  }

  void _onPlaybackStream(
      PlayerPlaybackStream event, Emitter<PlayerState> emit) {
    try {
      logPrint(
          '${event.state.processingState} [${DateTime.now().formatLongTime}]',
          'state');
      final _state = event.state.playerState;
      final _loop = event.state.repeatMode.toLoopMode;
      final loop = state.loopMode == _loop ? null : _loop;
      final playerState = _state == state.playerState ? null : _state;
      if (loop != null || playerState != null) {
        emit(state.copyWith(playerState: playerState, loopMode: loop));
      }
    } catch (e) {
      logPrint(e, 'playback stream');
    }
  }

  void _onNextTrack(PlayerNextTrack event, Emitter<PlayerState> emit) async {
    if (state.queue.isNotEmpty) {
      emit(state.copyWith(queue: state.queue.skip(1).toList()));
    } else if (state.upNext.isNotEmpty) {
      emit(state.copyWith(upNext: state.upNext.skip(1).toList()));
    }
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

  Future<void> _onReorder(
      PlayerQueueReordered event, Emitter<PlayerState> emit) async {
    List<TrackDetails> queueTracks = state.queue;
    final reorderedTrack = queueTracks[event.previous];
    queueTracks.removeAt(event.previous);
    queueTracks.insert(event.current, reorderedTrack);
    emit(state.copyWith(queue: queueTracks));
    try {
      await _audioHandler.customAction(PlayerActions.removeUpcomming);
      final uri = await _musicRepo.fromVideoId(state.queue.first.videoId);
      final _media = Utils.toMediaItem(state.queue.first, uri: uri!);
      _audioHandler.addQueueItem(_media);
    } catch (e) {
      logPrint(e, 'Queue next');
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
      logPrint(e, 'Liked');
    }
  }

  Future<void> _shuffleToggle(
      PlayerShuffleToggle event, Emitter<PlayerState> emit) async {
    // TODO: implement shuffle toggle.
    // await player.setShuffleModeEnabled(!state.shuffle);
    emit(state.copyWith(shuffle: !state.shuffle));
  }

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
      try {
        if (_audioHandler.queue.isLast(state.queue)) return;
        final uri = await _musicRepo.fromVideoId(track.videoId);
        if (uri == null) throw Exception();
        final _media = Utils.toMediaItem(track, uri: uri);
        // try {
        //   if (state.upNext.isEmpty) throw FormatException();
        //   if (state.queue.isNotEmpty) throw FormatException();
        //   await _audioHandler.customAction(
        //       PlayerActions.addToQueue, _media.extras);
        // } catch (_) {
        _audioHandler.addQueueItem(_media);
        // }
      } catch (_) {
        showToast(StringRes.cannotbeAdded);
      }
    } on FormatException {
      add(PlayerTrackChanged(event.track));
    } catch (e) {
      logPrint(e, 'Queue instaneous');
    }
  }

  Future<void> _onTrackEnded(
      PlayerTrackEnded event, Emitter<PlayerState> emit) async {
    try {
      // TODO: might need to refactor in case of recomendations/loop mode
      if (state.isEmptyOrFinished) throw FormatException();
      if (state.queue.isNotEmpty) {
        emit(state.copyWith(queue: state.queue.skip(1).toList()));
      } else if (state.upNext.isNotEmpty) {
        emit(state.copyWith(upNext: state.upNext.skip(1).toList()));
      }
      add(PlayerPrepareNextTrack());
    } on FormatException {
      await _audioHandler.stop();
      emit(PlayerState.init());
    } catch (e) {
      logPrint(e, 'Track ended');
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
    await _audioHandler.customAction(PlayerActions.clearQueue);
    final _track = event.tracks.first;
    emit(state.copyWith(
      musicGroupId: event.id,
      isLiked: event.liked,
      playerState: MusicState.loading,
      track: _track.asTrackDetails,
      upNext: event.tracks.skip(1).toList(),
      queue: [],
    ));

    try {
      final track = await Utils.getTrackDetails(_track);
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
      emit(state.copyWith(upNext: state.upNext.skip(1).toList()));
      add(PlayerPrepareNextTrack());
    } on FormatException {
      emit(state.copyWith(upNext: state.upNext.skip(1).toList()));
      add(PlayerUpNextHandler());
    }
  }

  Future<void> _onTrackChange(
      PlayerTrackChanged event, Emitter<PlayerState> emit) async {
    _audioHandler.pause();
    emit(state.copyWith(
      musicGroupId: '',
      track: event.track.asTrackDetails,
      playerState: MusicState.loading,
    ));
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
      logPrint(e, 'Track Change');
      showToast(StringRes.somethingWrong);
      emit(state.copyWith(playerState: MusicState.pause));
    }
  }
}
