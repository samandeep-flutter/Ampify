import 'package:ampify/data/utils/dimens.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  const RootState(this.index);
  const RootState.init() : index = 0;

  RootState copyWith(int? index) => RootState(index ?? this.index);

  @override
  List<Object?> get props => [index];
}

class RootBloc extends Bloc<RootEvent, RootState> {
  RootBloc() : super(const RootState.init()) {
    on<RootTabChanged>(_onTap);
  }
  late TabController tabController;

  final List<BottomNavigationBarItem> tabs = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined, size: Dimens.sizeMedium),
      activeIcon: Icon(Icons.home, size: Dimens.sizeLarge),
      label: 'Home',
      tooltip: 'Home',
    ),
    BottomNavigationBarItem(
        icon: Icon(Icons.search, size: Dimens.sizeMedium),
        activeIcon: Icon(Icons.search, size: Dimens.sizeLarge),
        label: 'Search',
        tooltip: 'Search'),
    BottomNavigationBarItem(
        icon: Icon(Icons.library_music_outlined, size: Dimens.sizeMedium),
        activeIcon: Icon(Icons.library_music, size: Dimens.sizeLarge),
        label: 'Library',
        tooltip: 'Library'),
  ];

  void _onTap(RootTabChanged event, Emitter<RootState> emit) {
    tabController.index = event.index;
    emit(state.copyWith(event.index));
  }
}
