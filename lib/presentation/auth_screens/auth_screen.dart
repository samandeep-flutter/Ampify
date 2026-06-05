import 'package:ampify/buisness_logic/auth_bloc/auth_bloc.dart';
import 'package:ampify/data/utils/exports.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final bloc = context.read<AuthBloc>();

    return BaseWidget(
      bodyPadding: Utils.insetsHoriz(Dimens.sizeXLarge),
      child: ListView(
        padding: Utils.paddingClamp(context),
        children: [
          SizedBox(height: context.height * .1),
          Align(
            child: Text(StringRes.welcome,
                style: Utils.titleTextStyle(scheme.textColor)),
          ),
          const SizedBox(height: Dimens.sizeExtraSmall),
          Text(StringRes.authDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: scheme.textColorLight, fontSize: Dimens.fontDefault)),
          SizedBox(height: context.height * .06),
          Form(
              key: bloc.formKey,
              child: Column(
                children: [
                  MyTextField(
                    isEmail: true,
                    title: 'Email Address',
                    controller: bloc.emailContr,
                    keyboardType: TextInputType.emailAddress,
                    backgroundColor: scheme.backgroundDark,
                  ),
                  const SizedBox(height: Dimens.sizeLarge),
                  MyTextField(
                    isPass: true,
                    title: 'Password',
                    controller: bloc.passwordContr,
                    backgroundColor: scheme.backgroundDark,
                  ),
                ],
              )),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state.isSuccess) context.goNamed(AppRoutes.homeView);
            },
            child: SizedBox(height: context.height * .06),
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return LoadingButton(
                width: double.infinity,
                enable: !state.isSuccess,
                isLoading: state.isEmailLoading,
                backgroundColor: scheme.primary,
                onPressed: () => bloc.add(AuthLogin()),
                child: const Text(StringRes.emailContinue),
              );
            },
          ),
          const SizedBox(height: Dimens.sizeDefault),
          Row(
            spacing: Dimens.sizeDefault,
            children: [
              Expanded(child: MyDivider()),
              Text('OR', style: TextStyle(color: scheme.textColorLight)),
              Expanded(child: MyDivider()),
            ],
          ),
          const SizedBox(height: Dimens.sizeDefault),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return LoadingTextButton(
                width: double.infinity,
                loading: state.isGoogleLoading,
                fgColor: scheme.textColor,
                border: scheme.textColorLight,
                onPressed: () => bloc.add(AuthGoogleLogin()),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(ImageRes.google, height: Dimens.iconMedSmall),
                    const SizedBox(width: Dimens.sizeLarge),
                    const Text(StringRes.googleContinue),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: context.height * .1),
        ],
      ),
    );
  }
}
