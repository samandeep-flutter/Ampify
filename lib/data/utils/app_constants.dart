import 'dart:developer' as dev;
import 'package:ampify/data/utils/exports.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

sealed class AppConstants {
  static const String baseUrl = 'https://api.spotify.com/v1/';
  static const String token = 'https://accounts.spotify.com/api/token';

  static const String search = 'search';
  static const String profile = 'me';
  static const String myPlaylists = 'me/playlists';
  static const String myAlbums = 'me/albums';
  static const String recentlyPlayed = 'me/player/recently-played';
  static String browse(String local) => 'browse/categories?locale=$local';
  static String severalTracks(String ids) => 'tracks?ids=$ids';
  static String severalAlbums(String ids) => 'albums?ids=$ids';
  static String newReleases(int offset) => 'browse/new-releases?offset=$offset';
  static String userPlaylists(String id) => 'users/$id/playlists';
  static String addtoPlaylist(String id, {required String uris}) =>
      'playlists/$id/tracks?uris=$uris';
  static String removeFromPlaylist(String id) => 'playlists/$id/tracks';
  static String playlistDetails(String id) => 'playlists/$id';
  static String albumDetails(String id) => 'albums/$id';
  static String likedSongs(int offset) => 'me/tracks?offset=$offset';
  static String savetoLiked(String id) => 'me/tracks?ids=$id';
  static String saveAlbum(String id) => 'me/albums?ids=$id';
  static String savePlaylist(String id) => 'playlists/$id/followers';
  static String changePlaylistCover(String id) => 'playlists/$id/images';
  static String isFollowAlbum(String id) => 'me/albums/contains?ids=$id';
  static String isFollowPlaylist(String id) =>
      'playlists/$id/followers/contains';
}

sealed class BoxKeys {
  static const String boxName = 'Ampify';
  static const String theme = 'theme';
  static const String themeMode = 'theme-mode';
  static const String uid = 'uid';
  static const String token = 'token';
  static const String refreshToken = 'refresh-token';
}

sealed class EnvKeys {
  static const String id = 'CLIENT_ID';
  static const String secret = 'CLIENT_SECRET';
  static const String redirect = 'REDIRECT';
}

sealed class UniqueIds {
  static const String likedSongs = '00-liked-songs';
}

sealed class PlayerActions {
  static const String clearQueue = 'clear-queue';
  static const String removeRange = 'remove-range';
  static const String removeUpcomming = 'remove-upcomming';
}

void logPrint(Object? value, [String? name]) {
  if (kReleaseMode) return;
  final log = value is String? ? value : value.toString();
  dev.log(log ?? 'null', name: name ?? StringRes.appName);
}

void dprint(Object? value) {
  if (kDebugMode) print(value ?? 'null');
}

class MyColoredBox extends StatelessWidget {
  final Color? color;
  final Widget child;
  const MyColoredBox({super.key, this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
        color: color ?? context.scheme.textColor.withAlpha(50), child: child);
  }
}

Future<void> showToast(String text, {int? timeInSec}) async {
  await Fluttertoast.cancel();
  Future.delayed(Durations.medium2).then((_) {
    Fluttertoast.showToast(
        msg: text,
        timeInSecForIosWeb: timeInSec ?? 1,
        gravity: ToastGravity.SNACKBAR);
  });
}

void showSnackBar(BuildContext context, {required String text}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      margin: Utils.insetsHoriz(Dimens.sizeSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.borderSmall),
      )));
}
