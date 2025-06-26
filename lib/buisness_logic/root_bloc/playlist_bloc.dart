import 'package:ampify/data/repositories/music_group_repo.dart';
import 'package:ampify/services/getit_instance.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlaylistEvents extends Equatable {
  const PlaylistEvents();

  @override
  List<Object?> get props => [];
}

class CreatePlaylist extends PlaylistEvents {
  final String title;
  final String userId;
  const CreatePlaylist({required this.userId, required this.title});

  @override
  List<Object?> get props => [userId, title, super.props];
}

class PlaylistState extends Equatable {
  final bool loading;
  final bool success;

  const PlaylistState({required this.loading, required this.success});

  const PlaylistState.init()
      : loading = false,
        success = false;

  PlaylistState copyWith({bool? loading, bool? success}) {
    return PlaylistState(
      loading: loading ?? this.loading,
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props => [loading, success];
}

class PlaylistBloc extends Bloc<PlaylistEvents, PlaylistState> {
  PlaylistBloc() : super(const PlaylistState.init()) {
    on<CreatePlaylist>(_onCreate);
  }

  final titleController = TextEditingController();
  final titleKey = GlobalKey<FormFieldState>();
  final MusicGroupRepo _repo = getIt();

  void createPlaylist(String id) {
    if (!(titleKey.currentState?.validate() ?? false)) return;
    add(CreatePlaylist(title: titleController.text, userId: id));
  }

  _onCreate(CreatePlaylist event, Emitter<PlaylistState> emit) async {
    emit(state.copyWith(loading: true));
    await _repo.createPlaylist(event.title, userId: event.userId,
        onSuccess: (json) {
      emit(state.copyWith(success: true, loading: false));
      titleController.clear();
    });
  }
}
