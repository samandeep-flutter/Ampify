import 'dart:async';
import 'package:ampify/data/utils/exports.dart';

class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

class LibraryInitial extends LibraryEvent {}

class LibraryRefresh extends LibraryEvent {}

class LibraryFiltered extends LibraryEvent {
  final LibItemType type;
  const LibraryFiltered(this.type);

  @override
  List<Object?> get props => [type, super.props];
}

class LibrarySorted extends LibraryEvent {
  final SortOrder order;
  const LibrarySorted(this.order);

  @override
  List<Object?> get props => [order, super.props];
}

class LibraryState extends Equatable {
  final SortOrder? sortby;
  final List<LibDbModel> items;
  final LibItemType? filterSel;
  final bool loading;
  final int? totalLiked;

  const LibraryState({
    required this.sortby,
    required this.items,
    required this.filterSel,
    required this.loading,
    required this.totalLiked,
  });
  const LibraryState.init()
      : sortby = SortOrder.custom,
        items = const [],
        filterSel = null,
        totalLiked = null,
        loading = true;

  LibraryState copyWith({
    SortOrder? sortby,
    List<LibDbModel>? items,
    LibItemType? filterSel,
    bool? loading,
    int? totalLiked,
  }) {
    return LibraryState(
      sortby: sortby ?? this.sortby,
      items: items ?? this.items,
      filterSel: filterSel,
      loading: loading ?? this.loading,
      totalLiked: totalLiked ?? this.totalLiked,
    );
  }

  @override
  List<Object?> get props => [items, sortby, filterSel, loading, totalLiked];
}

enum SortOrder {
  alphabetical('Alphabetical', icon: Icons.abc),
  artist('Artist', icon: Icons.person_outline),
  custom('Custom', icon: Icons.sort_outlined);

  final String title;
  final IconData? icon;
  const SortOrder(this.title, {this.icon});
}

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc() : super(const LibraryState.init()) {
    on<LibraryInitial>(_onInit);
    on<LibraryRefresh>(_onRefresh);
    on<LibraryFiltered>(_onFiltered);
    on<LibrarySorted>(_onSorted);
  }
  final _libRepo = AppConstants.libraryCollection;
  String get uid => BoxServices.instance.uid!;

  final scrollController = ScrollController();
  List<LibDbModel> _libItems = [];

  void _onInit(LibraryInitial event, Emitter<LibraryState> emit) {
    add(LibraryRefresh());
  }

  void _onSorted(LibrarySorted event, Emitter<LibraryState> emit) {
    switch (event.order) {
      case SortOrder.alphabetical:
        final items = state.items
          ..sort((a, b) => a.item.title.compareTo(b.item.title));
        emit(state.copyWith(items: items, sortby: event.order));
        break;
      case SortOrder.artist:
        final items = state.items
          ..sort((a, b) =>
              a.item.artist?.name.compareTo(b.item.artist?.name ?? '') ?? 0);
        emit(state.copyWith(items: items, sortby: event.order));
        break;
      case SortOrder.custom:
        final items = state.items
          ..sort((a, b) => a.addedAt.compareTo(b.addedAt));
        emit(state.copyWith(items: items, sortby: event.order));
        break;
    }
    _libRepo.doc(uid).update({'sort_order': event.order.name});
  }

  void _onFiltered(LibraryFiltered event, Emitter<LibraryState> emit) {
    if (state.filterSel == null) _libItems = state.items;
    if (state.filterSel == event.type) {
      emit(state.copyWith(filterSel: null, items: _libItems));
      return;
    }

    final items = _libItems.where((e) => e.item.type == event.type).toList();
    emit(state.copyWith(items: items, filterSel: event.type));
    _libRepo.doc(uid).update({'filter_order': event.type.id});
  }

  Future<void> _onRefresh(
      LibraryRefresh event, Emitter<LibraryState> emit) async {
    try {
      final likedCount = Completer<int?>();
      final _likedRepo = AppConstants.likedCollection(uid);
      _likedRepo.count().get().then((e) {
        likedCount.complete(e.count);
      });

      final _json = await _libRepo.doc(uid).get();
      final lib = LibResponseModel.fromJson(_json.data());

      _libItems = lib.items;
      final items = List<LibDbModel>.from(lib.items);
      items.sort((a, b) => a.item.id.compareTo(b.item.id));

      final liked = await likedCount.future;
      items.insert(0, Utils.likedSongs(count: liked));
      emit(state.copyWith(
        items: items,
        sortby: lib.sortby,
        filterSel: lib.filterSel,
        totalLiked: liked,
      ));
    } catch (e) {
      logPrint(e, 'refresh');
    } finally {
      emit(state.copyWith(loading: false));
    }
  }
}
