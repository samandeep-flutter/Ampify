import 'package:ampify/buisness_logic/home_bloc/home_bloc.dart';
import 'package:ampify/data/utils/dimens.dart';
import 'package:ampify/data/utils/image_resources.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/data/utils/utils.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../buisness_logic/home_bloc/listn_history_bloc.dart';
import '../widgets/base_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final bloc = context.read<HomeBloc>();

    return BaseWidget(
      padding: EdgeInsets.zero,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: context.background,
            title: const Text(StringRes.appName),
            centerTitle: false,
            titleTextStyle: Utils.defTitleStyle,
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(30),
                child: Row(
                  children: [
                    const SizedBox(width: Dimens.sizeDefault),
                    Text(StringRes.homeSubtitle,
                        style: TextStyle(
                          color: scheme.textColorLight,
                        )),
                  ],
                )),
            actions: [
              BlocProvider(
                create: (_) => ListnHistoryBloc(),
                child: IconButton(
                  onPressed: () => bloc.toHistory(context),
                  icon: Image.asset(
                    ImageRes.history,
                    height: Dimens.sizeLarge,
                  ),
                ),
              ),
              const SizedBox(width: Dimens.sizeDefault),
            ],
          ),
        ],
      ),
    );
  }
}
