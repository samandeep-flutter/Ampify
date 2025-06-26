import 'package:ampify/buisness_logic/home_bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ampify/services/extension_services.dart';
import '../../buisness_logic/player_bloc/player_bloc.dart';
import '../../buisness_logic/player_bloc/player_events.dart';
import '../../buisness_logic/root_bloc/root_bloc.dart';
import '../../buisness_logic/search_bloc/search_bloc.dart';
import 'player_screens/player_compact.dart';
import '../../data/utils/dimens.dart';

class RootView extends StatefulWidget {
  final Widget tabBar;
  const RootView(this.tabBar, {super.key});

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  @override
  void initState() {
    context.read<PlayerBloc>().add(PlayerInitial());
    context.read<SearchBloc>().add(SearchInitial());
    context.read<HomeBloc>().add(HomeInitial());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final bloc = context.read<RootBloc>();
    final searchBloc = context.read<SearchBloc>();

    return Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          alignment: Alignment.bottomCenter,
          children: [
            widget.tabBar,
            const Align(
              alignment: Alignment.bottomCenter,
              child: PlayerCompact(),
            ),
          ],
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            stops: [.8, 1],
            colors: [scheme.surface, scheme.surface.withAlpha(50)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          )),
          child: BlocBuilder<RootBloc, RootState>(
            buildWhen: (pr, cr) => pr.index != cr.index,
            builder: (context, state) {
              return BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 40,
                iconSize: Dimens.sizeMedium,
                unselectedItemColor: scheme.disabled,
                selectedItemColor: scheme.textColor,
                onTap: (index) {
                  if (index != 1) searchBloc.onSearchClear();
                  bloc.onIndexChange(context, index: index);
                },
                currentIndex: state.index,
                items: bloc.tabs,
              );
            },
          ),
        ));
  }
}
