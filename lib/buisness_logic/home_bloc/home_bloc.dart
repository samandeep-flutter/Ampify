import 'dart:async';
import 'package:ampify/data/utils/exports.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeEvent {}

class HomeState extends Equatable {
  final bool albumLoading;
  final bool recentLoading;
  final List<MyHomeSection> albums;
  final List<Track> recentlyPlayed;
  const HomeState({
    required this.albums,
    required this.recentlyPlayed,
    required this.albumLoading,
    required this.recentLoading,
  });

  const HomeState.init()
      : albums = const [],
        recentlyPlayed = const [],
        recentLoading = true,
        albumLoading = true;

  HomeState copyWith({
    bool? albumLoading,
    bool? recentLoading,
    List<Track>? recentlyPlayed,
    List<MyHomeSection>? albums,
  }) {
    return HomeState(
      albums: albums ?? this.albums,
      recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
      albumLoading: albumLoading ?? this.albumLoading,
      recentLoading: recentLoading ?? this.recentLoading,
    );
  }

  @override
  List<Object?> get props =>
      [albums, albumLoading, recentlyPlayed, recentLoading];
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState.init()) {
    on<HomeInitial>(_onInIt);
  }

  final YTMusic _provider = getIt();

  Future<void> _onInIt(HomeInitial event, Emitter<HomeState> emit) async {
    try {
      final _list = await _provider.getHomeSections();
      final list = _list.map((e) => MyHomeSection.fromYT(e)).toList();
      emit(state.copyWith(
          albums: list, albumLoading: false, recentLoading: false));
    } catch (e) {
      logPrint(e, 'home');
      emit(state.copyWith(albumLoading: false, recentLoading: false));
    }
    Future(NotiServices.instance.initialize);
  }
}
