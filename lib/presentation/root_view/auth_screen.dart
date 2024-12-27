import 'package:ampify/buisness_logic/root_bloc/auth_bloc.dart';
import 'package:ampify/data/utils/dimens.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/data/utils/utils.dart';
import 'package:ampify/presentation/widgets/loading_widgets.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:ampify/presentation/widgets/base_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final bloc = context.read<AuthBloc>();

    return BaseWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            StringRes.auth,
            style: Utils.titleTextStyle(scheme.onPrimaryContainer),
          ),
          const SizedBox(height: Dimens.sizeDefault),
          Text(StringRes.authDesc,
              style: TextStyle(color: scheme.textColorLight)),
          const Spacer(flex: 3),
          Center(
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: bloc.onSuccess,
              builder: (context, state) {
                return LoadingButton(
                  enable: !state.isSuccess,
                  isLoading: state.isLoading,
                  loaderColor: Colors.white,
                  onPressed: () => bloc.add(AuthInitial()),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(StringRes.auth),
                      SizedBox(width: Dimens.sizeSmall),
                      Icon(Icons.arrow_forward_rounded)
                    ],
                  ),
                );
              },
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
