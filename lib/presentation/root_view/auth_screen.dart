import 'package:ampify/buisness_logic/auth_bloc/auth_bloc.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final bloc = context.read<AuthBloc>();
    final spotify = context.isDarkMode ? Colors.green[900] : Colors.green;

    return BaseWidget(
      appBar: AppBar(
        backgroundColor: scheme.background,
        toolbarHeight: Dimens.sizeLarge,
      ),
      child: Column(
        children: [
          const Spacer(),
          Text(StringRes.auth, style: Utils.titleTextStyle(scheme.textColor)),
          const SizedBox(height: Dimens.sizeDefault),
          Text(StringRes.authDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: scheme.textColorLight, fontSize: Dimens.fontDefault)),
          const Spacer(),
          const SizedBox(height: Dimens.sizeDefault),
          BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state.isSuccess) context.goNamed(AppRoutes.homeView);
            },
            builder: (context, state) {
              return LoadingButton(
                width: double.infinity,
                enable: !state.isSuccess,
                isLoading: state.isLoading,
                loaderColor: spotify,
                backgroundColor: spotify,
                padding: const EdgeInsets.symmetric(vertical: Dimens.sizeLarge),
                onPressed: () => bloc.add(AuthInitial()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(ImageRes.spotify,
                        height: Dimens.iconDefault, color: scheme.onPrimary),
                    const SizedBox(width: Dimens.sizeDefault),
                    const Text(StringRes.authSpotify),
                  ],
                ),
              );
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
