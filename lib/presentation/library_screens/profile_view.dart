import 'package:ampify/buisness_logic/root_bloc/root_bloc.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with TickerProviderStateMixin {
  final box = BoxServices.instance;
  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return BaseWidget(
      appBar: AppBar(
        backgroundColor: scheme.background,
        title: const Text(StringRes.profile),
        titleTextStyle: Utils.defTitleStyle(context),
        centerTitle: false,
      ),
      child: ListView(
        children: [
          const SizedBox(height: Dimens.sizeDefault),
          Row(
            children: [
              BlocBuilder<RootBloc, RootState>(
                  buildWhen: (pr, cr) => pr.profile != cr.profile,
                  builder: (context, state) {
                    return MyCachedImage(state.profile?.image,
                        isAvatar: true, avatarRadius: context.width * .1);
                  }),
              const SizedBox(width: Dimens.sizeLarge),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BlocBuilder<RootBloc, RootState>(
                          buildWhen: (pr, cr) => pr.profile != cr.profile,
                          builder: (context, state) {
                            return Text(
                              state.profile?.displayName ?? '',
                              style: TextStyle(
                                color: scheme.textColor,
                                fontSize: Dimens.fontXXLarge,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                      const SizedBox(width: Dimens.sizeSmall),
                      BlocBuilder<RootBloc, RootState>(
                          buildWhen: (pr, cr) => pr.profile != cr.profile,
                          builder: (context, state) {
                            final tier = state.profile?.product;
                            return Container(
                              padding: Utils.insetsHoriz(Dimens.sizeSmall),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(Dimens.borderLarge),
                                  color: tier == 'premium'
                                      ? Colors.amber
                                      : scheme.backgroundDark),
                              child: Text(tier?.toUpperCase() ?? '',
                                  style:
                                      TextStyle(fontSize: Dimens.fontDefault)),
                            );
                          })
                    ],
                  ),
                  BlocBuilder<RootBloc, RootState>(
                      buildWhen: (pr, cr) => pr.profile != cr.profile,
                      builder: (context, state) {
                        return Text(
                          '${state.profile?.followers ?? ''} ${StringRes.followers}',
                          style: TextStyle(
                              color: scheme.textColorLight,
                              fontSize: Dimens.fontDefault,
                              fontWeight: FontWeight.w500),
                        );
                      }),
                ],
              )
            ],
          ),
          const SizedBox(height: Dimens.sizeLarge),
          Card(
            color: scheme.surface,
            child: Column(
              children: [
                const SizedBox(height: Dimens.sizeSmall),
                ListTile(
                  onTap: _switchTheme,
                  leading: Icon(Icons.color_lens_outlined),
                  title: Text(StringRes.themeMode,
                      style: TextStyle(fontSize: Dimens.fontXXXLarge)),
                ),
                const SizedBox(height: Dimens.sizeSmall),
              ],
            ),
          ),
          const SizedBox(height: Dimens.sizeLarge),
          ListTile(
            onTap: logout,
            textColor: scheme.error,
            leading: Icon(Icons.logout, color: scheme.error),
            title: Text(StringRes.logout.toUpperCase(),
                style: TextStyle(fontSize: Dimens.fontXXXLarge)),
          ),
        ],
      ),
    );
  }

  void logout() {
    final AuthServices auth = getIt();
    showDialog(
        context: context,
        builder: (context) {
          return MyAlertDialog(
            title: '${StringRes.logout} ?',
            content: Text(StringRes.logoutDesc,
                style: TextStyle(fontSize: Dimens.fontDefault)),
            actionPadding: const EdgeInsets.only(
                right: Dimens.sizeDefault, bottom: Dimens.sizeSmall),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: context.scheme.textColor,
                ),
                child: Text(StringRes.cancel.toUpperCase(),
                    style: TextStyle(fontSize: Dimens.fontDefault)),
              ),
              TextButton(
                onPressed: auth.logout,
                style:
                    TextButton.styleFrom(foregroundColor: context.scheme.error),
                child: Text(StringRes.logout.toUpperCase(),
                    style: TextStyle(fontSize: Dimens.fontDefault)),
              ),
            ],
          );
        });
  }

  void _switchTheme() {
    showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (context) {
          return MyBottomSheet(
            title: StringRes.themeMode,
            vsync: this,
            child: Column(
              children: [
                ...ThemeMode.values.map((e) {
                  return RadioListTile(
                    value: e,
                    groupValue: box.themeMode,
                    title: Row(
                      children: [
                        Icon(e.icon, size: Dimens.iconDefault),
                        const SizedBox(width: Dimens.sizeLarge),
                        Text(e.name.capitalize,
                            style: TextStyle(fontSize: Dimens.fontXXXLarge)),
                      ],
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    onChanged: (theme) async {
                      context.scheme.switchThemeMode(theme);
                      await Future.delayed(Durations.medium4);
                      // ignore: use_build_context_synchronously
                      context.pop();
                    },
                  );
                }),
                SafeArea(child: SizedBox(height: Dimens.sizeDefault)),
              ],
            ),
          );
        });
  }
}
