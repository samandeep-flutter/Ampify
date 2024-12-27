import 'dart:io';

import 'package:ampify/config/routes/app_routes.dart';
import 'package:ampify/data/repository/auth_repo.dart';
import 'package:ampify/data/utils/app_constants.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/services/box_services.dart';
import 'package:ampify/services/getit_instance.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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

  _onInit(AuthInitial event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true));
    final code = await _authRepo.auth();
    if (code != null) {
      await _authRepo.getToken(code);
      add(AuthFinished());
      return;
    }

    if (Platform.isAndroid) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (BoxServices.to.exist(BoxKeys.token)) {
        add(AuthFinished());
        return;
      }
    }
    emit(state.copyWith(isLoading: false));
    showToast(StringRes.somethingWrong);
  }

  void onSuccess(BuildContext context, AuthState state) {
    if (state.isSuccess) context.goNamed(AppRoutes.rootView);
  }

  _onFinish(AuthFinished event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: false, isSuccess: true));
  }
}
