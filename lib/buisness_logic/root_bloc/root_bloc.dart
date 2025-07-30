import 'package:ampify/data/data_models/profile_model.dart';
import 'package:ampify/data/repositories/library_repo.dart';
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

class RootTabChanged extends RootEvent {
  final int index;
  const RootTabChanged(this.index);

  @override
  List<Object?> get props => [index];
}

class RootState extends Equatable {
  final int index;
  final ProfileModel? profile;
  const RootState({required this.index, required this.profile});
  const RootState.init()
      : index = 0,
        profile = null;

  RootState copyWith({int? index, ProfileModel? profile}) {
    return RootState(
        index: index ?? this.index, profile: profile ?? this.profile);
  }

  @override
  List<Object?> get props => [index, profile];
}

class RootBloc extends Bloc<RootEvent, RootState> {
  RootBloc() : super(const RootState.init()) {
    on<RootInitial>(_onInit);
    on<RootTabChanged>(_onTap);
  }
  final LibraryRepo _libRepo = getIt();

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

  void _onInit(RootInitial event, Emitter<RootState> emit) async {
    await _libRepo.getProfile(onSuccess: (json) {
      emit(state.copyWith(profile: ProfileModel.fromJson(json)));
    });
  }

  void _onTap(RootTabChanged event, Emitter<RootState> emit) {
    emit(state.copyWith(index: event.index));
  }
}
