import 'package:ampify/buisness_logic/root_bloc/root_bloc.dart';
import 'package:ampify/data/utils/exports.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return BaseWidget(
      appBar: AppBar(
        backgroundColor: scheme.background,
        title: const Text(StringRes.profile),
        titleTextStyle: Utils.defTitleStyle(scheme.textColor),
        centerTitle: false,
      ),
      bodyPadding: Utils.insetsHoriz(Dimens.sizeXLarge),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: Dimens.sizeDefault),
          Row(
            children: [
              MyCachedImage(profile?.image,
                  isAvatar: true, avatarRadius: context.width * .1),
              const SizedBox(width: Dimens.sizeXLarge),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.displayName ?? '',
                    style: TextStyle(
                      color: scheme.textColor,
                      fontSize: Dimens.fontXXLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    profile?.email ?? '',
                    style: TextStyle(
                      color: scheme.textColorLight,
                      fontSize: Dimens.fontDefault,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: Dimens.sizeXLarge),
          Card(
            color: scheme.surface,
            child: Column(
              children: [
                const SizedBox(height: Dimens.sizeExtraSmall),
                ListTile(
                  onTap: () => _switchTheme(context),
                  leading: Icon(Icons.color_lens_outlined),
                  title: Text(StringRes.themeMode,
                      style: TextStyle(fontSize: Dimens.fontXXXLarge)),
                ),
                const SizedBox(height: Dimens.sizeExtraSmall),
              ],
            ),
          ),
          const SizedBox(height: Dimens.sizeSmall),
          ListTile(
            onTap: () => _logout(context),
            textColor: scheme.error,
            leading: Icon(Icons.logout, color: scheme.error),
            title: Text(StringRes.logout.toUpperCase(),
                style: TextStyle(fontSize: Dimens.fontXXXLarge)),
          ),
        ],
      ),
    );
  }

  UserModel? get profile => BoxServices.instance.profile;

  void _logout(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return MyAlertDialog(
            titleText: '${StringRes.logout} ?',
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
                onPressed: () {
                  context.read<RootBloc>().add(RootTabReset());
                  getIt<AuthServices>().logout();
                },
                style:
                    TextButton.styleFrom(foregroundColor: context.scheme.error),
                child: Text(StringRes.logout.toUpperCase(),
                    style: TextStyle(fontSize: Dimens.fontDefault)),
              ),
            ],
          );
        });
  }

  void _switchTheme(BuildContext context) {
    showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        useSafeArea: true,
        builder: (context) {
          return MyBottomSheet(
            title: StringRes.themeMode,
            child: Column(
              children: [
                const SizedBox(height: Dimens.sizeSmall),
                ...ThemeMode.values.map((e) {
                  return RadioGroup(
                    groupValue: BoxServices.instance.themeMode,
                    onChanged: (theme) async {
                      context.scheme.switchThemeMode(theme);
                      await Future.delayed(Durations.medium4);
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                    child: RadioListTile(
                      value: e,
                      title: Row(
                        children: [
                          Icon(e.icon, size: Dimens.iconDefault),
                          const SizedBox(width: Dimens.sizeXLarge),
                          Text(e.name.capitalize,
                              style: TextStyle(fontSize: Dimens.fontXXXLarge)),
                        ],
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                    ),
                  );
                }),
                SafeArea(child: SizedBox(height: Dimens.sizeDefault)),
              ],
            ),
          );
        });
  }
}
