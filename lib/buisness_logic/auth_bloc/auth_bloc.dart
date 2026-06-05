import 'dart:async';
import 'package:ampify/data/utils/exports.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthEvent {}

class AuthLogin extends AuthEvent {}

class AuthGoogleLogin extends AuthEvent {}

class AuthFinished extends AuthEvent {
  final UserCredential credentials;
  final String? token;

  const AuthFinished(this.credentials, {this.token});

  @override
  List<Object?> get props => [credentials, token];
}

class AuthState extends Equatable {
  final bool isEmailLoading;
  final bool isGoogleLoading;
  final bool isSuccess;
  const AuthState({
    required this.isEmailLoading,
    required this.isGoogleLoading,
    required this.isSuccess,
  });

  const AuthState.init()
      : isEmailLoading = false,
        isGoogleLoading = false,
        isSuccess = false;

  AuthState copyWith(
      {bool? isEmailLoading, bool? isGoogleLoading, bool? isSuccess}) {
    return AuthState(
      isEmailLoading: isEmailLoading ?? this.isEmailLoading,
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [isEmailLoading, isGoogleLoading, isSuccess];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState.init()) {
    on<AuthInitial>(_onInit);
    on<AuthLogin>(_emailSignin);
    on<AuthGoogleLogin>(_onGoogleLogin);
    on<AuthFinished>(_onFinish);
  }
  final AuthServices auth = getIt();
  final _fbAuth = FirebaseAuth.instance;
  final _google = GoogleSignIn.instance;

  final formKey = GlobalKey<FormState>();
  final emailContr = TextEditingController();
  final passwordContr = TextEditingController();

  void _onInit(AuthInitial event, Emitter<AuthState> emit) async {
    await _google.initialize();
  }

  void _onGoogleLogin(AuthGoogleLogin event, Emitter<AuthState> emit) async {
    formKey.currentState?.reset();
    emit(state.copyWith(isGoogleLoading: true));
    try {
      final user = await _google.authenticate(scopeHint: ['email']);
      GoogleSignInClientAuthorization? _auth =
          await user.authorizationClient.authorizationForScopes(['email']);
      _auth ??= await user.authorizationClient.authorizeScopes(['email']);
      final oAuth = GoogleAuthProvider.credential(
          accessToken: _auth.accessToken, idToken: user.authentication.idToken);
      final credentials = await _fbAuth.signInWithCredential(oAuth);
      add(AuthFinished(credentials, token: auth.deviceInfo?.fcmToken));
    } catch (e) {
      emit(state.copyWith(isGoogleLoading: false));
      logPrint(e, 'google-auth');
    }
  }

  void _emailSignin(AuthLogin event, Emitter<AuthState> emit) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? true)) return;
    emit(state.copyWith(isEmailLoading: true));
    try {
      final credentials = await _fbAuth.signInWithEmailAndPassword(
          email: emailContr.text.trim(), password: passwordContr.text.trim());
      add(AuthFinished(credentials, token: auth.deviceInfo?.fcmToken));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(isEmailLoading: false));
      onFbSignInException(e);
    } catch (e) {
      emit(state.copyWith(isEmailLoading: false));
      logPrint(e, 'email-auth');
    }
  }

  Future<void> _onFinish(AuthFinished event, Emitter<AuthState> emit) async {
    if (event.credentials.user == null) return;
    final collection = AppConstants.usersCollection;
    final _box = BoxServices.instance;

    try {
      final uid = event.credentials.user!.uid;
      final json = await collection.doc(uid).get();
      if (!json.exists) throw Exception();
      final user = UserModel.fromJson(json.data()!);
      collection.doc(uid).update({'login': true});
      if (user.deviceToken != event.token) {
        collection.doc(uid).update({'device_token': event.token});
      }
      _box.write(BoxKeys.profile,
          user.copyWith(login: true, deviceToken: event.token).toJson());
    } catch (e) {
      logPrint(e, 'fb-firestore');
      var details = UserModel(
        id: event.credentials.user!.uid,
        displayName: event.credentials.user!.displayName ?? '',
        email: event.credentials.user!.email!,
        image: event.credentials.user!.photoURL,
        deviceToken: event.token,
        login: true,
      );
      await collection.doc(details.id).set(details.toJson());
      _box.write(BoxKeys.profile, details.toJson());
    } finally {
      _box.write(BoxKeys.uid, event.credentials.user!.uid);

      emit(AuthState.init().copyWith(isSuccess: true));
    }
  }

  void onFbSignInException(FirebaseAuthException e) {
    logPrint(e, 'fbAuth');
    switch (e.code) {
      case 'invalid-credential':
        showToast(StringRes.errorInvalidCred, timeInSec: 3);
        break;
      case 'user-disabled':
        showToast(StringRes.errorUserDisabled, timeInSec: 3);
        break;
      case 'network-request-failed':
        showToast(StringRes.offlineDesc, timeInSec: 4);
        break;
      case 'account-exists-with-different-credential':
        showToast(StringRes.errorAccExist, timeInSec: 4);
        break;
      default:
        showToast(e.message ?? StringRes.errorUnknown);
    }
  }

  void onGoogleSignInException(GoogleSignInException e) {
    logPrint(e, 'gogleAuth');
    switch (e.code) {
      case GoogleSignInExceptionCode.canceled:
      case GoogleSignInExceptionCode.clientConfigurationError:
        break;
      case GoogleSignInExceptionCode.interrupted:
        showToast(StringRes.errorLoginIntrupted, timeInSec: 3);
        break;
      case GoogleSignInExceptionCode.uiUnavailable:
        showToast(StringRes.errorLoginUnavailable, timeInSec: 3);
        break;
      case GoogleSignInExceptionCode.unknownError:
      default:
        showToast(e.description ?? StringRes.errorLoginFailed);
    }
  }
}
