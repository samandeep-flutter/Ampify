import 'package:ampify/services/auth_services.dart';
import 'package:ampify/services/box_services.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:ampify/services/getit_instance.dart';
import 'package:ampify/data/utils/dimens.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/data/utils/utils.dart';
import 'package:ampify/presentation/widgets/base_widget.dart';
import 'package:ampify/presentation/widgets/my_alert_dialog.dart';
import 'package:ampify/presentation/widgets/my_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
              MyCachedImage(box.profile?.image,
                  isAvatar: true, avatarRadius: context.width * .1),
              const SizedBox(width: Dimens.sizeLarge),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        box.profile?.displayName ?? '',
                        style: TextStyle(
                          color: scheme.textColor,
                          fontSize: Dimens.fontExtraLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: Dimens.sizeSmall),
                      Builder(builder: (context) {
                        final tier = box.profile?.product;
                        return Container(
                          padding: Utils.insetsHoriz(Dimens.sizeSmall),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(Dimens.borderLarge),
                              color: tier == 'premium'
                                  ? Colors.amber
                                  : scheme.backgroundDark),
                          child: Text(tier?.toUpperCase() ?? '',
                              style: TextStyle(fontSize: Dimens.fontDefault)),
                        );
                      })
                    ],
                  ),
                  Text(
                    '${box.profile?.followers ?? ''} ${StringRes.followers}',
                    style: TextStyle(
                        color: scheme.textColorLight,
                        fontSize: Dimens.fontDefault,
                        fontWeight: FontWeight.w500),
                  ),
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
                      style: TextStyle(fontSize: Dimens.fontLarge)),
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
                style: TextStyle(fontSize: Dimens.fontLarge)),
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
                            style: TextStyle(fontSize: Dimens.fontLarge)),
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
