import 'package:ampify/data/utils/exports.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../library_bloc/library_bloc.dart';

sealed class RootEvent extends Equatable {
  const RootEvent();

  @override
  List<Object?> get props => [];
}

class RootInitial extends RootEvent {}

class RootTabReset extends RootEvent {}

class RootTabChanged extends RootEvent {
  final int index;
  const RootTabChanged(this.index);

  @override
  List<Object?> get props => [index, ...super.props];
}

class RootConnectivity extends RootEvent {
  final bool isConnected;
  const RootConnectivity(this.isConnected);

  @override
  List<Object?> get props => [isConnected, ...super.props];
}

class RootState extends Equatable {
  final int index;
  final bool isConnected;
  const RootState({required this.index, required this.isConnected});
  const RootState.init()
      : index = 0,
        isConnected = true;

  RootState copyWith({int? index, bool? isConnected}) {
    return RootState(
      index: index ?? this.index,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  @override
  List<Object?> get props => [index, isConnected];
}

class RootBloc extends Bloc<RootEvent, RootState> {
  RootBloc() : super(const RootState.init()) {
    on<RootInitial>(_onInit);
    on<RootTabChanged>(_onTap);
    on<RootTabReset>(_onReset);
    on<RootConnectivity>(_onConnectivity);
  }
  final List<BottomNavigationBarItem> tabs = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined, size: Dimens.iconMedSmall),
      activeIcon: Icon(Icons.home, size: Dimens.iconMedium),
      label: StringRes.home,
      tooltip: StringRes.home,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search, size: Dimens.iconMedSmall),
      activeIcon: Icon(Icons.search, size: Dimens.iconMedium),
      label: StringRes.search,
      tooltip: StringRes.search,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.library_music_outlined, size: Dimens.iconMedSmall),
      activeIcon: Icon(Icons.library_music, size: Dimens.iconMedium),
      label: StringRes.library,
      tooltip: StringRes.library,
    ),
  ];

  void _listener(bool result) => add(RootConnectivity(result));

  void _onConnectivity(RootConnectivity event, Emitter<RootState> emit) {
    emit(state.copyWith(isConnected: event.isConnected));
  }

  void _onInit(RootInitial event, Emitter<RootState> emit) {
    getIt<AuthServices>().connectionStream.listen(_listener);
  }

  void onIndexChange(BuildContext context, {required int index}) {
    final String path = GoRouterState.of(context).uri.path;
    switch (index) {
      case 0:
        if (path.startsWith(AppRoutePaths.homeView)) break;
        context.goNamed(AppRoutes.homeView);
        break;
      case 1:
        if (path.startsWith(AppRoutePaths.searchView)) break;
        context.goNamed(AppRoutes.searchView);
        break;
      case 2:
        if (path.startsWith(AppRoutePaths.libraryView)) break;
        context.read<LibraryBloc>().add(LibraryRefresh());
        context.goNamed(AppRoutes.libraryView);
        break;
    }
    add(RootTabChanged(index));
  }

  void _onTap(RootTabChanged event, Emitter<RootState> emit) {
    emit(state.copyWith(index: event.index));
  }

  void _onReset(RootTabReset event, Emitter<RootState> emit) {
    emit(state.copyWith(index: 0));
  }

  @override
  Future<void> close() {
    getIt<AuthServices>().dispose();
    return super.close();
  }
}
