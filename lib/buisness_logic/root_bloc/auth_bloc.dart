import 'dart:async';
import 'package:ampify/data/repositories/auth_repo.dart';
import 'package:ampify/data/repositories/library_repo.dart';
import 'package:ampify/data/utils/app_constants.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/services/box_services.dart';
import 'package:ampify/services/getit_instance.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthEvent {}

class AuthFinished extends AuthEvent {}

class AuthState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  const AuthState({required this.isLoading, required this.isSuccess});

  const AuthState.init()
      : isLoading = false,
        isSuccess = false;

  AuthState copyWith({bool? isLoading, bool? isSuccess}) {
    return AuthState(
        isLoading: isLoading ?? this.isLoading,
        isSuccess: isSuccess ?? this.isSuccess);
  }

  @override
  List<Object?> get props => [isLoading, isSuccess];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState.init()) {
    on<AuthInitial>(_onInit);
    on<AuthFinished>(_onFinish);
  }
  final AuthRepo _authRepo = getIt();
  final LibraryRepo _libRepo = getIt();
  final _box = BoxServices.instance;

  Future<void> _onInit(AuthInitial event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final code = await _authRepo.auth();
      try {
        await _authRepo.getToken(code!);
        add(AuthFinished());
        return;
      } catch (_) {}
      _box.listen(BoxKeys.token, (_) => add(AuthFinished()));
    } catch (e) {
      logPrint(e, 'auth init');
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onFinish(AuthFinished event, Emitter<AuthState> emit) async {
    final completer = Completer<bool>();
    await _libRepo.getProfile(onSuccess: (json) async {
      await _box.write(BoxKeys.profile, json);
      completer.complete(true);
      emit(state.copyWith(isLoading: false, isSuccess: true));
    }, onError: (e) {
      emit(state.copyWith(isLoading: false));
      showToast(StringRes.somethingWrong);
      logPrint(e, 'profile');
    });
    await completer.future;
  }
}
