import 'package:ampify/data/utils/exports.dart';

class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchEvent {}

class SearchCleared extends SearchEvent {}

class SearchTrigerred extends SearchEvent {}

class SearchInputChanged extends SearchEvent {
  final String query;
  const SearchInputChanged(this.query);

  SearchInputChanged copyWith(String? query) {
    return SearchInputChanged(query ?? this.query);
  }

  @override
  List<Object?> get props => [query, super.props];
}

class SearchState extends Equatable {
  final String query;
  final bool isError;
  final bool isLoading;
  final List<LibraryModel>? results;
  const SearchState({
    required this.query,
    this.isError = false,
    required this.isLoading,
    required this.results,
  });
  const SearchState.init()
      : query = '',
        results = null,
        isError = false,
        isLoading = false;

  SearchState copyWith({
    String? query,
    bool? isError,
    bool? isLoading,
    final List<LibraryModel>? results,
  }) {
    return SearchState(
      query: query ?? this.query,
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      results: results,
    );
  }

  @override
  List<Object?> get props => [query, isLoading, isError, results];
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(const SearchState.init()) {
    on<SearchTrigerred>(_onSearchTrigerred,
        transformer: Utils.debounce(Durations.extralong2));
    on<SearchInputChanged>(_onInputChanged);
    on<SearchInitial>(_onInit);
    on<SearchCleared>(_onSearchClear);
  }

  final YtMusicRepo _repo = getIt();
  final focusNode = FocusNode();
  final searchContr = TextEditingController();

  void _onInit(SearchInitial event, Emitter<SearchState> emit) {
    searchContr.addListener(_onSearchTextChanged);
  }

  void onSearchClear() => add(SearchCleared());

  void _onSearchTextChanged() => add(SearchInputChanged(searchContr.text));

  void _onSearchClear(SearchCleared event, Emitter<SearchState> emit) {
    searchContr.clear();
    focusNode.unfocus();
    emit(state.copyWith(isLoading: false, results: null));
  }

  Future<void> _onInputChanged(
      SearchInputChanged event, Emitter<SearchState> emit) async {
    if (state.query == event.query) return;
    if (searchContr.text.isEmpty) {
      emit(state.copyWith(isLoading: false, results: null, query: ''));
    } else {
      emit(state.copyWith(query: event.query, isLoading: true));
      add(SearchTrigerred());
    }
  }

  Future<void> _onSearchTrigerred(
      SearchTrigerred event, Emitter<SearchState> emit) async {
    try {
      if (searchContr.text.isEmpty) throw FormatException();
      final musicGroups = await _repo.search(searchContr.text);
      musicGroups.sort((a, b) {
        final fName = a.title.queryMatch(searchContr.text);
        final fArtist = a.artist?.name.queryMatch(searchContr.text) ?? 0;
        final first = fName.compareTo(fArtist);

        final sName = b.title.queryMatch(searchContr.text);
        final sArtist = b.artist?.name.queryMatch(searchContr.text) ?? 0;
        final second = sName.compareTo(sArtist);

        return second.compareTo(first);
      });

      emit(state.copyWith(isLoading: false, results: musicGroups));
    } on FormatException {
      emit(state.copyWith(isLoading: false, results: null, query: ''));
    } catch (e) {
      logPrint(e, 'search');
      emit(state.copyWith(isLoading: false, isError: true));
    }
  }
}
