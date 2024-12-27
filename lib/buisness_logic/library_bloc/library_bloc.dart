import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LibraryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LibraryInitial extends LibraryEvent {}

class LibraryState extends Equatable {
  const LibraryState();
  const LibraryState.init();

  @override
  List<Object?> get props => [];
}

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc() : super(const LibraryState.init()) {
    on<LibraryInitial>(_onInit);
  }
  _onInit(LibraryInitial event, Emitter<LibraryState> emit) {}
}
