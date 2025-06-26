import 'dart:async';
import 'package:ampify/services/box_services.dart';
import 'package:ampify/data/repositories/library_repo.dart';
import 'package:ampify/data/utils/utils.dart';
import 'package:ampify/services/getit_instance.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../data/data_models/library_model.dart';

class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

class LibraryInitial extends LibraryEvent {}

class LibraryLoadMore extends LibraryEvent {}

class LibraryFiltered extends LibraryEvent {
  final LibItemType type;
  const LibraryFiltered(this.type);

  @override
  List<Object?> get props => [type, super.props];
}

class LibraryLoadTrigger extends LibraryEvent {}

class LibrarySorted extends LibraryEvent {
  final SortOrder order;
  const LibrarySorted(this.order);

  @override
  List<Object?> get props => [order, super.props];
}

class LibraryState extends Equatable {
  final SortOrder? sortby;
  final List<LibraryModel> items;
  final LibItemType? filterSel;
  final bool loading;
  final bool moreLoading;
  final int? totalLiked;
  final int playlistCount;
  final int albumCount;

  const LibraryState({
    required this.sortby,
    required this.items,
    required this.filterSel,
    required this.loading,
    required this.moreLoading,
    required this.totalLiked,
    required this.playlistCount,
    required this.albumCount,
  });
  const LibraryState.init()
      : sortby = SortOrder.custom,
        items = const [],
        totalLiked = null,
        filterSel = null,
        moreLoading = false,
        loading = true,
        albumCount = 0,
        playlistCount = 0;

  LibraryState copyWith({
    SortOrder? sortby,
    List<LibraryModel>? items,
    LibItemType? filterSel,
    int? totalLiked,
    bool? loading,
    bool? moreLoading,
    int? playlistCount,
    int? albumCount,
  }) {
    return LibraryState(
      sortby: sortby ?? this.sortby,
      items: items ?? this.items,
      filterSel: filterSel,
      loading: loading ?? this.loading,
      moreLoading: moreLoading ?? this.moreLoading,
      totalLiked: totalLiked ?? this.totalLiked,
      playlistCount: playlistCount ?? this.playlistCount,
      albumCount: albumCount ?? this.albumCount,
    );
  }

  @override
  List<Object?> get props => [
        items,
        sortby,
        filterSel,
        moreLoading,
        totalLiked,
        loading,
        playlistCount,
        albumCount
      ];
}

enum SortOrder { alphabetical, owner, custom }

EventTransformer<T> _debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc() : super(const LibraryState.init()) {
    on<LibraryInitial>(_onInit);
    on<LibraryLoadMore>(_onLoadMore);
    on<LibraryFiltered>(_onFiltered);
    on<LibraryLoadTrigger>(_onLoadTrigger, transformer: _debounce(duration));
    on<LibrarySorted>(_onSorted);
  }
  final LibraryRepo _repo = getIt();
  final box = BoxServices.instance;
  final duration = const Duration(milliseconds: 200);
  final scrollController = ScrollController();
  List<LibraryModel> _libItems = [];

  _onSorted(LibrarySorted event, Emitter<LibraryState> emit) async {
    switch (event.order) {
      case SortOrder.alphabetical:
        final items = state.items
          ..sort((a, b) => a.name?.compareTo(b.name ?? '') ?? 0);
        emit(state.copyWith(items: items, sortby: SortOrder.alphabetical));
        break;
      case SortOrder.owner:
        final items = state.items
          ..sort((a, b) => a.owner?.name?.compareTo(b.owner?.name ?? '') ?? 0);
        emit(state.copyWith(items: items, sortby: SortOrder.owner));
        break;
      case SortOrder.custom:
        final items = state.items
          ..sort((a, b) => a.id?.compareTo(b.id ?? '') ?? 0);
        emit(state.copyWith(items: items, sortby: SortOrder.custom));
        break;
    }
  }

  _loadMoreItems() {
    if (!scrollController.hasClients || state.moreLoading) return;
    final total = state.albumCount + state.playlistCount;
    if (state.items.length >= total) return;
    if (scrollController.position.extentAfter < 300) {
      add(LibraryLoadMore());
    }
  }

  _onFiltered(LibraryFiltered event, Emitter<LibraryState> emit) async {
    if (state.filterSel == null) _libItems = state.items;
    if (state.filterSel == event.type) {
      emit(state.copyWith(filterSel: null, items: _libItems));
      return;
    }

    final items = _libItems.where((e) => e.type == event.type).toList();
    emit(state.copyWith(items: items, filterSel: event.type));
  }

  _onLoadMore(LibraryLoadMore event, Emitter<LibraryState> emit) async {
    emit(state.copyWith(moreLoading: true));
    add(LibraryLoadTrigger());
  }

  _onLoadTrigger(LibraryLoadTrigger event, Emitter<LibraryState> emit) async {
    final plCompleter = Completer<bool>();
    final alCompleter = Completer<bool>();
    List<LibraryModel> items = state.items;

    final plOffset = items.where((e) => e.type == LibItemType.playlist);
    final alOffset = items.where((e) => e.type != LibItemType.playlist);

    if (plOffset.length < state.playlistCount) {
      _repo.getMyPlaylists(
          offset: plOffset.length,
          onSuccess: (json) async {
            final playlists = List<LibraryModel>.from(
                json['items']?.map((e) => LibraryModel.fromJson(e)) ?? []);
            items.addAll(playlists);
            plCompleter.complete(true);
          });
    }

    if (alOffset.length < state.albumCount) {
      _repo.getMyAlbums(
          offset: alOffset.length,
          onSuccess: (json) {
            final albums = List<LibraryModel>.from(
                json['items']?.map((e) => LibraryModel.fromJson(e['album'])) ??
                    []);
            items.addAll(albums);
            alCompleter.complete(true);
          });
    }

    if (plOffset.length < state.playlistCount) await plCompleter.future;
    if (alOffset.length < state.albumCount) await alCompleter.future;
    emit(state.copyWith(items: items, moreLoading: false));
  }

  _onInit(LibraryInitial event, Emitter<LibraryState> emit) async {
    final playlistCount = Completer<int>();
    final albumCount = Completer<int>();
    scrollController.addListener(_loadMoreItems);

    List<LibraryModel> items = [];

    _repo.getMyPlaylists(onSuccess: (json) async {
      final playlists = List<LibraryModel>.from(
          json['items']?.map((e) => LibraryModel.fromJson(e)) ?? []);
      items.addAll(playlists);
      try {
        await _repo.getLikedSongs(
            limit: 1,
            onSuccess: (json) {
              emit(state.copyWith(totalLiked: json['total']));
            });
      } catch (_) {}
      playlistCount.complete((json['total'] as int?) ?? 0);
    });

    _repo.getMyAlbums(onSuccess: (json) {
      final albums = List<LibraryModel>.from(
          json['items']?.map((e) => LibraryModel.fromJson(e['album'])) ?? []);
      items.addAll(albums);
      albumCount.complete((json['total'] as int?) ?? 0);
    });

    final plCount = await playlistCount.future;
    final alCount = await albumCount.future;

    if ((state.totalLiked ?? 0) > 0) {
      items.add(Utils.likedSongs(count: state.totalLiked));
    }
    items.sort((a, b) => a.id?.compareTo(b.id ?? '') ?? 0);
    emit(state.copyWith(
        items: items,
        loading: false,
        playlistCount: plCount,
        albumCount: alCount));
  }
}
