import 'package:ampify/buisness_logic/root_bloc/auth_bloc.dart';
import 'package:ampify/presentation/home_screens/listn_history.dart';
import 'package:ampify/services/getit_instance.dart';
import 'package:ampify/presentation/root_view/auth_screen.dart';
import 'package:ampify/presentation/root_view/root_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
      GoRoute(
          name: AppRoutes.rootView,
          path: AppRoutePaths.rootView,
          builder: (_, state) => const RootView(),
          routes: [
            GoRoute(
                name: AppRoutes.listnHistory,
                path: AppRoutes.listnHistory,
                builder: (_, state) => const ListeningHistory()),
          ]),
    ],
  );
}
