import 'dart:async';
import 'package:ampify/data/utils/exports.dart';

class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

class LibraryInitial extends LibraryEvent {}

class LibraryRefresh extends LibraryEvent {}

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

enum SortOrder {
  alphabetical('Alphabetical', icon: Icons.abc),
  artist('Artist', icon: Icons.person_outline),
  custom('Custom', icon: Icons.sort_outlined),
  ;

  final String title;
  final IconData? icon;
  const SortOrder(this.title, {this.icon});
}

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc() : super(const LibraryState.init()) {
    on<LibraryInitial>(_onInit);
    on<LibraryRefresh>(_onRefresh);
    on<LibraryLoadMore>(_onLoadMore);
    on<LibraryFiltered>(_onFiltered);
    on<LibraryLoadTrigger>(_onLoadTrigger,
        transformer: Utils.debounce(Durations.short4));
    on<LibrarySorted>(_onSorted);
  }
  final box = BoxServices.instance;
  final scrollController = ScrollController();
  List<LibraryModel> _libItems = [];

  void _onInit(LibraryInitial event, Emitter<LibraryState> emit) {
    // scrollController.addListener(_loadMoreItems);
    add(LibraryRefresh());
  }

  void _onSorted(LibrarySorted event, Emitter<LibraryState> emit) {
    switch (event.order) {
      case SortOrder.alphabetical:
        final items = state.items..sort((a, b) => a.title.compareTo(b.title));
        emit(state.copyWith(items: items, sortby: event.order));
        break;
      case SortOrder.artist:
        final items = state.items
          ..sort((a, b) => a.artist?.name.compareTo(b.artist?.name ?? '') ?? 0);
        emit(state.copyWith(items: items, sortby: event.order));
        break;
      case SortOrder.custom:
        final items = state.items..sort((a, b) => a.id.compareTo(b.id));
        emit(state.copyWith(items: items, sortby: event.order));
        break;
    }
  }

  // void _loadMoreItems() {
  //   if (!scrollController.hasClients || state.moreLoading) return;
  //   final total = state.albumCount + state.playlistCount;
  //   if (_libItems.length >= total) return;
  //   if (scrollController.position.extentAfter < 300) {
  //     add(LibraryLoadMore());
  //   }
  // }

  void _onFiltered(LibraryFiltered event, Emitter<LibraryState> emit) {
    if (state.filterSel == null) _libItems = state.items;
    if (state.filterSel == event.type) {
      emit(state.copyWith(filterSel: null, items: _libItems));
      return;
    }

    final items = _libItems.where((e) => e.type == event.type).toList();
    emit(state.copyWith(items: items, filterSel: event.type));
  }

  void _onLoadMore(LibraryLoadMore event, Emitter<LibraryState> emit) {
    emit(state.copyWith(moreLoading: true));
    add(LibraryLoadTrigger());
  }

  Future<void> _onLoadTrigger(
      LibraryLoadTrigger event, Emitter<LibraryState> emit) async {
    final plCompleter = Completer<bool>();
    final alCompleter = Completer<bool>();
    List<LibraryModel> items = state.items;

    final plOffset = _libItems.where((e) => e.type.isPlaylist);
    final alOffset = _libItems.where((e) => !e.type.isPlaylist);

    try {
      if (plOffset.length < state.playlistCount) {
        // TODO: implement playlist load more mechanism
        // _repo.getMyPlaylists(
        //     offset: plOffset.length,
        //     onSuccess: (json) async {
        //       final playlists = List<LibraryModel>.from(
        //           json['items']?.map((e) => LibraryModel.fromJson(e)) ?? []);
        //       items.addAll(playlists);
        //       plCompleter.complete(true);
        //     });
      }

      if (alOffset.length < state.albumCount) {
        // TODO: implement album load more mechanism
        // _repo.getMyAlbums(
        //     offset: alOffset.length,
        //     onSuccess: (json) {
        //       final albums = List<LibraryModel>.from(json['items']
        //               ?.map((e) => LibraryModel.fromJson(e['album'])) ??
        //           []);
        //       items.addAll(albums);
        //       alCompleter.complete(true);
        //     });
      }

      if (plOffset.length < state.playlistCount) await plCompleter.future;
      if (alOffset.length < state.albumCount) await alCompleter.future;
      items.sort((a, b) => a.id.compareTo(b.id));
      _libItems = items;
      emit(state.copyWith(items: items));
    } catch (e) {
      logPrint(e, 'load more');
    } finally {
      emit(state.copyWith(moreLoading: false));
    }
  }

  Future<void> _onRefresh(
      LibraryRefresh event, Emitter<LibraryState> emit) async {
    final playlistCount = Completer<int>();
    final albumCount = Completer<int>();
    List<LibraryModel> items = [];

    try {
      // TODO: implement playlist/album refesh mechanism
      // _repo.getMyPlaylists(onSuccess: (json) async {
      //   final playlists = List<LibraryModel>.from(
      //       json['items']?.map((e) => LibraryModel.fromJson(e)) ?? []);
      //   items.addAll(playlists);
      //   try {
      //     await _repo.getLikedSongs(
      //         limit: 1,
      //         onSuccess: (json) {
      //           emit(state.copyWith(totalLiked: json['total']));
      //         });
      //   } catch (_) {}
      //   playlistCount.complete((json['total'] as int?) ?? 0);
      // });

      // _repo.getMyAlbums(onSuccess: (json) {
      //   final albums = List<LibraryModel>.from(
      //       json['items']?.map((e) => LibraryModel.fromJson(e['album'])) ?? []);
      //   items.addAll(albums);
      //   albumCount.complete((json['total'] as int?) ?? 0);
      // });

      final plCount = await playlistCount.future;
      final alCount = await albumCount.future;

      if ((state.totalLiked ?? 0) > 0) {
        items.add(Utils.likedSongs(count: state.totalLiked));
      }
      items.sort((a, b) => a.id.compareTo(b.id));
      _libItems = items;
      emit(state.copyWith(
          items: items, playlistCount: plCount, albumCount: alCount));
    } catch (e) {
      logPrint(e, 'refresh');
    } finally {
      emit(state.copyWith(loading: false));
    }
  }
}
