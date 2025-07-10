import 'package:ampify/services/extension_services.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/music_group_repo.dart';
import '../../data/utils/app_constants.dart';
import '../../data/utils/string.dart';
import '../../services/getit_instance.dart';

class EditPlaylistEvents extends Equatable {
  const EditPlaylistEvents();

  @override
  List<Object?> get props => [];
}

class EditPlaylistInitial extends EditPlaylistEvents {
  final String? id;
  final String? image;
  final String? title;
  final String? desc;
  const EditPlaylistInitial(
      {required this.id, required this.title, this.desc, this.image});

  @override
  List<Object?> get props => [id, title, desc, image, super.props];
}

class EditPlaylistDetails extends EditPlaylistEvents {
  final String? title;
  final String? desc;
  const EditPlaylistDetails({this.title, this.desc});

  @override
  List<Object?> get props => [title, desc, super.props];
}

class EditPlaylistState extends Equatable {
  final String? id;
  final String? title;
  final String? desc;
  final String? image;
  final bool public;
  final bool loading;
  final bool success;

  const EditPlaylistState({
    required this.id,
    required this.title,
    required this.desc,
    required this.image,
    required this.public,
    required this.loading,
    required this.success,
  });

  const EditPlaylistState.init()
      : id = null,
        title = null,
        desc = null,
        image = null,
        public = false,
        loading = false,
        success = false;

  EditPlaylistState copyWith({
    String? id,
    String? image,
    String? title,
    String? desc,
    bool? public,
    bool? loading,
    bool? success,
  }) {
    return EditPlaylistState(
      id: id ?? this.id,
      image: image ?? this.image,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      public: public ?? this.public,
      loading: loading ?? this.loading,
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props => [loading, success];
}

class EditPlaylistBloc extends Bloc<EditPlaylistEvents, EditPlaylistState> {
  EditPlaylistBloc() : super(const EditPlaylistState.init()) {
    on<EditPlaylistDetails>(_onEditDetails);
    on<EditPlaylistInitial>(_onInit);
  }
  final MusicGroupRepo _repo = getIt();
  final titleContr = TextEditingController();
  final descContr = TextEditingController();

  void onEdited() {
    add(EditPlaylistDetails(
        title: titleContr.text.isNotEmpty ? titleContr.text : null,
        desc: descContr.text.isNotEmpty ? descContr.text : null));
  }

  Future<void> _onInit(
      EditPlaylistInitial event, Emitter<EditPlaylistState> emit) async {
    titleContr.text = event.title?.unescape ?? '';
    descContr.text = event.desc?.unescape ?? '';
    emit(state.copyWith(
        id: event.id,
        title: event.title,
        desc: event.desc,
        image: event.image));
  }

  Future<void> _onEditDetails(
      EditPlaylistDetails event, Emitter<EditPlaylistState> emit) async {
    emit(state.copyWith(loading: true));
    final result = await _repo.editPlaylist(
        id: state.id!,
        title: event.title ?? state.title!,
        desc: event.desc ?? state.desc!,
        public: state.public);

    emit(state.copyWith(loading: false, success: result));
    showToast(StringRes.detailsUpdated);
  }
}
