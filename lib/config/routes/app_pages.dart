import 'dart:convert';

import 'package:ampify/buisness_logic/auth_bloc/auth_bloc.dart';
import 'package:ampify/buisness_logic/music_group_bloc/edit_playlist_bloc.dart';
import 'package:ampify/buisness_logic/music_group_bloc/music_group_bloc.dart';
import 'package:ampify/presentation/home_screens/home_screen.dart';
import 'package:ampify/presentation/home_screens/listn_history.dart';
import 'package:ampify/presentation/library_screens/library_screen.dart';
import 'package:ampify/presentation/library_screens/profile_view.dart';
import 'package:ampify/presentation/music_groups/edit_playlist.dart';
import 'package:ampify/presentation/root_view/not_found_screen.dart';
import 'package:ampify/buisness_logic/player_bloc/track_radio_bloc.dart';
import 'package:ampify/presentation/root_view/track_radio.dart';
import 'package:ampify/presentation/search_screens/search_page.dart';
import 'package:ampify/presentation/root_view/auth_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:ampify/data/utils/exports.dart';
import '../../buisness_logic/home_bloc/listn_history_bloc.dart';
import '../../buisness_logic/music_group_bloc/playlist_bloc.dart';
import '../../presentation/library_screens/liked_songs.dart';
import '../../presentation/music_groups/music_group_screen.dart';
import '../../presentation/root_view/root_view.dart';
import '../../presentation/track_widgets/create_playlist.dart';

abstract class AppPage {
  @protected
  static final AuthServices _auth = getIt();

  static GoRouter routes = GoRouter(
    initialLocation: '/${_auth.initialRoute}',
    debugLogDiagnostics: kDebugMode,
    navigatorKey: _auth.navigator,
    errorBuilder: (_, state) => NotFoundScreen(state),
    routes: [
      GoRoute(
        name: AppRoutes.auth,
        path: AppRoutePaths.auth,
        builder: (_, state) {
          return BlocProvider(
              create: (_) => AuthBloc(), child: const AuthScreen());
        },
      ),
      GoRoute(
        name: AppRoutes.createPlaylist,
        path: AppRoutePaths.createPlaylist,
        builder: (_, state) {
          final id = state.pathParameters['userId'] as String;
          return BlocProvider(
              create: (_) => PlaylistBloc(),
              child: CreatePlaylistView(userId: id));
        },
      ),
      GoRoute(
        name: AppRoutes.modifyPlaylist,
        path: AppRoutePaths.modifyPlaylist,
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final titile = state.uri.queryParameters['title'];
          final image = state.uri.queryParameters['image'];
          final desc = state.uri.queryParameters['desc'];

          return BlocProvider(
            create: (_) => EditPlaylistBloc(),
            child: EditPlaylistScreen(
                id: id!, title: titile, image: image, desc: desc),
          );
        },
      ),
      ShellRoute(
          navigatorKey: _auth.shellNavigator,
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
                path: AppRoutePaths.musicGroup,
                builder: (context, state) {
                  try {
                    String id = state.pathParameters['id']!;
                    final type = LibItemType.values.firstWhere((e) {
                      return e.name == state.pathParameters['type'];
                    }, orElse: () => LibItemType.album);
                    return BlocProvider(
                        create: (_) => MusicGroupBloc(),
                        child: MusicGroupScreen(id: id, type: type));
                  } catch (e) {
                    logPrint(e, 'route');
                    return NotFoundScreen(state);
                  }
                }),
            GoRoute(
                name: AppRoutes.songRadio,
                path: AppRoutePaths.songRadio,
                builder: (context, state) {
                  final id = state.pathParameters['id'];
                  final track = jsonDecode(state.extra as String? ?? '');
                  return BlocProvider(
                      create: (_) => TrackRadioBloc(),
                      child: TrackRadio(id!, track: track));
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
                  GoRoute(
                      name: AppRoutes.profile,
                      path: AppRoutes.profile,
                      builder: (_, state) => const ProfileView()),
                ]),
          ]),
    ],
  );
}
