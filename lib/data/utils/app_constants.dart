import 'dart:developer' as dev;
import 'package:ampify/data/utils/dimens.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/data/utils/utils.dart';
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
  static const String boxName = 'ampify';
  static const String theme = '$boxName:theme';
  static const String token = '$boxName:token';
  static const String refreshToken = '$boxName:refresh-token';
  static const String profile = '$boxName:profile';
}

sealed class UniqueIds {
  static const String likedSongs = '00-liked-songs';
}

void logPrint(Object? value, [String? name]) {
  if (kReleaseMode) return;
  final log = value is String? ? value : value.toString();
  dev.log(log ?? 'null', name: name ?? StringRes.appName);
}

void dprint(String? value) {
  if (kReleaseMode) return;
  debugPrint(value ?? 'null');
}

class MyColoredBox extends StatelessWidget {
  final Color? color;
  final Widget child;
  const MyColoredBox({super.key, this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: color ?? Colors.black12, child: child);
  }
}

showToast(String text, {int? timeInSec}) async {
  await Fluttertoast.cancel();
  Future.delayed(const Duration(milliseconds: 300)).then((_) {
    Fluttertoast.showToast(
        msg: text,
        timeInSecForIosWeb: timeInSec ?? 1,
        gravity: ToastGravity.SNACKBAR);
  });
}

showSnackBar(BuildContext context, {required String text}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      margin: Utils.paddingHoriz(Dimens.sizeSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.borderSmall),
      )));
}
