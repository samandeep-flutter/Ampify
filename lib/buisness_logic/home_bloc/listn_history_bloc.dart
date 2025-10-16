import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListnHistoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ListnHistoryInitial extends ListnHistoryEvent {}

class ListnState extends Equatable {
  const ListnState();
  const ListnState.init();

  @override
  List<Object?> get props => [];
}

class ListnHistoryBloc extends Bloc<ListnHistoryEvent, ListnState> {
  ListnHistoryBloc() : super(const ListnState.init()) {
    on<ListnHistoryInitial>(_onInit);
  }
  void _onInit(ListnHistoryInitial event, Emitter<ListnState> emit) {}
}
