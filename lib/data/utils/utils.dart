import 'package:ampify/data/data_models/common/other_models.dart';
import 'package:ampify/data/data_models/library_model.dart';
import 'package:ampify/data/utils/app_constants.dart';
import 'package:ampify/data/utils/dimens.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import '../../buisness_logic/player_bloc/player_state.dart';
import '../data_models/common/tracks_model.dart';

sealed class Utils {
  static TextStyle defTitleStyle(BuildContext context) {
    return TextStyle(
        fontSize: Dimens.fontExtraDoubleLarge,
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

  static SliverGridDelegate fixedCrossAxis(int count,
      {double? spacing, double? aspectRatio}) {
    return SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        childAspectRatio: aspectRatio ?? 1,
        mainAxisSpacing: spacing ?? 0,
        crossAxisSpacing: spacing ?? 0);
  }

  static Future<TrackDetails> getTrackDetails(Track track) async {
    final palete = await PaletteGenerator.fromImageProvider(
        NetworkImage(track.album?.image ?? ''),
        size: const Size(200, 200));
    final color = palete.lightVibrantColor?.color;
    final darkColor = palete.darkVibrantColor?.color;

    return TrackDetails(
      id: track.id,
      albumId: track.album?.id,
      title: track.name,
      bgColor: color,
      darkBgColor: darkColor,
      image: track.album?.image,
      subtitle: track.artists?.asString,
    );
  }

  static Future<Color?> getImageColor(String? image) async {
    try {
      final palete = await PaletteGenerator.fromImageProvider(
          NetworkImage(image!),
          size: const Size(200, 200));
      return palete.lightVibrantColor?.color;
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
