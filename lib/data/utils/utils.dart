import 'dart:async';

import 'package:ampify/data/data_models/common/other_models.dart';
import 'package:ampify/data/data_models/library_model.dart';
import 'package:ampify/data/repositories/music_repo.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:rxdart/rxdart.dart';
import '../data_models/common/tracks_model.dart';

sealed class Utils {
  @protected
  static final MusicRepo _repo = getIt();

  static TextStyle defTitleStyle(BuildContext context) {
    return TextStyle(
        fontSize: Dimens.fontLarge,
        fontWeight: FontWeight.w600,
        color: context.scheme.textColor);
  }

  static TextStyle titleTextStyle([Color? color]) {
    return TextStyle(
        fontSize: Dimens.fontTitle, fontWeight: FontWeight.bold, color: color);
  }

  static EdgeInsets insetsHoriz(double padding) {
    return EdgeInsets.symmetric(horizontal: padding);
  }

  static EdgeInsets insetsOnly(double padding,
      {double? top, double? bottom, double? left, double? right}) {
    return EdgeInsets.fromLTRB(
        left ?? padding, top ?? padding, right ?? padding, bottom ?? padding);
  }

  static OutlinedBorder continuousBorder(double radius, {Color? border}) {
    return ContinuousRectangleBorder(
        side: border != null ? BorderSide(color: border) : BorderSide.none,
        borderRadius: BorderRadius.circular(Dimens.borderLarge));
  }

  static SliverGridDelegate fixedCrossAxis(int count,
      {double? spacing, double? aspectRatio}) {
    return SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        childAspectRatio: aspectRatio ?? 1,
        mainAxisSpacing: spacing ?? 0,
        crossAxisSpacing: spacing ?? 0);
  }

  static Future<TrackDetails> getTrackDetails(Track track) async {
    final _details = Completer<SongYtDetails>();
    final artist = track.artists?.asString.split(',').first;
    _repo.getDetailsFromQuery('${track.name} $artist').then((details) {
      _details.complete(details);
    });
    final palete = await PaletteGenerator.fromImageProvider(
        NetworkImage(track.album?.image ?? ''),
        size: const Size.square(200));

    final details = await _details.future;

    return TrackDetails(
      id: track.id,
      albumId: track.album?.id,
      title: track.name,
      bgColor: palete.lightVibrantColor?.color,
      darkBgColor: palete.darkVibrantColor?.color,
      image: track.album?.image,
      subtitle: track.artists?.asString,
      duration: details.duration,
      videoId: details.videoId,
    );
  }

  static Future<Color?> getImageColor(String? image) async {
    try {
      final palete = await PaletteGenerator.fromImageProvider(
          NetworkImage(image!),
          size: const Size(200, 200));
      return palete.dominantColor?.color;
    } catch (_) {
      return null;
    }
  }

  static LibraryModel likedSongs({required int? count}) {
    return LibraryModel(
      image: null,
      id: UniqueIds.likedSongs,
      type: LibItemType.playlist,
      name: StringRes.likedSongs,
      owner: OwnerModel(name: '$count songs'),
    );
  }

  static MediaItem toMediaItem(TrackDetails track, {Uri? uri}) {
    return MediaItem(
      id: track.id ?? '',
      album: track.albumId ?? '',
      duration: track.duration,
      artist: track.subtitle ?? '',
      artUri: Uri.tryParse(track.image ?? ''),
      title: track.title ?? '',
      extras: {'uri': uri, ...track.toJson()},
    );
  }

  static EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }

//   static String timeFromNow(DateTime? date) {
//     if (date == null) return '';
//     final diff = now.difference(date);
//     if (diff.inDays > 0) {
//       switch (diff.inDays) {
//         case > 364:
//           return '${(diff.inDays / 365).toStringAsFixed(1)} years ago';
//         case > 30:
//           return '${(diff.inDays / 30.416).round()} days ago';
//         case > 6:
//           return '${(diff.inDays / 7).round()} weeks ago';
//         case 1:
//           return '1 day ago';
//         default:
//           return '${diff.inDays} days ago';
//       }
//     } else if (diff.inHours > 0) {
//       return '${diff.inHours} hours ago';
//     } else if (diff.inMinutes > 0) {
//       return '${diff.inMinutes} min ago';
//     }

//     return 'Just now';
//   }
}
