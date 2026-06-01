import 'package:ampify/data/utils/exports.dart';
import '../library_bloc/library_bloc.dart';

sealed class RootEvent extends Equatable {
  const RootEvent();

  @override
  List<Object?> get props => [];
}

class RootTabReset extends RootEvent {}

class RootTabChanged extends RootEvent {
  final int index;
  const RootTabChanged(this.index);

  @override
  List<Object?> get props => [index, ...super.props];
}

class RootState extends Equatable {
  final int index;
  const RootState({required this.index});
  const RootState.init() : index = 0;

  RootState copyWith({int? index}) {
    return RootState(index: index ?? this.index);
  }

  @override
  List<Object?> get props => [index];
}

class RootBloc extends Bloc<RootEvent, RootState> {
  RootBloc() : super(const RootState.init()) {
    on<RootTabChanged>(_onTap);
    on<RootTabReset>(_onReset);
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

  final AuthServices auth = getIt();

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
}
