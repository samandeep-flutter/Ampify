import 'package:ampify/buisness_logic/library_bloc/playlist_bloc.dart';
import 'package:ampify/buisness_logic/root_bloc/auth_bloc.dart';
import 'package:ampify/presentation/home_screens/home_screen.dart';
import 'package:ampify/presentation/home_screens/listn_history.dart';
import 'package:ampify/presentation/library_screens/library_screen.dart';
import 'package:ampify/presentation/search_screens/search_page.dart';
import 'package:ampify/services/getit_instance.dart';
import 'package:ampify/presentation/root_view/auth_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/library_screens/playlist_view.dart';
import '../../presentation/root_view/root_view.dart';
import '../../services/auth_services.dart';
import 'app_routes.dart';

abstract class AppPage {
  static final AuthServices _auth = getIt();

  static GoRouter routes = GoRouter(
    initialLocation: '/${_auth.navigate()}',
    debugLogDiagnostics: kDebugMode,
    routes: [
      GoRoute(
        name: AppRoutes.auth,
        path: AppRoutePaths.auth,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => AuthBloc(),
            child: const AuthScreen(),
          );
        },
      ),
      ShellRoute(
          builder: (_, state, navigator) => RootView(navigator),
          routes: [
            GoRoute(
                name: AppRoutes.homeView,
                path: AppRoutePaths.homeView,
                builder: (_, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                      name: AppRoutes.listnHistory,
                      path: AppRoutes.listnHistory,
                      builder: (_, state) => const ListeningHistory()),
                ]),
            GoRoute(
              name: AppRoutes.searchView,
              path: AppRoutePaths.searchView,
              builder: (_, state) => const SearchPage(),
            ),
            GoRoute(
                name: AppRoutes.libraryView,
                path: AppRoutePaths.libraryView,
                builder: (_, state) => const LibraryScreen(),
                routes: [
                  GoRoute(
                      name: AppRoutes.playlistView,
                      path: AppRoutes.playlistView,
                      builder: (context, state) {
                        final id = state.extra as String;
                        context.read<PlaylistBloc>().add(PlaylistInitial(id));
                        return const PlaylistView();
                      }),
                ]),
          ]),
    ],
  );
}
