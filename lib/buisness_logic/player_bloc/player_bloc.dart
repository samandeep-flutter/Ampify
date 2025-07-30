import 'dart:async';
import 'package:ampify/buisness_logic/player_bloc/player_state.dart';
import 'package:ampify/data/repositories/library_repo.dart';
import 'package:ampify/data/repositories/music_repo.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/transformers.dart';
import '../../data/data_models/common/tracks_model.dart';
import 'player_events.dart';

EventTransformer<T> _debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc() : super(const PlayerState.init()) {
    on<PlayerInitial>(_onInit);
    on<PlayerTrackLiked>(_onTrackLiked);
    on<PlayerShuffleToggle>(_shuffleToggle);
    on<PlayerQueueReordered>(_onReorder);
    on<PlayerQueueAdded>(_onQueueAdded, transformer: _debounce(_duration));
    on<PlayerTrackEnded>(_onTrackEnded, transformer: _debounce(longDuration));
    on<PlayerQueueCleared>(_onQueueCleared);
    on<PlayerTrackChanged>(_onTrackChange);
    on<MusicGroupPlayed>(_onMusicGroup);
    on<PlayerMediaStream>(_onMediaStream);
    on<PlayerPlaybackStream>(_onPlaybackStream);
  }

  @override
  void onChange(Change<PlayerState> change) {
    dprint(change.changesOnly);
    super.onChange(change);
  }

  @override
  Future<void> close() {
    positionStream?.drain();
    return super.close();
  }

  final _duration = const Duration(milliseconds: 500);
  final longDuration = const Duration(seconds: 2);

  final AudioHandler _audioHandler = getIt();
  final MusicRepo _musicRepo = getIt();
  final LibraryRepo _libRepo = getIt();

  Stream<Duration>? positionStream;

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

  void onPlayPause() {
    if (state.playerState.isPlaying) {
      _audioHandler.pause();
    } else if (state.playerState.isPause) {
      _audioHandler.play();
    }
  }

  void onTrackLiked(String id, [bool? liked]) {
    add(PlayerTrackLiked(id, liked: liked));
  }

  void onTrackShare(String id) {}

  void onShuffle() => add(PlayerShuffleToggle());

  void onRepeat() => _audioHandler.setRepeatMode(state.loopMode.toAudioState);

  void clearQueue() => add(PlayerQueueCleared());

  void clearUpnext() {}

  void onPrevious() {}

  void onNext() {}

  void onQueueReorder(int pr, int cr) {
    add(PlayerQueueReordered(previous: pr, current: cr));
  }

  void _createPosition(Duration? duration) {
    positionStream = AudioService.createPositionStream(
      steps: duration?.inSeconds ?? 60,
      maxPeriod: duration ?? Durations.extralong4,
      minPeriod: Durations.extralong4,
    );
  }

  void _onMediaStream(PlayerMediaStream event, Emitter<PlayerState> emit) {
    final json = event.mediaItem.extras;
    final track = TrackDetails.fromJson(json!);
    emit(state.copyWith(track: track));
  }

  void _onPlaybackStream(
      PlayerPlaybackStream event, Emitter<PlayerState> emit) {
    final _state = event.state.playerState;
    final _loop = event.state.repeatMode.toLoopMode;
    emit(state.copyWith(playerState: _state, loopMode: _loop));
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
      if (_audioHandler.queue.value.isNotEmpty) return;
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
      emit(state.copyWith(musicGroupId: null));
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
      emit(state.copyWith(queue: newQueue, length: track.duration));
      _createPosition(track.duration);
      _audioHandler.play();
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
      emit(state.copyWith(upNext: newUpNext, length: track.duration));
      _createPosition(track.duration);
      final _queue = _audioHandler.queue.value;
      final _item = _queue.firstWhere((item) => item.id == track.id);
      _audioHandler.updateMediaItem(_item.copyWith(duration: track.duration));
      await _audioHandler.play();
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
        _audioHandler.addQueueItem(_media);
      } catch (e) {
        logPrint(e, 'preloading queue');
      }
    } else if (state.upNext.isNotEmpty) {
      final track = state.upNext.first;
      try {
        final artist = track.artists?.asString.split(',').first;
        final uri = await _musicRepo.searchSong('${track.name} $artist');
        final _media = Utils.toMediaItem(track.asTrackDetails, uri: uri);
        _audioHandler.addQueueItem(_media);
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
    _createPosition(track.duration);

    emit(state.copyWith(length: track.duration));
    _audioHandler.play();
    final upnext = event.tracks.skip(1).toList();
    emit(state.copyWith(queue: [], upNext: upnext));
  }

  Future<void> _onTrackChange(
      PlayerTrackChanged event, Emitter<PlayerState> emit) async {
    _audioHandler.pause();
    final track = await Utils.getTrackDetails(event.track);
    emit(state.copyWith(
        track: track, isLiked: event.liked, length: track.duration));
    try {
      _audioHandler.customAction(PlayerActions.clearQueue);
      emit(state.copyWith(queue: []));
      final uri = await _musicRepo.fromVideoId(track.videoId);
      final _media = Utils.toMediaItem(track, uri: uri);
      _audioHandler.addQueueItem(_media);
      _createPosition(track.duration);
      _audioHandler.play();
    } catch (e) {
      logPrint(e, 'Track Change');
      showToast(StringRes.somethingWrong);
      emit(state.copyWith(playerState: MusicState.pause));
    }
  }
}
