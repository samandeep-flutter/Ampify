import 'dart:async';
import 'package:ampify/data/repositories/music_repo.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:audio_service/audio_service.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:rxdart/rxdart.dart';

sealed class Utils {
  @protected
  static final MusicRepo _repo = getIt();

  static TextStyle defTitleStyle(BuildContext context) {
    return TextStyle(
        fontSize: Dimens.fontXXLarge,
        fontWeight: FontWeight.w600,
        color: context.scheme.textColor);
  }

  static TextStyle titleStyleLarge(BuildContext context) {
    return TextStyle(
        fontSize: Dimens.fontExtraLarge,
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

  static double titleScroll(ScrollController controller, [double? fraction]) {
    final appbarHeight = controller.position.extentInside * (fraction ?? .4);
    if (controller.offset > (appbarHeight - kToolbarHeight)) {
      return 1;
    }
    return 0;
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
    final _details = Completer<SongYtDetails?>();
    if (track.ytDetails != null) {
      _details.complete(track.ytDetails);
    } else {
      _repo.getDetailsFromQuery(track).then((details) {
        _details.complete(details);
      });
    }
    PaletteGenerator? palete;
    try {
      palete = await PaletteGenerator.fromImageProvider(
          NetworkImage(track.album?.image ?? ''),
          size: const Size.square(200));
    } catch (_) {}
    final details = await _details.future;
    final defColor = palete?.dominantColor?.color;

    return TrackDetails(
      id: track.id,
      albumId: track.album?.id,
      title: track.name,
      bgColor: palete?.vibrantColor?.color ?? defColor,
      darkBgColor: palete?.darkVibrantColor?.color ?? defColor,
      image: track.album?.image,
      subtitle: track.artists?.asString,
      duration: details?.duration,
      videoId: details?.videoId,
    );
  }

  static Future<Color?> getImageColor(String? image) async {
    try {
      final palete = await PaletteGenerator.fromImageProvider(
          NetworkImage(image!),
          size: const Size(200, 200));
      return palete.vibrantColor?.color ?? palete.dominantColor?.color;
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

  static MediaItem toMediaItem(TrackDetails track, {required Uri uri}) {
    return MediaItem(
      id: track.id ?? '',
      album: track.albumId ?? '',
      duration: track.duration,
      artist: track.subtitle ?? '',
      artUri: Uri.tryParse(track.image ?? ''),
      title: track.title ?? '',
      extras: {'uri': uri.toString(), ...track.toJson()},
    );
  }

  static EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }
}
