import 'package:ampify/config/routes/app_routes.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeEvent {}

class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeInitial>(_onInIt);
  }

  _onInIt(HomeInitial event, Emitter<HomeState> emit) {}

  void toHistory(BuildContext context) {
    context.pushNamed(AppRoutes.listnHistory);
  }
}
