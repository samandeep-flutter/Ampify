import 'package:ampify/buisness_logic/root_bloc/music_group_bloc.dart';
import 'package:ampify/buisness_logic/root_bloc/auth_bloc.dart';
import 'package:ampify/buisness_logic/root_bloc/playlist_bloc.dart';
import 'package:ampify/data/data_models/library_model.dart';
import 'package:ampify/presentation/home_screens/home_screen.dart';
import 'package:ampify/presentation/home_screens/listn_history.dart';
import 'package:ampify/presentation/library_screens/library_screen.dart';
import 'package:ampify/presentation/search_screens/search_page.dart';
import 'package:ampify/services/getit_instance.dart';
import 'package:ampify/presentation/root_view/auth_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../buisness_logic/home_bloc/listn_history_bloc.dart';
import '../../presentation/library_screens/liked_songs.dart';
import '../../presentation/library_screens/music_group_screen.dart';
import '../../presentation/root_view/root_view.dart';
import '../../presentation/track_widgets/create_playlist.dart';
import '../../services/auth_services.dart';
import 'app_routes.dart';

abstract class AppPage {
  static final AuthServices _auth = getIt();

  static GoRouter routes = GoRouter(
    initialLocation: '/${_auth.navigate()}',
    debugLogDiagnostics: kDebugMode,
    // navigatorKey: _auth.navigator,
    routes: [
      GoRoute(
        name: AppRoutes.auth,
        path: AppRoutePaths.auth,
        builder: (_, state) {
          return BlocProvider(
            create: (_) => AuthBloc(),
            child: const AuthScreen(),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.createPlaylist,
        path: AppRoutePaths.createPlaylist,
        builder: (_, state) {
          final id = state.pathParameters['userId'] as String;
          return BlocProvider(
            create: (_) => PlaylistBloc(),
            child: CreatePlaylistView(userId: id),
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
                      builder: (_, state) {
                        return BlocProvider(
                            create: (_) => ListnHistoryBloc(),
                            child: const ListeningHistory());
                      }),
                ]),
            GoRoute(
                name: AppRoutes.musicGroup,
                path: '${AppRoutePaths.musicGroup}/:type/:id',
                builder: (context, state) {
                  String id = state.pathParameters['id']!;
                  final type = LibItemType.values.firstWhere((e) {
                    return e.name == state.pathParameters['type'];
                  });
                  final bloc = context.read<MusicGroupBloc>();
                  bloc.add(MusicGroupInitial(id: id, type: type));
                  return const MusicGroupScreen();
                }),
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
                      name: AppRoutes.likedSongs,
                      path: AppRoutes.likedSongs,
                      builder: (_, state) => const LikedSongs()),
                ]),
          ]),
    ],
  );
}
