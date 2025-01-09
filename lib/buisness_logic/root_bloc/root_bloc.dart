import 'package:ampify/config/routes/app_routes.dart';
import 'package:ampify/data/repository/auth_repo.dart';
import 'package:ampify/data/utils/dimens.dart';
import 'package:ampify/services/getit_instance.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/utils/string.dart';

sealed class RootEvent extends Equatable {
  const RootEvent();

  @override
  List<Object?> get props => [];
}

class RootInitial extends RootEvent {}

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
    on<RootInitial>(_onInit);
    on<RootTabChanged>(_onTap);
  }

  final List<BottomNavigationBarItem> tabs = const [
    BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined, size: Dimens.sizeMedium),
        activeIcon: Icon(Icons.home, size: Dimens.sizeLarge),
        label: StringRes.home,
        tooltip: StringRes.home),
    BottomNavigationBarItem(
        icon: Icon(Icons.search, size: Dimens.sizeMedium),
        activeIcon: Icon(Icons.search, size: Dimens.sizeLarge),
        label: StringRes.search,
        tooltip: StringRes.search),
    BottomNavigationBarItem(
        icon: Icon(Icons.library_music_outlined, size: Dimens.sizeMedium),
        activeIcon: Icon(Icons.library_music, size: Dimens.sizeLarge),
        label: StringRes.library,
        tooltip: StringRes.library),
  ];

  onIndexChange(BuildContext context, {required int index}) {
    switch (index) {
      case 0:
        context.goNamed(AppRoutes.homeView);
        break;
      case 1:
        context.goNamed(AppRoutes.searchView);
        break;
      case 2:
        context.goNamed(AppRoutes.libraryView);
        break;
    }
    add(RootTabChanged(index));
  }

  void _onInit(RootInitial event, Emitter<RootState> emit) async {
    await getIt<AuthRepo>().refreshToken();
  }

  void _onTap(RootTabChanged event, Emitter<RootState> emit) {
    emit(state.copyWith(event.index));
  }
}
