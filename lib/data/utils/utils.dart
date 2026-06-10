import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:audio_service/audio_service.dart';
import 'package:palette_generator/palette_generator.dart';
// import 'package:open_filex/open_filex.dart';
import 'package:rxdart/rxdart.dart';

sealed class Utils {
  static final MusicRepo _repo = getIt();
  static final _random = Random();

  static TextStyle defTitleStyle([Color? color]) {
    return TextStyle(
      fontSize: Dimens.fontXXLarge,
      fontWeight: FontWeight.w600,
      color: color,
    );
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

  static Size get defSize => Size(850, 550);

  static double defClamp(BuildContext context) {
    return clampDouble(context.width * .5, 350, 500);
  }

  static double maxBuffer(num buffer, [double? extra]) {
    return _random.nextInt(buffer.toInt()) * 1 + (extra ?? 0);
  }

  static double largeClamp(BuildContext context) {
    return clampDouble(context.width * .7, 600, 1000);
  }

  static EdgeInsets paddingClamp(BuildContext context) {
    return insetsHoriz((context.width - defClamp(context)) * .5);
  }

  static EdgeInsets insetsHoriz(double padding) {
    return EdgeInsets.symmetric(horizontal: padding);
  }

  static EdgeInsets insetsVert(double padding) {
    return EdgeInsets.symmetric(vertical: padding);
  }

  static EdgeInsets insetsOnly(double padding,
      {double? top, double? bottom, double? left, double? right}) {
    return EdgeInsets.fromLTRB(
        left ?? padding, top ?? padding, right ?? padding, bottom ?? padding);
  }

  static double titleScroll(ScrollController controller, [double? fraction]) {
    final appbarHeight = controller.position.extentInside * (fraction ?? .4);
    if (controller.offset > (appbarHeight - kToolbarHeight)) {
      return 1;
    }
    return 0;
  }

  static OutlinedBorder roundedBorder(double radius) {
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
  }

  static GestureRecognizer tapRecoganiser(VoidCallback onTap) {
    return TapGestureRecognizer()..onTap = onTap;
  }

  static bool errorToast(bool offline, [String? message]) {
    showToast(offline ? StringRes.offlineDesc : message ?? '');
    return !offline;
  }

  static String errorText(bool offline, [String? message]) {
    return offline ? StringRes.offlineDesc : message ?? '';
  }

  static OutlinedBorder continuousBorder(double radius, {Color? border}) {
    return ContinuousRectangleBorder(
        side: border != null ? BorderSide(color: border) : BorderSide.none,
        borderRadius: BorderRadius.circular(Dimens.borderLarge));
  }

  static SliverGridDelegate gridDelegate(int count,
      {double? spacing, double? aspectRatio}) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: count,
      childAspectRatio: aspectRatio ?? 1,
      crossAxisSpacing: spacing ?? Dimens.sizeSmall,
      mainAxisSpacing: spacing ?? Dimens.sizeSmall,
    );
  }

  static SliverGridDelegate fixedCrossAxis(int count,
      {double? spacing, double? aspectRatio}) {
    return SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        childAspectRatio: aspectRatio ?? 1,
        mainAxisSpacing: spacing ?? 0,
        crossAxisSpacing: spacing ?? 0);
  }

  static void postFrame(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) => callback.call());
  }

  // static FutureOr<void> openFile(String path) async {
  //   try {
  //     final result = await OpenFilex.open(path);
  //     dprint(result);
  //   } catch (e) {
  //     logPrint(e, 'open-file');
  //   }
  // }

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
      subtitle: track.artists?.map((e) => e.name).join(', '),
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
        artist: ArtistBasic(name: '$count songs'));
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
