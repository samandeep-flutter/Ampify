import 'package:ampify/buisness_logic/home_bloc/home_bloc.dart';
import 'package:ampify/buisness_logic/player_bloc/player_bloc.dart';
import 'package:ampify/buisness_logic/root_bloc/root_bloc.dart';
import 'package:ampify/buisness_logic/search_bloc/search_bloc.dart';
import 'package:ampify/data/utils/dimens.dart';
import 'package:ampify/presentation/home_screens/home_screen.dart';
import 'package:ampify/presentation/library_screens/library_screen.dart';
import 'package:ampify/presentation/root_view/player_screens/player_compact.dart';
import 'package:ampify/presentation/search_screens/search_page.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../buisness_logic/player_bloc/player_events.dart';
import '../../services/notification_services.dart';

class RootView extends StatefulWidget {
  const RootView({super.key});

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> with TickerProviderStateMixin {
  @override
  void initState() {
    final root = context.read<RootBloc>();
    root.tabController = TabController(length: root.tabs.length, vsync: this);
    context.read<HomeBloc>().add(HomeInitial());
    context.read<SearchBloc>().add(SearchInitial());
    context.read<PlayerBloc>().add(PlayerInitial());
    Future(MyNotifications.initialize);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final bloc = context.read<RootBloc>();
    return Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          alignment: Alignment.bottomCenter,
          children: [
            TabBarView(
              controller: bloc.tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [HomeScreen(), SearchPage(), LibraryScreen()],
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: PlayerCompact(),
            ),
          ],
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [
              Colors.white10,
              Colors.white,
              Colors.white,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )),
          child: BlocBuilder<RootBloc, RootState>(
            buildWhen: (previous, current) {
              return previous.index != current.index;
            },
            builder: (context, state) {
              return BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 40,
                iconSize: Dimens.sizeMedium,
                selectedFontSize: 0,
                unselectedFontSize: 0,
                unselectedItemColor: scheme.disabled,
                selectedItemColor: scheme.onPrimaryContainer,
                onTap: (index) {
                  if (index != 1) {
                    context.read<SearchBloc>().onSearchClear();
                  }
                  bloc.add(RootTabChanged(index));
                },
                currentIndex: state.index,
                items: bloc.tabs,
              );
            },
          ),
        ));
  }
}
