import 'package:ampify/buisness_logic/home_bloc/home_bloc.dart';
import 'package:ampify/buisness_logic/library_bloc/library_bloc.dart';
import 'package:ampify/buisness_logic/player_bloc/player_slider_bloc.dart';
import 'package:ampify/buisness_logic/player_bloc/player_state.dart';
import 'package:ampify/data/utils/exports.dart';
import '../../buisness_logic/player_bloc/player_bloc.dart';
import '../../buisness_logic/player_bloc/player_events.dart';
import '../../buisness_logic/root_bloc/root_bloc.dart';
import '../../buisness_logic/search_bloc/search_bloc.dart';
import 'player_screens/player_compact.dart';

class RootView extends StatefulWidget {
  final Widget tabBar;
  const RootView(this.tabBar, {super.key});

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  @override
  void initState() {
    context.read<RootBloc>().add(RootInitial());
    context.read<PlayerBloc>().add(PlayerInitial());
    context.read<PlayerSliderBloc>().add(PlayerSliderInitial());
    context.read<SearchBloc>().add(SearchInitial());
    context.read<HomeBloc>().add(HomeInitial());
    context.read<LibraryBloc>().add(LibraryInitial());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final bloc = context.read<RootBloc>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: scheme.background,
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.bottomCenter,
        children: [
          widget.tabBar,
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BlocBuilder<PlayerBloc, PlayerState>(buildWhen: (pr, cr) {
                  return pr.playerState.isHidden != cr.playerState.isHidden;
                }, builder: (context, state) {
                  return AnimatedSlide(
                      duration: Durations.medium2,
                      offset: Offset(0, state.playerState.isHidden ? 2 : 0),
                      child: PlayerCompact());
                }),
                DecoratedBox(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        stops: [.2, .6, .8, 1],
                        colors: [
                          scheme.background,
                          scheme.background.withAlpha(200),
                          scheme.background.withAlpha(80),
                          scheme.background.withAlpha(0),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.background.withAlpha(66),
                          spreadRadius: Dimens.sizeDefault,
                          blurRadius: Dimens.sizeMidLarge,
                        )
                      ]),
                  child: BlocBuilder<RootBloc, RootState>(
                      buildWhen: (pr, cr) => pr.isConnected != cr.isConnected,
                      builder: (context, state) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MediaQuery.removePadding(
                              context: context,
                              removeBottom: !state.isConnected,
                              child: BlocBuilder<RootBloc, RootState>(
                                buildWhen: (pr, cr) => pr.index != cr.index,
                                builder: (context, state) {
                                  return BottomNavigationBar(
                                    backgroundColor: Colors.transparent,
                                    elevation: Dimens.sizeExtraLarge,
                                    selectedFontSize: Dimens.fontDefault,
                                    unselectedFontSize: Dimens.fontMed,
                                    unselectedItemColor: scheme.textColorLight,
                                    selectedItemColor: scheme.textColor,
                                    onTap: (index) => bloc
                                        .onIndexChange(context, index: index),
                                    currentIndex: state.index,
                                    items: bloc.tabs,
                                  );
                                },
                              ),
                            ),
                            Container(
                              height: state.isConnected ? 0 : null,
                              padding: EdgeInsets.only(
                                  top: Dimens.sizeSmall,
                                  bottom: Dimens.sizeDefault),
                              color: Colors.blue.shade700,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.language, color: scheme.onPrimary),
                                  const SizedBox(width: Dimens.sizeDefault),
                                  Text(
                                    'No internet connection',
                                    style: TextStyle(
                                        color: scheme.onPrimary,
                                        fontSize: Dimens.fontXXXLarge),
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
