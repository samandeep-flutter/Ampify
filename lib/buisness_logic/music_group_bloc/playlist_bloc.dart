import 'package:ampify/data/utils/exports.dart';

class PlaylistEvents extends Equatable {
  const PlaylistEvents();

  @override
  List<Object?> get props => [];
}

class CreatePlaylist extends PlaylistEvents {
  final String title;
  final String uid;
  const CreatePlaylist({required this.uid, required this.title});

  @override
  List<Object?> get props => [uid, title, super.props];
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
    add(CreatePlaylist(title: titleController.text, uid: id));
  }

  Future<void> _onCreate(
      CreatePlaylist event, Emitter<PlaylistState> emit) async {
    emit(state.copyWith(loading: true));
    final id = BoxServices.instance.uid!;
    await _repo.createPlaylist(id, event.title);
    emit(state.copyWith(success: true, loading: false));
    titleController.clear();
  }
}
