import 'package:ampify/config/routes/app_routes.dart';
import 'package:ampify/data/utils/color_resources.dart';
import 'package:ampify/data/utils/dimens.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/presentation/widgets/my_alert_dialog.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/utils/app_constants.dart';
import '../../services/box_services.dart';

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

  void logout(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return MyAlertDialog(
            title: '${StringRes.logout} ?',
            content: const Text(StringRes.logoutDesc),
            actionPadding: const EdgeInsets.only(
                right: Dimens.sizeDefault, bottom: Dimens.sizeSmall),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: context.scheme.textColor,
                ),
                child: const Text(StringRes.cancel),
              ),
              TextButton(
                onPressed: () {
                  BoxServices.to.remove(BoxKeys.token);
                  context.goNamed(AppRoutes.auth);
                },
                style: TextButton.styleFrom(
                  foregroundColor: ColorRes.error,
                ),
                child: Text(StringRes.logout.toUpperCase()),
              ),
            ],
          );
        });
  }
}
