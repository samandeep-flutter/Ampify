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

class RootTabChanged extends RootEvent {
  final int index;
  const RootTabChanged(this.index);

  @override
  List<Object?> get props => [index];
}

class RootState extends Equatable {
  final int index;
  const RootState({required this.index});
  const RootState.init() : index = 0;

  RootState copyWith(int? index) {
    return RootState(index: index ?? this.index);
  }

  @override
  List<Object?> get props => [index];
}

class RootBloc extends Bloc<RootEvent, RootState> {
  RootBloc() : super(const RootState.init()) {
    on<RootTabChanged>(_onTap);
  }
  final List<BottomNavigationBarItem> tabs = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined, size: Dimens.iconMedSmall),
      activeIcon: Icon(Icons.home, size: Dimens.iconDefault),
      label: StringRes.home,
      tooltip: StringRes.home,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search, size: Dimens.iconMedSmall),
      activeIcon: Icon(Icons.search, size: Dimens.iconDefault),
      label: StringRes.search,
      tooltip: StringRes.search,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.library_music_outlined, size: Dimens.iconMedSmall),
      activeIcon: Icon(Icons.library_music, size: Dimens.iconDefault),
      label: StringRes.library,
      tooltip: StringRes.library,
    ),
  ];

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
    emit(state.copyWith(event.index));
  }
}
