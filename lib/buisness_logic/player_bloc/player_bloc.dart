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
    on<PlayerTrackChanged>(_onTrackChange);
    on<MusicGroupPlayed>(_onMusicGroup);
    on<PlayerMediaStream>(_onMediaStream,
        transformer: Utils.debounce(Durations.long2));
    on<PlayerPlaybackStream>(_onPlaybackStream,
        transformer: Utils.debounce(Durations.long2));
    on<PlayerNextTrack>(_onNextTrack);
    on<PlayerPreviousTrack>(_onPreviousTrack);
  }

  @override
  void onChange(Change<PlayerState> change) {
    dprint(change.changesOnly);
    super.onChange(change);
  }

  @override
  void onEvent(PlayerEvent event) {
    dprint(event.runtimeType.toString());
    super.onEvent(event);
  }

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
      logPrint(value, 'seek');
    }
  }

  void onPlayPause() => _audioHandler.click();

  void onTrackLiked(String id, [bool? liked]) {
    add(PlayerTrackLiked(id, liked: liked));
  }

  void onTrackShare(String id) {}

  void onShuffle() => add(PlayerShuffleToggle());

  void onRepeat() {
    _audioHandler.setRepeatMode(state.loopMode.toAudioState);
  }

  void clearQueue() => add(PlayerQueueCleared());

  void clearUpnext() {}

  void onQueueReorder(int pr, int cr) {
    add(PlayerQueueReordered(previous: pr, current: cr));
  }

  // void _createPosition(Duration? duration) {
  //   AudioService.createPositionStream(
  //     steps: duration?.inSeconds ?? 60,
  //     maxPeriod: duration ?? Durations.extralong4,
  //     minPeriod: Durations.extralong4,
  //   );
  // }

  void _onMediaStream(PlayerMediaStream event, Emitter<PlayerState> emit) {
    final json = event.mediaItem.extras;
    final track = TrackDetails.fromJson(json!);
    if (track.id == state.track.id) return;
    emit(state.copyWith(track: track));
  }

  void _onPlaybackStream(
      PlayerPlaybackStream event, Emitter<PlayerState> emit) {
    final _state = event.state.playerState;
    final _loop = event.state.repeatMode.toLoopMode;
    final loop = state.loopMode == _loop ? null : _loop;
    final playerState = _state == state.playerState ? null : _state;
    if (loop != null || playerState != null) {
      emit(state.copyWith(playerState: playerState, loopMode: loop));
    }
  }

  void _onNextTrack(PlayerNextTrack event, Emitter<PlayerState> emit) async {
    if (state.queue.isNotEmpty) {
      emit(state.copyWith(queue: state.queue.skip(1).toList()));
    } else if (state.upNext.isNotEmpty) {
      emit(state.copyWith(upNext: state.upNext.skip(1).toList()));
    }
    await _audioHandler.skipToNext();
  }

  void _onPreviousTrack(
      PlayerPreviousTrack event, Emitter<PlayerState> emit) async {
    if (state.queue.isNotEmpty) {
      final queue = [state.track, ...state.queue];
      emit(state.copyWith(queue: queue));
    } else if (state.upNext.isNotEmpty) {
      final upNext = [state.track.asTrack, ...state.upNext];
      emit(state.copyWith(upNext: upNext));
    }
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
      _audioHandler.customAction(PlayerActions.removeUpcomming);
      final uri = await _musicRepo.fromVideoId(state.queue.first.videoId);
      final _media = Utils.toMediaItem(state.queue.first, uri: uri);
      _audioHandler.addQueueItem(_media);
    } catch (e) {
      logPrint(e, 'Queue next');
    }
  }

  Future<void> _onTrackLiked(
      PlayerTrackLiked event, Emitter<PlayerState> emit) async {
    if (event.liked ?? false) {
      try {
        emit(state.copyWith(isLiked: false));
        final result = await _libRepo.removefromLikedSongs(event.id);
        if (!result) throw Exception();
      } catch (e) {
        emit(state.copyWith(isLiked: true));
      }
      return;
    }
    try {
      if (state.track.id == event.id) {
        emit(state.copyWith(isLiked: true));
      }
      final result = await _libRepo.addtoLikedSongs(event.id);
      if (!result) throw FormatException();
    } on FormatException {
      if (state.track.id == event.id) {
        emit(state.copyWith(isLiked: false));
      }
    } catch (e) {
      logPrint(e, 'Liked');
    }
  }

  Future<void> _shuffleToggle(
      PlayerShuffleToggle event, Emitter<PlayerState> emit) async {
    // TODO: implement shuffle toggle
    // await player.setShuffleModeEnabled(!state.shuffle);
    emit(state.copyWith(shuffle: !state.shuffle));
  }

  Future<void> _onQueueAdded(
      PlayerQueueAdded event, Emitter<PlayerState> emit) async {
    try {
      if (state.playerState.isHidden) {
        showToast(StringRes.noQueue);
        return;
      }
      showToast(StringRes.queueAdded);
      final track = await Utils.getTrackDetails(event.track);
      emit(state.copyWith(queue: [...state.queue, track]));
      if (state.upNext.isNotEmpty) {
        _audioHandler.customAction(PlayerActions.removeUpcomming);
      }
      if (_audioHandler.queue.isLast(state.queue)) return;
      logPrint('song added instaneously...');
      final uri = await _musicRepo.fromVideoId(track.videoId);
      final _media = Utils.toMediaItem(track, uri: uri);
      _audioHandler.addQueueItem(_media);
    } catch (e) {
      logPrint(e, 'Queue instaneous');
    }
  }

  Future<void> _onTrackEnded(
      PlayerTrackEnded event, Emitter<PlayerState> emit) async {
    if (state.queue.isEmpty && state.upNext.isEmpty) {
      emit(state.copyWith(musicGroupId: null, playerState: MusicState.hidden));
      logPrint('empty queue...');
      return;
    }
    if (state.queue.isNotEmpty) {
      await _playTrackFromQueue(emit);
    } else if (state.upNext.isNotEmpty) {
      await _playTrackFromUpNext(emit);
    }
    await _prepareNextTrackSource();
  }

  Future<void> _playTrackFromQueue(Emitter<PlayerState> emit) async {
    final track = state.queue.first;
    final newQueue = state.queue.skip(1).toList();
    logPrint(track.title, 'next from queue');
    try {
      emit(state.copyWith(queue: newQueue));
      // _createPosition(track.duration);
      // _audioHandler.play();
    } catch (e) {
      emit(state.copyWith(playerState: MusicState.pause));
      logPrint(e, 'queue');
    }
  }

  Future<void> _playTrackFromUpNext(Emitter<PlayerState> emit) async {
    try {
      emit(state.copyWith(
          track: state.upNext.first.asTrackDetails,
          playerState: MusicState.loading));
      final track = await Utils.getTrackDetails(state.upNext.first);
      final newUpNext = state.upNext.skip(1).toList();
      emit(state.copyWith(upNext: newUpNext));
      // _createPosition(track.duration);
      final _queue = _audioHandler.queue.value;
      final _item = _queue.firstWhere((item) => item.id == track.id);
      await _audioHandler
          .updateMediaItem(_item.copyWith(duration: track.duration));
      _audioHandler.play();
    } catch (e) {
      emit(state.copyWith(playerState: MusicState.pause));
      logPrint(e, 'upNext');
    }
  }

  Future<void> _prepareNextTrackSource() async {
    if (state.queue.isNotEmpty) {
      final track = state.queue.first;
      try {
        final uri = await _musicRepo.fromVideoId(track.videoId);
        final _media = Utils.toMediaItem(track, uri: uri);
        await _audioHandler.addQueueItem(_media);
        _audioHandler.play();
      } catch (e) {
        logPrint(e, 'preloading queue');
      }
    } else if (state.upNext.isNotEmpty) {
      final track = state.upNext.first;
      try {
        final artist = track.artists?.asString.split(',').first;
        final uri = await _musicRepo.searchSong('${track.name} $artist');
        final _media = Utils.toMediaItem(track.asTrackDetails, uri: uri);
        await _audioHandler.addQueueItem(_media);
        _audioHandler.play();
      } catch (e) {
        logPrint(e, 'preloading upNext');
      }
    }
  }

  void _onQueueCleared(PlayerQueueCleared event, Emitter<PlayerState> emit) {
    _audioHandler.customAction(PlayerActions.removeUpcomming);
    emit(state.copyWith(queue: []));
  }

  Future<void> _onMusicGroup(
      MusicGroupPlayed event, Emitter<PlayerState> emit) async {
    await _audioHandler.customAction(PlayerActions.clearQueue);
    emit(state.copyWith(
      track: event.tracks.first.asTrackDetails,
      playerState: MusicState.loading,
      musicGroupId: event.id,
      isLiked: event.liked,
    ));
    final track = await Utils.getTrackDetails(event.tracks.first);
    final uri = await _musicRepo.fromVideoId(track.videoId);
    final _media = Utils.toMediaItem(track, uri: uri);
    _audioHandler.addQueueItem(_media);
    // _createPosition(track.duration);
    _audioHandler.play();
    final upnext = event.tracks.skip(1).toList();
    emit(state.copyWith(queue: [], upNext: upnext));
  }

  Future<void> _onTrackChange(
      PlayerTrackChanged event, Emitter<PlayerState> emit) async {
    _audioHandler.pause();
    emit(state.copyWith(
        track: event.track.asTrackDetails, playerState: MusicState.loading));
    final track = await Utils.getTrackDetails(event.track);
    emit(state.copyWith(track: track, isLiked: event.liked));
    try {
      _audioHandler.customAction(PlayerActions.clearQueue);
      emit(state.copyWith(queue: []));
      final uri = await _musicRepo.fromVideoId(track.videoId);
      final _media = Utils.toMediaItem(track, uri: uri);
      await _audioHandler.playMediaItem(_media);
      // _createPosition(track.duration);
      _audioHandler.play();
    } catch (e) {
      logPrint(e, 'Track Change');
      showToast(StringRes.somethingWrong);
      emit(state.copyWith(playerState: MusicState.pause));
    }
  }
}
